class Boulder {
  final String id;
  final String name;
  final DateTime setAt;
  final DateTime? removedAt;
  final String createdByUid;

  Boulder({
    required this.id,
    required this.name,
    required this.setAt,
    required this.removedAt,
    required this.createdByUid
  });

  Boulder.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String,
      name = json['name'] as String,
      setAt = json['setAt'] as DateTime,
      removedAt = json['removedAt'] as DateTime,
      createdByUid = json['createdByUid'] as String;

  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'setAt': setAt,
      'removedAt': removedAt,
      'cratedByUid': createdByUid
    };
  }
}