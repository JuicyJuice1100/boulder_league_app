import 'package:boulder_league_app/models/base_meta_data.dart';

class Gym {
  final String id;
  final String name;
  String? activeSeasonId;
  final BaseMetaData baseMetaData;

  Gym({
    required this.id,
    required this.name,
    this.activeSeasonId,
    required this.baseMetaData,
  });

  factory Gym.fromJson(Map<String, dynamic> json, String id) {
    return Gym(
      id: id,
      name: json['name'] ?? '',
      activeSeasonId: json['activeSeasonId'],
      baseMetaData: BaseMetaData.fromJson(json['baseMetaData']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'activeSeasonId': activeSeasonId,
      'baseMetaData': baseMetaData.toJson(),
    };
  }
}
