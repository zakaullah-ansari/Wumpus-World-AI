import '../mixins/risk_evaluation_mixin.dart';

/// The player-controlled explorer. Notice `Agent` stays focused purely on
/// *identity and movement* — all scoring/risk math is delegated to the
/// mixed-in [RiskEvaluationMixin] (separation of concerns via Mixins,
/// Syllabus #1).
class Agent with RiskEvaluationMixin {
  int row;
  int col;
  int arrows;
  bool hasGold;
  bool isAlive;
  final List<String> moveHistory = [];

  Agent({
    this.row = 0,
    this.col = 0,
    this.arrows = 1,
    this.hasGold = false,
    this.isAlive = true,
  });

  void recordMove(String action) => moveHistory.add(action);
}
