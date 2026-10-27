import '../../supabase_config.dart';
import '../model/timeslot.dart';

class TimeslotRepository {
  Future<List<Timeslot>> fetchTimeslots({
    required String date,
    String? therapistId,
    bool availableOnly = false,
  }) async {
    final day = DateTime.parse(date).weekday % 7; // PostgreSQL: Sunday = 0.
    final rule = await supabase
        .from('rules')
        .select('start_time, end_time, slot_duration')
        .eq('day_of_week', day)
        .maybeSingle();
    if (rule == null) return [];

    var bookingsQuery = supabase
        .from('booking')
        .select('start_time, end_time')
        .eq('booking_date', date)
        .inFilter('status', ['booked', 'pending']);
    if (therapistId != null) {
      bookingsQuery = bookingsQuery.eq('therapist_id', therapistId);
    }
    final bookings = await bookingsQuery;
    final occupied = (bookings as List)
        .map((row) => Map<String, dynamic>.from(row)['start_time'].toString())
        .toSet();

    int minutes(String time) {
      final parts = time.split(':');
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    }

    String clock(int value) =>
        '${(value ~/ 60).toString().padLeft(2, '0')}:${(value % 60).toString().padLeft(2, '0')}:00';

    final start = minutes(rule['start_time'].toString());
    final end = minutes(rule['end_time'].toString());
    final duration = (rule['slot_duration'] as num).toInt();
    final slots = <Timeslot>[];
    for (var minute = start; minute + duration <= end; minute += duration) {
      final startTime = clock(minute);
      final isAvailable = !occupied.contains(startTime);
      if (!availableOnly || isAvailable) {
        slots.add(Timeslot(
          date: date,
          startTime: startTime,
          endTime: clock(minute + duration),
          isAvailable: isAvailable,
        ));
      }
    }
    return slots;
  }
}
