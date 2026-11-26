import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../money/money.dart';

const _initialBalanceKurusKey = 'initial_balance_kurus';
const _onboardingDoneKey = 'onboarding_completed';
const _notificationsEnabledKey = 'notifications_enabled';

/// Uygulama başlarken main.dart içinde gerçek SharedPreferences ile override edilir.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

class AppSettingsState {
  const AppSettingsState({
    required this.initialBalance,
    required this.hasCompletedOnboarding,
    required this.notificationsEnabled,
  });

  final Money initialBalance;
  final bool hasCompletedOnboarding;
  final bool notificationsEnabled;

  AppSettingsState copyWith({
    Money? initialBalance,
    bool? hasCompletedOnboarding,
    bool? notificationsEnabled,
  }) {
    return AppSettingsState(
      initialBalance: initialBalance ?? this.initialBalance,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettingsState>(
  AppSettingsNotifier.new,
);

class AppSettingsNotifier extends Notifier<AppSettingsState> {
  @override
  AppSettingsState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final kurus = prefs.getInt(_initialBalanceKurusKey) ?? 0;
    final done = prefs.getBool(_onboardingDoneKey) ?? false;
    final notifEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;
    return AppSettingsState(
      initialBalance: Money(kurus),
      hasCompletedOnboarding: done,
      notificationsEnabled: notifEnabled,
    );
  }

  Future<void> completeOnboarding(Money initialBalance) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(_initialBalanceKurusKey, initialBalance.kurus);
    await prefs.setBool(_onboardingDoneKey, true);
    state = state.copyWith(
      initialBalance: initialBalance,
      hasCompletedOnboarding: true,
    );
  }

  Future<void> updateInitialBalance(Money initialBalance) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(_initialBalanceKurusKey, initialBalance.kurus);
    state = state.copyWith(initialBalance: initialBalance);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_notificationsEnabledKey, enabled);
    state = state.copyWith(notificationsEnabled: enabled);
  }
}
