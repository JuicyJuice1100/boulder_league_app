class CompletedBoulder {
  final String uid;
  final String boulderId;
  final DateTime completedAt;
  final int attempts;
  final num score;

  CompletedBoulder({
    required this.uid,
    required this.boulderId,
    required this.completedAt,
    required this.attempts,
    required this.score
  });

  CompletedBoulder.fromJson(Map<String, dynamic> json)
    : uid = json['uid'] as String,
      boulderId = json['boulderId'] as String,
      completedAt = json['completedAt'] as DateTime,
      attempts = json['attempts'] as int,
      score = json['score'] as num;
  
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'boulderId': boulderId,
      'completedAt': completedAt,
      'attempts': attempts,
      'score': score
    };
  }
}