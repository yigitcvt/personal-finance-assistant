import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/money/money.dart';
import '../application/transactions_provider.dart';
import '../domain/transaction_model.dart';

Future<void> showTransactionFormSheet(
  BuildContext context, {
  TransactionType initialType = TransactionType.expense,
  TransactionRecord? existing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => TransactionFormSheet(
      initialType: existing?.type ?? initialType,
      existing: existing,
    ),
  );
}

class TransactionFormSheet extends ConsumerStatefulWidget {
  const TransactionFormSheet({
    super.key,
    required this.initialType,
    this.existing,
  });

  final TransactionType initialType;
  final TransactionRecord? existing;

  @override
  ConsumerState<TransactionFormSheet> createState() =>
      _TransactionFormSheetState();
}

class _TransactionFormSheetState extends ConsumerState<TransactionFormSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late TransactionType _type;
  late TransactionStatus _status;
  late String _categoryId;
  late DateTime _date;
  String? _errorText;
  bool _isSaving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _type = existing.type;
      _status = existing.status;
      _categoryId = existing.categoryId;
      _date = existing.date;
      _titleController.text = existing.title;
      _amountController.text = (existing.amountKurus / 100).toStringAsFixed(2);
      _noteController.text = existing.note ?? '';
    } else {
      _type = widget.initialType;
      _status = TransactionStatus.completed;
      _categoryId = AppCategories.byType(_type).first.id;
      _date = DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onTypeChanged(TransactionType newType) {
    if (_type == newType) return;
    setState(() {
      _type = newType;
      _categoryId = AppCategories.byType(newType).first.id;
      if (newType == TransactionType.expense) {
        _status = TransactionStatus.completed;
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;
    final l10n = AppLocalizations.of(context);

    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _errorText = l10n.enterTransactionNameError);
      return;
    }

    final parsedMoney = Money.tryParse(_amountController.text);
    if (parsedMoney == null || parsedMoney.kurus <= 0) {
      setState(() => _errorText = l10n.enterPositiveAmountError);
      return;
    }

    setState(() {
      _errorText = null;
      _isSaving = true;
    });

    final now = DateTime.now();
    final noteText = _noteController.text.trim();
    final notifier = ref.read(transactionsProvider.notifier);

    if (_isEditing) {
      final updated = widget.existing!.copyWith(
        title: title,
        amountKurus: parsedMoney.kurus,
        type: _type,
        status: _type == TransactionType.income
            ? _status
            : TransactionStatus.completed,
        categoryId: _categoryId,
        date: _date,
        note: noteText.isEmpty ? null : noteText,
        clearNote: noteText.isEmpty,
        updatedAt: now,
      );
      await notifier.updateTransaction(updated);
    } else {
      final record = TransactionRecord(
        title: title,
        amountKurus: parsedMoney.kurus,
        type: _type,
        status: _type == TransactionType.income
            ? _status
            : TransactionStatus.completed,
        categoryId: _categoryId,
        date: _date,
        note: noteText.isEmpty ? null : noteText,
        createdAt: now,
        updatedAt: now,
      );
      await notifier.addTransaction(record);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _delete() async {
    final existing = widget.existing;
    if (existing?.id == null || _isSaving) return;
    final l10n = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteRecordTitle),
        content: Text(l10n.deleteRecordConfirm(existing!.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(transactionsProvider.notifier)
          .deleteTransaction(existing!.id!);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final categories = AppCategories.byType(_type);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isEditing ? l10n.editTransaction : l10n.newTransaction,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (_isEditing)
                  IconButton(
                    onPressed: _delete,
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: theme.colorScheme.error,
                    ),
                    tooltip: l10n.delete,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<TransactionType>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text(l10n.expense),
                    icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text(l10n.income),
                    icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (s) => _onTypeChanged(s.first),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.transactionNameLabel,
                hintText: l10n.transactionNameHint,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.amountLabel,
                hintText: '0.00',
                suffixText: '₺',
              ),
            ),
            if (_type == TransactionType.income) ...[
              const SizedBox(height: 16),
              Text(
                l10n.incomeStatusLabel,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<TransactionStatus>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: TransactionStatus.completed,
                      label: Text(l10n.statusReceived),
                      icon: const Icon(Icons.check_circle_outline_rounded,
                          size: 18),
                    ),
                    ButtonSegment(
                      value: TransactionStatus.pending,
                      label: Text(l10n.statusPending),
                      icon: const Icon(Icons.schedule_rounded, size: 18),
                    ),
                  ],
                  selected: {_status},
                  onSelectionChanged: (s) {
                    setState(() => _status = s.first);
                  },
                ),
              ),
              if (_status == TransactionStatus.pending) ...[
                const SizedBox(height: 6),
                Text(
                  l10n.pendingIncomeHelper,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
            const SizedBox(height: 16),
            Text(
              l10n.categoryLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((cat) {
                final selected = cat.id == _categoryId;
                return ChoiceChip(
                  label: Text(l10n.categoryName(cat.id)),
                  avatar: Icon(cat.icon, size: 18, color: cat.color),
                  selected: selected,
                  onSelected: (_) => setState(() => _categoryId = cat.id),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.dateLabel,
                  suffixIcon:
                      const Icon(Icons.calendar_today_outlined, size: 20),
                ),
                child: Text(l10n.formatDate(_date)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _noteController,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.noteOptionalLabel,
                hintText: l10n.noteOptionalHint,
              ),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              child: Text(_isEditing ? l10n.saveChanges : l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
