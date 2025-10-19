import 'package:boulder_league_app/models/base_meta_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Season {
  final String id;
  final String gymId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final BaseMetaData baseMetaData;

  Season({
    required this.id,
    required this.gymId,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.baseMetaData
  });

  factory Season.fromJson(Map<String, dynamic> json, String id) {
    return Season(
      id: id,
      gymId: json['gymId'] ?? '',
      name: json['name'] ?? '',
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      isActive: json['isActive'] ?? false,
      baseMetaData: BaseMetaData.fromJson(json['baseMetaData'])
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'gymId': gymId,
      'name': name,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'isActive': isActive, 
      'baseMetaData': baseMetaData.toJson()
    };
  }
}