import '../models/agent.dart';
import '../models/cell.dart';
import '../models/game_config.dart';

enum GameStatus { playing, won, lost }

/// Immutable snapshot of "everything the UI needs to render a frame" of
/// the game. NOTE on pragmatism: [grid] and [agent] are mutated in place
/// by [GameController] for simplicity (a fully immutable 8x8 grid copy on
/// every move would be wasteful for a teaching app) — but a *new*
/// [GameState] wrapper is always created via [copyWith] on every change,
/// so Riverpod's identity-based change detection still reliably notifies
/// listeners every time.
class GameState {
  final GameConfig config;
  final List<List<Cell>> grid;
  final Agent agent;
  final GameStatus status;
  final String advisorHint;
  final bool isAskingAdvisor;
  final String? lastEventMessage;

  const GameState({
    required this.config,
    required this.grid,
    required this.agent,
    required this.status,
    required this.advisorHint,
    required this.isAskingAdvisor,
    this.lastEventMessage,
  });

  bool get isGameOver => status != GameStatus.playing;

  bool get canClimbOut =>
      !isGameOver && agent.row == 0 && agent.col == 0 && agent.hasGold;

  GameState copyWith({
    GameConfig? config,
    List<List<Cell>>? grid,
    Agent? agent,
    GameStatus? status,
    String? advisorHint,
    bool? isAskingAdvisor,
    String? lastEventMessage,
  }) {
    return GameState(
      config: config ?? this.config,
      grid: grid ?? this.grid,
      agent: agent ?? this.agent,
      status: status ?? this.status,
      advisorHint: advisorHint ?? this.advisorHint,
      isAskingAdvisor: isAskingAdvisor ?? this.isAskingAdvisor,
      lastEventMessage: lastEventMessage ?? this.lastEventMessage,
    );
  }
}
