import 'package:cloud_firestore/cloud_firestore.dart';

class Season {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String createdByUid;
  final String createdByName;

  Season({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.createdByUid,
    required this.createdByName
  });

  factory Season.fromJson(Map<String, dynamic> json, String id) {
    return Season(
      id: id,
      name: json['name'] ?? '',
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      isActive: json['isActive'] ?? false,
      createdByUid: json['createdByUid'] ?? '',
      createdByName: json['createdByName'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'isActive': isActive, 
      'cratedByUid': createdByUid,
      'createdByName': createdByName
    };
  }
}