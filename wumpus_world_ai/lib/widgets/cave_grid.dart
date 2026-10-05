import 'package:flutter/material.dart';
import '../models/cell.dart';
import '../painters/percept_painter.dart';

typedef OnCellTap = void Function(Cell cell);

/// Renders an NxN cave as a responsive grid using [GridView.builder]
/// (Syllabus #2). `gridSize` now comes from the chosen [GameConfig]
/// (FEATURE: difficulty levels) instead of being hardcoded to 4, so this
/// widget scales to 4x4 / 6x6 / 8x8 without any other changes.
/// [MediaQuery] drives adaptive sizing so the same board looks right on a
/// small phone, a tablet, and a browser tab.
class CaveGrid extends StatelessWidget {
  final List<List<Cell>> grid;
  final OnCellTap onCellTap;
  final int agentRow;
  final int agentCol;
  final int gridSize;

  const CaveGrid({
    super.key,
    required this.grid,
    required this.onCellTap,
    required this.agentRow,
    required this.agentCol,
    required this.gridSize,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxBoard = screenWidth < 500 ? screenWidth * 0.92 : 560.0;
    // Keep individual tiles from shrinking below a usable/tappable size on
    // large grids (accessibility: tap targets should stay reasonably
    // large even on an 8x8 board).
    final boardSize = (gridSize * 64.0).clamp(240.0, maxBoard).toDouble();

    return SizedBox(
      width: boardSize,
      height: boardSize,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridSize,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: gridSize * gridSize,
        itemBuilder: (context, index) {
          final row = index ~/ gridSize;
          final col = index % gridSize;
          final cell = grid[row][col];
          final isAgentHere = row == agentRow && col == agentCol;
          return Semantics(
            label: _describeCell(cell, isAgentHere),
            button: true,
            child: GestureDetector(
              onTap: () => onCellTap(cell),
              child: _CaveTile(cell: cell, isAgentHere: isAgentHere),
            ),
          );
        },
      ),
    );
  }

  String _describeCell(Cell cell, bool isAgentHere) {
    final parts = <String>['Cell row ${cell.row + 1}, column ${cell.col + 1}'];
    if (isAgentHere) parts.add('your explorer is here');
    if (!cell.isVisited && !cell.isDiscovered) {
      parts.add('unexplored');
    } else {
      if (cell.isVisited) parts.add('visited');
      if (cell.hasBreeze) parts.add('breeze felt');
      if (cell.hasStench) parts.add('stench smelled');
      if (cell.hasGold && cell.isVisited) parts.add('gold here');
    }
    return parts.join(', ');
  }
}

class _CaveTile extends StatelessWidget {
  final Cell cell;
  final bool isAgentHere;

  const _CaveTile({required this.cell, required this.isAgentHere});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Layer 1: solid "fog" base — always present underneath.
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.brown[900]!, Colors.brown[800]!],
            ),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        // Layer 2: the real tile, fog-of-war faded in once visited.
        AnimatedOpacity(
          opacity: cell.isVisited ? 1.0 : (cell.isDiscovered ? 0.35 : 0.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.brown[100]!, Colors.brown[300]!],
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: CustomPaint(
              painter: PerceptPainter(
                hasBreeze: cell.hasBreeze,
                hasStench: cell.hasStench,
              ),
              child: Center(
                child: isAgentHere
                    ? const Icon(Icons.explore, color: Colors.redAccent)
                    : (cell.hasGold && cell.isVisited
                        ? const Icon(Icons.diamond, color: Colors.amber)
                        : null),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
