import 'package:cloud_firestore/cloud_firestore.dart';

class Boulder {
  final String id;
  final String gymId;
  final String name;
  final num week;
  final String seasonId;
  final DateTime createdAt;
  final DateTime lastUpdate;
  final String createdByUid;


  Boulder({
    required this.id,
    required this.gymId,
    required this.name,
    required this.week,
    required this.seasonId,
    required this.createdAt,
    required this.lastUpdate,
    required this.createdByUid
  });

  factory Boulder.fromJson(Map<String, dynamic> json, String id) {
    return Boulder(
      id: id,
      gymId: json['gymId'] ?? '',
      name: json['name'] ?? '',
      week: json['week'] ?? 0,
      seasonId: json['season'] ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      lastUpdate: (json['lastUpdate'] as Timestamp).toDate(),
      createdByUid: json['createdByUid'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'gymId': gymId,
      'name': name,
      'week': week,
      'seasonId': seasonId,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdate': Timestamp.fromDate(lastUpdate),
      'cratedByUid': createdByUid
    };
  }
}