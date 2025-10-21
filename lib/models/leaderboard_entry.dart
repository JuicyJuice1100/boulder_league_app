class LeaderboardEntry {
  final String uid;
  final num totalScore;
  final int boulderCount;
  final String? displayName;

  LeaderboardEntry({
    required this.uid,
    required this.totalScore,
    required this.boulderCount,
    this.displayName,
  });

  String get userName => displayName ?? uid;
}
