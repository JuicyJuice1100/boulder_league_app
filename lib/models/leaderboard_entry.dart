class LeaderboardEntry {
  final String uid;
  final num totalScore;
  final String? displayName;

  LeaderboardEntry({
    required this.uid,
    required this.totalScore,
    this.displayName,
  });

  String get userName => displayName ?? uid;
}
