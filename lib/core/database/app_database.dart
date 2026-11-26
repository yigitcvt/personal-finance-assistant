import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../features/scheduled_payments/domain/scheduled_payment_model.dart';
import '../../features/transactions/domain/transaction_model.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'personal_finance_assistant.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount_kurus INTEGER NOT NULL,
            type TEXT NOT NULL,
            status TEXT NOT NULL,
            category_id TEXT NOT NULL,
            date_ms INTEGER NOT NULL,
            note TEXT,
            created_at_ms INTEGER NOT NULL,
            updated_at_ms INTEGER NOT NULL
          )
        ''');

        await db.execute(
          'CREATE INDEX idx_transactions_date ON transactions(date_ms DESC)',
        );

        await _createScheduledPaymentsTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createScheduledPaymentsTable(db);
        }
      },
    );
  }

  Future<void> _createScheduledPaymentsTable(Database db) async {
    await db.execute('''
      CREATE TABLE scheduled_payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount_kurus INTEGER NOT NULL,
        due_date_ms INTEGER NOT NULL,
        category_id TEXT NOT NULL,
        frequency TEXT NOT NULL,
        reminder_days_before INTEGER NOT NULL DEFAULT 1,
        is_paid INTEGER NOT NULL DEFAULT 0,
        note TEXT,
        created_at_ms INTEGER NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_scheduled_due_date ON scheduled_payments(due_date_ms ASC)',
    );
  }

  // --- Transactions ---

  Future<List<TransactionRecord>> getAllTransactions() async {
    final db = await database;
    final rows = await db.query(
      'transactions',
      orderBy: 'date_ms DESC, id DESC',
    );
    return rows.map(TransactionRecord.fromMap).toList();
  }

  Future<int> insertTransaction(TransactionRecord record) async {
    final db = await database;
    return db.insert(
      'transactions',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateTransaction(TransactionRecord record) async {
    final db = await database;
    return db.update(
      'transactions',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Scheduled Payments ---

  Future<List<ScheduledPayment>> getAllScheduledPayments() async {
    final db = await database;
    final rows = await db.query(
      'scheduled_payments',
      orderBy: 'is_paid ASC, due_date_ms ASC, id ASC',
    );
    return rows.map(ScheduledPayment.fromMap).toList();
  }

  Future<int> insertScheduledPayment(ScheduledPayment payment) async {
    final db = await database;
    return db.insert(
      'scheduled_payments',
      payment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateScheduledPayment(ScheduledPayment payment) async {
    final db = await database;
    return db.update(
      'scheduled_payments',
      payment.toMap(),
      where: 'id = ?',
      whereArgs: [payment.id],
    );
  }

  Future<int> deleteScheduledPayment(int id) async {
    final db = await database;
    return db.delete(
      'scheduled_payments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
