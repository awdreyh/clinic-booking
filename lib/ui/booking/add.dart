import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/model/room.dart';
import '../../data/model/therapist.dart';
import '../../data/model/timeslot.dart';
import '../../data/repository/booking.dart';
import '../../data/repository/booking_options.dart';
import '../../data/repository/room.dart';
import '../../l10n/app_localizations.dart';

enum BookingFrequency { single, weekly, fortnightly, monthly }

class AddBookingScreen extends StatefulWidget {
  const AddBookingScreen({super.key});

  @override
  State<AddBookingScreen> createState() => _AddBookingScreenState();
}

class _AddBookingScreenState extends State<AddBookingScreen> {
  static const _availabilityDays = 90;

  final _optionsRepository = BookingOptionsRepository();
  final _roomRepository = RoomRepository();
  final _bookingRepository = BookingRepository();

  late Future<_BookingOptions> _optionsFuture;
  final _availabilityEnd = DateUtils.dateOnly(
    DateTime.now(),
  ).add(const Duration(days: _availabilityDays));

  BookingFrequency _frequency = BookingFrequency.single;
  Therapist? _selectedTherapist;
  Room? _selectedRoom;
  DateTime? _selectedDate;
  Timeslot? _selectedSlot;
  List<Timeslot> _availableSlots = [];
  bool _loadingAvailability = false;
  bool _availabilityFailed = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _optionsFuture = _loadOptions();
  }

  Future<_BookingOptions> _loadOptions() async {
    final therapists = await _optionsRepository.fetchTherapists();
    final rooms = await _roomRepository.fetchRooms();
    return _BookingOptions(
      therapists: therapists,
      rooms: rooms.where((room) => room.status == 'active').toList(),
    );
  }

  Future<void> _loadAvailability() async {
    final therapist = _selectedTherapist;
    final room = _selectedRoom;
    setState(() {
      _availableSlots = [];
      _selectedDate = null;
      _selectedSlot = null;
      _availabilityFailed = false;
    });

    if (therapist == null || room == null) return;

    setState(() => _loadingAvailability = true);
    try {
      final slots = await _optionsRepository.fetchAvailableTimeslots(
        therapistId: therapist.id,
        roomId: room.id,
        startDate: DateUtils.dateOnly(DateTime.now()),
        endDate: _availabilityEnd,
      );
      if (!mounted ||
          !identical(therapist, _selectedTherapist) ||
          !identical(room, _selectedRoom)) {
        return;
      }
      setState(() {
        _availableSlots = slots.where(_startsInFuture).toList();
        _loadingAvailability = false;
      });
    } catch (_) {
      if (!mounted ||
          !identical(therapist, _selectedTherapist) ||
          !identical(room, _selectedRoom)) {
        return;
      }
      setState(() {
        _loadingAvailability = false;
        _availabilityFailed = true;
      });
    }
  }

  bool _startsInFuture(Timeslot slot) {
    return _slotStart(slot).isAfter(DateTime.now());
  }

  DateTime _slotStart(Timeslot slot) {
    return DateTime.parse('${slot.date}T${slot.startTime}');
  }

  Set<DateTime> get _availableDates {
    return {
      for (final slot in _availableSlots)
        DateUtils.dateOnly(DateTime.parse(slot.date)),
    };
  }

  List<Timeslot> get _slotsForSelectedDate {
    final selectedDate = _selectedDate;
    if (selectedDate == null) return [];
    final slots = _availableSlots
        .where(
          (slot) => DateUtils.isSameDay(DateTime.parse(slot.date), selectedDate),
        )
        .toList();
    slots.sort((a, b) => _slotStart(a).compareTo(_slotStart(b)));
    return slots;
  }

  List<Timeslot> get _bookingSlots {
    final selectedDate = _selectedDate;
    final selectedSlot = _selectedSlot;
    if (selectedDate == null || selectedSlot == null) return [];
    if (_frequency == BookingFrequency.single) return [selectedSlot];

    return [
      for (final date in _recurrenceDates(DateUtils.dateOnly(selectedDate)))
        ?_matchingSlot(date, selectedSlot),
    ];
  }

  Iterable<DateTime> _recurrenceDates(DateTime start) sync* {
    yield start;
    var occurrence = start;
    var monthOffset = 0;
    while (true) {
      occurrence = switch (_frequency) {
        BookingFrequency.single => _availabilityEnd.add(
            const Duration(days: 1),
          ),
        BookingFrequency.weekly => occurrence.add(const Duration(days: 7)),
        BookingFrequency.fortnightly => occurrence.add(
            const Duration(days: 14),
          ),
        BookingFrequency.monthly => _addMonths(start, ++monthOffset),
      };
      if (occurrence.isAfter(_availabilityEnd)) break;
      yield occurrence;
    }
  }

  DateTime _addMonths(DateTime date, int months) {
    final monthIndex = date.month - 1 + months;
    final year = date.year + monthIndex ~/ 12;
    final month = monthIndex % 12 + 1;
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final day = date.day > daysInMonth ? daysInMonth : date.day;
    return DateTime(year, month, day);
  }

  Timeslot? _matchingSlot(DateTime date, Timeslot selectedSlot) {
    for (final slot in _availableSlots) {
      if (DateUtils.isSameDay(DateTime.parse(slot.date), date) &&
          slot.startTime == selectedSlot.startTime &&
          slot.endTime == selectedSlot.endTime) {
        return slot;
      }
    }
    return null;
  }

  Future<void> _submit() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final therapist = _selectedTherapist;
    final room = _selectedRoom;
    final slots = _bookingSlots;
    if (userId == null ||
        therapist == null ||
        room == null ||
        slots.isEmpty ||
        _submitting) {
      return;
    }

    setState(() => _submitting = true);
    try {
      await _bookingRepository.createBookings(
        userId: userId,
        therapistId: therapist.id,
        roomId: room.id,
        timeslotIds: [for (final slot in slots) slot.id],
        recurrenceType: _frequency.name,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).bookingCreated)),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _frequencyLabel(AppLocalizations l10n, BookingFrequency frequency) {
    return switch (frequency) {
      BookingFrequency.single => l10n.singleBooking,
      BookingFrequency.weekly => l10n.weeklyBooking,
      BookingFrequency.fortnightly => l10n.fortnightlyBooking,
      BookingFrequency.monthly => l10n.monthlyBooking,
    };
  }

  String _timeRange(MaterialLocalizations materialL10n, Timeslot slot) {
    final start = _slotStart(slot);
    final end = DateTime.parse('${slot.date}T${slot.endTime}');
    return '${materialL10n.formatTimeOfDay(TimeOfDay.fromDateTime(start))} - '
        '${materialL10n.formatTimeOfDay(TimeOfDay.fromDateTime(end))}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final materialL10n = MaterialLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addBooking)),
      body: FutureBuilder<_BookingOptions>(
        future: _optionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return _OptionsLoadError(
              message: l10n.bookingOptionsLoadError,
              retryLabel: l10n.retry,
              onRetry: () {
                setState(() => _optionsFuture = _loadOptions());
              },
            );
          }

          final options = snapshot.data!;
          final availableDates = _availableDates;
          final selectedDateSlots = _slotsForSelectedDate;
          final bookingSlots = _bookingSlots;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              Text(
                l10n.bookingType,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SegmentedButton<BookingFrequency>(
                segments: [
                  for (final frequency in BookingFrequency.values)
                    ButtonSegment(
                      value: frequency,
                      label: Text(_frequencyLabel(l10n, frequency)),
                    ),
                ],
                selected: {_frequency},
                onSelectionChanged: (selection) {
                  setState(() => _frequency = selection.first);
                },
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<Therapist>(
                initialValue: _selectedTherapist,
                decoration: InputDecoration(
                  labelText: l10n.selectTherapist,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  for (final therapist in options.therapists)
                    DropdownMenuItem(
                      value: therapist,
                      child: Text(therapist.name),
                    ),
                ],
                onChanged: (therapist) {
                  setState(() => _selectedTherapist = therapist);
                  _loadAvailability();
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Room>(
                initialValue: _selectedRoom,
                decoration: InputDecoration(
                  labelText: l10n.selectRoom,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  for (final room in options.rooms)
                    DropdownMenuItem(
                      value: room,
                      child: Text(
                        room.department == null
                            ? room.name
                            : '${room.name} · ${room.department}',
                      ),
                    ),
                ],
                onChanged: (room) {
                  setState(() => _selectedRoom = room);
                  _loadAvailability();
                },
              ),
              const SizedBox(height: 24),
              Text(
                l10n.selectDate,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    if (_selectedTherapist == null || _selectedRoom == null)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          l10n.chooseTherapistAndRoom,
                          textAlign: TextAlign.center,
                        ),
                      )
                    else if (_loadingAvailability)
                      const Padding(
                        padding: EdgeInsets.all(48),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_availabilityFailed)
                      _InlineError(
                        message: l10n.availabilityLoadError,
                        retryLabel: l10n.retry,
                        onRetry: _loadAvailability,
                      )
                    else ...[
                      CalendarDatePicker(
                        key: ValueKey(
                          '${_selectedTherapist?.id}-${_selectedRoom?.id}',
                        ),
                        initialDate:
                            availableDates.isEmpty
                                ? DateUtils.dateOnly(DateTime.now())
                                : availableDates.reduce(
                                    (a, b) => a.isBefore(b) ? a : b,
                                  ),
                        firstDate: DateUtils.dateOnly(DateTime.now()),
                        lastDate: _availabilityEnd,
                        currentDate: DateUtils.dateOnly(DateTime.now()),
                        selectableDayPredicate: availableDates.contains,
                        onDateChanged: (date) {
                          setState(() {
                            _selectedDate = date;
                            _selectedSlot = null;
                          });
                        },
                      ),
                      if (availableDates.isEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: Text(
                            l10n.noAvailableDates,
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.selectTime,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (_selectedDate == null)
                Text(l10n.selectDateFirst)
              else if (selectedDateSlots.isEmpty)
                Text(l10n.noTimeslotsForDate)
              else
                Column(
                  children: [
                    for (final slot in selectedDateSlots)
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          selected: _selectedSlot?.id == slot.id,
                          leading: Icon(
                            _selectedSlot?.id == slot.id
                                ? Icons.check_circle
                                : Icons.schedule_outlined,
                          ),
                          title: Text(_timeRange(materialL10n, slot)),
                          subtitle: Text(
                            l10n.spacesRemaining(
                              slot.capacity - slot.usedCount,
                            ),
                          ),
                          onTap: () => setState(() => _selectedSlot = slot),
                        ),
                      ),
                  ],
                ),
              if (_frequency != BookingFrequency.single &&
                  _selectedSlot != null) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.recurringAvailabilityNote(_availabilityDays),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed:
                      _submitting || bookingSlots.isEmpty ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: Text(l10n.bookingSessions(bookingSlots.length)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BookingOptions {
  const _BookingOptions({required this.therapists, required this.rooms});

  final List<Therapist> therapists;
  final List<Room> rooms;
}

class _OptionsLoadError extends StatelessWidget {
  const _OptionsLoadError({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _InlineError(
          message: message,
          retryLabel: retryLabel,
          onRetry: onRetry,
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: Text(retryLabel),
        ),
      ],
    );
  }
}
