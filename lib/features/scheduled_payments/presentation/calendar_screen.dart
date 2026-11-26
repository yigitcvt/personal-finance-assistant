import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../transactions/application/transactions_provider.dart';
import '../../transactions/presentation/transaction_form_sheet.dart';
import '../../transactions/presentation/widgets/transaction_tile.dart';
import '../application/scheduled_payments_provider.dart';
import '../domain/scheduled_payment_model.dart';
import 'scheduled_payment_form_sheet.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final transactions = ref.watch(transactionsProvider).value ?? const [];
    final scheduled = ref.watch(scheduledPaymentsProvider).value ?? const [];
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final dayTransactions =
        transactions.where((t) => _isSameDay(t.date, _selectedDay)).toList();
    final dayScheduled = scheduled
        .where((p) => !p.isPaid && _isSameDay(p.dueDate, _selectedDay))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.calendarTitle),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showScheduledPaymentFormSheet(
          context,
          initialDate: _selectedDay,
        ),
        icon: const Icon(Icons.event_available_rounded),
        label: Text(l10n.planPayment),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TableCalendar<Object>(
                  locale: l10n.locale.languageCode,
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2100),
                  focusedDay: _focusedDay,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  selectedDayPredicate: (day) => _isSameDay(day, _selectedDay),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: colorScheme.tertiary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  eventLoader: (day) {
                    final events = <Object>[];
                    for (final p in scheduled) {
                      if (!p.isPaid && _isSameDay(p.dueDate, day)) {
                        events.add(p);
                      }
                    }
                    for (final t in transactions) {
                      if (_isSameDay(t.date, day)) {
                        events.add(t);
                      }
                    }
                    return events;
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.dayRecordsHeader(l10n.formatDate(_selectedDay)),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  l10n.recordsCount(
                    dayScheduled.length + dayTransactions.length,
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: (dayScheduled.isEmpty && dayTransactions.isEmpty)
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event_note_outlined,
                            size: 40,
                            color: colorScheme.primary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l10n.noDayRecordsTitle,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.noDayRecordsSubtitle,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
                    children: [
                      for (final p in dayScheduled) ...[
                        _ScheduledPaymentTile(
                          payment: p,
                          onTap: () => showScheduledPaymentFormSheet(
                            context,
                            existing: p,
                          ),
                          onMarkPaid: () => ref
                              .read(scheduledPaymentsProvider.notifier)
                              .markAsPaid(p),
                        ),
                        const SizedBox(height: 10),
                      ],
                      for (final t in dayTransactions) ...[
                        TransactionTile(
                          record: t,
                          onTap: () => showTransactionFormSheet(
                            context,
                            existing: t,
                          ),
                          onMarkReceived: t.isPending
                              ? () => ref
                                  .read(transactionsProvider.notifier)
                                  .markIncomeAsReceived(t)
                              : null,
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ScheduledPaymentTile extends StatelessWidget {
  const _ScheduledPaymentTile({
    required this.payment,
    required this.onTap,
    required this.onMarkPaid,
  });

  final ScheduledPayment payment;
  final VoidCallback onTap;
  final VoidCallback onMarkPaid;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category.icon,
                  color: Colors.amber.shade800,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            payment.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            l10n.frequencyLabel(payment.frequency),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${l10n.categoryName(category.id)} • ${l10n.scheduledPaymentSubtitle}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
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
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: onMarkPaid,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      child: Text(
                        l10n.markAsPaid,
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
