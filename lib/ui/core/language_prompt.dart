import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import 'app_theme.dart';
import 'locale_provider.dart';

class LanguagePromptPage extends StatelessWidget {
  const LanguagePromptPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.chooseLanguageTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                  ),
                  onPressed: () => context.read<LocaleProvider>().setLocale('zh'),
                  child: Text(l10n.languageChinese),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.read<LocaleProvider>().setLocale('en'),
                  child: Text(l10n.languageEnglish),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
