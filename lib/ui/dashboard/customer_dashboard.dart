import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../l10n/app_localizations.dart';
import '../booking/add.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  late Future<List<_UpcomingBooking>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _bookingsFuture = _fetchUpcomingBookings();
  }

  Future<List<_UpcomingBooking>> _fetchUpcomingBookings() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return [];

    final rows = await Supabase.instance.client
        .from('booking')
        .select('therapist_id, service_id, booking_date, start_time, end_time')
        .eq('customer_id', user.id)
        .inFilter('status', ['booked', 'pending']);

    final therapistIds = rows
        .map((row) => row['therapist_id'])
        .whereType<String>()
        .toSet()
        .toList();
    final serviceIds = rows
        .map((row) => row['service_id'])
        .whereType<num>()
        .map((id) => id.toInt())
        .toSet()
        .toList();
    final therapistNames = <String, String>{};
    final serviceNames = <int, String>{};
    if (therapistIds.isNotEmpty) {
      final therapists = await Supabase.instance.client
          .from('user')
          .select('id, name')
          .inFilter('id', therapistIds);
      for (final therapist in therapists) {
        therapistNames[therapist['id'] as String] =
            therapist['name']?.toString() ?? '';
      }
    }
    if (serviceIds.isNotEmpty) {
      final services = await Supabase.instance.client
          .from('service')
          .select('id, name')
          .inFilter('id', serviceIds);
      for (final service in services) {
        serviceNames[(service['id'] as num).toInt()] =
            service['name']?.toString() ?? '';
      }
    }

    final now = DateTime.now();
    final bookings = <_UpcomingBooking>[];
    for (final row in rows) {
      final date = row['booking_date']?.toString();
      final startTime = row['start_time']?.toString();
      final endTime = row['end_time']?.toString();
      if (date == null || startTime == null || endTime == null) continue;

      final startAt = DateTime.parse('${date}T$startTime');
      if (!startAt.isAfter(now)) continue;

      bookings.add(
        _UpcomingBooking(
          therapistName:
              therapistNames[row['therapist_id']?.toString()] ?? 'Therapist',
          serviceName: serviceNames[(row['service_id'] as num?)?.toInt()],
          startAt: startAt,
          endAt: DateTime.parse('${date}T$endTime'),
        ),
      );
    }

    bookings.sort((a, b) => a.startAt.compareTo(b.startAt));
    return bookings;
  }

  Future<void> _refreshBookings() async {
    final future = _fetchUpcomingBookings();
    setState(() {
      _bookingsFuture = future;
    });
    try {
      await future;
    } catch (_) {
      // FutureBuilder renders the error state.
    }
  }

  Future<void> _openBooking() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const BookingConfirmPage()),
    );
    if (mounted) await _refreshBookings();
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final l10n = AppLocalizations.of(context);
    final name = user?.userMetadata?['name']?.toString().trim();
    final greetingName = name == null || name.isEmpty
        ? user?.email?.split('@').first
        : name;
    final materialL10n = MaterialLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myBookings),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.signOut,
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<_UpcomingBooking>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          final bookings = snapshot.data ?? const <_UpcomingBooking>[];
          return RefreshIndicator(
            onRefresh: _refreshBookings,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              children: [
                Text(
                  greetingName == null
                      ? l10n.welcomeUser
                      : '${l10n.welcomeUser} $greetingName',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 28),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (snapshot.hasError)
                  _LoadError(
                    message: l10n.bookingLoadError,
                    retryLabel: l10n.retry,
                    onRetry: _refreshBookings,
                  )
                else ...[
                  Text(
                    l10n.nextBooking,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  if (bookings.isEmpty)
                    _EmptyBookings(message: l10n.noUpcomingBookings)
                  else
                    _NextBookingCard(
                      booking: bookings.first,
                      dateLabel: materialL10n.formatMediumDate(
                        bookings.first.startAt,
                      ),
                      timeLabel: _formatTimeRange(
                        materialL10n,
                        bookings.first.startAt,
                        bookings.first.endAt,
                      ),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _openBooking,
                      icon: const Icon(Icons.add),
                      label: Text(l10n.addBooking),
                    ),
                  ),
                  if (bookings.length > 1) ...[
                    const SizedBox(height: 32),
                    Text(
                      l10n.otherUpcomingBookings,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    for (final booking in bookings.skip(1))
                      _BookingListTile(
                        booking: booking,
                        dateLabel: materialL10n.formatMediumDate(
                          booking.startAt,
                        ),
                        timeLabel: _formatTimeRange(
                          materialL10n,
                          booking.startAt,
                          booking.endAt,
                        ),
                      ),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

String _formatTimeRange(
  MaterialLocalizations localizations,
  DateTime startAt,
  DateTime endAt,
) {
  return '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(startAt))} - '
      '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(endAt))}';
}

class _UpcomingBooking {
  const _UpcomingBooking({
    required this.therapistName,
    this.serviceName,
    required this.startAt,
    required this.endAt,
  });

  final String therapistName;
  final String? serviceName;
  final DateTime startAt;
  final DateTime endAt;
}

class _NextBookingCard extends StatelessWidget {
  const _NextBookingCard({
    required this.booking,
    required this.dateLabel,
    required this.timeLabel,
  });

  final _UpcomingBooking booking;
  final String dateLabel;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: colors.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.event_available, color: colors.onPrimaryContainer),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.therapistName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colors.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (booking.serviceName case final serviceName?)
                    Text(serviceName),
                  const SizedBox(height: 12),
                  Text('$dateLabel · $timeLabel'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingListTile extends StatelessWidget {
  const _BookingListTile({
    required this.booking,
    required this.dateLabel,
    required this.timeLabel,
  });

  final _UpcomingBooking booking;
  final String dateLabel;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.calendar_month_outlined),
      title: Text(booking.therapistName),
      subtitle: Text('$dateLabel · $timeLabel'),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 40,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({
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
