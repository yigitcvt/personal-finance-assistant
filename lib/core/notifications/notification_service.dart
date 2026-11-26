import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../features/scheduled_payments/domain/scheduled_payment_model.dart';
import '../l10n/app_localizations.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const _channelId = 'payment_reminders_channel';

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    await init();
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl == null) return false;

    final notifGranted =
        await androidImpl.requestNotificationsPermission() ?? false;
    await androidImpl.requestExactAlarmsPermission();
    return notifGranted;
  }

  Future<void> showTestNotification({
    Locale locale = const Locale('en'),
  }) async {
    await init();
    final l10n = AppLocalizations.forLocale(locale);
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        l10n.notifChannelName,
        channelDescription: l10n.notifChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    await _plugin.show(
      id: 999999,
      title: l10n.appTitle,
      body: l10n.notifTestBody,
      notificationDetails: details,
    );
  }

  Future<void> schedulePaymentReminders(
    ScheduledPayment payment, {
    required bool enabled,
    Locale locale = const Locale('en'),
  }) async {
    if (payment.id == null) return;
    await cancelPaymentReminders(payment.id!);

    if (!enabled || payment.isPaid) return;
    await init();

    final l10n = AppLocalizations.forLocale(locale);
    final now = tz.TZDateTime.now(tz.local);
    final dueMorning = tz.TZDateTime(
      tz.local,
      payment.dueDate.year,
      payment.dueDate.month,
      payment.dueDate.day,
      9,
      0,
    );

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        l10n.notifChannelName,
        channelDescription: l10n.notifChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    if (payment.reminderDaysBefore > 0) {
      final beforeDate = dueMorning.subtract(
        Duration(days: payment.reminderDaysBefore),
      );
      if (beforeDate.isAfter(now)) {
        await _plugin.zonedSchedule(
          id: payment.id! * 2,
          title: l10n.notifUpcomingTitle,
          body: l10n.notifUpcomingBody(
            payment.title,
            payment.amount.format(),
            payment.reminderDaysBefore,
          ),
          scheduledDate: beforeDate,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    }

    if (dueMorning.isAfter(now)) {
      await _plugin.zonedSchedule(
        id: payment.id! * 2 + 1,
        title: l10n.notifDueTodayTitle,
        body: l10n.notifDueTodayBody(
          payment.title,
          payment.amount.format(),
        ),
        scheduledDate: dueMorning,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> cancelPaymentReminders(int paymentId) async {
    await init();
    await _plugin.cancel(id: paymentId * 2);
    await _plugin.cancel(id: paymentId * 2 + 1);
  }

  Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }
}
