import 'package:flutter/material.dart';

import '../../data/model/service.dart';
import '../../data/model/timeslot.dart';
import '../../data/model/user.dart';
import 'booking_step_shared.dart';

class BookingStep4 extends StatelessWidget {
  const BookingStep4({
    super.key,
    required this.service,
    required this.therapist,
    required this.date,
    required this.slot,
    required this.priceOption,
  });

  final Service service;
  final User therapist;
  final DateTime date;
  final Timeslot slot;
  final BookingPriceOption? priceOption;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Review your appointment',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          BookingSummaryTile(
            icon: Icons.spa_outlined,
            label: 'Service',
            value: service.name,
          ),
          if (priceOption != null)
            BookingSummaryTile(
              icon: Icons.timelapse,
              label: 'Duration',
              value: priceOption!.label,
            ),
          BookingSummaryTile(
            icon: Icons.person_outline,
            label: 'Therapist',
            value: therapist.name,
          ),
          BookingSummaryTile(
            icon: Icons.calendar_month_outlined,
            label: 'Date & time',
            value: '${MaterialLocalizations.of(context).formatMediumDate(date)} · ${formatBookingTimeRange(context, slot)}',
          ),
          if (priceOption != null)
            BookingSummaryTile(
              icon: Icons.payments_outlined,
              label: 'Total',
              value: priceOption!.priceLabel,
            ),
          const SizedBox(height: 16),
          const Text(
            'Your booking will be sent as a pending request. Payment options are shown after confirmation.',
          ),
        ],
      );
}
