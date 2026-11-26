import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/money/money.dart';
import '../../transactions/domain/transaction_model.dart';
import '../application/scheduled_payments_provider.dart';
import '../domain/scheduled_payment_model.dart';

Future<void> showScheduledPaymentFormSheet(
  BuildContext context, {
  ScheduledPayment? existing,
  DateTime? initialDate,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => ScheduledPaymentFormSheet(
      existing: existing,
      initialDate: initialDate,
    ),
  );
}

class ScheduledPaymentFormSheet extends ConsumerStatefulWidget {
  const ScheduledPaymentFormSheet({
    super.key,
    this.existing,
    this.initialDate,
  });

  final ScheduledPayment? existing;
  final DateTime? initialDate;

  @override
  ConsumerState<ScheduledPaymentFormSheet> createState() =>
      _ScheduledPaymentFormSheetState();
}

class _ScheduledPaymentFormSheetState
    extends ConsumerState<ScheduledPaymentFormSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late DateTime _dueDate;
  late String _categoryId;
  late RecurrenceFrequency _frequency;
  late int _reminderDaysBefore;
  String? _errorText;
  bool _isSaving = false;

  bool get _isEditing => widget.existing != null;

  static const _reminderDayOptions = [0, 1, 3, 7];

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _titleController.text = existing.title;
      _amountController.text = (existing.amountKurus / 100).toStringAsFixed(2);
      _noteController.text = existing.note ?? '';
      _dueDate = existing.dueDate;
      _categoryId = existing.categoryId;
      _frequency = existing.frequency;
      _reminderDaysBefore = existing.reminderDaysBefore;
    } else {
      final base =
          widget.initialDate ?? DateTime.now().add(const Duration(days: 1));
      _dueDate = DateTime(base.year, base.month, base.day);
      _categoryId = 'exp_faturalar';
      _frequency = RecurrenceFrequency.monthly;
      _reminderDaysBefore = 1;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;
    final l10n = AppLocalizations.of(context);

    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _errorText = l10n.enterPaymentNameError);
      return;
    }

    final money = Money.tryParse(_amountController.text);
    if (money == null || money.kurus <= 0) {
      setState(() => _errorText = l10n.enterPositiveAmountError);
      return;
    }

    setState(() {
      _errorText = null;
      _isSaving = true;
    });

    final note = _noteController.text.trim();
    final notifier = ref.read(scheduledPaymentsProvider.notifier);

    if (_isEditing) {
      await notifier.updatePayment(
        widget.existing!.copyWith(
          title: title,
          amountKurus: money.kurus,
          dueDate: _dueDate,
          categoryId: _categoryId,
          frequency: _frequency,
          reminderDaysBefore: _reminderDaysBefore,
          note: note.isEmpty ? null : note,
          clearNote: note.isEmpty,
        ),
      );
    } else {
      await notifier.addPayment(
        ScheduledPayment(
          title: title,
          amountKurus: money.kurus,
          dueDate: _dueDate,
          categoryId: _categoryId,
          frequency: _frequency,
          reminderDaysBefore: _reminderDaysBefore,
          isPaid: false,
          note: note.isEmpty ? null : note,
          createdAt: DateTime.now(),
        ),
      );
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
        title: Text(l10n.deletePaymentTitle),
        content: Text(l10n.deletePaymentConfirm(existing!.title)),
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
          .read(scheduledPaymentsProvider.notifier)
          .deletePayment(existing!.id!);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
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
                  _isEditing ? l10n.editPayment : l10n.planFuturePayment,
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
            const SizedBox(height: 14),
            TextField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.paymentNameLabel,
                hintText: l10n.paymentNameHint,
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
            const SizedBox(height: 14),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.dueDateLabel,
                  suffixIcon:
                      const Icon(Icons.calendar_today_outlined, size: 20),
                ),
                child: Text(l10n.formatDate(_dueDate)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.recurrenceLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: RecurrenceFrequency.values.map((freq) {
                return ChoiceChip(
                  label: Text(l10n.frequencyLabel(freq)),
                  selected: _frequency == freq,
                  onSelected: (_) => setState(() => _frequency = freq),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.reminderTimeLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _reminderDayOptions.map((days) {
                return ChoiceChip(
                  label: Text(l10n.reminderOptionLabel(days)),
                  selected: _reminderDaysBefore == days,
                  onSelected: (_) => setState(() => _reminderDaysBefore = days),
                );
              }).toList(),
            ),
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
              children: AppCategories.expenseCategories.map((cat) {
                return ChoiceChip(
                  label: Text(l10n.categoryName(cat.id)),
                  avatar: Icon(cat.icon, size: 18, color: cat.color),
                  selected: _categoryId == cat.id,
                  onSelected: (_) => setState(() => _categoryId = cat.id),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _noteController,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.noteOptionalLabel,
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
              child: Text(_isEditing ? l10n.saveChanges : l10n.planPayment),
            ),
          ],
        ),
      ),
    );
  }
}
