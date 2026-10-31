import 'package:flutter/material.dart';

import '../dashboard/guest_dashboard.dart';
import '../user/login.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  static const _primary = Color(0xFFB9C697);
  static const _ink = Color(0xFF34402E);

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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 460),
                    decoration: BoxDecoration(
                      color: _primary.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/enso-logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 34),
                  const Text(
                    'A little space for your wellbeing',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                    color: Colors.white,
                      fontSize: 28,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Discover caring therapists and find a time that works for you.',
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
                        backgroundColor: _primary,
                        foregroundColor: _ink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Continue as a guest',
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
                        side: const BorderSide(color: _primary, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Sign in',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'You can browse first and sign in when you’re ready to book.',
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
