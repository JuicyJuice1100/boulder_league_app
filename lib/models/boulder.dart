class Boulder {
  final String id;
  final String name;
  final String week;
  final String month;
  final String createdByUid;

  Boulder({
    required this.id,
    required this.name,
    required this.week,
    required this.month,
    required this.createdByUid
  });

  factory Boulder.fromJson(Map<String, dynamic> json, String id) {
    return Boulder(
      id: id,
      name: json['name'] ?? '',
      week: json['week'] ?? '',
      month: json['month'] ?? '',
      createdByUid: json['createdByUid'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'week': week,
      'month': month,
      'cratedByUid': createdByUid
    };
  }
}