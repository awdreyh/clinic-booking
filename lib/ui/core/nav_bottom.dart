import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../dashboard/admin_dashboard.dart';
import '../dashboard/therapist_dashboard.dart';
import '../therapist/list.dart';
import '../user/dashboard.dart';
import 'app_theme.dart';

/// Routes signed-in users to the dashboard for their profile role.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late Future<String> _roleFuture;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _roleFuture = _fetchRole();
  }

  Future<String> _fetchRole() async {
    final id = Supabase.instance.client.auth.currentUser?.id;
    if (id == null) return 'customer';
    final profile = await Supabase.instance.client
        .from('user')
        .select('role')
        .eq('id', id)
        .maybeSingle();
    final role = profile?['role']?.toString() ?? 'customer';
    return const {'customer', 'therapist', 'admin'}.contains(role)
        ? role
        : 'customer';
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
        future: _roleFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(title: const Text('Account')),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Could not load your account role.'),
                    TextButton(
                      onPressed: () => setState(() => _roleFuture = _fetchRole()),
                      child: const Text('Retry'),
                    ),
                    TextButton(
                      onPressed: () => Supabase.instance.client.auth.signOut(),
                      child: const Text('Sign out'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          final role = snapshot.data!;
          final pages = switch (role) {
            'therapist' => <Widget>[
                TherapistDashboard(
                  therapistId: Supabase.instance.client.auth.currentUser!.id,
                ),
              ],
            'admin' => <Widget>[const AdminDashboard()],
            _ => <Widget>[const TherapistListPage(), const CustomerDashboard()],
          };
          final labels = role == 'customer'
              ? const ['Therapists', 'My bookings']
              : const ['Dashboard'];
          final icons = role == 'customer'
              ? const [Icons.medical_services_outlined, Icons.event_note_outlined]
              : const [Icons.dashboard_outlined];
          if (role != 'customer') return pages.single;
          final activeIndex = _index >= pages.length ? pages.length - 1 : _index;

          return Scaffold(
            body: IndexedStack(index: activeIndex, children: pages),
            bottomNavigationBar: NavigationBar(
              selectedIndex: activeIndex,
              onDestinationSelected: (index) => setState(() => _index = index),
              backgroundColor: AppColors.espresso,
              indicatorColor: AppColors.accent,
              destinations: [
                for (var i = 0; i < labels.length; i++)
                  NavigationDestination(
                    icon: Icon(icons[i], color: AppColors.textOnDarkMuted),
                    selectedIcon: Icon(icons[i], color: Colors.white),
                    label: labels[i],
                  ),
              ],
            ),
          );
        },
      );
}
