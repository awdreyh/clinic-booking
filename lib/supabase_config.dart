import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

final supabase = Supabase.instance.client;

Future<void> initSupabase() async {
  await SupabaseService.init();
}
class SupabaseService {
  // Centralized client reference
  static SupabaseClient get client => Supabase.instance.client;

  // Run with --dart-define=USE_LOCAL_SUPABASE=true to target `supabase start`.
  // static const _useLocal = bool.fromEnvironment('USE_LOCAL_SUPABASE');

  // 10.0.2.2 is the Android emulator's alias for the host machine's 127.0.0.1.
  static String get _localUrl =>
      !kIsWeb && Platform.isAndroid
        ? 'http://10.0.2.2:54331'
        : 'http://127.0.0.1:54331';
  static const _localPublishableKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';

  // static const _cloudUrl = 'https://rgmodxpfbtqszajsmxti.supabase.co';
  // static const _cloudPublishableKey =
  //     'sb_publishable_2CsRxp7-QLhg4ZESZIUFVg_fqKORvo9';

  static Future<void> init() async {
    await Supabase.initialize(
      url: _localUrl,
      publishableKey: _localPublishableKey,
    );
  }
}
