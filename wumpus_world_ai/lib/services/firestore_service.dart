import 'package:cloud_firestore/cloud_firestore.dart';

/// A single row on the global leaderboard: one completed cave run.
class LeaderboardEntry {
  final String playerName;
  final int score;
  final int movesUsed;
  final DateTime achievedAt;

  LeaderboardEntry({
    required this.playerName,
    required this.score,
    required this.movesUsed,
    required this.achievedAt,
  });

  factory LeaderboardEntry.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return LeaderboardEntry(
      playerName: data['playerName'] ?? 'Explorer',
      score: data['score'] ?? 0,
      movesUsed: data['movesUsed'] ?? 0,
      achievedAt: (data['achievedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

/// Wraps all Cloud Firestore CRUD + real-time streaming for the global
/// "top safe cave runs" leaderboard (Syllabus #4 — Cloud Firestore).
class FirestoreService {
  final CollectionReference<Map<String, dynamic>> _runs =
      FirebaseFirestore.instance.collection('cave_runs');

  /// CREATE: persists one finished run. Wrapped in try/catch because any
  /// network/DB write can legitimately fail offline (Syllabus #1 —
  /// Exception Handling).
  Future<void> submitRun({
    required String playerName,
    required int score,
    required int movesUsed,
  }) async {
    try {
      await _runs.add({
        'playerName': playerName,
        'score': score,
        'movesUsed': movesUsed,
        'achievedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Could not save run to the leaderboard: $e');
    }
  }

  /// READ (real-time): a live-updating Stream of the top N scores, ordered
  /// descending. This is what powers the `StreamBuilder` leaderboard screen.
  Stream<List<LeaderboardEntry>> topRunsStream({int limit = 10}) {
    return _runs
        .orderBy('score', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(LeaderboardEntry.fromDoc).toList());
  }
}
