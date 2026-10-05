import 'package:flutter/material.dart';
import '../models/agent.dart';
import '../models/cell.dart';
import '../models/percept.dart';
import '../services/ai_advisor_service.dart';
import '../services/firestore_service.dart';
import '../widgets/cave_grid.dart';
import '../widgets/move_history_list.dart';
import '../world/wumpus_world_generator.dart';
import 'leaderboard_screen.dart';

/// The main gameplay screen: owns the grid, the agent, fog-of-war reveals,
/// and wires together local reasoning (RiskEvaluationMixin), the async AI
/// REST advisor, and the Firestore leaderboard write-back.
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

  /// EPHEMERAL STATE (Syllabus #3): every grid movement only matters for
  /// *this* screen's lifetime, so a plain `setState` is the right tool —
  /// no global state manager needed for something this local.
  ///
  /// TODO (BLOCK 1 — LIVE CODE WITH TRAINER):
  /// 1. Compute `newRow`/`newCol` from `dRow`/`dCol` and bail out (return)
  ///    if they fall outside the 0..3 grid bounds.
  /// 2. Call `setState(() { ... })` and inside it:
  ///      - update `_agent.row` / `_agent.col`
  ///      - call `_agent.applyMoveCost()`
  ///      - call `_revealFog()`
  ///      - call `_agent.recordMove(...)` with a readable description
  ///      - check `_currentCell` for `hasPit`/`hasWumpus` -> apply death
  ///        penalty + `_endGame(...)`
  ///      - else check `hasGold && !_agent.hasGold` -> pick it up + bonus
  void _move(int dRow, int dCol) {
    if (_gameOver) return;
    throw UnimplementedError('TODO: implement _move');
  }

  /// Fog-of-war reveal: entering a cell fully reveals it; its neighbours
  /// become "discovered" (percept known) without being fully explored.
  ///
  /// TODO (BLOCK 1 — LIVE CODE WITH TRAINER):
  /// 1. Set `_currentCell.isVisited = true`.
  /// 2. Loop over `_neighboursOf(_agent.row, _agent.col)` and set each
  ///    neighbour's `isDiscovered = true`.
  void _revealFog() {
    throw UnimplementedError('TODO: implement _revealFog');
  }

  List<Cell> _neighboursOf(int r, int c) {
    const deltas = [
      [-1, 0],
      [1, 0],
      [0, -1],
      [0, 1],
    ];
    final result = <Cell>[];
    for (final d in deltas) {
      final nr = r + d[0];
      final nc = c + d[1];
      if (nr >= 0 && nr < 4 && nc >= 0 && nc < 4) {
        result.add(_grid[nr][nc]);
      }
    }
    return result;
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

  Future<void> _endGame(String message) async {
    _gameOver = true;
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
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Run complete'),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wumpus World AI — Score: ${_agent.score}')),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Center(
              child: CaveGrid(
                grid: _grid,
                agentRow: _agent.row,
                agentCol: _agent.col,
                onCellTap: (_) {}, // hook: students can add tap-to-inspect
              ),
            ),
          ),
          _buildDPad(),
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
}
