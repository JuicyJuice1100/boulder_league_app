import 'package:boulder_league_app/models/boulder.dart';
import 'package:boulder_league_app/models/meta_data.dart';

class User {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String roleId;
  final List<Map<String, CompletedBoulder>> completedBoulders;
  final MetaData? metaData;

  User({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.roleId,
    required this.completedBoulders,
    this.metaData
  });

  User.fromJson(Map<String, dynamic> json)
    : uid = json['uid'] as String,
      email = json['email'] as String,
      firstName = json['firstName'] as String,
      lastName = json['lastName'] as String,
      roleId = json['roleId'] as String,  
      completedBoulders = json['completedBoulders'] as List<Map<String, CompletedBoulder>>,
      metaData = json['metaData'] as MetaData;

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'roleId': roleId,
      'completedBoulders': completedBoulders,
      'metaData': metaData
    };
  }
}