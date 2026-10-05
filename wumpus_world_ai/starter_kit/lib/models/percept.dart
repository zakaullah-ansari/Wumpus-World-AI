/// A lightweight, serialisable snapshot of what the agent currently senses.
///
/// This is intentionally separate from [Cell] — [Cell] is the *world's*
/// ground truth, while [PerceptSnapshot] is only the *agent's* subjective
/// reading at one point in time. That reading is exactly what we forward
/// to the AI REST API as a text prompt (Syllabus #4).
class PerceptSnapshot {
  final int row;
  final int col;
  final bool breeze;
  final bool stench;
  final bool glitter;

  PerceptSnapshot({
    required this.row,
    required this.col,
    this.breeze = false,
    this.stench = false,
    this.glitter = false,
  });

  /// Produces human-readable text like:
  /// "Cell (2,2): [Breeze]" — the exact style of prompt fragment the
  /// AI tactical advisor expects.
  String describe() {
    final tags = <String>[];
    if (breeze) tags.add('Breeze');
    if (stench) tags.add('Stench');
    if (glitter) tags.add('Glitter');
    if (tags.isEmpty) tags.add('Clean');
    return 'Cell (${row + 1},${col + 1}): [${tags.join(', ')}]';
  }
}
