class ServiceAttribute {
  const ServiceAttribute({
    required this.id,
    required this.serviceId,
    this.duration,
    this.sessions,
    required this.price,
    this.membershipPrice,
    this.createdAt,
  });

  final int id;
  final int serviceId;
  /// Duration in minutes; null for session packages and memberships.
  final int? duration;
  /// Number of visits; null for timed services and memberships.
  final int? sessions;
  final double price;
  final double? membershipPrice;
  final DateTime? createdAt;

  factory ServiceAttribute.fromJson(Map<String, dynamic> json) =>
      ServiceAttribute(
        id: (json['id'] as num).toInt(),
        serviceId: (json['service_id'] as num).toInt(),
        duration: (json['duration'] as num?)?.toInt(),
        sessions: (json['sessions'] as num?)?.toInt(),
        price: (json['price'] as num).toDouble(),
        membershipPrice: (json['membership_price'] as num?)?.toDouble(),
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at'].toString()),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'service_id': serviceId,
        'duration': duration,
        'sessions': sessions,
        'price': price,
        'membership_price': membershipPrice,
        'created_at': createdAt?.toIso8601String(),
      };
}
