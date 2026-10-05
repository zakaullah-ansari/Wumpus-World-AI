/// Represents a single square in the 4x4 Wumpus World cave grid.
///
/// BEGINNER MENTAL MODEL
/// ----------------------
/// Think of a [Cell] as a "truth card" that the game keeps face-down.
/// Each boolean is an independent fact about that square. Nothing here is
/// "the UI" — this is pure data (Object-Oriented Programming, Syllabus #1).
/// The grid widget later decides what to actually draw, based on what the
/// *player* has earned the right to see (fog-of-war).
///
/// We deliberately split the booleans into three honest groups so beginners
/// never confuse "what's true about the world" with "what the player knows":
///   1. Ground truth   -> hasPit, hasWumpus, hasGold
///   2. Derived signals -> hasBreeze, hasStench (computed from NEIGHBOURS)
///   3. Player knowledge -> isVisited, isDiscovered (fog-of-war state)
class Cell {
  final int row;
  final int col;

  // ---- 1) Ground truth: what is ACTUALLY in this square ----
  bool hasPit;
  bool hasWumpus;
  bool hasGold;

  // ---- 2) Derived percepts: sensed FROM an adjacent cell ----
  bool hasBreeze; // true if a neighbouring cell hasPit
  bool hasStench; // true if a neighbouring cell hasWumpus

  // ---- 3) Player knowledge (fog-of-war): what has been revealed ----
  bool isVisited; // agent physically stood here -> fully revealed
  bool isDiscovered; // agent sensed a percept about it, but hasn't entered

  Cell({
    required this.row,
    required this.col,
    this.hasPit = false,
    this.hasWumpus = false,
    this.hasGold = false,
    this.hasBreeze = false,
    this.hasStench = false,
    this.isVisited = false,
    this.isDiscovered = false,
  });

  bool get isDeadly => hasPit || hasWumpus;
  bool get isSafe => !isDeadly;
  bool get isHidden => !isVisited && !isDiscovered;

  @override
  String toString() => 'Cell(${row + 1},${col + 1})';
}
