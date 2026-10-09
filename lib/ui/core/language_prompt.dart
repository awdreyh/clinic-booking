import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_theme.dart';
import 'locale_provider.dart';

/// Shown once on first launch when the device region doesn't clearly
/// indicate a preferred language (bilingual by design, since no locale is
/// active yet).
class LanguagePromptPage extends StatelessWidget {
  const LanguagePromptPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '选择语言 / Choose your language',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.accent),
                  onPressed: () =>
                      context.read<LocaleProvider>().setLocale('zh'),
                  child: const Text('简体中文'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () =>
                      context.read<LocaleProvider>().setLocale('en'),
                  child: const Text('English'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
