class Category {
  const Category({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.parentId,
    this.createdAt,
  });

  final int id;
  final Map<String, String> name;
  final Map<String, String>? description;
  final String? image;
  final int? parentId;
  final DateTime? createdAt;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: (json['id'] as num).toInt(),
        name: _localizedText(json['name']),
        description: json['description'] == null
            ? null
            : _localizedText(json['description']),
        image: json['image'] as String?,
        parentId: (json['parent_id'] as num?)?.toInt(),
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at'].toString()),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'image': image,
        'parent_id': parentId,
        'created_at': createdAt?.toIso8601String(),
      };

  String nameFor(String languageCode) => _localizedValue(name, languageCode);
  String? descriptionFor(String languageCode) => description == null
      ? null
      : _localizedValue(description!, languageCode);
}

Map<String, String> _localizedText(dynamic value) {
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value.toString()));
  }
  if (value is String) return {'en': value};
  return const {};
}

String _localizedValue(Map<String, String> values, String languageCode) =>
    values[languageCode] ?? values['en'] ?? values.values.firstOrNull ?? '';
