import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Future<void> initSupabase() => SupabaseService.init();

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static String _required(String key) {
    final value = dotenv.env[key]?.trim();
    if (value == null || value.isEmpty) {
      throw StateError('Missing $key in .env.app');
    }
    return value;
  }

  static bool get _useCloud =>
      (dotenv.env['SUPABASE_ENV'] ?? 'local').toLowerCase() == 'cloud';

  static String get _url {
    if (_useCloud) return _required('CLOUD_BASE_URL');
    if (!kIsWeb && Platform.isAndroid) {
      return _required('LOCAL_ANDROID_EMULATOR_BASE_URL');
    }
    if (!kIsWeb && Platform.isIOS) {
      return _required('LOCAL_IOS_SIMULATOR_BASE_URL');
    }
    return _required('LOCAL_DESKTOP_BASE_URL');
  }

  static String get _publishableKey =>
      _required(_useCloud ? 'CLOUD_API_KEY' : 'LOCAL_API_KEY');

  static Future<void> init() async {
    await Supabase.initialize(
      url: _url,
      publishableKey: _publishableKey,
    );
  }
}
