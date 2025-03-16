class Boulder {
  final String id;
  final String name;
  final String grade;
  final DateTime setAt;
  final DateTime removedAt;

  Boulder({
    required this.id,
    required this.name,
    required this.grade,
    required this.setAt,
    required this.removedAt
  });
}

class CompletedBoulder {
  final String boulderId;
  final DateTime completedAt;
  final int attempts;
  final num score;

  CompletedBoulder({
    required this.boulderId,
    required this.completedAt,
    required this.attempts,
    required this.score
  });
}