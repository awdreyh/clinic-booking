import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../booking/add.dart';

/// Customer dashboard built from the Enso Space homepage content.
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F5),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Hero(
            name: name,
            l10n: l10n,
            bookingsLabel: l10n.myBookings,
            onViewBookings: onViewBookings,
          ),
          EnsoPillars(l10n: l10n),
          EnsoVisitUs(l10n: l10n),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.name,
    required this.l10n,
    required this.bookingsLabel,
    required this.onViewBookings,
  });

  final String? name;
  final AppLocalizations l10n;
  final String bookingsLabel;
  final VoidCallback onViewBookings;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 460,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/enso-bg.jpg', fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x591C2418), Color(0xD91C2418)],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'assets/enso-logo.png',
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'ENSO SPACE · 渊心.养身',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    l10n.tr('Massage. Beauty. Tea'),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          height: 1.1,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.tr('A sanctuary of energy, nature, serenity and oneness.'),
                    style: const TextStyle(
                      color: Color(0xFFE7EAE0),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  if (name != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      l10n.tr('Welcome back, {name}', {'name': name}),
                      style: const TextStyle(
                        color: Color(0xFFB9C697),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const BookingConfirmPage(),
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFB9C697),
                        foregroundColor: const Color(0xFF30372B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.spa_outlined),
                      label: Text(
                        l10n.tr('Book now'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: onViewBookings,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.event_note_outlined, size: 18),
                      label: Text(bookingsLabel),
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

class EnsoPillars extends StatelessWidget {
  const EnsoPillars({super.key, required this.l10n});

  final AppLocalizations l10n;

  static const _pillars = [
    (
      icon: Icons.spa_outlined,
      title: 'Massage',
      body: 'Rooted in Chinese Meridian Theory — both relaxation and true physical recovery.',
    ),
    (
      icon: Icons.face_retouching_natural,
      title: 'Beauty',
      body: 'Beauty flows naturally from balance — our treatments help your face reflect your inner harmony.',
    ),
    (
      icon: Icons.emoji_food_beverage_outlined,
      title: 'Tea',
      body: 'A bridge between people, cultures and a peaceful state of mind.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.tr('ABOUT US'),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Color(0xFF4A5D3E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.tr('Three ways to unwind'),
            style: const TextStyle(
              fontSize: 24,
              color: Color(0xFF30372B),
            ),
          ),
          const SizedBox(height: 16),
          for (final pillar in _pillars)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E0D5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEF1E7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(pillar.icon, color: const Color(0xFF4A5D3E)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.tr(pillar.title),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Color(0xFF30372B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const SizedBox(height: 6),
                        Text(
                          l10n.tr(pillar.body),
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.55,
                            color: Color(0xFF797A6F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class EnsoVisitUs extends StatelessWidget {
  const EnsoVisitUs({super.key, required this.l10n});

  final AppLocalizations l10n;

  Future<void> _open(String uri) async {
    await launchUrl(Uri.parse(uri));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF30372B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.tr('VISIT US'),
            style: const TextStyle(
              color: Color(0xFFB9C697),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          _ContactRow(
            icon: Icons.place_outlined,
            title: 'Enso Space 渊心.养身',
            subtitle: '1/17 Remuera Road, Newmarket, Auckland',
            onTap: () => _open(
              'https://maps.google.com/?q=1/17 Remuera Road, Newmarket, Auckland',
            ),
          ),
          _ContactRow(
            icon: Icons.phone_outlined,
            title: '022 185 8228',
            subtitle: l10n.tr('English / 中文'),
            onTap: () => _open('tel:0221858228'),
          ),
          _ContactRow(
            icon: Icons.mail_outline,
            title: 'info@ensospace.co.nz',
            subtitle: l10n.tr('Send us a message'),
            onTap: () => _open('mailto:info@ensospace.co.nz'),
          ),
          _ContactRow(
            icon: Icons.schedule_outlined,
            title: l10n.tr('Open every day'),
            subtitle: l10n.tr('9:00 am – 9:00 pm'),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFFB9C697)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFFC9CFC0),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.arrow_outward,
                size: 16,
                color: Color(0xFFB9C697),
              ),
          ],
        ),
      ),
    );
  }
}
