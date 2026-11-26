import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/app_settings_provider.dart';

const _localeCodeKey = 'app_locale_code';

class SupportedAppLocale {
  const SupportedAppLocale({
    required this.locale,
    required this.nativeName,
    required this.englishName,
  });

  final Locale locale;
  final String nativeName;
  final String englishName;
}

const List<SupportedAppLocale> supportedAppLocales = [
  SupportedAppLocale(
    locale: Locale('en'),
    nativeName: 'English',
    englishName: 'English',
  ),
  SupportedAppLocale(
    locale: Locale('tr'),
    nativeName: 'Türkçe',
    englishName: 'Turkish',
  ),
];

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final savedCode = prefs.getString(_localeCodeKey);
    // Default language is always English unless the user manually changes it.
    return switch (savedCode) {
      'tr' => const Locale('tr'),
      _ => const Locale('en'),
    };
  }

  Future<void> setLocale(Locale locale) async {
    if (state.languageCode == locale.languageCode) return;
    state = locale;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_localeCodeKey, locale.languageCode);
  }
}
