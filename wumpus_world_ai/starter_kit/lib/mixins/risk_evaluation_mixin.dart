import '../models/cell.dart';

/// A MIXIN is a "superpower" you bolt onto a class without using classic
/// single-parent inheritance. `Agent` already needs to "be" an agent
/// (its own identity/position/history) — it doesn't want to *also* be a
/// `ScoreCalculator` or `RiskEvaluator` through `extends`, because Dart only
/// allows one superclass. `with RiskEvaluationMixin` lets `Agent` borrow
/// this scoring/risk behaviour instead (Syllabus #1 — Mixins).
///
/// PRODUCTION MENTAL MODEL: mixins are how Flutter itself gives you
/// `SingleTickerProviderStateMixin` for animations — reusable, composable
/// behaviour bundles rather than rigid class hierarchies.
mixin RiskEvaluationMixin {
  int score = 0; // mixins CAN hold their own state in Dart.

  static const int moveCost = -1;
  static const int goldReward = 1000;
  static const int deathPenalty = -1000;
  static const int climbOutBonus = 10;

  // TODO (BLOCK 2 — LIVE CODE WITH TRAINER): score += moveCost
  void applyMoveCost() {}

  // TODO (BLOCK 2 — LIVE CODE WITH TRAINER): score += goldReward
  void applyGoldBonus() {}

  // TODO (BLOCK 2 — LIVE CODE WITH TRAINER): score += deathPenalty
  void applyDeathPenalty() {}

  // TODO (BLOCK 2 — LIVE CODE WITH TRAINER): score += climbOutBonus
  void applyClimbOutBonus() {}

  /// A cheap LOCAL heuristic the agent can use instantly, before ever
  /// calling the (slower, async) AI REST API. It should look at how many
  /// of the already-visited neighbours around [cell] reported a danger
  /// percept (hasBreeze or hasStench), and express that as a 0-100% value.
  ///
  /// TODO (BLOCK 2 — LIVE CODE WITH TRAINER):
  /// 1. If `visitedNeighbours` is empty, return 50.0 (unknown -> moderate risk).
  /// 2. Otherwise count how many neighbours have hasBreeze OR hasStench.
  /// 3. Return (dangerSignals / visitedNeighbours.length) * 100.
  double estimateLocalRisk(Cell cell, List<Cell> visitedNeighbours) {
    throw UnimplementedError('TODO: implement estimateLocalRisk');
  }
}
