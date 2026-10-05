import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

/// Streams the global top 10 safe cave runs live from Cloud Firestore.
///
/// PRODUCTION MENTAL MODEL: a [StreamBuilder] is a standing subscription —
/// it rebuilds itself every single time Firestore pushes a new snapshot
/// (another player finishing a run, anywhere in the world, updates every
/// open leaderboard instantly). Compare this with [FutureBuilder], which
/// resolves ONCE and then goes quiet.
class LeaderboardScreen extends StatelessWidget {
  final FirestoreService firestoreService;

  const LeaderboardScreen({super.key, required this.firestoreService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🏆 Top Safe Cave Runs')),
      body: StreamBuilder<List<LeaderboardEntry>>(
        stream: firestoreService.topRunsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Could not load leaderboard: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final runs = snapshot.data ?? [];
          if (runs.isEmpty) {
            return const Center(child: Text('No runs yet — be the first explorer!'));
          }

          return ListView.builder(
            itemCount: runs.length,
            itemBuilder: (context, index) {
              final run = runs[index];
              return ListTile(
                leading: CircleAvatar(child: Text('#${index + 1}')),
                title: Text(run.playerName),
                subtitle: Text('${run.movesUsed} moves'),
                trailing: Text(
                  '${run.score} pts',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
