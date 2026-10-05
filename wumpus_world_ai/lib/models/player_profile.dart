/// A player's persistent stats, stored at `players/{uid}` in Firestore.
/// Distinct from a single [LeaderboardEntry] (one run) — this is the
/// player's running totals across every run they've ever played.
class PlayerProfile {
  final String displayName;
  final int gamesPlayed;
  final int bestScore;
  final int bestMoves; // lowest moves on a WINNING run; -1 means "none yet"

  const PlayerProfile({
    required this.displayName,
    required this.gamesPlayed,
    required this.bestScore,
    required this.bestMoves,
  });

  static const empty = PlayerProfile(
    displayName: 'Explorer',
    gamesPlayed: 0,
    bestScore: 0,
    bestMoves: -1,
  );

  bool get hasWonBefore => bestMoves >= 0;

  factory PlayerProfile.fromMap(Map<String, dynamic> data) => PlayerProfile(
        displayName: data['displayName'] as String? ?? 'Explorer',
        gamesPlayed: data['gamesPlayed'] as int? ?? 0,
        bestScore: data['bestScore'] as int? ?? 0,
        bestMoves: data['bestMoves'] as int? ?? -1,
      );

  Map<String, dynamic> toMap() => {
        'displayName': displayName,
        'gamesPlayed': gamesPlayed,
        'bestScore': bestScore,
        'bestMoves': bestMoves,
      };
}
