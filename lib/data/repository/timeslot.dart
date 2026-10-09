import '../../supabase_config.dart';
import '../model/timeslot.dart';

class TimeslotRepository {
  Future<List<Timeslot>> fetchTimeslots(int roomId, String date) async {
    final res = await supabase
        .from('timeslot')
        .select()
        .eq('room_id', roomId)
        .eq('date', date);

    return (res as List).map((e) => Timeslot.fromJson(e)).toList();
  }
}
