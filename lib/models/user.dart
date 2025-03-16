import 'package:boulder_league_app/models/boulder.dart';

class User {
  final String email;
  final List<Map<String, CompletedBoulder>> completedBoulders;

  User({
    required this.email,
    required this.completedBoulders,
  });

  User.fromJson(Map<String, dynamic> json)
    : email = json['email'] as String,
      completedBoulders = json['completedBoulders'] as List<Map<String, CompletedBoulder>>;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'completedBoulders': completedBoulders,
    };
  }
}