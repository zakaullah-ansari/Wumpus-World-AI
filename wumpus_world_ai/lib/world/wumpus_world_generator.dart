import 'dart:math';
import '../models/cell.dart';

/// Builds a fresh, solvable 4x4 Wumpus World: scatters pits, places exactly
/// one Wumpus and one Gold cell, then derives Breeze/Stench percepts for
/// every neighbouring cell. Cell (0,0) — the agent's start — is always safe.
class WumpusWorldGenerator {
  static const int size = 4;
  final Random _random;

  WumpusWorldGenerator({int? seed}) : _random = Random(seed);

  List<List<Cell>> generate({double pitProbability = 0.2}) {
    final grid = List.generate(
      size,
      (r) => List.generate(size, (c) => Cell(row: r, col: c)),
    );

    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (r == 0 && c == 0) continue; // start cell must be safe
        if (_random.nextDouble() < pitProbability) {
          grid[r][c].hasPit = true;
        }
      }
    }

    _placeOnSafeRandomCell(grid, (cell) => cell.hasWumpus = true);
    _placeOnSafeRandomCell(grid, (cell) => cell.hasGold = true);

    recomputePercepts(grid);
    grid[0][0].isVisited = true;
    return grid;
  }

  void _placeOnSafeRandomCell(List<List<Cell>> grid, void Function(Cell) place) {
    Cell target;
    do {
      target = grid[_random.nextInt(size)][_random.nextInt(size)];
    } while ((target.row == 0 && target.col == 0) || target.isDeadly);
    place(target);
  }

  /// Recomputes Breeze/Stench for every cell from scratch. Exposed as a
  /// `static` utility (not just a private instance method) so gameplay
  /// code can call it again after the world changes mid-game — e.g. after
  /// the Wumpus is slain by an arrow, its stench should vanish everywhere.
  static void recomputePercepts(List<List<Cell>> grid) {
    for (final row in grid) {
      for (final cell in row) {
        cell.hasBreeze = false;
        cell.hasStench = false;
      }
    }
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        for (final neighbour in neighboursOf(grid, r, c)) {
          if (neighbour.hasPit) grid[r][c].hasBreeze = true;
          if (neighbour.hasWumpus) grid[r][c].hasStench = true;
        }
      }
    }
  }

  static List<Cell> neighboursOf(List<List<Cell>> grid, int r, int c) {
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
      if (nr >= 0 && nr < size && nc >= 0 && nc < size) {
        result.add(grid[nr][nc]);
      }
    }
    return result;
  }
}
