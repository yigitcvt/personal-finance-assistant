import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/money/money.dart';
import '../../../core/settings/app_settings_provider.dart';
import '../../scheduled_payments/application/scheduled_payments_provider.dart';
import '../../scheduled_payments/domain/scheduled_payment_model.dart';
import '../domain/transaction_model.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

final transactionsProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<TransactionRecord>>(
  TransactionsNotifier.new,
);

class TransactionsNotifier extends AsyncNotifier<List<TransactionRecord>> {
  @override
  Future<List<TransactionRecord>> build() async {
    final db = ref.read(appDatabaseProvider);
    return db.getAllTransactions();
  }

  Future<void> addTransaction(TransactionRecord record) async {
    final db = ref.read(appDatabaseProvider);
    await db.insertTransaction(record);
    state = AsyncData(await db.getAllTransactions());
  }

  Future<void> updateTransaction(TransactionRecord record) async {
    final db = ref.read(appDatabaseProvider);
    await db.updateTransaction(record);
    state = AsyncData(await db.getAllTransactions());
  }

  Future<void> deleteTransaction(int id) async {
    final db = ref.read(appDatabaseProvider);
    await db.deleteTransaction(id);
    state = AsyncData(await db.getAllTransactions());
  }

  Future<void> markIncomeAsReceived(TransactionRecord record) async {
    final updated = record.copyWith(
      status: TransactionStatus.completed,
      updatedAt: DateTime.now(),
    );
    await updateTransaction(updated);
  }
}

class BalanceSummary {
  const BalanceSummary({
    required this.currentBalance,
    required this.spendableBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.pendingIncome,
    required this.upcomingPaymentsTotal,
  });

  final Money currentBalance;
  final Money spendableBalance;
  final Money monthlyIncome;
  final Money monthlyExpense;
  final Money pendingIncome;
  final Money upcomingPaymentsTotal;
}

final balanceSummaryProvider = Provider<BalanceSummary>((ref) {
  final settings = ref.watch(appSettingsProvider);
  final transactionsAsync = ref.watch(transactionsProvider);
  final scheduledAsync = ref.watch(scheduledPaymentsProvider);

  final transactions = transactionsAsync.value ?? const <TransactionRecord>[];
  final scheduled = scheduledAsync.value ?? const <ScheduledPayment>[];

  final now = DateTime.now();
  var totalBalanceKurus = settings.initialBalance.kurus;
  var monthlyIncomeKurus = 0;
  var monthlyExpenseKurus = 0;
  var pendingIncomeKurus = 0;

  for (final tx in transactions) {
    final isCurrentMonth =
        tx.date.year == now.year && tx.date.month == now.month;

    if (tx.type == TransactionType.income) {
      if (tx.status == TransactionStatus.completed) {
        totalBalanceKurus += tx.amountKurus;
        if (isCurrentMonth) {
          monthlyIncomeKurus += tx.amountKurus;
        }
      } else {
        pendingIncomeKurus += tx.amountKurus;
      }
    } else {
      if (tx.status == TransactionStatus.completed) {
        totalBalanceKurus -= tx.amountKurus;
        if (isCurrentMonth) {
          monthlyExpenseKurus += tx.amountKurus;
        }
      }
    }
  }

  // Henüz yapılmamış ödemeler mevcut bakiyeden düşülmez,
  // ancak Harcanabilir Bakiye hesabında dikkate alınır.
  var upcomingUnpaidKurus = 0;
  for (final p in scheduled) {
    if (!p.isPaid) {
      upcomingUnpaidKurus += p.amountKurus;
    }
  }

  final current = Money(totalBalanceKurus);
  final spendable = Money(totalBalanceKurus - upcomingUnpaidKurus);

  return BalanceSummary(
    currentBalance: current,
    spendableBalance: spendable,
    monthlyIncome: Money(monthlyIncomeKurus),
    monthlyExpense: Money(monthlyExpenseKurus),
    pendingIncome: Money(pendingIncomeKurus),
    upcomingPaymentsTotal: Money(upcomingUnpaidKurus),
  );
});
