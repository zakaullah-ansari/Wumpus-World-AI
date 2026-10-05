import 'package:flutter/material.dart';
import '../models/agent.dart';
import '../models/cell.dart';
import '../models/percept.dart';
import '../services/ai_advisor_service.dart';
import '../services/firestore_service.dart';
import '../widgets/cave_grid.dart';
import '../widgets/move_history_list.dart';
import '../widgets/theme_toggle_button.dart';
import '../world/wumpus_world_generator.dart';
import 'leaderboard_screen.dart';

/// The main gameplay screen: owns the grid, the agent, fog-of-war reveals,
/// and wires together local reasoning (RiskEvaluationMixin), the async AI
/// REST advisor, and the Firestore leaderboard write-back.
///
/// EXTENDED (post-core-workshop) features on top of the base curriculum:
///   - Arrow-shooting to slay the Wumpus (classic Wumpus World action)
///   - A "Climb Out" win condition once the agent returns to (0,0) with gold
///   - An animated win/lose result dialog
///   - A tap-to-inspect cell detail panel that respects fog-of-war
class GameScreen extends StatefulWidget {
  final AiAdvisorService aiAdvisorService;
  final FirestoreService firestoreService;

  const GameScreen({
    super.key,
    required this.aiAdvisorService,
    required this.firestoreService,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<List<Cell>> _grid;
  final Agent _agent = Agent();
  String _advisorHint = 'Tap "Ask AI Advisor" before a risky move.';
  bool _isAskingAdvisor = false;
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    _grid = WumpusWorldGenerator().generate();
  }

  Cell get _currentCell => _grid[_agent.row][_agent.col];
  bool get _canClimbOut => _agent.row == 0 && _agent.col == 0 && _agent.hasGold;

  /// EPHEMERAL STATE (Syllabus #3): every grid movement only matters for
  /// *this* screen's lifetime, so a plain `setState` is the right tool —
  /// no global state manager needed for something this local.
  void _move(int dRow, int dCol) {
    if (_gameOver) return;
    final newRow = _agent.row + dRow;
    final newCol = _agent.col + dCol;
    if (newRow < 0 || newRow > 3 || newCol < 0 || newCol > 3) return;

    setState(() {
      _agent
        ..row = newRow
        ..col = newCol
        ..applyMoveCost();
      _revealFog();
      _agent.recordMove('Moved to (${newRow + 1},${newCol + 1})');

      if (_currentCell.hasPit || _currentCell.hasWumpus) {
        _agent.applyDeathPenalty();
        _endGame(
          _currentCell.hasPit
              ? '💀 You fell into a bottomless pit! Final score: ${_agent.score}'
              : '💀 The Wumpus got you! Final score: ${_agent.score}',
          didWin: false,
        );
      } else if (_currentCell.hasGold && !_agent.hasGold) {
        _agent.hasGold = true;
        _agent.applyGoldBonus();
        _agent.recordMove('✨ Picked up the Gold! Head back to (1,1) and Climb Out.');
      }
    });
  }

  /// EXTENDED: classic Wumpus World arrow-shooting. Fires in a straight
  /// line from the agent's current cell until it either hits the Wumpus
  /// (killing it and silencing every Stench on the board) or exits the grid.
  void _shootArrow(int dRow, int dCol) {
    if (_gameOver || _agent.arrows <= 0) return;

    setState(() {
      _agent.arrows--;
      _agent.applyArrowCost();

      bool hit = false;
      int r = _agent.row + dRow;
      int c = _agent.col + dCol;
      while (r >= 0 && r < 4 && c >= 0 && c < 4) {
        if (_grid[r][c].hasWumpus) {
          _grid[r][c].hasWumpus = false;
          WumpusWorldGenerator.recomputePercepts(_grid);
          hit = true;
          break;
        }
        r += dRow;
        c += dCol;
      }

      _agent.recordMove(
        hit ? '🏹 A scream echoes through the cave — the Wumpus is slain!' : '🏹 The arrow vanishes into the dark. Miss.',
      );
    });
  }

  /// EXTENDED: the actual Wumpus World win condition — return to the start
  /// cell carrying the gold, then explicitly climb out.
  void _climbOut() {
    if (_gameOver || !_canClimbOut) return;
    setState(() {
      _agent.applyClimbOutBonus();
      _agent.recordMove('🪜 Climbed out of the cave with the gold!');
    });
    _endGame('🏆 You escaped the cave with the gold! Final score: ${_agent.score}', didWin: true);
  }

  /// Fog-of-war reveal: entering a cell fully reveals it; its neighbours
  /// become "discovered" (percept known) without being fully explored.
  void _revealFog() {
    _currentCell.isVisited = true;
    for (final neighbour in _neighboursOf(_agent.row, _agent.col)) {
      neighbour.isDiscovered = true;
    }
  }

  List<Cell> _neighboursOf(int r, int c) => WumpusWorldGenerator.neighboursOf(_grid, r, c);

  /// EXTENDED: tap-to-inspect panel. Respects fog-of-war — a hidden cell
  /// reveals nothing, a merely "discovered" cell only reveals that *some*
  /// neighbour sensed danger (not which one), and a fully "visited" cell
  /// shows everything the agent actually witnessed first-hand.
  void _showCellDetails(Cell cell) {
    if (cell.isHidden) return;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cell (${cell.row + 1}, ${cell.col + 1})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (cell.isVisited) ...[
              Text(cell.isSafe ? '✅ Confirmed safe — you stood here.' : '⚠️ This is where the run ended.'),
              if (cell.hasGold) const Text('✨ Gold was found here.'),
            ] else ...[
              const Text('🌫️ Not yet explored — only sensed from a neighbouring cell.'),
            ],
            const SizedBox(height: 8),
            Text(cell.hasBreeze ? '💨 Breeze detected adjacent to this cell.' : 'No breeze sensed nearby.'),
            Text(cell.hasStench ? '🤢 Stench detected adjacent to this cell.' : 'No stench sensed nearby.'),
          ],
        ),
      ),
    );
  }

  /// Calls the AI REST API asynchronously (Future + async/await,
  /// Syllabus #1) and safely surfaces any network failure to the UI.
  Future<void> _askAiAdvisor() async {
    setState(() => _isAskingAdvisor = true);
    final percept = PerceptSnapshot(
      row: _agent.row,
      col: _agent.col,
      breeze: _currentCell.hasBreeze,
      stench: _currentCell.hasStench,
      glitter: _currentCell.hasGold,
    );
    try {
      final hint = await widget.aiAdvisorService.getRiskAdvice(percept.describe());
      setState(() => _advisorHint = hint);
    } catch (e) {
      setState(() => _advisorHint = 'Advisor failed: $e');
    } finally {
      setState(() => _isAskingAdvisor = false);
    }
  }

  Future<void> _endGame(String message, {required bool didWin}) async {
    setState(() => _gameOver = true);
    try {
      await widget.firestoreService.submitRun(
        playerName: 'Explorer', // swap for FirebaseAuth displayName in Block 3
        score: _agent.score,
        movesUsed: _agent.moveHistory.length,
      );
    } catch (_) {
      // Non-fatal: a failed leaderboard sync should never block the dialog.
    }
    if (!mounted) return;

    // EXTENDED: an animated win/lose overlay (scale + fade in) instead of a
    // flat AlertDialog pop, using showGeneralDialog's transitionBuilder.
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Result',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.elasticOut);
        return Opacity(
          opacity: animation.value.clamp(0.0, 1.0).toDouble(),
          child: Transform.scale(
            scale: curved.value.clamp(0.0, 1.3).toDouble(),
            child: AlertDialog(
              icon: Icon(
                didWin ? Icons.emoji_events : Icons.dangerous,
                color: didWin ? Colors.amber : Colors.redAccent,
                size: 48,
              ),
              title: Text(didWin ? 'Victory!' : 'Game Over'),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => LeaderboardScreen(firestoreService: widget.firestoreService),
                    ),
                  ),
                  child: const Text('View Leaderboard'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wumpus World AI — Score: ${_agent.score}'),
        actions: const [ThemeToggleButton()],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Center(
              child: CaveGrid(
                grid: _grid,
                agentRow: _agent.row,
                agentCol: _agent.col,
                onCellTap: _showCellDetails,
              ),
            ),
          ),
          _buildControls(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(_isAskingAdvisor ? 'Thinking…' : _advisorHint),
                ),
                ElevatedButton(
                  onPressed: _isAskingAdvisor ? null : _askAiAdvisor,
                  child: const Text('Ask AI Advisor'),
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: MoveHistoryList(moves: _agent.moveHistory)),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Column(
      children: [
        _buildDPad(),
        const SizedBox(height: 4),
        _buildShootRow(),
        const SizedBox(height: 4),
        ElevatedButton.icon(
          onPressed: _canClimbOut ? _climbOut : null,
          icon: const Icon(Icons.exit_to_app),
          label: const Text('Climb Out'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _canClimbOut ? Colors.amber : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDPad() {
    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_up),
          onPressed: () => _move(-1, 0),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_left),
              onPressed: () => _move(0, -1),
            ),
            const SizedBox(width: 40),
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_right),
              onPressed: () => _move(0, 1),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => _move(1, 0),
        ),
      ],
    );
  }

  /// EXTENDED: arrow-shooting controls, reusing the same D-pad layout but
  /// styled distinctly (outline icons) and labelled with remaining arrows.
  Widget _buildShootRow() {
    final canShoot = !_gameOver && _agent.arrows > 0;
    return Column(
      children: [
        Text('🏹 Arrows left: ${_agent.arrows}', style: const TextStyle(fontSize: 12)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: 'Shoot up',
              icon: const Icon(Icons.arrow_upward),
              onPressed: canShoot ? () => _shootArrow(-1, 0) : null,
            ),
            IconButton(
              tooltip: 'Shoot left',
              icon: const Icon(Icons.arrow_back),
              onPressed: canShoot ? () => _shootArrow(0, -1) : null,
            ),
            IconButton(
              tooltip: 'Shoot right',
              icon: const Icon(Icons.arrow_forward),
              onPressed: canShoot ? () => _shootArrow(0, 1) : null,
            ),
            IconButton(
              tooltip: 'Shoot down',
              icon: const Icon(Icons.arrow_downward),
              onPressed: canShoot ? () => _shootArrow(1, 0) : null,
            ),
          ],
        ),
      ],
    );
  }
}
