class ServiceAttribute {
  const ServiceAttribute({
    required this.id,
    required this.serviceId,
    required this.attributeKey,
    required this.attributeValue,
    this.createdAt,
  });

  final int id;
  final int? serviceId;
  final String attributeKey;
  final String attributeValue;
  final DateTime? createdAt;

  factory ServiceAttribute.fromJson(Map<String, dynamic> json) =>
      ServiceAttribute(
        id: (json['id'] as num).toInt(),
        serviceId: (json['service_id'] as num?)?.toInt(),
        attributeKey: json['attribute_key'] as String,
        attributeValue: json['attribute_value'] as String,
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at'].toString()),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'service_id': serviceId,
        'attribute_key': attributeKey,
        'attribute_value': attributeValue,
        'created_at': createdAt?.toIso8601String(),
      };
}
