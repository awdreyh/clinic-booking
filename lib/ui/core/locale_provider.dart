import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the app's active [Locale]: persists an explicit user choice, and
/// on first launch either defaults silently to Chinese (device region is
/// mainland China) or flags that the user must be asked to choose.
class LocaleProvider extends ChangeNotifier {
  static const _prefsKey = 'app_locale_code';

  static const supportedLocales = [Locale('zh'), Locale('en')];

  Locale _locale = const Locale('zh');
  bool _needsPrompt = false;
  bool _initialized = false;

  Locale get locale => _locale;
  bool get needsPrompt => _needsPrompt;
  bool get initialized => _initialized;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);

    if (saved != null) {
      _locale = Locale(saved);
      _needsPrompt = false;
    } else if (_systemLocaleIsMainlandChina()) {
      _locale = const Locale('zh');
      _needsPrompt = false;
      await prefs.setString(_prefsKey, 'zh');
    } else {
      // Unknown region: ask the user on first launch instead of guessing.
      _needsPrompt = true;
    }

    _initialized = true;
    notifyListeners();
  }

  bool _systemLocaleIsMainlandChina() {
    final systemLocale = PlatformDispatcher.instance.locale;
    return systemLocale.countryCode == 'CN';
  }

  Future<void> setLocale(String languageCode) async {
    _locale = Locale(languageCode);
    _needsPrompt = false;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, languageCode);
  }
}
