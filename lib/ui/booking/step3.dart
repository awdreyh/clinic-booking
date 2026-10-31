import 'package:flutter/material.dart';

import '../../data/model/service.dart';
import '../../data/model/timeslot.dart';
import 'booking_step_shared.dart';

class BookingStep3 extends StatelessWidget {
  const BookingStep3({
    super.key,
    required this.service,
    required this.collectionName,
    required this.priceOption,
    required this.extraTime,
    required this.date,
    required this.slots,
    required this.selectedSlot,
    required this.onDateChanged,
    required this.onSlotSelected,
  });

  final Service? service;
  final String? collectionName;
  final BookingPriceOption? priceOption;
  final BookingPriceOption? extraTime;
  final DateTime date;
  final List<Timeslot> slots;
  final Timeslot? selectedSlot;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<Timeslot> onSlotSelected;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          BookingServiceSummary(
            service: service,
            collectionName: collectionName,
            priceOption: priceOption,
            extraTime: extraTime,
          ),
          const SizedBox(height: 12),
          CalendarDatePicker(
            initialDate: date,
            firstDate: DateUtils.dateOnly(DateTime.now()),
            lastDate: DateUtils.dateOnly(
              DateTime.now().add(const Duration(days: 365)),
            ),
            onDateChanged: onDateChanged,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              'Available times',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          if (slots.isEmpty)
            const BookingEmptyState(
              message: 'No available times on this date. Choose another day.',
            ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final slot in slots)
                ChoiceChip(
                  label: Text(formatBookingTimeRange(context, slot)),
                  selected: selectedSlot?.startTime == slot.startTime,
                  onSelected: (_) => onSlotSelected(slot),
                ),
            ],
          ),
        ],
      );
}
