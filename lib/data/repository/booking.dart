import 'package:uuid/uuid.dart';

import '../../supabase_config.dart';
import '../model/booking.dart';

class BookingRepository {
  Future<Booking> createBooking({
    required String userId,
    required int roomId,
    required int timeslotId,
    String? therapistId,
  }) async {
    final res = await supabase.from('booking').insert({
      'user_id': userId,
      'therapist_id': therapistId,
      'room_id': roomId,
      'timeslot_id': timeslotId,
      'status': 'booked',
      'recurrence_type': 'single',
    }).select().single();

    return Booking.fromJson(res);
  }

  Future<List<Booking>> createBookings({
    required String userId,
    required String therapistId,
    required int roomId,
    required List<int> timeslotIds,
    required String recurrenceType,
  }) async {
    final recurrenceGroupId =
        recurrenceType == 'single' ? null : const Uuid().v4();
    final rows = [
      for (final timeslotId in timeslotIds)
        {
          'user_id': userId,
          'therapist_id': therapistId,
          'room_id': roomId,
          'timeslot_id': timeslotId,
          'status': 'booked',
          'recurrence_type': recurrenceType,
          'recurrence_group_id': recurrenceGroupId,
        },
    ];

    final res = await supabase.from('booking').insert(rows).select();
    return (res as List)
        .map((row) => Booking.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }
}

class CancelBookingRepository {
  Future<Booking> cancelBooking({
    required int id,
  }) async {
    final res = await supabase.from('booking').update({
      'status': 'canceled',
    }).eq('id', id).select().single();

    return Booking.fromJson(res);
  }
}
class UpdateBookingRepository {
  Future<Booking> updateBooking({
    required int id,
    required String status,
  }) async {
    final res = await supabase.from('booking').update({
      'status': status,
    }).eq('id', id).select().single();

    return Booking.fromJson(res);
  }
}
