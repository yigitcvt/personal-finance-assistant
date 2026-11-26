import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../scheduled_payments/application/scheduled_payments_provider.dart';
import '../../scheduled_payments/domain/scheduled_payment_model.dart';
import '../../scheduled_payments/presentation/scheduled_payment_form_sheet.dart';
import '../../transactions/application/transactions_provider.dart';
import '../../transactions/domain/transaction_model.dart';
import '../../transactions/presentation/transaction_form_sheet.dart';
import '../../transactions/presentation/widgets/transaction_tile.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final summary = ref.watch(balanceSummaryProvider);
    final transactionsAsync = ref.watch(transactionsProvider);
    final scheduledAsync = ref.watch(scheduledPaymentsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final upcomingPayments = (scheduledAsync.value ?? const <ScheduledPayment>[])
        .where((p) => !p.isPaid)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.82),
                ],
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.totalCurrentBalance,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimary.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 8),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    summary.currentBalance.format(),
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.spendableBalance,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimary.withValues(alpha: 0.9),
                        ),
                      ),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          summary.spendableBalance.format(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (summary.upcomingPaymentsTotal.isPositive) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.pendingScheduledPayments,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimary.withValues(alpha: 0.85),
                        ),
                      ),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          '-${summary.upcomingPaymentsTotal.format()}',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (summary.pendingIncome.isPositive) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.pendingIncomeLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimary.withValues(alpha: 0.85),
                        ),
                      ),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          '+${summary.pendingIncome.format()}',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => showTransactionFormSheet(
                    context,
                    initialType: TransactionType.income,
                  ),
                  icon: Icon(
                    Icons.add_circle_outline_rounded,
                    color: Colors.green.shade700,
                  ),
                  label: Text(l10n.addIncome),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => showTransactionFormSheet(
                    context,
                    initialType: TransactionType.expense,
                  ),
                  icon: Icon(
                    Icons.remove_circle_outline_rounded,
                    color: Colors.red.shade700,
                  ),
                  label: Text(l10n.addExpense),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryMiniCard(
                  icon: Icons.arrow_downward_rounded,
                  iconColor: Colors.green.shade600,
                  label: l10n.monthlyIncome,
                  value: summary.monthlyIncome.format(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryMiniCard(
                  icon: Icons.arrow_upward_rounded,
                  iconColor: Colors.red.shade600,
                  label: l10n.monthlyExpense,
                  value: summary.monthlyExpense.format(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.upcomingPayments,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton.icon(
                onPressed: () => showScheduledPaymentFormSheet(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(l10n.planButton),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (upcomingPayments.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_available_outlined,
                      color: colorScheme.primary.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.noUpcomingPaymentsDesc,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                for (var i = 0; i < upcomingPayments.take(3).length; i++) ...[
                  _UpcomingPaymentCard(
                    payment: upcomingPayments[i],
                    dateText: l10n.formatDate(upcomingPayments[i].dueDate),
                    frequencyText:
                        l10n.frequencyLabel(upcomingPayments[i].frequency),
                    markPaidLabel: l10n.markPaidShort,
                    onTap: () => showScheduledPaymentFormSheet(
                      context,
                      existing: upcomingPayments[i],
                    ),
                    onMarkPaid: () => ref
                        .read(scheduledPaymentsProvider.notifier)
                        .markAsPaid(upcomingPayments[i]),
                  ),
                  if (i != upcomingPayments.take(3).length - 1)
                    const SizedBox(height: 10),
                ],
              ],
            ),
          const SizedBox(height: 24),
          Text(
            l10n.recentTransactions,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          transactionsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('${l10n.transactionsLoadError}: $err'),
              ),
            ),
            data: (transactions) {
              if (transactions.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 28,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 40,
                          color: colorScheme.primary.withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.noTransactionsTitle,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.noTransactionsDashboardSubtitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final recent = transactions.take(5).toList();
              return Column(
                children: [
                  for (var i = 0; i < recent.length; i++) ...[
                    TransactionTile(
                      record: recent[i],
                      onTap: () => showTransactionFormSheet(
                        context,
                        existing: recent[i],
                      ),
                      onMarkReceived: recent[i].isPending
                          ? () => ref
                              .read(transactionsProvider.notifier)
                              .markIncomeAsReceived(recent[i])
                          : null,
                    ),
                    if (i != recent.length - 1) const SizedBox(height: 10),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _UpcomingPaymentCard extends StatelessWidget {
  const _UpcomingPaymentCard({
    required this.payment,
    required this.dateText,
    required this.frequencyText,
    required this.markPaidLabel,
    required this.onTap,
    required this.onMarkPaid,
  });

  final ScheduledPayment payment;
  final String dateText;
  final String frequencyText;
  final String markPaidLabel;
  final VoidCallback onTap;
  final VoidCallback onMarkPaid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = payment.category;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category.icon,
                  color: Colors.amber.shade800,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$dateText • $frequencyText',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      payment.amount.format(),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  InkWell(
                    onTap: onMarkPaid,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      child: Text(
                        markPaidLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryMiniCard extends StatelessWidget {
  const _SummaryMiniCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: iconColor),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
