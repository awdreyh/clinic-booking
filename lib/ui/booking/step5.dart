import 'package:flutter/material.dart';

import '../../data/model/service.dart';
import '../../data/model/timeslot.dart';
import '../../data/model/user.dart';
import 'booking_step_shared.dart';

class BookingStep5 extends StatelessWidget {
  const BookingStep5({
    super.key,
    required this.service,
    required this.therapist,
    required this.date,
    required this.slot,
    required this.priceOption,
    required this.extraTime,
    required this.totalPrice,
  });

  final Service service;
  final User? therapist;
  final DateTime date;
  final Timeslot slot;
  final BookingPriceOption? priceOption;
  final BookingPriceOption? extraTime;
  final double? totalPrice;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const Icon(Icons.verified_outlined, size: 64),
      const SizedBox(height: 16),
      Text(
        'Ready to confirm?',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 8),
      const Text(
        'Confirming creates your booking request and opens the payment step.',
      ),
      const SizedBox(height: 20),
      BookingSummaryTile(
        icon: Icons.spa_outlined,
        label: 'Service',
        value: service.name,
      ),
      BookingSummaryTile(
        icon: Icons.person_outline,
        label: 'Therapist',
        value: therapist?.name ?? 'No preference',
      ),
      if (extraTime != null)
        BookingSummaryTile(
          icon: Icons.more_time,
          label: 'Extra time',
          value: '+${extraTime!.duration} min · ${extraTime!.priceLabel}',
        ),
      BookingSummaryTile(
        icon: Icons.calendar_month_outlined,
        label: 'Appointment',
        value:
            '${MaterialLocalizations.of(context).formatMediumDate(date)} · ${formatBookingTimeRange(context, slot)}',
      ),
      if (totalPrice != null)
        BookingSummaryTile(
          icon: Icons.payments_outlined,
          label: 'Due',
          value: '\$${totalPrice!.toStringAsFixed(0)}',
        ),
    ],
  );
}
