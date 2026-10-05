import 'package:flutter/material.dart';
import '../models/cell.dart';
import '../painters/percept_painter.dart';

typedef OnCellTap = void Function(Cell cell);

/// Renders the 4x4 cave as a responsive grid using [GridView.builder]
/// (Syllabus #2). [MediaQuery] drives adaptive sizing so the same board
/// looks right on a small phone, a tablet, and a browser tab.
class CaveGrid extends StatelessWidget {
  final List<List<Cell>> grid;
  final OnCellTap onCellTap;
  final int agentRow;
  final int agentCol;

  const CaveGrid({
    super.key,
    required this.grid,
    required this.onCellTap,
    required this.agentRow,
    required this.agentCol,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize = screenWidth < 500 ? screenWidth * 0.92 : 480.0;

    return SizedBox(
      width: boardSize,
      height: boardSize,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: 16,
        itemBuilder: (context, index) {
          final row = index ~/ 4;
          final col = index % 4;
          final cell = grid[row][col];
          final isAgentHere = row == agentRow && col == agentCol;
          return GestureDetector(
            onTap: () => onCellTap(cell),
            child: _CaveTile(cell: cell, isAgentHere: isAgentHere),
          );
        },
      ),
    );
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
            color: Colors.brown[900],
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
              color: Colors.brown[200],
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
