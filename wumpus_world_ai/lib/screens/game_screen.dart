import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cell.dart';
import '../state/game_controller.dart';
import '../state/game_state.dart';
import '../widgets/animated_score.dart';
import '../widgets/cave_grid.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/move_history_list.dart';
import '../widgets/theme_toggle_button.dart';
import 'leaderboard_screen.dart';

/// The main gameplay screen. CODE enhancement: all gameplay logic now
/// lives in [GameController] (a Riverpod `Notifier`) instead of this
/// widget's own `State` — this screen just watches [gameControllerProvider]
/// and renders whatever it currently holds, forwarding taps back into the
/// controller's methods.
///
/// A `ConsumerStatefulWidget` (not a plain `ConsumerWidget`) because it
/// still needs one piece of purely local, ephemeral UI state: whether the
/// confetti overlay is currently playing.
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _confettiActive = false;
  String? _lastShownMessage;

  void _showCellDetails(BuildContext context, Cell cell) {
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

  Future<void> _showResultDialog(GameState state) async {
    final didWin = state.status == GameStatus.won;
    await showGeneralDialog(
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
              content: Text(state.lastEventMessage ?? ''),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
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
    // UI/UX enhancement: react to each new in-game event exactly once (not
    // on every rebuild) by listening for changes in `lastEventMessage` —
    // this is the piece `GameState.lastEventMessage` was specifically added
    // for, since the mutable `moveHistory` list can't be diffed by identity.
    ref.listen<GameState>(gameControllerProvider, (previous, next) {
      final message = next.lastEventMessage;
      if (message != null && message != _lastShownMessage) {
        _lastShownMessage = message;
        if (!next.isGameOver) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
        }
      }
      if (next.status == GameStatus.won && previous?.status != GameStatus.won) {
        setState(() => _confettiActive = true);
      }
      if (next.isGameOver && previous?.status == GameStatus.playing) {
        _showResultDialog(next);
      }
    });

    final state = ref.watch(gameControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: AnimatedScore(
          score: state.agent.score,
          style: Theme.of(context).appBarTheme.titleTextStyle ??
              const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: const [ThemeToggleButton()],
      ),
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              // Responsive/accessible layout (UI/UX enhancement): on a wide
              // screen (tablet/desktop), put the grid and controls side by
              // side instead of stacked, so the D-pad doesn't get squeezed
              // off-screen below a large 8x8 board.
              final isWide = constraints.maxWidth > 760;
              final grid = Center(
                child: CaveGrid(
                  grid: state.grid,
                  gridSize: state.config.gridSize,
                  agentRow: state.agent.row,
                  agentCol: state.agent.col,
                  onCellTap: (cell) => _showCellDetails(context, cell),
                ),
              );
              final sidePanel = Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildControls(state),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(state.isAskingAdvisor ? 'Thinking…' : state.advisorHint),
                        ),
                        ElevatedButton(
                          onPressed: state.isAskingAdvisor
                              ? null
                              : () => ref.read(gameControllerProvider.notifier).askAiAdvisor(),
                          child: const Text('Ask AI Advisor'),
                        ),
                      ],
                    ),
                  ),
                ],
              );

              if (isWide) {
                return Row(
                  children: [
                    Expanded(flex: 3, child: grid),
                    SizedBox(
                      width: 320,
                      child: Column(
                        children: [
                          Expanded(child: sidePanel),
                          Expanded(child: MoveHistoryList(moves: state.agent.moveHistory)),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  Expanded(flex: 3, child: grid),
                  sidePanel,
                  Expanded(flex: 2, child: MoveHistoryList(moves: state.agent.moveHistory)),
                ],
              );
            },
          ),
          Positioned.fill(
            child: ConfettiOverlay(active: _confettiActive),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(GameState state) {
    final controller = ref.read(gameControllerProvider.notifier);
    return Column(
      children: [
        _buildDPad(controller, state),
        const SizedBox(height: 4),
        _buildShootRow(controller, state),
        const SizedBox(height: 4),
        ElevatedButton.icon(
          onPressed: state.canClimbOut ? controller.climbOut : null,
          icon: const Icon(Icons.exit_to_app),
          label: const Text('Climb Out'),
          style: ElevatedButton.styleFrom(
            backgroundColor: state.canClimbOut ? Colors.amber : null,
            minimumSize: const Size(48, 48),
          ),
        ),
      ],
    );
  }

  Widget _buildDPad(GameController controller, GameState state) {
    return Column(
      children: [
        _dPadButton(
          icon: Icons.keyboard_arrow_up,
          label: 'Move up',
          onPressed: state.isGameOver ? null : () => controller.move(-1, 0),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _dPadButton(
              icon: Icons.keyboard_arrow_left,
              label: 'Move left',
              onPressed: state.isGameOver ? null : () => controller.move(0, -1),
            ),
            const SizedBox(width: 40),
            _dPadButton(
              icon: Icons.keyboard_arrow_right,
              label: 'Move right',
              onPressed: state.isGameOver ? null : () => controller.move(0, 1),
            ),
          ],
        ),
        _dPadButton(
          icon: Icons.keyboard_arrow_down,
          label: 'Move down',
          onPressed: state.isGameOver ? null : () => controller.move(1, 0),
        ),
      ],
    );
  }

  /// Accessibility enhancement: every directional button carries an
  /// explicit `Semantics` label (an icon alone isn't enough for a screen
  /// reader) and keeps at least a 44x44 logical-pixel tap target.
  Widget _dPadButton({required IconData icon, required String label, required VoidCallback? onPressed}) {
    return Semantics(
      label: label,
      button: true,
      child: IconButton(
        tooltip: label,
        icon: Icon(icon),
        iconSize: 28,
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildShootRow(GameController controller, GameState state) {
    final canShoot = !state.isGameOver && state.agent.arrows > 0;
    return Column(
      children: [
        Text('🏹 Arrows left: ${state.agent.arrows}', style: const TextStyle(fontSize: 12)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _dPadButton(
              icon: Icons.arrow_upward,
              label: 'Shoot up',
              onPressed: canShoot ? () => controller.shootArrow(-1, 0) : null,
            ),
            _dPadButton(
              icon: Icons.arrow_back,
              label: 'Shoot left',
              onPressed: canShoot ? () => controller.shootArrow(0, -1) : null,
            ),
            _dPadButton(
              icon: Icons.arrow_forward,
              label: 'Shoot right',
              onPressed: canShoot ? () => controller.shootArrow(0, 1) : null,
            ),
            _dPadButton(
              icon: Icons.arrow_downward,
              label: 'Shoot down',
              onPressed: canShoot ? () => controller.shootArrow(1, 0) : null,
            ),
          ],
        ),
      ],
    );
  }
}
