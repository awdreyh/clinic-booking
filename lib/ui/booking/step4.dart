import 'package:flutter/material.dart';

import '../../data/model/service.dart';
import '../../data/model/timeslot.dart';
import '../../data/model/user.dart';
import '../../l10n/app_localizations.dart';
import 'booking_step_shared.dart';

class BookingStep4 extends StatelessWidget {
  const BookingStep4({
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
      Text(
        l10n.tr('Review your appointment'),
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 12),
      BookingSummaryTile(
        icon: Icons.spa_outlined,
        label: l10n.tr('Service'),
        value: service.nameFor(l10n.localeName),
      ),
      if (priceOption != null)
        BookingSummaryTile(
          icon: Icons.timelapse,
          label: l10n.tr('Duration'),
          value: priceOption!.labelFor(l10n),
        ),
      if (extraTime != null)
        BookingSummaryTile(
          icon: Icons.more_time,
          label: l10n.tr('Extra time'),
          value: '+${extraTime!.duration} min · ${extraTime!.priceLabel}',
        ),
      BookingSummaryTile(
        icon: Icons.person_outline,
        label: l10n.tr('Therapist'),
        value: therapist?.name ?? l10n.tr('No preference'),
      ),
      BookingSummaryTile(
        icon: Icons.calendar_month_outlined,
        label: l10n.tr('Date & time'),
        value:
            '${MaterialLocalizations.of(context).formatMediumDate(date)} · ${formatBookingTimeRange(context, slot)}',
      ),
      if (totalPrice != null)
        BookingSummaryTile(
          icon: Icons.payments_outlined,
          label: l10n.tr('Total'),
          value: '\$${totalPrice!.toStringAsFixed(0)}',
        ),
      const SizedBox(height: 16),
      Text(
        l10n.tr('Your booking will be sent as a pending request. Payment options are shown after confirmation.'),
      ),
    ],
  );
}
}

