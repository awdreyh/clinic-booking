import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../../data/model/service.dart';
import '../../data/model/timeslot.dart';
import '../../data/model/user.dart';
import '../../data/repository/booking.dart';
import '../../l10n/app_localizations.dart';

class BookingConfirmPage extends StatefulWidget {
  const BookingConfirmPage({
    super.key,
    required this.therapist,
    required this.timeslot,
    this.service,
  });

  final User therapist;
  final Timeslot timeslot;
  final Service? service;

  @override
  State<BookingConfirmPage> createState() => _BookingConfirmPageState();
}

class _BookingConfirmPageState extends State<BookingConfirmPage> {
  final _bookingRepository = BookingRepository();
  bool _saving = false;

  Future<void> _confirm() async {
    final l10n = AppLocalizations.of(context);
    final customerId = Supabase.instance.client.auth.currentUser?.id;
    if (_saving) return;
    if (customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tr('Sign in to request a booking.'))),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await _bookingRepository.createBooking(
        customerId: customerId,
        therapistId: widget.therapist.id,
        bookingDate: widget.timeslot.date,
        startTime: widget.timeslot.startTime,
        endTime: widget.timeslot.endTime,
        serviceId: widget.service?.id,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tr('Booking request sent.'))),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.tr('Could not create booking: {error}', {'error': error}))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final l10n = AppLocalizations.of(context);
    final start = DateTime.parse(
      '${widget.timeslot.date}T${widget.timeslot.startTime}',
    );
    final end = DateTime.parse(
      '${widget.timeslot.date}T${widget.timeslot.endTime}',
    );
    String time(DateTime date) => localizations.formatTimeOfDay(
          TimeOfDay.fromDateTime(date),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tr('Confirm booking'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(widget.therapist.name,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today_outlined),
            title: Text(localizations.formatMediumDate(start)),
            subtitle: Text('${time(start)} â€“ ${time(end)}'),
          ),
          if (widget.service != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.medical_services_outlined),
              title: Text(widget.service!.nameFor(l10n.localeName)),
              subtitle: widget.service!.descriptionFor(l10n.localeName) == null
                  ? null
                  : Text(widget.service!.descriptionFor(l10n.localeName)!),
            ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _confirm,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.tr('Confirm booking')),
          ),
        ],
      ),
    );
  }
}
