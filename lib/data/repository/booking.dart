import '../../supabase_config.dart';
import '../model/booking.dart';
import '../model/booking_service.dart';

class BookingRepository {
  Future<List<Booking>> fetchBookings({
    String? customerId,
    String? therapistId,
  }) async {
    var query = supabase.from('booking').select();
    if (customerId != null) query = query.eq('customer_id', customerId);
    if (therapistId != null) query = query.eq('therapist_id', therapistId);
    final rows = await query.order('created_at', ascending: false);
    return (rows as List)
        .map((row) => Booking.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<Booking> createBooking({
    required String customerId,
    required String bookingDate,
    required String startTime,
    required String endTime,
    String? therapistId,
    int? serviceId,
    String? duration,
    double? price,
    String? notes,
    List<BookingService>? services,
  }) async {
    final row = await supabase.from('booking').insert({
      'customer_id': customerId,
      'booking_date': bookingDate,
      'start_time': startTime,
      'end_time': endTime,
      'therapist_id': therapistId,
      'service_id': serviceId,
      'duration': duration,
      'price': price,
      'notes': notes,
      'status': 'pending',
    }).select().single();
    final booking = Booking.fromJson(row);
    final requestedItems = services ?? (serviceId == null ? const <BookingService>[] : [
      BookingService(
        bookingId: booking.id,
        serviceId: serviceId,
        duration: _durationMinutes(duration),
        price: price ?? 0,
      ),
    ]);
    final itemsByService = <int, BookingService>{};
    for (final item in requestedItems) {
      final existing = itemsByService[item.serviceId];
      itemsByService[item.serviceId] = existing == null
          ? BookingService(
              bookingId: booking.id,
              serviceId: item.serviceId,
              duration: item.duration,
              price: item.price,
            )
          : BookingService(
              bookingId: booking.id,
              serviceId: item.serviceId,
              duration: existing.duration == null && item.duration == null
                  ? null
                  : (existing.duration ?? 0) + (item.duration ?? 0),
              price: existing.price + item.price,
            );
    }
    final items = itemsByService.values.toList();
    if (items.isNotEmpty) {
      try {
        await supabase.from('booking_service').insert(items.map((item) => {
          'booking_id': booking.id,
          'service_id': item.serviceId,
          'duration': item.duration,
          'price': item.price,
        }).toList());
      } catch (_) {
        await supabase.from('booking').delete().eq('id', booking.id);
        rethrow;
      }
    }
    final loaded = await supabase.from('booking').select('*, booking_service(*)').eq('id', booking.id).single();
    return Booking.fromJson(loaded);
  }

  int? _durationMinutes(String? value) {
    final match = RegExp(r'\d+').firstMatch(value ?? '');
    return match == null ? null : int.parse(match.group(0)!);
  }

  Future<Booking> updateStatus({
    required int id,
    required String status,
  }) async {
    const allowedStatuses = {'booked', 'pending', 'cancelled'};
    if (!allowedStatuses.contains(status)) {
      throw ArgumentError.value(status, 'status', 'Unsupported booking status');
    }
    final row = await supabase
        .from('booking')
        .update({'status': status})
        .eq('id', id)
        .select()
        .single();
    return Booking.fromJson(row);
  }

  Future<Booking> cancelBooking(int id) =>
      updateStatus(id: id, status: 'cancelled');
}
