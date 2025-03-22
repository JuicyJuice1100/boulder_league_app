class Boulder {
  final String id;
  final String name;
  final DateTime setAt;
  final DateTime removedAt;

  Boulder({
    required this.id,
    required this.name,
    required this.setAt,
    required this.removedAt
  });

  Boulder.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String,
      name = json['name'] as String,
      setAt = json['setAt'] as DateTime,
      removedAt = json['removedAt'] as DateTime;
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'setAt': setAt,
      'removedAt': removedAt
    };
  }
}