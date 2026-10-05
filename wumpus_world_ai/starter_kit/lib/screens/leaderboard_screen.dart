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
      // TODO (BLOCK 3 — LIVE CODE WITH TRAINER):
      // Replace this placeholder with a StreamBuilder<List<LeaderboardEntry>>:
      // 1. `stream: firestoreService.topRunsStream()`
      // 2. In `builder: (context, snapshot) { ... }`:
      //      - if snapshot.hasError -> show an error Text
      //      - if snapshot.connectionState == ConnectionState.waiting ->
      //        show a CircularProgressIndicator
      //      - otherwise read `final runs = snapshot.data ?? [];`
      //      - if runs.isEmpty -> show an empty-state Text
      //      - else return a ListView.builder rendering each LeaderboardEntry
      //        as a ListTile (rank, playerName, movesUsed, score).
      body: const Center(
        child: Text('TODO: wire up the StreamBuilder leaderboard here'),
      ),
    );
  }
}
