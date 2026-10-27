import '../../supabase_config.dart';
import '../model/booking.dart';

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
    return Booking.fromJson(row);
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
