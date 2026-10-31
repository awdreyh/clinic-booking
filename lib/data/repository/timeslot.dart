import '../../supabase_config.dart';
import '../model/timeslot.dart';

class TimeslotRepository {
  Future<List<Timeslot>> fetchTimeslots({
    required String date,
    String? therapistId,
    List<String>? anyTherapistIds,
    bool availableOnly = false,
    int? requiredMinutes,
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
        .select('therapist_id, start_time, end_time')
        .eq('booking_date', date)
        .inFilter('status', ['booked', 'pending']);
    if (therapistId != null) {
      bookingsQuery = bookingsQuery.eq('therapist_id', therapistId);
    }
    final bookings = await bookingsQuery;

    int minutes(String time) {
      final parts = time.split(':');
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    }

    String clock(int value) =>
        '${(value ~/ 60).toString().padLeft(2, '0')}:${(value % 60).toString().padLeft(2, '0')}:00';

    final occupiedByTherapist = <String, List<(int, int)>>{};
    for (final row in bookings as List) {
      final values = Map<String, dynamic>.from(row);
      final key = values['therapist_id']?.toString() ?? '';
      occupiedByTherapist
          .putIfAbsent(key, () => [])
          .add((
            minutes(values['start_time'].toString()),
            minutes(values['end_time'].toString()),
          ));
    }

    bool hasOverlap(List<(int, int)>? intervals, int slotStart, int slotEnd) =>
        intervals != null &&
        intervals.any(
          (booking) => booking.$1 < slotEnd && slotStart < booking.$2,
        );

    final start = minutes(rule['start_time'].toString());
    final end = minutes(rule['end_time'].toString());
    final gridStep = (rule['slot_duration'] as num).toInt();
    final length = requiredMinutes == null || requiredMinutes < gridStep
        ? gridStep
        : requiredMinutes;
    final slots = <Timeslot>[];
    for (var minute = start; minute + length <= end; minute += gridStep) {
      final slotEnd = minute + length;
      final isAvailable = therapistId != null
          ? !hasOverlap(occupiedByTherapist[therapistId], minute, slotEnd)
          : (anyTherapistIds != null && anyTherapistIds.isNotEmpty)
          ? anyTherapistIds.any(
              (id) => !hasOverlap(occupiedByTherapist[id], minute, slotEnd),
            )
          : occupiedByTherapist.values.every(
              (intervals) => !hasOverlap(intervals, minute, slotEnd),
            );
      if (!availableOnly || isAvailable) {
        slots.add(Timeslot(
          date: date,
          startTime: clock(minute),
          endTime: clock(slotEnd),
          isAvailable: isAvailable,
        ));
      }
    }
    return slots;
  }
}
