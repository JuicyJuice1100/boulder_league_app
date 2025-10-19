import 'package:cloud_firestore/cloud_firestore.dart';

class ScoredBoulder {
  final String uid;
  final String boulderId;
  final String boulderName;
  final String gymId;
  final String seasonId;
  final String seasonName;
  final num week;
  final bool top;
  final int attempts;
  final DateTime createdAt;
  final DateTime lastUpdate;
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
    required this.gymId,
    required this.seasonId,
    required this.seasonName,
    required this.week,
    required this.attempts,
    required this.top,
    required this.createdAt,
    required this.lastUpdate,
    required this.score 
  });

  ScoredBoulder.fromJson(Map<String, dynamic> json, String id)
    : uid = json['uid'] as String,
      boulderId = json['boulderId'] as String,
      boulderName = json['boulderName'] as String,
      gymId = json['gymId'] as String,
      seasonId = json['seasonId'] as String,
      seasonName = json['seasonName'] as String,
      week = json['week'] as num,
      attempts = json['attempts'] as int,
      top = json['top'] as bool,
      createdAt = (json['createdAt'] as Timestamp).toDate(),
      lastUpdate = (json['lastUpdate'] as Timestamp).toDate(),
      score = json['score'] as num;
  
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'boulderId': boulderId,
      'boulderName': boulderName,
      'gymId': gymId,
      'seasonId': seasonId,
      'seasonName': seasonName,
      'week': week,
      'attempts': attempts,
      'top': top,
      'createdAt': createdAt,
      'lastUpdate': lastUpdate,
      'score': score
    };
  }
}