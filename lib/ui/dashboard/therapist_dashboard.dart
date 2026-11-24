import 'package:flutter/material.dart';

import '../../data/model/booking.dart';
import '../../data/repository/booking.dart';
import '../../l10n/app_localizations.dart';
import 'dashboard_widgets.dart';

class TherapistDashboard extends StatefulWidget {
  const TherapistDashboard({super.key, required this.therapistId});

  final String therapistId;

  @override
  State<TherapistDashboard> createState() => _TherapistDashboardState();
}

class _TherapistDashboardState extends State<TherapistDashboard> {
  final _bookings = BookingRepository();
  late Future<List<Booking>> _future;

  @override
  void initState() {
    super.initState();
    _future = _bookings.fetchBookings(therapistId: widget.therapistId);
  }

  Future<void> _reload() async {
    final future = _bookings.fetchBookings(therapistId: widget.therapistId);
    setState(() => _future = future);
    await future;
  }

  Future<void> _setStatus(Booking booking, String status) async {
    try {
      await _bookings.updateStatus(id: booking.id, status: status);
      await _reload();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).tr(
            'Could not update booking: {error}', {'error': error},
          ))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DashboardScaffold(
        title: l10n.tr('Therapist dashboard'),
        child: FutureBuilder<List<Booking>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return DashboardLoadError(error: snapshot.error!);
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final bookings = snapshot.data!;
            final pending = bookings.where((b) => b.status == 'pending').length;
            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  StatCard(
                    label: l10n.tr('Pending requests'),
                    value: '$pending',
                    icon: Icons.pending_actions,
                  ),
                  const SizedBox(height: 20),
                  Text(l10n.tr('Bookings'), style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  if (bookings.isEmpty)
                    ListTile(title: Text(l10n.tr('No bookings yet.'))),
                  for (final booking in bookings)
                    BookingCard(
                      booking: booking,
                      onAccept: booking.status == 'pending'
                          ? () => _setStatus(booking, 'booked')
                          : null,
                      onCancel: booking.status != 'cancelled'
                          ? () => _setStatus(booking, 'cancelled')
                          : null,
                    ),
                ],
              ),
            );
          },
        ),
      );
  }
}
