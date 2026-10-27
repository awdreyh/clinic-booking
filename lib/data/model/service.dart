class Service {
  const Service({
    required this.id,
    required this.name,
    this.description,
    this.categoryId,
    this.createdAt,
  });

  final int id;
  final String name;
  final String? description;
  final int? categoryId;
  final DateTime? createdAt;

  factory Service.fromJson(Map<String, dynamic> json) => Service(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String,
        description: json['description'] as String?,
        categoryId: (json['category_id'] as num?)?.toInt(),
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at'].toString()),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'category_id': categoryId,
        'created_at': createdAt?.toIso8601String(),
      };
}
