import 'package:boulder_league_app/models/boulder.dart';

class User {
  final String uid;
  final List<Map<String, CompletedBoulder>> completedBoulders;

  User({
    required this.uid,
    required this.completedBoulders,
  });

  User.fromJson(Map<String, dynamic> json)
    : uid = json['uid'] as String,
      completedBoulders = json['completedBoulders'] as List<Map<String, CompletedBoulder>>;

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'completedBoulders': completedBoulders,
    };
  }
}