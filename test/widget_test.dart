import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_assistant/core/l10n/app_localizations.dart';
import 'package:personal_finance_assistant/core/l10n/locale_provider.dart';
import 'package:personal_finance_assistant/core/money/money.dart';
import 'package:personal_finance_assistant/core/settings/app_settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Money parses and formats currency without floating-point error', () {
    final a = Money.tryParse('0,10')!;
    final b = Money.tryParse('0,20')!;
    expect((a + b).kurus, 30);
    expect((a + b).format(), '0,30 ₺');

    final big = Money.tryParse('1.250,75')!;
    expect(big.kurus, 125075);
    expect(big.format(), '1.250,75 ₺');
  });

  test('AppLocalizations supports English (default) and Turkish', () {
    final en = AppLocalizations.forLocale(const Locale('en'));
    final tr = AppLocalizations.forLocale(const Locale('tr'));

    expect(en.appTitle, 'Finance Assistant');
    expect(tr.appTitle, 'Finans Asistanı');

    expect(en.categoryName('inc_maas'), 'Salary');
    expect(tr.categoryName('inc_maas'), 'Maaş');
  });

  test('LocaleNotifier defaults to English and persists language selection', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final container1 = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container1.dispose);

    // Default must be English on first launch
    expect(container1.read(localeProvider), const Locale('en'));

    // Switch to Turkish and verify persistence
    await container1.read(localeProvider.notifier).setLocale(const Locale('tr'));
    expect(container1.read(localeProvider), const Locale('tr'));

    // Simulate app restart with a fresh ProviderContainer
    final container2 = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container2.dispose);
    expect(container2.read(localeProvider), const Locale('tr'));
  });
}
