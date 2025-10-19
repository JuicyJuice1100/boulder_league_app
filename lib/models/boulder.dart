import 'package:boulder_league_app/models/base_meta_data.dart';

class Boulder {
  final String id;
  final String gymId;
  final String name;
  final num week;
  final String seasonId;
  final BaseMetaData baseMetaData;


  Boulder({
    required this.id,
    required this.gymId,
    required this.name,
    required this.week,
    required this.seasonId,
    required this.baseMetaData
  });

  factory Boulder.fromJson(Map<String, dynamic> json, String id) {
    return Boulder(
      id: id,
      gymId: json['gymId'] ?? '',
      name: json['name'] ?? '',
      week: json['week'] ?? 0,
      seasonId: json['season'] ?? '',
      baseMetaData: BaseMetaData.fromJson(json['baseMetaData'])
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'gymId': gymId,
      'name': name,
      'week': week,
      'seasonId': seasonId,
      'baseMetaData': baseMetaData.toJson()
    };
  }
}