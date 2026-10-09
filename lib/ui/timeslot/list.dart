import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/model/room.dart';
import '../../data/model/timeslot.dart';
import '../../data/repository/timeslot.dart';
import '../../data/repository/booking.dart';

class TimeslotScreen extends StatefulWidget {
  final Room room;
  const TimeslotScreen({super.key, required this.room});

  @override
  State<TimeslotScreen> createState() => _TimeslotScreenState();
}

class _TimeslotScreenState extends State<TimeslotScreen> {
  final timeslotRepo = TimeslotRepository();
  final bookingRepo = BookingRepository();

  List<Timeslot> slots = [];
  bool loading = true;
  late final String date;

  @override
  void initState() {
    super.initState();
    date = DateTime.now().toIso8601String().split('T').first;
    _loadTimeslots();
  }

  Future<void> _loadTimeslots() async {
    final data = await timeslotRepo.fetchTimeslots(widget.room.id, date);
    setState(() {
      slots = data;
      loading = false;
    });
  }

  Future<void> _book(Timeslot slot) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await bookingRepo.createBooking(
        userId: userId,
        roomId: widget.room.id,
        timeslotId: slot.id,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(title: Text('${widget.room.name} 时间段')),
      body: ListView.builder(
        itemCount: slots.length,
        itemBuilder: (_, i) {
          final s = slots[i];
          final available = s.usedCount < s.capacity;

          return ListTile(
            title: Text('${s.startTime} - ${s.endTime}'),
            subtitle: Text('已预约：${s.usedCount}/${s.capacity}'),
            trailing: available ? const Text('可预约') : const Text('已满'),
            onTap: available ? () => _book(s) : null,
          );
        },
      ),
    );
  }
}
