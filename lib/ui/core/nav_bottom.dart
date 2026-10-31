import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../l10n/app_localizations.dart';
import '../dashboard/admin_dashboard.dart';
import '../dashboard/therapist_dashboard.dart';
import '../user/profile.dart';
import '../therapist/list.dart';
import '../dashboard/customer_dashboard.dart';
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
          final l10n = AppLocalizations.of(context);
          final pages = switch (role) {
            'therapist' => <Widget>[
                TherapistDashboard(
                  therapistId: Supabase.instance.client.auth.currentUser!.id,
                ),
                const ProfilePage(role: 'therapist'),
              ],
            'admin' => <Widget>[
                const AdminDashboard(),
                const ProfilePage(role: 'admin'),
              ],
            _ => <Widget>[
                CustomerHomePage(
                  onViewBookings: () => setState(() => _index = 1),
                ),
                const CustomerDashboard(),
                const ProfilePage(role: 'customer'),
              ],
          };
          final isChinese = Localizations.localeOf(context).languageCode == 'zh';
          final labels = switch (role) {
            'customer' => [
                isChinese ? '首页' : 'Dashboard',
                l10n.myBookings,
                l10n.navProfile,
              ],
            'therapist' => ['Dashboard', l10n.navProfile],
            _ => ['Dashboard', l10n.navProfile],
          };
          final icons = switch (role) {
            'customer' => const [
                Icons.home_outlined,
                Icons.event_note_outlined,
                Icons.person_outline,
              ],
            _ => const [Icons.dashboard_outlined, Icons.person_outline],
          };
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

class CustomerHomePage extends StatelessWidget {
  const CustomerHomePage({super.key, required this.onViewBookings});

  final VoidCallback onViewBookings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = Supabase.instance.client.auth.currentUser;
    final metadataName = user?.userMetadata?['name']?.toString().trim();
    final name = metadataName == null || metadataName.isEmpty
        ? user?.email?.split('@').first
        : metadataName;
    final isChinese = Localizations.localeOf(context).languageCode == 'zh';

    return Scaffold(
      appBar: AppBar(title: Text(isChinese ? '首页' : 'Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            name == null ? l10n.welcomeUser : '${l10n.welcomeUser} $name',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            isChinese ? '为您的身心健康找到合适的护理。' : 'Find thoughtful care for your wellbeing.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.spa_outlined, size: 36, color: AppColors.accentDark),
                  const SizedBox(height: 16),
                  Text(
                    isChinese ? '预约您的下一次护理' : 'Plan your next visit',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TherapistListPage()),
                      ),
                      icon: const Icon(Icons.search),
                      label: Text(l10n.addBooking),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onViewBookings,
                      icon: const Icon(Icons.event_note_outlined),
                      label: Text(l10n.myBookings),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
