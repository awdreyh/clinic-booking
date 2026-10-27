import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/model/booking.dart';

class DashboardScaffold extends StatelessWidget {
  const DashboardScaffold({required this.title, required this.child, super.key});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [
            IconButton(
              tooltip: 'Sign out',
              icon: const Icon(Icons.logout),
              onPressed: () => Supabase.instance.client.auth.signOut(),
            ),
          ],
        ),
        body: child,
      );
}

class BookingCard extends StatelessWidget {
  const BookingCard({required this.booking, this.onAccept, this.onCancel, super.key});

  final Booking booking;
  final VoidCallback? onAccept;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final date = booking.bookingDate ?? 'Date unavailable';
    final time = '${booking.startTime ?? '--:--'} – ${booking.endTime ?? '--:--'}';
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.event_note_outlined),
              title: Text('$date · $time'),
              subtitle: Text(
                'Customer ${booking.customerId ?? '-'} · ${booking.status}',
              ),
            ),
            if (onAccept != null || onCancel != null)
              ButtonBar(
                children: [
                  if (onCancel != null)
                    TextButton(onPressed: onCancel, child: const Text('Cancel')),
                  if (onAccept != null)
                    FilledButton(onPressed: onAccept, child: const Text('Confirm')),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(icon, size: 28),
              const SizedBox(width: 14),
              Expanded(child: Text(label)),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
      );
}

class DashboardLoadError extends StatelessWidget {
  const DashboardLoadError({required this.error, super.key});

  final Object error;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Could not load dashboard: $error'),
        ),
      );
}
