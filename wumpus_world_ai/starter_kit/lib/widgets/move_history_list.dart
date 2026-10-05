import 'package:flutter/material.dart';

/// Scrollable move log rendered with [ListView.builder] (Syllabus #2) —
/// only the visible rows are ever built, which matters once a long cave
/// run accumulates dozens of moves.
class MoveHistoryList extends StatelessWidget {
  final List<String> moves;

  const MoveHistoryList({super.key, required this.moves});

  @override
  Widget build(BuildContext context) {
    if (moves.isEmpty) {
      return const Center(child: Text('No moves yet — step into the cave!'));
    }
    return ListView.builder(
      reverse: true, // newest move at the top
      itemCount: moves.length,
      itemBuilder: (context, index) {
        final move = moves[moves.length - 1 - index];
        return ListTile(
          dense: true,
          leading: const Icon(Icons.history, size: 16),
          title: Text(move),
        );
      },
    );
  }
}
