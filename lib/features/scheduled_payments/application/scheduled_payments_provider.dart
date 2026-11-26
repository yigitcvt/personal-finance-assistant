import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/locale_provider.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/settings/app_settings_provider.dart';
import '../../transactions/application/transactions_provider.dart';
import '../../transactions/domain/transaction_model.dart';
import '../domain/scheduled_payment_model.dart';

final scheduledPaymentsProvider =
    AsyncNotifierProvider<ScheduledPaymentsNotifier, List<ScheduledPayment>>(
  ScheduledPaymentsNotifier.new,
);

class ScheduledPaymentsNotifier extends AsyncNotifier<List<ScheduledPayment>> {
  @override
  Future<List<ScheduledPayment>> build() async {
    final db = ref.read(appDatabaseProvider);
    return db.getAllScheduledPayments();
  }

  Future<void> addPayment(ScheduledPayment payment) async {
    final db = ref.read(appDatabaseProvider);
    final id = await db.insertScheduledPayment(payment);
    final saved = payment.copyWith(id: id);

    final notifEnabled = ref.read(appSettingsProvider).notificationsEnabled;
    final locale = ref.read(localeProvider);
    await NotificationService.instance.schedulePaymentReminders(
      saved,
      enabled: notifEnabled,
      locale: locale,
    );

    state = AsyncData(await db.getAllScheduledPayments());
  }

  Future<void> updatePayment(ScheduledPayment payment) async {
    final db = ref.read(appDatabaseProvider);
    await db.updateScheduledPayment(payment);

    final notifEnabled = ref.read(appSettingsProvider).notificationsEnabled;
    final locale = ref.read(localeProvider);
    await NotificationService.instance.schedulePaymentReminders(
      payment,
      enabled: notifEnabled,
      locale: locale,
    );

    state = AsyncData(await db.getAllScheduledPayments());
  }

  Future<void> deletePayment(int id) async {
    final db = ref.read(appDatabaseProvider);
    await db.deleteScheduledPayment(id);
    await NotificationService.instance.cancelPaymentReminders(id);
    state = AsyncData(await db.getAllScheduledPayments());
  }

  Future<void> markAsPaid(ScheduledPayment payment) async {
    if (payment.id == null || payment.isPaid) return;

    final db = ref.read(appDatabaseProvider);
    final now = DateTime.now();

    await db.updateScheduledPayment(payment.copyWith(isPaid: true));
    await NotificationService.instance.cancelPaymentReminders(payment.id!);

    final expense = TransactionRecord(
      title: payment.title,
      amountKurus: payment.amountKurus,
      type: TransactionType.expense,
      status: TransactionStatus.completed,
      categoryId: payment.categoryId,
      date: now,
      note: payment.note,
      createdAt: now,
      updatedAt: now,
    );
    await ref.read(transactionsProvider.notifier).addTransaction(expense);

    final nextDate = payment.nextDueDate();
    if (nextDate != null) {
      final nextPayment = ScheduledPayment(
        title: payment.title,
        amountKurus: payment.amountKurus,
        dueDate: nextDate,
        categoryId: payment.categoryId,
        frequency: payment.frequency,
        reminderDaysBefore: payment.reminderDaysBefore,
        isPaid: false,
        note: payment.note,
        createdAt: now,
      );
      final nextId = await db.insertScheduledPayment(nextPayment);
      final notifEnabled = ref.read(appSettingsProvider).notificationsEnabled;
      final locale = ref.read(localeProvider);
      await NotificationService.instance.schedulePaymentReminders(
        nextPayment.copyWith(id: nextId),
        enabled: notifEnabled,
        locale: locale,
      );
    }

    state = AsyncData(await db.getAllScheduledPayments());
  }

  Future<void> syncNotifications(bool enabled) async {
    if (!enabled) {
      await NotificationService.instance.cancelAll();
      return;
    }
    final locale = ref.read(localeProvider);
    final list = state.value ??
        await ref.read(appDatabaseProvider).getAllScheduledPayments();
    for (final p in list) {
      if (!p.isPaid) {
        await NotificationService.instance.schedulePaymentReminders(
          p,
          enabled: true,
          locale: locale,
        );
      }
    }
  }
}
