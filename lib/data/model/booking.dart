import 'booking_service.dart';

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
    this.services = const [],
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
  final List<BookingService> services;

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
        services: (json['booking_service'] as List? ?? const [])
            .map((item) => BookingService.fromJson(Map<String, dynamic>.from(item)))
            .toList(),
        notes: json['notes'] as String?,
            createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at'].toString()),
   

      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer_id': customerId,
        'booking_date': bookingDate,
        'start_time': startTime,
        'end_time': endTime,
        'status': status,
        'therapist_id': therapistId,
        'service_id': serviceId,
        'duration': duration,
        'price': price,
        'notes': notes,
        'created_at': createdAt?.toIso8601String(),
      };
}

