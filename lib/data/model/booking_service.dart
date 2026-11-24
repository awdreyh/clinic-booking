class BookingService {
  const BookingService({
    this.id,
    required this.bookingId,
    required this.serviceId,
    this.duration,
    required this.price,
  });

  final int? id;
  final int bookingId;
  final int serviceId;
  final int? duration;
  final double price;

  factory BookingService.fromJson(Map<String, dynamic> json) => BookingService(
        id: (json['id'] as num?)?.toInt(),
        bookingId: (json['booking_id'] as num).toInt(),
        serviceId: (json['service_id'] as num).toInt(),
        duration: (json['duration'] as num?)?.toInt(),
        price: (json['price'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'booking_id': bookingId,
        'service_id': serviceId,
        'duration': duration,
        'price': price,
      };
}
