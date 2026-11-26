import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../core/money/money.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/settings/app_settings_provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../scheduled_payments/application/scheduled_payments_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _showLanguageSheet(
    BuildContext context,
    WidgetRef ref,
    Locale currentLocale,
  ) async {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.selectLanguageTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    for (var i = 0; i < supportedAppLocales.length; i++) ...[
                      Builder(
                        builder: (context) {
                          final item = supportedAppLocales[i];
                          final isSelected = item.locale.languageCode ==
                              currentLocale.languageCode;
                          return ListTile(
                            title: Text(
                              item.nativeName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                            subtitle: item.nativeName != item.englishName
                                ? Text(item.englishName)
                                : null,
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_circle_rounded,
                                    color: theme.colorScheme.primary,
                                  )
                                : null,
                            onTap: () async {
                              await ref
                                  .read(localeProvider.notifier)
                                  .setLocale(item.locale);
                              final notifEnabled = ref
                                  .read(appSettingsProvider)
                                  .notificationsEnabled;
                              if (notifEnabled) {
                                await ref
                                    .read(scheduledPaymentsProvider.notifier)
                                    .syncNotifications(true);
                              }
                              if (sheetContext.mounted) {
                                Navigator.of(sheetContext).pop();
                              }
                            },
                          );
                        },
                      ),
                      if (i != supportedAppLocales.length - 1)
                        const Divider(height: 1),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showEditBalanceDialog(
    BuildContext context,
    WidgetRef ref,
    Money currentBalance,
  ) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(
      text: (currentBalance.kurus / 100).toStringAsFixed(2),
    );
    String? errorText;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.initialBalanceLabel),
              content: TextField(
                controller: controller,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  suffixText: '₺',
                  errorText: errorText,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () async {
                    final parsed = Money.tryParse(controller.text);
                    if (parsed == null) {
                      setState(() {
                        errorText = l10n.invalidAmountShortError;
                      });
                      return;
                    }
                    await ref
                        .read(appSettingsProvider.notifier)
                        .updateInitialBalance(parsed);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(l10n.save),
                ),
              ],
            );
          },
        );
      },
    );
    controller.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final settings = ref.watch(appSettingsProvider);
    final theme = Theme.of(context);

    final currentLanguageName = supportedAppLocales
        .firstWhere(
          (e) => e.locale.languageCode == locale.languageCode,
          orElse: () => supportedAppLocales.first,
        )
        .nativeName;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            l10n.appearanceSection,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.themeTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.themeSubtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<ThemeMode>(
                          showSelectedIcon: false,
                          segments: [
                            ButtonSegment(
                              value: ThemeMode.light,
                              label: Text(l10n.themeLight),
                              icon: const Icon(Icons.light_mode_outlined,
                                  size: 18),
                            ),
                            ButtonSegment(
                              value: ThemeMode.dark,
                              label: Text(l10n.themeDark),
                              icon: const Icon(Icons.dark_mode_outlined,
                                  size: 18),
                            ),
                            ButtonSegment(
                              value: ThemeMode.system,
                              label: Text(l10n.themeSystem),
                              icon: const Icon(Icons.brightness_auto_outlined,
                                  size: 18),
                            ),
                          ],
                          selected: {themeMode},
                          onSelectionChanged: (selection) {
                            ref
                                .read(themeModeProvider.notifier)
                                .setThemeMode(selection.first);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  leading: Icon(
                    Icons.language_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(l10n.languageTitle),
                  subtitle: Text(currentLanguageName),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showLanguageSheet(context, ref, locale),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.notificationsSection,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    Icons.notifications_active_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(l10n.paymentRemindersTitle),
                  subtitle: Text(l10n.paymentRemindersSubtitle),
                  value: settings.notificationsEnabled,
                  onChanged: (value) async {
                    if (value) {
                      await NotificationService.instance.requestPermissions();
                    }
                    await ref
                        .read(appSettingsProvider.notifier)
                        .setNotificationsEnabled(value);
                    await ref
                        .read(scheduledPaymentsProvider.notifier)
                        .syncNotifications(value);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.send_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(l10n.sendTestNotificationTitle),
                  subtitle: Text(l10n.sendTestNotificationSubtitle),
                  onTap: () async {
                    final granted =
                        await NotificationService.instance.requestPermissions();
                    await NotificationService.instance
                        .showTestNotification(locale: locale);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            granted
                                ? l10n.testNotificationSent
                                : l10n.testNotificationCheckPerms,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.accountSection,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              leading: Icon(
                Icons.account_balance_wallet_outlined,
                color: theme.colorScheme.primary,
              ),
              title: Text(l10n.initialBalanceLabel),
              subtitle: Directionality(
                textDirection: TextDirection.ltr,
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(settings.initialBalance.format()),
                ),
              ),
              trailing: const Icon(Icons.edit_outlined, size: 20),
              onTap: () => _showEditBalanceDialog(
                context,
                ref,
                settings.initialBalance,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
