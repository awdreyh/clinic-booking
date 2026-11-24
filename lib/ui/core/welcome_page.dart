import 'package:flutter/material.dart';

import '../dashboard/guest_dashboard.dart';
import '../user/login.dart';
import 'app_theme.dart';
import '../../l10n/app_localizations.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  void _continueAsGuest(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const GuestDashboard()),
    );
  }

  void _signIn(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
     final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/enso-bg.jpg', fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x660D0906), Color(0xB30D0906)],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 52),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 260), 
                    child: Image.asset(
                      'assets/enso-logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 34),                  
                    Text(
                
                    l10n.welcomeTitle,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                    color: Colors.white,
                      fontSize: 28,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                   Text(
                    l10n.welcomeSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                    color: Color(0xFFF0E9E1),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: () => _continueAsGuest(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.ink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child:  Text(l10n.continueAsGuest,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: () => _signIn(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 235, 238, 234),
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child:  Text(l10n.signIn,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 16),
                   Text(
                    l10n.welcomeSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFFE2D9CE), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          ),
      )],
      ),
    );
  }
}
