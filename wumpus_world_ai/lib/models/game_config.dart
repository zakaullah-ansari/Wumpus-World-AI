/// How hard a cave run is. Each tier scales the grid size, pit density, and
/// starting arrow count — this is what the new Difficulty screen lets the
/// player pick before a run starts (FEATURE enhancement).
enum Difficulty { easy, normal, hard }

class GameConfig {
  final Difficulty difficulty;
  final int gridSize;
  final double pitProbability;
  final int startingArrows;

  const GameConfig({
    required this.difficulty,
    required this.gridSize,
    required this.pitProbability,
    required this.startingArrows,
  });

  static const easy = GameConfig(
    difficulty: Difficulty.easy,
    gridSize: 4,
    pitProbability: 0.15,
    startingArrows: 2,
  );

  static const normal = GameConfig(
    difficulty: Difficulty.normal,
    gridSize: 6,
    pitProbability: 0.20,
    startingArrows: 2,
  );

  static const hard = GameConfig(
    difficulty: Difficulty.hard,
    gridSize: 8,
    pitProbability: 0.25,
    startingArrows: 1,
  );

  static const all = [easy, normal, hard];

  String get label => switch (difficulty) {
        Difficulty.easy => 'Easy',
        Difficulty.normal => 'Normal',
        Difficulty.hard => 'Hard',
      };

  String get description =>
      '${gridSize}x$gridSize cave • ${(pitProbability * 100).round()}% pit density • $startingArrows ${startingArrows == 1 ? 'arrow' : 'arrows'}';
}
