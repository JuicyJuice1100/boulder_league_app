class Boulder {
  final String id;
  final String name;
  final String week;
  final String season;
  final String createdByUid;

  Boulder({
    required this.id,
    required this.name,
    required this.week,
    required this.season,
    required this.createdByUid
  });

  factory Boulder.fromJson(Map<String, dynamic> json, String id) {
    return Boulder(
      id: id,
      name: json['name'] ?? '',
      week: json['week'] ?? '',
      season: json['season'] ?? '',
      createdByUid: json['createdByUid'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'week': week,
      'season': season,
      'cratedByUid': createdByUid
    };
  }
}