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

  void applyMoveCost() => score += moveCost;
  void applyGoldBonus() => score += goldReward;
  void applyDeathPenalty() => score += deathPenalty;
  void applyClimbOutBonus() => score += climbOutBonus;

  /// A cheap LOCAL heuristic the agent can use instantly, before ever
  /// calling the (slower, async) AI REST API. It simply looks at how many
  /// of the already-visited neighbours around [cell] reported a danger
  /// percept, and expresses that as a 0-100% risk score.
  ///
  /// This is what "Knowledge-Based Agent reasoning" looks like in miniature:
  /// combine locally known facts into a probability estimate.
  double estimateLocalRisk(Cell cell, List<Cell> visitedNeighbours) {
    if (visitedNeighbours.isEmpty) {
      return 50.0; // no evidence yet -> assume moderate/unknown risk
    }
    final dangerSignals =
        visitedNeighbours.where((c) => c.hasBreeze || c.hasStench).length;
    return (dangerSignals / visitedNeighbours.length) * 100;
  }
}
