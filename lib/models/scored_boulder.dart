import 'package:cloud_firestore/cloud_firestore.dart';

class ScoredBoulder {
  final String uid;
  final String boulderId;
  final String boulderName;
  final bool top;
  final int attempts;
  final Timestamp lastUpdated;
  num score;

  void calculateScore() {
    num calculatedScore = 0;

    if (top) {
      calculatedScore += 100;

      if (attempts == 1) {
        calculatedScore += 25;
      } else {
        calculatedScore -= (attempts - 1) * 0.1;
      }
    }

    score = calculatedScore;
  }

  ScoredBoulder({
    required this.uid,
    required this.boulderId,
    required this.boulderName,
    required this.attempts,
    required this.top,
    required this.lastUpdated,
    required this.score 
  });

  ScoredBoulder.fromJson(Map<String, dynamic> json, String id)
    : uid = json['uid'] as String,
      boulderId = json['boulderId'] as String,
      boulderName = json['boulderName'] as String,
      attempts = json['attempts'] as int,
      top = json['top'] as bool,
      lastUpdated = json['lastUpdated'] as Timestamp,
      score = json['score'] as num;
  
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'boulderId': boulderId,
      'boulderName': boulderName,
      'attempts': attempts,
      'top': top,
      'lastUpdated': lastUpdated,
      'score': score
    };
  }
}