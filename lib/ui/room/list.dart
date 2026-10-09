import 'package:flutter/material.dart';
import '../../data/repository/room.dart';
import '../../data/model/room.dart';
import '../timeslot/list.dart';

class RoomListScreen extends StatefulWidget {
  const RoomListScreen({super.key});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  final repo = RoomRepository();
  List<Room> rooms = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final data = await repo.fetchRooms();
      if (!mounted) return;
      setState(() => rooms = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('诊室列表')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('无法加载诊室，请检查 Supabase 连接。'),
                const SizedBox(height: 8),
                Text(error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadRooms,
                  child: const Text('重试'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('诊室列表')),
      body: ListView.builder(
        itemCount: rooms.length,
        itemBuilder: (_, i) {
          final r = rooms[i];
          return ListTile(
            title: Text(r.name),
            subtitle: Text(r.department ?? ''),
            trailing: Text(r.status),
            onTap: () async {
              final booked = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => TimeslotScreen(room: r),
                ),
              );
              if (!context.mounted || booked != true) return;
              Navigator.of(context).pop(true);
            },
          );
        },
      ),
    );
  }
}
