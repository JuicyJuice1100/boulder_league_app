import 'package:boulder_league_app/models/base_meta_data.dart';

class ScoredBoulder {
  final String id;
  final String uid;
  final String boulderId;
  final String gymId;
  final String seasonId;
  final num week;
  final num attempts;
  final bool completed;
  final num score;
  final String? displayName;
  final BaseMetaData baseMetaData;

  ScoredBoulder({
    required this.id,
    required this.uid,
    required this.boulderId,
    required this.gymId,
    required this.seasonId,
    required this.week,
    required this.attempts,
    required this.completed,
    required this.score,
    this.displayName,
    required this.baseMetaData
  });

  factory ScoredBoulder.fromJson(Map<String, dynamic> json, String id) {
    return ScoredBoulder(
      id: id,
      uid: json['uid'],
      boulderId: json['boulderId'],
      gymId: json['gymId'],
      seasonId: json['seasonId'],
      week: json['week'],
      attempts: json['attempts'],
      completed: json['completed'],
      score: json['score'],
      displayName: json['displayName'],
      baseMetaData: BaseMetaData.fromJson(json['baseMetaData'])
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'boulderId': boulderId,
      'gymId': gymId,
      'seasonId': seasonId,
      'week': week,
      'attempts': attempts,
      'completed': completed,
      'score': score,
      'displayName': displayName,
      'baseMetaData': baseMetaData.toJson()
    };
  }
}