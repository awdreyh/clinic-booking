import 'package:flutter/material.dart';

import '../../data/model/booking.dart';
import '../../data/model/user.dart';
import '../../data/repository/booking.dart';
import '../../data/repository/user.dart';
import '../../l10n/app_localizations.dart';
import 'dashboard_widgets.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _bookings = BookingRepository();
  final _users = UserRepository();
  late Future<({List<Booking> bookings, List<User> users})> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<({List<Booking> bookings, List<User> users})> _load() async {
    final results = await Future.wait([
      _bookings.fetchBookings(),
      _users.fetchUsers(),
    ]);
    return (
      bookings: results[0] as List<Booking>,
      users: results[1] as List<User>,
    );
  }

  Future<void> _reload() async {
    final future = _load();
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
        title: l10n.tr('Admin dashboard'),
        child: FutureBuilder<({List<Booking> bookings, List<User> users})>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return DashboardLoadError(error: snapshot.error!);
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data!;
            final therapists =
                data.users.where((user) => user.role == 'therapist').length;
            final customers =
                data.users.where((user) => user.role == 'customer').length;
            final pending =
                data.bookings.where((booking) => booking.status == 'pending').length;

            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: l10n.tr('Customers'),
                          value: '$customers',
                          icon: Icons.people_outline,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatCard(
                          label: l10n.tr('Therapists'),
                          value: '$therapists',
                          icon: Icons.medical_services_outlined,
                        ),
                      ),
                    ],
                  ),
                  StatCard(
                    label: l10n.tr('Pending bookings'),
                    value: '$pending',
                    icon: Icons.pending_actions,
                  ),
                  const SizedBox(height: 20),
                  Text(l10n.tr('Bookings'), style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  if (data.bookings.isEmpty)
                    ListTile(title: Text(l10n.tr('No bookings yet.'))),
                  for (final booking in data.bookings)
                    BookingCard(
                      booking: booking,
                      onAccept: booking.status == 'pending'
                          ? () => _setStatus(booking, 'booked')
                          : null,
                      onCancel: booking.status != 'cancelled'
                          ? () => _setStatus(booking, 'cancelled')
                          : null,
                    ),
                  const SizedBox(height: 20),
                  Text(l10n.tr('Users'), style: Theme.of(context).textTheme.titleLarge),
                  for (final user in data.users)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.person_outline),
                      title: Text(user.name),
                      subtitle: Text('${user.email} · ${l10n.tr(user.role)}'),
                    ),
                ],
              ),
            );
          },
        ),
      );
  }
}
