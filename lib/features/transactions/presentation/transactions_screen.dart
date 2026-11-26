import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../application/transactions_provider.dart';
import '../domain/transaction_model.dart';
import 'transaction_form_sheet.dart';
import 'widgets/transaction_tile.dart';

enum _TransactionFilter { all, income, expense, pending }

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  _TransactionFilter _filter = _TransactionFilter.all;

  List<TransactionRecord> _applyFilter(List<TransactionRecord> list) {
    return switch (_filter) {
      _TransactionFilter.all => list,
      _TransactionFilter.income =>
        list.where((e) => e.type == TransactionType.income).toList(),
      _TransactionFilter.expense =>
        list.where((e) => e.type == TransactionType.expense).toList(),
      _TransactionFilter.pending =>
        list.where((e) => e.status == TransactionStatus.pending).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final transactionsAsync = ref.watch(transactionsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transactionsTitle),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showTransactionFormSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addTransaction),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(
              children: [
                _FilterChip(
                  label: l10n.filterAll,
                  selected: _filter == _TransactionFilter.all,
                  onTap: () => setState(() => _filter = _TransactionFilter.all),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: l10n.filterIncome,
                  selected: _filter == _TransactionFilter.income,
                  onTap: () =>
                      setState(() => _filter = _TransactionFilter.income),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: l10n.filterExpense,
                  selected: _filter == _TransactionFilter.expense,
                  onTap: () =>
                      setState(() => _filter = _TransactionFilter.expense),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: l10n.filterPendingIncome,
                  selected: _filter == _TransactionFilter.pending,
                  onTap: () =>
                      setState(() => _filter = _TransactionFilter.pending),
                ),
              ],
            ),
          ),
          Expanded(
            child: transactionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text('${l10n.transactionsLoadError}: $err'),
              ),
              data: (all) {
                final filtered = _applyFilter(all);
                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer
                                  .withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.receipt_long_rounded,
                              size: 34,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            all.isEmpty
                                ? l10n.noTransactionsTitle
                                : l10n.noFilteredTransactionsTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            all.isEmpty
                                ? l10n.noTransactionsListSubtitle
                                : l10n.noFilteredTransactionsSubtitle,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return TransactionTile(
                      record: item,
                      onTap: () => showTransactionFormSheet(
                        context,
                        existing: item,
                      ),
                      onMarkReceived: item.isPending
                          ? () => ref
                              .read(transactionsProvider.notifier)
                              .markIncomeAsReceived(item)
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
