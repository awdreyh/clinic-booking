import '../../supabase_config.dart';
import '../model/therapist.dart';
import '../model/timeslot.dart';

class BookingOptionsRepository {
  Future<List<Therapist>> fetchTherapists() async {
    final rows = await supabase
        .from('user')
        .select('id, name, email')
        .eq('role', 'therapist')
        .order('name');

    return (rows as List)
        .map((row) => Therapist.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<List<Timeslot>> fetchAvailableTimeslots({
    required String therapistId,
    required int roomId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final start = _formatDate(startDate);
    final end = _formatDate(endDate);
    final scheduleRows = await supabase
        .from('therapist_schedule')
        .select('timeslot_id')
        .eq('therapist_id', therapistId)
        .eq('room_id', roomId)
        .gte('date', start)
        .lte('date', end);

    final timeslotIds = (scheduleRows as List)
        .map((row) => row['timeslot_id'] as int)
        .toSet()
        .toList();
    if (timeslotIds.isEmpty) return [];

    final slotRows = await supabase
        .from('timeslot')
        .select()
        .eq('room_id', roomId)
        .gte('date', start)
        .lte('date', end)
        .inFilter('id', timeslotIds)
        .order('date')
        .order('start_time');

    return (slotRows as List)
        .map((row) => Timeslot.fromJson(Map<String, dynamic>.from(row)))
        .where((slot) => slot.usedCount < slot.capacity)
        .toList();
  }
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
