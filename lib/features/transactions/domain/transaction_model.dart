import 'package:flutter/material.dart';

import '../../../core/money/money.dart';

enum TransactionType { income, expense }

enum TransactionStatus { completed, pending }

class CategoryItem {
  const CategoryItem({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
  });

  final String id;
  final String name;
  final TransactionType type;
  final IconData icon;
  final Color color;
}

class AppCategories {
  static const List<CategoryItem> incomeCategories = [
    CategoryItem(
      id: 'inc_maas',
      name: 'Maaş',
      type: TransactionType.income,
      icon: Icons.work_outline_rounded,
      color: Color(0xFF0F766E),
    ),
    CategoryItem(
      id: 'inc_burs',
      name: 'Burs',
      type: TransactionType.income,
      icon: Icons.school_outlined,
      color: Color(0xFF2563EB),
    ),
    CategoryItem(
      id: 'inc_harclik',
      name: 'Harçlık',
      type: TransactionType.income,
      icon: Icons.savings_outlined,
      color: Color(0xFF16A34A),
    ),
    CategoryItem(
      id: 'inc_freelance',
      name: 'Freelance',
      type: TransactionType.income,
      icon: Icons.laptop_mac_rounded,
      color: Color(0xFF7C3AED),
    ),
    CategoryItem(
      id: 'inc_ek_gelir',
      name: 'Ek gelir',
      type: TransactionType.income,
      icon: Icons.trending_up_rounded,
      color: Color(0xFF0891B2),
    ),
    CategoryItem(
      id: 'inc_diger',
      name: 'Diğer',
      type: TransactionType.income,
      icon: Icons.more_horiz_rounded,
      color: Color(0xFF64748B),
    ),
  ];

  static const List<CategoryItem> expenseCategories = [
    CategoryItem(
      id: 'exp_market',
      name: 'Market',
      type: TransactionType.expense,
      icon: Icons.shopping_basket_outlined,
      color: Color(0xFFEA580C),
    ),
    CategoryItem(
      id: 'exp_yemek',
      name: 'Yemek',
      type: TransactionType.expense,
      icon: Icons.restaurant_outlined,
      color: Color(0xFFDC2626),
    ),
    CategoryItem(
      id: 'exp_ulasim',
      name: 'Ulaşım',
      type: TransactionType.expense,
      icon: Icons.directions_bus_outlined,
      color: Color(0xFF2563EB),
    ),
    CategoryItem(
      id: 'exp_faturalar',
      name: 'Faturalar',
      type: TransactionType.expense,
      icon: Icons.receipt_long_outlined,
      color: Color(0xFFD97706),
    ),
    CategoryItem(
      id: 'exp_egitim',
      name: 'Eğitim',
      type: TransactionType.expense,
      icon: Icons.menu_book_outlined,
      color: Color(0xFF4F46E5),
    ),
    CategoryItem(
      id: 'exp_eglence',
      name: 'Eğlence',
      type: TransactionType.expense,
      icon: Icons.movie_outlined,
      color: Color(0xFFDB2777),
    ),
    CategoryItem(
      id: 'exp_abonelikler',
      name: 'Abonelikler',
      type: TransactionType.expense,
      icon: Icons.autorenew_rounded,
      color: Color(0xFF9333EA),
    ),
    CategoryItem(
      id: 'exp_saglik',
      name: 'Sağlık',
      type: TransactionType.expense,
      icon: Icons.favorite_border_rounded,
      color: Color(0xFFE11D48),
    ),
    CategoryItem(
      id: 'exp_diger',
      name: 'Diğer',
      type: TransactionType.expense,
      icon: Icons.more_horiz_rounded,
      color: Color(0xFF64748B),
    ),
  ];

  static List<CategoryItem> byType(TransactionType type) {
    return type == TransactionType.income ? incomeCategories : expenseCategories;
  }

  static CategoryItem findById(String id, TransactionType fallbackType) {
    final all = [...incomeCategories, ...expenseCategories];
    for (final item in all) {
      if (item.id == id) return item;
    }
    return byType(fallbackType).last;
  }
}

class TransactionRecord {
  const TransactionRecord({
    this.id,
    required this.title,
    required this.amountKurus,
    required this.type,
    required this.status,
    required this.categoryId,
    required this.date,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String title;
  final int amountKurus;
  final TransactionType type;
  final TransactionStatus status;
  final String categoryId;
  final DateTime date;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  Money get amount => Money(amountKurus);

  bool get isIncome => type == TransactionType.income;
  bool get isPending => status == TransactionStatus.pending;

  CategoryItem get category => AppCategories.findById(categoryId, type);

  TransactionRecord copyWith({
    int? id,
    String? title,
    int? amountKurus,
    TransactionType? type,
    TransactionStatus? status,
    String? categoryId,
    DateTime? date,
    String? note,
    bool clearNote = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      amountKurus: amountKurus ?? this.amountKurus,
      type: type ?? this.type,
      status: status ?? this.status,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: clearNote ? null : (note ?? this.note),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'amount_kurus': amountKurus,
      'type': type.name,
      'status': status.name,
      'category_id': categoryId,
      'date_ms': date.millisecondsSinceEpoch,
      'note': note,
      'created_at_ms': createdAt.millisecondsSinceEpoch,
      'updated_at_ms': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory TransactionRecord.fromMap(Map<String, Object?> map) {
    final typeStr = map['type'] as String? ?? 'expense';
    final statusStr = map['status'] as String? ?? 'completed';

    return TransactionRecord(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      amountKurus: map['amount_kurus'] as int? ?? 0,
      type: typeStr == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      status: statusStr == 'pending'
          ? TransactionStatus.pending
          : TransactionStatus.completed,
      categoryId: map['category_id'] as String? ?? 'exp_diger',
      date: DateTime.fromMillisecondsSinceEpoch(map['date_ms'] as int),
      note: map['note'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['created_at_ms'] as int,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map['updated_at_ms'] as int,
      ),
    );
  }
}
