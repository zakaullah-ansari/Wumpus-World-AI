import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/player_profile.dart';

/// Reads/writes a player's persistent stats at `players/{uid}`. Separate
/// from [FirestoreService]'s leaderboard (which stores one row per run) —
/// this stores running totals per player (FEATURE enhancement: profiles).
class PlayerProfileService {
  final CollectionReference<Map<String, dynamic>> _players =
      FirebaseFirestore.instance.collection('players');

  /// Live stream of a player's profile. Emits [PlayerProfile.empty] for a
  /// brand-new player who hasn't finished a run yet.
  Stream<PlayerProfile> watchProfile(String uid) {
    return _players.doc(uid).snapshots().map(
          (doc) => doc.exists ? PlayerProfile.fromMap(doc.data()!) : PlayerProfile.empty,
        );
  }

  Future<void> updateDisplayName(String uid, String displayName) async {
    try {
      await _players.doc(uid).set({'displayName': displayName}, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Could not update display name: $e');
    }
  }

  /// Atomically folds one finished run into the player's running totals,
  /// creating the profile document on first write. A Firestore
  /// [Transaction] is used so two near-simultaneous writes (unlikely here,
  /// but a good habit) can never clobber each other's counters.
  Future<void> recordRun(
    String uid, {
    required String displayName,
    required int score,
    required int movesUsed,
    required bool won,
  }) async {
    final doc = _players.doc(uid);
    try {
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final snapshot = await tx.get(doc);
        final existing =
            snapshot.exists ? PlayerProfile.fromMap(snapshot.data()!) : PlayerProfile.empty;
        final updated = PlayerProfile(
          displayName: displayName,
          gamesPlayed: existing.gamesPlayed + 1,
          bestScore: score > existing.bestScore ? score : existing.bestScore,
          bestMoves: won && (existing.bestMoves < 0 || movesUsed < existing.bestMoves)
              ? movesUsed
              : existing.bestMoves,
        );
        tx.set(doc, updated.toMap());
      });
    } catch (e) {
      throw Exception('Could not update profile stats: $e');
    }
  }
}
