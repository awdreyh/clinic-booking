class Booking {
  const Booking({
    required this.id,
    this.customerId,
    this.bookingDate,
    this.startTime,
    this.endTime,
    this.status = 'pending',
    this.therapistId,
    this.serviceId,
    this.duration,
    this.price,
    this.notes,
    this.createdAt,
  });

  final int id;
  final String? customerId;
  final String? bookingDate;
  final String? startTime;
  final String? endTime;
  final String status;
  final String? therapistId;
  final int? serviceId;
  final String? duration;
  final double? price;
  final String? notes;
  final DateTime? createdAt;

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: (json['id'] as num).toInt(),
        customerId: json['customer_id'] as String?,
        bookingDate: json['booking_date'] as String?,
        startTime: json['start_time'] as String?,
        endTime: json['end_time'] as String?,
        status: json['status'] as String? ?? 'pending',
        therapistId: json['therapist_id'] as String?,
        serviceId: (json['service_id'] as num?)?.toInt(),
        duration: json['duration'] as String?,
        price: (json['price'] as num?)?.toDouble(),
        notes: json['notes'] as String?,
        createdAt: _dateTime(json['created_at']),
      );

  static DateTime? _dateTime(Object? value) =>
      value == null ? null : DateTime.parse(value.toString());
}
