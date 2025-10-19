import 'package:cloud_firestore/cloud_firestore.dart';

class BaseMetaData {
  final String createdByUid;
  final String lastUpdateByUid;
  final DateTime createdAt;
  final DateTime lastUpdateAt;

  BaseMetaData({
    required this.createdByUid,
    required this.lastUpdateByUid,
    required this.createdAt,
    required this.lastUpdateAt
  });

  factory BaseMetaData.fromJson(Map<String, dynamic> json) {
    return BaseMetaData(
      createdByUid: json['createdByUid'],
      lastUpdateByUid: json['lastUpdateByUid'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      lastUpdateAt: (json['lastUpdateAt'] as Timestamp).toDate()
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdByUid': createdByUid,
      'lastUpdateByUid': lastUpdateByUid,
      'createdAt': createdAt,
      'lastUpdateAt': lastUpdateAt
    };
  }
}