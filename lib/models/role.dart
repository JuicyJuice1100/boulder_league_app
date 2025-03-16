import 'package:boulder_league_app/models/permission.dart';

class Role {
  final int id;
  final String name;
  final List<Map<String, Permission>> permissions;

  Role({
    required this.id,
    required this.name,
    required this.permissions
  });
}