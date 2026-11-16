import 'package:flutter/material.dart';

import '../../data/model/service.dart';
import '../../data/model/timeslot.dart';
import '../../data/model/user.dart';
import '../../l10n/app_localizations.dart';
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const Icon(Icons.verified_outlined, size: 64),
      const SizedBox(height: 16),
      Text(
        l10n.tr('Ready to confirm?'),
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 8),
       Text(
        l10n.tr('Confirming creates your booking request and opens the payment step.'),
      ),
      const SizedBox(height: 20),
      BookingSummaryTile(
        icon: Icons.spa_outlined,
        label: l10n.tr('Service'),
        value: service.name,
      ),
      BookingSummaryTile(
        icon: Icons.person_outline,
        label: l10n.tr('Therapist'),
        value: therapist?.name ?? l10n.tr('No preference'),
      ),
      if (extraTime != null)
        BookingSummaryTile(
          icon: Icons.more_time,
          label: l10n.tr('Extra time'),
          value: '+${extraTime!.duration} min Â· ${extraTime!.priceLabel}',
        ),
      BookingSummaryTile(
        icon: Icons.calendar_month_outlined,
        label: l10n.tr('Appointment'),
        value:
            '${MaterialLocalizations.of(context).formatMediumDate(date)} Â· ${formatBookingTimeRange(context, slot)}',
      ),
      if (totalPrice != null)
        BookingSummaryTile(
          icon: Icons.payments_outlined,
          label: l10n.tr('Due'),
          value: '\$${totalPrice!.toStringAsFixed(0)}',
        ),
    ],
  );
}
}

