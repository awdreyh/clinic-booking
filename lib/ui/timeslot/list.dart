import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/model/timeslot.dart';
import '../../data/repository/booking.dart';
import '../../data/repository/timeslot.dart';

class TimeslotScreen extends StatefulWidget {
  const TimeslotScreen({super.key, required this.therapistId});

  final String? therapistId;

  @override
  State<TimeslotScreen> createState() => _TimeslotScreenState();
}

class _TimeslotScreenState extends State<TimeslotScreen> {
  final _timeslotRepo = TimeslotRepository();
  final _bookingRepo = BookingRepository();

  late DateTime _selectedDate;
  List<Timeslot> _slots = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateUtils.dateOnly(DateTime.now());
    _loadTimeslots();
  }

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  Future<void> _loadTimeslots() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final slots = await _timeslotRepo.fetchTimeslots(
        date: _dateKey(_selectedDate),
        therapistId: widget.therapistId,
        availableOnly: true,
      );
      if (!mounted) return;
      setState(() {
        _slots = slots;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _book(Timeslot slot) async {
    final customerId = Supabase.instance.client.auth.currentUser?.id;
    if (customerId == null) return;

    try {
      await _bookingRepo.createBooking(
        customerId: customerId,
        bookingDate: slot.date,
        startTime: slot.startTime,
        endTime: slot.endTime,
        therapistId: widget.therapistId,
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
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Timeslots')),
      body: Column(
        children: [
          CalendarDatePicker(
            initialDate: _selectedDate,
            firstDate: DateUtils.dateOnly(DateTime.now()),
            lastDate: DateUtils.dateOnly(
              DateTime.now().add(const Duration(days: 365)),
            ),
            onDateChanged: (date) {
              setState(() => _selectedDate = DateUtils.dateOnly(date));
              _loadTimeslots();
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Could not load timeslots.'),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _loadTimeslots,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _slots.isEmpty
                        ? const Center(
                            child: Text('No available timeslots for this day.'),
                          )
                        : ListView.separated(
                            itemCount: _slots.length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final slot = _slots[index];
                              final available = slot.isAvailable;
                              final foreground = available
                                  ? colors.onSurface
                                  : colors.onSurfaceVariant;
                              return ListTile(
                                title: Text(
                                  '${slot.startTime} – ${slot.endTime}',
                                  style: TextStyle(color: foreground),
                                ),
                                subtitle: Text(
                                  available ? 'Available' : 'Unavailable',
                                  style: TextStyle(color: foreground),
                                ),
                                enabled: available,
                                onTap: available ? () => _book(slot) : null,
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
