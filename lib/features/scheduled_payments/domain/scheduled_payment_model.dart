import '../../../core/money/money.dart';
import '../../transactions/domain/transaction_model.dart';

enum RecurrenceFrequency {
  once('Tek seferlik'),
  weekly('Haftalık'),
  monthly('Aylık'),
  yearly('Yıllık');

  const RecurrenceFrequency(this.label);
  final String label;

  static RecurrenceFrequency fromName(String? name) {
    return RecurrenceFrequency.values.firstWhere(
      (e) => e.name == name,
      orElse: () => RecurrenceFrequency.once,
    );
  }
}

class ScheduledPayment {
  const ScheduledPayment({
    this.id,
    required this.title,
    required this.amountKurus,
    required this.dueDate,
    required this.categoryId,
    required this.frequency,
    required this.reminderDaysBefore,
    required this.isPaid,
    this.note,
    required this.createdAt,
  });

  final int? id;
  final String title;
  final int amountKurus;
  final DateTime dueDate;
  final String categoryId;
  final RecurrenceFrequency frequency;
  final int reminderDaysBefore; // 0 = sadece ödeme günü, 1, 3, 7 gün önce
  final bool isPaid;
  final String? note;
  final DateTime createdAt;

  Money get amount => Money(amountKurus);

  CategoryItem get category =>
      AppCategories.findById(categoryId, TransactionType.expense);

  /// Tekrarlayan ödemeler için bir sonraki dönemin vade tarihini hesaplar.
  DateTime? nextDueDate() {
    switch (frequency) {
      case RecurrenceFrequency.once:
        return null;
      case RecurrenceFrequency.weekly:
        return DateTime(dueDate.year, dueDate.month, dueDate.day + 7);
      case RecurrenceFrequency.monthly:
        final nextMonth = DateTime(dueDate.year, dueDate.month + 1, 1);
        final lastDayOfNextMonth =
            DateTime(nextMonth.year, nextMonth.month + 1, 0).day;
        final day = dueDate.day > lastDayOfNextMonth
            ? lastDayOfNextMonth
            : dueDate.day;
        return DateTime(nextMonth.year, nextMonth.month, day);
      case RecurrenceFrequency.yearly:
        final nextYear = dueDate.year + 1;
        final lastDay = DateTime(nextYear, dueDate.month + 1, 0).day;
        final day = dueDate.day > lastDay ? lastDay : dueDate.day;
        return DateTime(nextYear, dueDate.month, day);
    }
  }

  ScheduledPayment copyWith({
    int? id,
    String? title,
    int? amountKurus,
    DateTime? dueDate,
    String? categoryId,
    RecurrenceFrequency? frequency,
    int? reminderDaysBefore,
    bool? isPaid,
    String? note,
    bool clearNote = false,
    DateTime? createdAt,
  }) {
    return ScheduledPayment(
      id: id ?? this.id,
      title: title ?? this.title,
      amountKurus: amountKurus ?? this.amountKurus,
      dueDate: dueDate ?? this.dueDate,
      categoryId: categoryId ?? this.categoryId,
      frequency: frequency ?? this.frequency,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      isPaid: isPaid ?? this.isPaid,
      note: clearNote ? null : (note ?? this.note),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'amount_kurus': amountKurus,
      'due_date_ms': dueDate.millisecondsSinceEpoch,
      'category_id': categoryId,
      'frequency': frequency.name,
      'reminder_days_before': reminderDaysBefore,
      'is_paid': isPaid ? 1 : 0,
      'note': note,
      'created_at_ms': createdAt.millisecondsSinceEpoch,
    };
  }

  factory ScheduledPayment.fromMap(Map<String, Object?> map) {
    return ScheduledPayment(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      amountKurus: map['amount_kurus'] as int? ?? 0,
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['due_date_ms'] as int),
      categoryId: map['category_id'] as String? ?? 'exp_faturalar',
      frequency: RecurrenceFrequency.fromName(map['frequency'] as String?),
      reminderDaysBefore: map['reminder_days_before'] as int? ?? 1,
      isPaid: (map['is_paid'] as int? ?? 0) == 1,
      note: map['note'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['created_at_ms'] as int,
      ),
    );
  }
}
