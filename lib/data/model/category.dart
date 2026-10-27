class Category {
  const Category({
    required this.id,
    required this.name,
    this.description,
    this.parentId,
    this.createdAt,
  });

  final int id;
  final String name;
  final String? description;
  final int? parentId;
  final DateTime? createdAt;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String,
        description: json['description'] as String?,
        parentId: (json['parent_id'] as num?)?.toInt(),
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at'].toString()),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'parent_id': parentId,
        'created_at': createdAt?.toIso8601String(),
      };
}
