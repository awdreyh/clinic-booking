import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';
import 'ui/core/nav_bottom.dart';
import 'ui/core/locale_provider.dart';
import 'ui/core/language_prompt.dart';
import 'ui/core/welcome_page.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env.app');
  // Initialize Supabase with your URL and anon Key
  await SupabaseService.init();

  final localeProvider = LocaleProvider();
  await localeProvider.init();

  runApp(MyApp(localeProvider: localeProvider));
}

final supabase = Supabase.instance.client;
final _navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.localeProvider});

  final LocaleProvider localeProvider;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LocaleProvider>.value(
      value: localeProvider,
      child: Consumer<LocaleProvider>(
        builder: (context, locale, _) {
          return MaterialApp(
            navigatorKey: _navigatorKey,
            title: 'Clinic Booking',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB9C697)),
              scaffoldBackgroundColor: const Color(0xFFF8F9F5),
            ),
            locale: locale.locale,
            supportedLocales: LocaleProvider.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: locale.needsPrompt
                ? const LanguagePromptPage()
                : const AuthGate(),
          );
        },
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final StreamSubscription<AuthState> _authSubscription;
  late bool _signedIn;

  @override
  void initState() {
    super.initState();
    _signedIn = supabase.auth.currentSession != null;
    _authSubscription = supabase.auth.onAuthStateChange.listen(
      _onAuthStateChange,
      onError: (Object error) => debugPrint('Auth stream error: $error'),
    );
  }

  void _onAuthStateChange(AuthState state) {
    final signedIn = state.session != null;
    if (signedIn == _signedIn) return;
    setState(() => _signedIn = signedIn);
    // Pushed routes (sign-in, guest browsing, booking) hide the auth change.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _signedIn ? const HomeShell() : const WelcomePage();
}

