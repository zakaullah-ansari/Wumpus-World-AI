import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/agent.dart';
import '../models/cell.dart';
import '../models/game_config.dart';
import '../models/percept.dart';
import '../providers/player_profile_provider.dart';
import '../providers/service_providers.dart';
import '../world/wumpus_world_generator.dart';
import 'game_state.dart';

/// All gameplay logic lives here now, instead of inside `GameScreen`'s
/// `State` object. This is the CODE enhancement: `GameScreen` becomes a
/// thin, mostly-declarative `ConsumerWidget` that just renders whatever
/// `GameState` this controller currently holds, and forwards user taps
/// into one of the methods below. That split is what makes the game logic
/// unit-testable without ever constructing a widget tree.
class GameController extends Notifier<GameState> {
  @override
  GameState build() => _freshState(GameConfig.normal);

  GameState _freshState(GameConfig config) {
    final grid = WumpusWorldGenerator(gridSize: config.gridSize)
        .generate(pitProbability: config.pitProbability);
    return GameState(
      config: config,
      grid: grid,
      agent: Agent(arrows: config.startingArrows),
      status: GameStatus.playing,
      advisorHint: 'Tap "Ask AI Advisor" before a risky move.',
      isAskingAdvisor: false,
    );
  }

  /// Starts a brand-new run with the chosen [GameConfig] (called from the
  /// Difficulty screen).
  void startNewGame(GameConfig config) {
    state = _freshState(config);
  }

  Cell get _currentCell => state.grid[state.agent.row][state.agent.col];

  /// EPHEMERAL STATE, Riverpod-flavoured: reassigning `state` is the
  /// equivalent of the old `setState(() {...})` call — it's still fully
  /// local to this one cave run, just managed outside the widget now.
  void move(int dRow, int dCol) {
    if (state.isGameOver) return;
    final agent = state.agent;
    final size = state.config.gridSize;
    final newRow = agent.row + dRow;
    final newCol = agent.col + dCol;
    if (newRow < 0 || newRow >= size || newCol < 0 || newCol >= size) return;

    agent
      ..row = newRow
      ..col = newCol
      ..applyMoveCost();
    _revealFog();
    final moveMessage = 'Moved to (${newRow + 1},${newCol + 1})';
    agent.recordMove(moveMessage);
    state = state.copyWith(agent: agent, lastEventMessage: moveMessage);

    final cell = _currentCell;
    if (cell.hasPit || cell.hasWumpus) {
      agent.applyDeathPenalty();
      final message = cell.hasPit
          ? '💀 You fell into a bottomless pit! Final score: ${agent.score}'
          : '💀 The Wumpus got you! Final score: ${agent.score}';
      _finishGame(GameStatus.lost, agent, message);
    } else if (cell.hasGold && !agent.hasGold) {
      agent.hasGold = true;
      agent.applyGoldBonus();
      const goldMessage = '✨ Picked up the Gold! Head back to start and Climb Out.';
      agent.recordMove(goldMessage);
      state = state.copyWith(agent: agent, lastEventMessage: goldMessage);
    }
  }

  /// Classic Wumpus World arrow-shooting: fires in a straight line until it
  /// either hits the Wumpus (killing it and silencing every Stench on the
  /// board) or exits the grid.
  void shootArrow(int dRow, int dCol) {
    final agent = state.agent;
    if (state.isGameOver || agent.arrows <= 0) return;
    final size = state.config.gridSize;

    agent.arrows--;
    agent.applyArrowCost();

    bool hit = false;
    int r = agent.row + dRow;
    int c = agent.col + dCol;
    while (r >= 0 && r < size && c >= 0 && c < size) {
      if (state.grid[r][c].hasWumpus) {
        state.grid[r][c].hasWumpus = false;
        WumpusWorldGenerator.recomputePercepts(state.grid, size);
        hit = true;
        break;
      }
      r += dRow;
      c += dCol;
    }

    final message =
        hit ? '🏹 A scream echoes through the cave — the Wumpus is slain!' : '🏹 The arrow vanishes into the dark. Miss.';
    agent.recordMove(message);
    state = state.copyWith(agent: agent, lastEventMessage: message);
  }

  /// The real Wumpus World win condition: return to the start cell
  /// carrying the gold, then explicitly climb out.
  void climbOut() {
    if (!state.canClimbOut) return;
    final agent = state.agent;
    agent.applyClimbOutBonus();
    const message = '🪜 Climbed out of the cave with the gold!';
    agent.recordMove(message);
    _finishGame(GameStatus.won, agent, '🏆 You escaped with the gold! Final score: ${agent.score}');
  }

  void _revealFog() {
    _currentCell.isVisited = true;
    final size = state.config.gridSize;
    for (final neighbour in WumpusWorldGenerator.neighboursOf(state.grid, state.agent.row, state.agent.col, size)) {
      neighbour.isDiscovered = true;
    }
  }

  /// Calls the AI REST API asynchronously and safely surfaces any network
  /// failure to the UI — never lets an exception escape into the widget
  /// tree.
  Future<void> askAiAdvisor() async {
    state = state.copyWith(isAskingAdvisor: true);
    final cell = _currentCell;
    final percept = PerceptSnapshot(
      row: state.agent.row,
      col: state.agent.col,
      breeze: cell.hasBreeze,
      stench: cell.hasStench,
      glitter: cell.hasGold,
    );
    try {
      final hint = await ref.read(aiAdvisorServiceProvider).getRiskAdvice(percept.describe());
      state = state.copyWith(advisorHint: hint, isAskingAdvisor: false);
    } catch (e) {
      state = state.copyWith(advisorHint: 'Advisor failed: $e', isAskingAdvisor: false);
    }
  }

  Future<void> _finishGame(GameStatus status, Agent agent, String message) async {
    state = state.copyWith(agent: agent, status: status, lastEventMessage: message);

    final playerName = ref.read(playerNameProvider);
    try {
      await ref.read(firestoreServiceProvider).submitRun(
            playerName: playerName,
            score: agent.score,
            movesUsed: agent.moveHistory.length,
          );
    } catch (_) {
      // Non-fatal: a failed leaderboard sync should never block the result dialog.
    }

    final uid = ref.read(authServiceProvider).currentUser?.uid;
    if (uid != null) {
      try {
        await ref.read(playerProfileServiceProvider).recordRun(
              uid,
              displayName: playerName,
              score: agent.score,
              movesUsed: agent.moveHistory.length,
              won: status == GameStatus.won,
            );
      } catch (_) {
        // Non-fatal for the same reason.
      }
    }
  }
}

final gameControllerProvider = NotifierProvider<GameController, GameState>(GameController.new);
