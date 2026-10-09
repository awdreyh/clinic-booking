import '../../supabase_config.dart';
import '../model/room.dart';

class RoomRepository {
  Future<List<Room>> fetchRooms() async {
    final res = await supabase.from('room').select();
    return (res as List).map((e) => Room.fromJson(e)).toList();
  }
}

class RoomStatusRepository {
  Future<List<String>> fetchRoomStatuses() async {
    final res = await supabase.from('room').select('status');
    return (res as List).map((e) => e['status'] as String).toList();
  }
}

class CreateRoomRepository {
  Future<Room> createRoom({
    required String name,
    String? department,
    required String status,
  }) async {
    final res = await supabase.from('room').insert({
      'name': name,
      'department': department,
      'status': status,
    }).select().single();
    return Room.fromJson(res);
  }
}

class UpdateRoomRepository {
  Future<Room> updateRoom({
    required int id,
    required String name,
    String? department,
    required String status,
  }) async {
    final res = await supabase.from('room').update({
      'name': name,
      'department': department,
      'status': status,
    }).eq('id', id).select().single();
    return Room.fromJson(res);
  }
}

class DeleteRoomRepository {
  Future<void> deleteRoom({
    required int id,
  }) async {
    await supabase.from('room').delete().eq('id', id);
  }
}
