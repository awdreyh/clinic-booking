import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/model/category.dart';
import '../../data/model/service.dart';
import '../../data/repository/category.dart';
import '../../data/repository/service.dart';
import '../../l10n/app_localizations.dart';
import '../core/welcome_page.dart';
import '../therapist/list.dart';
import '../user/login.dart';
import 'customer_home.dart';

typedef _ServiceCatalog = ({
  List<Category> categories,
  List<Service> services,
  Map<int, double> startingPrices,
  Map<int, double> startingMemberPrices,
});

/// Guest landing page mirroring the signed-in dashboard, with a service catalog.
class GuestDashboard extends StatefulWidget {
  const GuestDashboard({super.key});

  @override
  State<GuestDashboard> createState() => _GuestDashboardState();
}

class _GuestDashboardState extends State<GuestDashboard> {
  late Future<_ServiceCatalog> _catalogFuture;

  @override
  void initState() {
    super.initState();
    _catalogFuture = _loadCatalog();
  }

  Future<_ServiceCatalog> _loadCatalog() async {
    final results = await Future.wait([
      CategoryRepository().fetchCategories(),
      ServiceRepository().fetchServices(),
    ]);
    final categories = results[0] as List<Category>;
    final services = results[1] as List<Service>;
    final rows = await Supabase.instance.client
        .from('service_attribute')
        .select('service_id, price, membership_price');
    final startingPrices = <int, double>{};
    final startingMemberPrices = <int, double>{};
    for (final row in rows) {
      final values = Map<String, dynamic>.from(row);
      final serviceId = (values['service_id'] as num).toInt();
      final price = (values['price'] as num).toDouble();
      final current = startingPrices[serviceId];
      if (current == null || price < current) startingPrices[serviceId] = price;
      final memberPrice = (values['membership_price'] as num?)?.toDouble();
      if (memberPrice != null) {
        final currentMemberPrice = startingMemberPrices[serviceId];
        if (currentMemberPrice == null || memberPrice < currentMemberPrice) {
          startingMemberPrices[serviceId] = memberPrice;
        }
      }
    }
    return (
      categories: categories,
      services: services
          .where((service) => service.nameFor('en').trim().toLowerCase() != 'extra time')
          .toList(),
      startingPrices: startingPrices,
      startingMemberPrices: startingMemberPrices,
    );
  }

  void _openAuth({bool createAccount = false}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AuthScreen(initialSignUp: createAccount),
      ),
    );
  }

  void _browseTherapists() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TherapistListPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F5),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _GuestHero(
            l10n: l10n,
            onBack: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const WelcomePage()),
            ),
            onSignIn: _openAuth,
            onBrowse: _browseTherapists,
          ),
          FutureBuilder<_ServiceCatalog>(
            future: _catalogFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        l10n.tr('Could not load services.'),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () => setState(
                          () => _catalogFuture = _loadCatalog(),
                        ),
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                );
              }
              return _ServicesSection(
                catalog: snapshot.data!,
                l10n: l10n,
                onBook: _openAuth,
              );
            },
          ),
          EnsoPillars(l10n: l10n),
          EnsoVisitUs(l10n: l10n),
        ],
      ),
    );
  }
}

class _GuestHero extends StatelessWidget {
  const _GuestHero({
    required this.l10n,
    required this.onBack,
    required this.onSignIn,
    required this.onBrowse,
  });

  final AppLocalizations l10n;
  final VoidCallback onBack;
  final VoidCallback onSignIn;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 440,
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
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: l10n.tr('Back to welcome'),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: onBack,
                      ),
                      ClipOval(
                        child: Image.asset(
                          'assets/enso-logo.png',
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                         l10n.tr('Massage. Beauty. Tea'),
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
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
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: FilledButton.icon(
                            onPressed: onSignIn,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFB9C697),
                              foregroundColor: const Color(0xFF30372B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.login),
                            label: Text(
                              l10n.tr('Sign in to book'),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: onBrowse,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.people_outline, size: 18),
                            label: Text(
                              l10n.tr('Browse therapists'),
                            ),
                          ),
                        ),
                      ],
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

class _ServicesSection extends StatelessWidget {
  const _ServicesSection({
    required this.catalog,
    required this.l10n,
    required this.onBook,
  });

  final _ServiceCatalog catalog;
  final AppLocalizations l10n;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    if (catalog.services.isEmpty) {
      return const SizedBox.shrink();
    }
    final servicesByCategory = <int?, List<Service>>{};
    for (final service in catalog.services) {
      servicesByCategory.putIfAbsent(service.categoryId, () => []).add(service);
    }
    final sections = <({String title, List<Service> services})>[];
    for (final category in catalog.categories) {
      final services = servicesByCategory.remove(category.id);
      if (services != null && services.isNotEmpty) {
        sections.add((title: category.nameFor(l10n.localeName), services: services));
      }
    }
    final uncategorized = servicesByCategory.remove(null);
    if (uncategorized != null && uncategorized.isNotEmpty) {
      sections.add((title: l10n.tr('Other services'), services: uncategorized));
    }
    for (final entry in servicesByCategory.entries) {
      if (entry.value.isNotEmpty) {
        sections.add((
          title: l10n.tr('Other services'),
          services: entry.value,
        ));
      }
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.tr('OUR SERVICES'),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Color(0xFF4A5D3E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.tr('Treatments for every body'),
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF30372B),
            ),
          ),
          const SizedBox(height: 16),
          for (final section in sections) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 4),
              child: Text(
                section.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF30372B),
                ),
              ),
            ),
            GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: section.services.length,             
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 196,
              ),
              itemBuilder: (context, index) {
                final service = section.services[index];
                return _ServiceCard(
                  service: service,
                  startingPrice: catalog.startingPrices[service.id],
                  startingMemberPrice: catalog.startingMemberPrices[service.id],
                  l10n: l10n,
                  onTap: onBook,
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.service,
    required this.startingPrice,
    required this.startingMemberPrice,
    required this.l10n,
    required this.onTap,
  });

  final Service service;
  final double? startingPrice;
  final double? startingMemberPrice;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E0D5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.asset(
                service.image?.isNotEmpty == true
                    ? service.image!
                    : 'assets/services/default.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Image.asset(
                  'assets/services/default.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(11, 8, 10, 9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.nameFor(l10n.localeName),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.15,
                      color: Color(0xFF30372B),
                    ),
                  ),
                  if (startingPrice != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      l10n.tr('From {price}', {
                        'price': '\$${startingPrice!.toStringAsFixed(0)}',
                      }),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4A5D3E),
                      ),
                    ),
                  ],
                  if (startingMemberPrice != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      l10n.tr('Member price from {price}', {
                        'price': '\$${startingMemberPrice!.toStringAsFixed(0)}',
                      }),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF8B6A35),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

