import 'package:flutter/material.dart';

import '../therapist/list.dart';
import '../user/login.dart';
import '../core/welcome_page.dart';

class GuestDashboard extends StatelessWidget {
  const GuestDashboard({super.key});

  void _openAuth(BuildContext context, {bool createAccount = false}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AuthScreen(initialSignUp: createAccount),
      ),
    );
  }

  void _browseTherapists(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TherapistListPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back to welcome page',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const WelcomePage()),
          ),
        ),
        title: const Text('Clinic Booking'),
        actions: [
          TextButton(
            onPressed: () => _openAuth(context),
            child: const Text('Sign in'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.spa_outlined, size: 42, color: colors.primary),
                  const SizedBox(height: 24),
                  Text(
                    'Care that fits your day.',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: colors.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Explore our therapists and find a time that works for you.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colors.onPrimaryContainer,
                        ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _browseTherapists(context),
                      icon: const Icon(Icons.search),
                      label: const Text('Browse therapists'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _openAuth(context, createAccount: true),
                      child: const Text('Create an account'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Book with confidence',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.people_outline),
              title: Text('Meet our therapists'),
              subtitle: Text('View therapist profiles and available services.'),
            ),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.event_available_outlined),
              title: Text('Choose a convenient time'),
              subtitle: Text('Browse available appointment times before signing in.'),
            ),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.bookmark_outline),
              title: Text('Manage your bookings'),
              subtitle: Text('Sign in to request and keep track of appointments.'),
            ),
          ],
        ),
      ),
    );
  }
}
