import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/model/service.dart';
import '../../data/repository/service.dart';
import '../core/welcome_page.dart';
import '../therapist/list.dart';
import '../user/login.dart';
import 'customer_home.dart';

typedef _ServiceCatalog = ({
  List<Service> services,
  Map<int, double> startingPrices,
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
    final services = await ServiceRepository().fetchServices();
    final rows = await Supabase.instance.client
        .from('service_attribute')
        .select('service_id, price');
    final startingPrices = <int, double>{};
    for (final row in rows) {
      final values = Map<String, dynamic>.from(row);
      final serviceId = (values['service_id'] as num).toInt();
      final price = (values['price'] as num).toDouble();
      final current = startingPrices[serviceId];
      if (current == null || price < current) startingPrices[serviceId] = price;
    }
    return (
      services: services
          .where((service) => service.name.trim().toLowerCase() != 'extra time')
          .toList(),
      startingPrices: startingPrices,
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
    final isChinese = Localizations.localeOf(context).languageCode == 'zh';
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F5),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _GuestHero(
            isChinese: isChinese,
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
                        isChinese ? '暂时无法加载服务。' : 'Could not load services.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () => setState(
                          () => _catalogFuture = _loadCatalog(),
                        ),
                        child: Text(isChinese ? '重试' : 'Retry'),
                      ),
                    ],
                  ),
                );
              }
              return _ServicesSection(
                catalog: snapshot.data!,
                isChinese: isChinese,
                onBook: _openAuth,
              );
            },
          ),
          EnsoPillars(isChinese: isChinese),
          EnsoVisitUs(isChinese: isChinese),
        ],
      ),
    );
  }
}

class _GuestHero extends StatelessWidget {
  const _GuestHero({
    required this.isChinese,
    required this.onBack,
    required this.onSignIn,
    required this.onBrowse,
  });

  final bool isChinese;
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
                        tooltip: isChinese ? '返回欢迎页' : 'Back to welcome',
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
                          'Massage. Beauty. Tea',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                color: Colors.white,
                                fontFamily: 'serif',
                                height: 1.1,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          isChinese
                              ? '融能量、自然、宁静与合一于一体的疗愈空间。'
                              : 'A sanctuary of energy, nature, serenity and oneness.',
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
                              isChinese ? '登录后预约' : 'Sign in to book',
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
                              isChinese ? '浏览治疗师' : 'Browse therapists',
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
    required this.isChinese,
    required this.onBook,
  });

  final _ServiceCatalog catalog;
  final bool isChinese;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    if (catalog.services.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isChinese ? '服务项目' : 'OUR SERVICES',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Color(0xFF4A5D3E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isChinese ? '选择适合您的护理' : 'Treatments for every body',
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 24,
              color: Color(0xFF30372B),
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: catalog.services.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 196,
            ),
            itemBuilder: (context, index) => _ServiceCard(
              service: catalog.services[index],
              startingPrice: catalog.startingPrices[catalog.services[index].id],
              isChinese: isChinese,
              onTap: onBook,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.service,
    required this.startingPrice,
    required this.isChinese,
    required this.onTap,
  });

  final Service service;
  final double? startingPrice;
  final bool isChinese;
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
              child: service.image?.isNotEmpty == true
                  ? Image.network(
                      service.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Image.asset(
                        'assets/enso-bg.jpg',
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset('assets/enso-bg.jpg', fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(11, 8, 10, 9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'serif',
                      fontSize: 15,
                      height: 1.15,
                      color: Color(0xFF30372B),
                    ),
                  ),
                  if (startingPrice != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      isChinese
                          ? '\$${startingPrice!.toStringAsFixed(0)} 起'
                          : 'From \$${startingPrice!.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4A5D3E),
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

