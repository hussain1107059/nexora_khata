import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'database_config.dart';
import 'logger.dart';

typedef DbBatchCallback = Future<void> Function(Batch batch);
typedef DbTxnCallback<T> = Future<T> Function(Transaction txn);

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _db;

  Database get db {
    if (_db == null) throw StateError('Database not initialized');
    return _db!;
  }

  bool get isInitialized => _db != null;

  Future<Database> open({String? dbName}) async {
    if (_db != null) return _db!;
    final name = dbName ?? DatabaseConfig.dbName;

    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWebNoWebWorker;
      try {
        _db = await openDatabase(
          name,
          version: DatabaseConfig.dbVersion,
          onCreate: _createSchema,
          onUpgrade: _upgradeSchema,
          onConfigure: _configure,
          singleInstance: true,
        );
      } catch (e) {
        log.e('[DB] web open failed: $e');
        rethrow;
      }
      await _applyMigrations();
      return _db!;
    }

    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, name);
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    try {
      _db = await openDatabase(
        path,
        version: DatabaseConfig.dbVersion,
        onCreate: _createSchema,
        onUpgrade: _upgradeSchema,
        onConfigure: _configure,
        singleInstance: true,
      );
    } catch (e) {
      log.w('[DB] open failed: $e');
      try {
        final f = File(path);
        if (await f.exists()) await f.delete();
        log.i('[DB] deleted db file, retrying...');
        _db = await openDatabase(
          path,
          version: DatabaseConfig.dbVersion,
          onCreate: _createSchema,
          onUpgrade: _upgradeSchema,
          onConfigure: _configure,
          singleInstance: true,
        );
      } catch (e2) {
        log.e('[DB] retry also failed: $e2');
        rethrow;
      }
    }
    await _applyMigrations();
    return _db!;
  }

  Future<void> _configure(Database db) async {
    try {
      await db.execute('PRAGMA journal_mode=${DatabaseConfig.journalMode}');
    } catch (_) {}
    try {
      await db.execute('PRAGMA synchronous=${DatabaseConfig.synchronous}');
    } catch (_) {}
    try {
      await db.execute('PRAGMA cache_size=${DatabaseConfig.cacheSize}');
    } catch (_) {}
    try {
      await db.execute('PRAGMA busy_timeout=${DatabaseConfig.busyTimeout}');
    } catch (_) {}
    try {
      if (DatabaseConfig.foreignKeys) {
        await db.execute('PRAGMA foreign_keys=ON');
      }
    } catch (_) {}
  }

  Future<void> _createSchema(Database db, int version) async {
    final batch = db.batch();
    _createUsersTable(batch);
    _createBusinessesTable(batch);
    _createCustomersTable(batch);
    _createSuppliersTable(batch);
    _createCashAccountsTable(batch);
    _createBankAccountsTable(batch);
    _createIncomeCategoriesTable(batch);
    _createExpenseCategoriesTable(batch);
    _createIncomesTable(batch);
    _createExpensesTable(batch);
    _createTransfersTable(batch);
    _createDailyBalanceTable(batch);
    _createNotesTable(batch);
    _createAttachmentsTable(batch);
    _createSettingsTable(batch);
    _createBackupLogsTable(batch);
    _createMigrationsTable(batch);
    _createIndexes(batch);
    await batch.commit(noResult: true);
    _createTriggers(db);
    await _recordMigration(db, version, 'initial_schema');
    await _seedDefaults(db);
  }

  void _createUsersTable(Batch b) {
    b.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        password_hash TEXT,
        pin TEXT,
        avatar_path TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        last_login_at TEXT,
        status TEXT NOT NULL DEFAULT 'active'
          CHECK(status IN ('active','inactive','suspended')),
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');
  }

  void _createBusinessesTable(Batch b) {
    b.execute('''
      CREATE TABLE businesses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        type TEXT,
        phone TEXT,
        email TEXT,
        address TEXT,
        logo_path TEXT,
        currency TEXT NOT NULL DEFAULT 'BDT',
        fiscal_year_start TEXT,
        registration_no TEXT,
        tax_id TEXT,
        notes TEXT,
        status TEXT NOT NULL DEFAULT 'active'
          CHECK(status IN ('active','inactive')),
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }

  void _createCustomersTable(Batch b) {
    b.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        address TEXT,
        company TEXT,
        opening_balance REAL NOT NULL DEFAULT 0,
        credit_limit REAL,
        notes TEXT,
        status TEXT NOT NULL DEFAULT 'active'
          CHECK(status IN ('active','inactive','blocked')),
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE
      )
    ''');
  }

  void _createSuppliersTable(Batch b) {
    b.execute('''
      CREATE TABLE suppliers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        address TEXT,
        company TEXT,
        opening_balance REAL NOT NULL DEFAULT 0,
        credit_limit REAL,
        notes TEXT,
        status TEXT NOT NULL DEFAULT 'active'
          CHECK(status IN ('active','inactive','blocked')),
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE
      )
    ''');
  }

  void _createCashAccountsTable(Batch b) {
    b.execute('''
      CREATE TABLE cash_accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        balance REAL NOT NULL DEFAULT 0,
        currency TEXT NOT NULL DEFAULT 'BDT',
        description TEXT,
        is_default INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'active'
          CHECK(status IN ('active','inactive','closed')),
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE
      )
    ''');
  }

  void _createBankAccountsTable(Batch b) {
    b.execute('''
      CREATE TABLE bank_accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_id INTEGER NOT NULL,
        bank_name TEXT NOT NULL,
        account_name TEXT NOT NULL,
        account_number TEXT,
        branch TEXT,
        swift_code TEXT,
        routing_number TEXT,
        balance REAL NOT NULL DEFAULT 0,
        currency TEXT NOT NULL DEFAULT 'BDT',
        description TEXT,
        is_default INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'active'
          CHECK(status IN ('active','inactive','closed')),
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE
      )
    ''');
  }

  void _createIncomeCategoriesTable(Batch b) {
    b.execute('''
      CREATE TABLE income_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        icon TEXT,
        color TEXT,
        parent_id INTEGER,
        sort_order INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'active'
          CHECK(status IN ('active','inactive')),
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
        FOREIGN KEY (parent_id) REFERENCES income_categories(id)
          ON DELETE SET NULL
      )
    ''');
  }

  void _createExpenseCategoriesTable(Batch b) {
    b.execute('''
      CREATE TABLE expense_categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        icon TEXT,
        color TEXT,
        parent_id INTEGER,
        sort_order INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'active'
          CHECK(status IN ('active','inactive')),
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
        FOREIGN KEY (parent_id) REFERENCES expense_categories(id)
          ON DELETE SET NULL
      )
    ''');
  }

  void _createIncomesTable(Batch b) {
    b.execute('''
      CREATE TABLE incomes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_id INTEGER NOT NULL,
        customer_id INTEGER,
        cash_account_id INTEGER,
        bank_account_id INTEGER,
        category_id INTEGER NOT NULL,
        amount REAL NOT NULL CHECK(amount > 0),
        description TEXT,
        reference TEXT,
        image_path TEXT,
        income_date TEXT NOT NULL,
        payment_method TEXT,
        is_recurring INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'completed'
          CHECK(status IN ('completed','pending','cancelled')),
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
        FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL,
        FOREIGN KEY (cash_account_id) REFERENCES cash_accounts(id)
          ON DELETE SET NULL,
        FOREIGN KEY (bank_account_id) REFERENCES bank_accounts(id)
          ON DELETE SET NULL,
        FOREIGN KEY (category_id) REFERENCES income_categories(id)
          ON DELETE RESTRICT
      )
    ''');
  }

  void _createExpensesTable(Batch b) {
    b.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_id INTEGER NOT NULL,
        supplier_id INTEGER,
        cash_account_id INTEGER,
        bank_account_id INTEGER,
        category_id INTEGER NOT NULL,
        amount REAL NOT NULL CHECK(amount > 0),
        description TEXT,
        reference TEXT,
        image_path TEXT,
        expense_date TEXT NOT NULL,
        payment_method TEXT,
        is_recurring INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'completed'
          CHECK(status IN ('completed','pending','cancelled')),
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
        FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE SET NULL,
        FOREIGN KEY (cash_account_id) REFERENCES cash_accounts(id)
          ON DELETE SET NULL,
        FOREIGN KEY (bank_account_id) REFERENCES bank_accounts(id)
          ON DELETE SET NULL,
        FOREIGN KEY (category_id) REFERENCES expense_categories(id)
          ON DELETE RESTRICT
      )
    ''');
  }

  void _createTransfersTable(Batch b) {
    b.execute('''
      CREATE TABLE transfers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_id INTEGER NOT NULL,
        from_type TEXT NOT NULL CHECK(from_type IN ('cash','bank')),
        from_cash_account_id INTEGER,
        from_bank_account_id INTEGER,
        to_type TEXT NOT NULL CHECK(to_type IN ('cash','bank')),
        to_cash_account_id INTEGER,
        to_bank_account_id INTEGER,
        amount REAL NOT NULL CHECK(amount > 0),
        description TEXT,
        reference TEXT,
        transfer_date TEXT NOT NULL,
        fee REAL NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'completed'
          CHECK(status IN ('completed','pending','cancelled')),
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
        FOREIGN KEY (from_cash_account_id) REFERENCES cash_accounts(id)
          ON DELETE SET NULL,
        FOREIGN KEY (from_bank_account_id) REFERENCES bank_accounts(id)
          ON DELETE SET NULL,
        FOREIGN KEY (to_cash_account_id) REFERENCES cash_accounts(id)
          ON DELETE SET NULL,
        FOREIGN KEY (to_bank_account_id) REFERENCES bank_accounts(id)
          ON DELETE SET NULL
      )
    ''');
  }

  void _createDailyBalanceTable(Batch b) {
    b.execute('''
      CREATE TABLE daily_balance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        total_cash REAL NOT NULL DEFAULT 0,
        total_bank REAL NOT NULL DEFAULT 0,
        total_income REAL NOT NULL DEFAULT 0,
        total_expense REAL NOT NULL DEFAULT 0,
        net_balance REAL NOT NULL DEFAULT 0,
        previous_day_balance REAL NOT NULL DEFAULT 0,
        notes TEXT,
        status TEXT NOT NULL DEFAULT 'active'
          CHECK(status IN ('active','locked')),
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
        UNIQUE(business_id, date)
      )
    ''');
  }

  void _createNotesTable(Batch b) {
    b.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT,
        reference_type TEXT,
        reference_id INTEGER,
        is_pinned INTEGER NOT NULL DEFAULT 0,
        color TEXT,
        status TEXT NOT NULL DEFAULT 'active'
          CHECK(status IN ('active','archived','deleted')),
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE
      )
    ''');
  }

  void _createAttachmentsTable(Batch b) {
    b.execute('''
      CREATE TABLE attachments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_id INTEGER NOT NULL,
        reference_type TEXT NOT NULL,
        reference_id INTEGER NOT NULL,
        file_name TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_size INTEGER,
        mime_type TEXT,
        notes TEXT,
        status TEXT NOT NULL DEFAULT 'active'
          CHECK(status IN ('active','deleted')),
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE
      )
    ''');
  }

  void _createSettingsTable(Batch b) {
    b.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_id INTEGER,
        key TEXT NOT NULL,
        value TEXT NOT NULL,
        type TEXT NOT NULL DEFAULT 'string'
          CHECK(type IN ('string','integer','boolean','json')),
        status TEXT NOT NULL DEFAULT 'active'
          CHECK(status IN ('active','inactive')),
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
        UNIQUE(business_id, key)
      )
    ''');
  }

  void _createBackupLogsTable(Batch b) {
    b.execute('''
      CREATE TABLE backup_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_id INTEGER,
        file_name TEXT NOT NULL,
        file_path TEXT,
        file_size INTEGER,
        type TEXT NOT NULL DEFAULT 'manual'
          CHECK(type IN ('manual','automatic','scheduled')),
        status TEXT NOT NULL DEFAULT 'completed'
          CHECK(status IN ('completed','failed','in_progress')),
        error_message TEXT,
        checksum TEXT,
        notes TEXT,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        updated_at TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE SET NULL
      )
    ''');
  }

  void _createMigrationsTable(Batch b) {
    b.execute('''
      CREATE TABLE _migrations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        version INTEGER NOT NULL UNIQUE,
        name TEXT NOT NULL,
        applied_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');
  }

  void _createIndexes(Batch b) {
    final idx = <void Function()>[
      () => b.execute('CREATE INDEX idx_businesses_user ON businesses(user_id)'),
      () => b.execute('CREATE INDEX idx_customers_business ON customers(business_id)'),
      () => b.execute('CREATE INDEX idx_customers_phone ON customers(phone)'),
      () => b.execute('CREATE INDEX idx_suppliers_business ON suppliers(business_id)'),
      () => b.execute('CREATE INDEX idx_suppliers_phone ON suppliers(phone)'),
      () => b.execute('CREATE INDEX idx_cash_accounts_business ON cash_accounts(business_id)'),
      () => b.execute('CREATE INDEX idx_bank_accounts_business ON bank_accounts(business_id)'),
      () => b.execute('CREATE INDEX idx_income_cat_business ON income_categories(business_id)'),
      () => b.execute('CREATE INDEX idx_income_cat_parent ON income_categories(parent_id)'),
      () => b.execute('CREATE INDEX idx_expense_cat_business ON expense_categories(business_id)'),
      () => b.execute('CREATE INDEX idx_expense_cat_parent ON expense_categories(parent_id)'),
      () => b.execute('CREATE INDEX idx_incomes_business ON incomes(business_id)'),
      () => b.execute('CREATE INDEX idx_incomes_date ON incomes(income_date)'),
      () => b.execute('CREATE INDEX idx_incomes_category ON incomes(category_id)'),
      () => b.execute('CREATE INDEX idx_incomes_customer ON incomes(customer_id)'),
      () => b.execute('CREATE INDEX idx_incomes_status ON incomes(status)'),
      () => b.execute('CREATE INDEX idx_incomes_date_status ON incomes(income_date, status)'),
      () => b.execute('CREATE INDEX idx_expenses_business ON expenses(business_id)'),
      () => b.execute('CREATE INDEX idx_expenses_date ON expenses(expense_date)'),
      () => b.execute('CREATE INDEX idx_expenses_category ON expenses(category_id)'),
      () => b.execute('CREATE INDEX idx_expenses_supplier ON expenses(supplier_id)'),
      () => b.execute('CREATE INDEX idx_expenses_status ON expenses(status)'),
      () => b.execute('CREATE INDEX idx_expenses_date_status ON expenses(expense_date, status)'),
      () => b.execute('CREATE INDEX idx_transfers_business ON transfers(business_id)'),
      () => b.execute('CREATE INDEX idx_transfers_date ON transfers(transfer_date)'),
      () => b.execute('CREATE INDEX idx_daily_balance_business ON daily_balance(business_id)'),
      () => b.execute('CREATE INDEX idx_daily_balance_date ON daily_balance(date)'),
      () => b.execute('CREATE INDEX idx_notes_business ON notes(business_id)'),
      () => b.execute('CREATE INDEX idx_notes_reference ON notes(reference_type, reference_id)'),
      () => b.execute('CREATE INDEX idx_attachments_reference ON attachments(reference_type, reference_id)'),
      () => b.execute('CREATE INDEX idx_settings_business ON settings(business_id)'),
      () => b.execute('CREATE INDEX idx_backup_logs_business ON backup_logs(business_id)'),
    ];
    for (final fn in idx) {
      fn();
    }
  }

  void _createTriggers(Database db) {
    final triggers = <String>[
      'CREATE TRIGGER IF NOT EXISTS trg_cash_balance_income AFTER INSERT ON incomes WHEN NEW.cash_account_id IS NOT NULL AND NEW.status = \'completed\' BEGIN UPDATE cash_accounts SET balance = balance + NEW.amount WHERE id = NEW.cash_account_id; END',
      'CREATE TRIGGER IF NOT EXISTS trg_cash_balance_expense AFTER INSERT ON expenses WHEN NEW.cash_account_id IS NOT NULL AND NEW.status = \'completed\' BEGIN UPDATE cash_accounts SET balance = balance - NEW.amount WHERE id = NEW.cash_account_id; END',
      'CREATE TRIGGER IF NOT EXISTS trg_bank_balance_income AFTER INSERT ON incomes WHEN NEW.bank_account_id IS NOT NULL AND NEW.status = \'completed\' BEGIN UPDATE bank_accounts SET balance = balance + NEW.amount WHERE id = NEW.bank_account_id; END',
      'CREATE TRIGGER IF NOT EXISTS trg_bank_balance_expense AFTER INSERT ON expenses WHEN NEW.bank_account_id IS NOT NULL AND NEW.status = \'completed\' BEGIN UPDATE bank_accounts SET balance = balance - NEW.amount WHERE id = NEW.bank_account_id; END',
      'CREATE TRIGGER IF NOT EXISTS trg_transfer_subtract AFTER INSERT ON transfers WHEN NEW.status = \'completed\' BEGIN UPDATE cash_accounts SET balance = balance - NEW.amount - NEW.fee WHERE id = NEW.from_cash_account_id; UPDATE bank_accounts SET balance = balance - NEW.amount - NEW.fee WHERE id = NEW.from_bank_account_id; END',
      'CREATE TRIGGER IF NOT EXISTS trg_transfer_add AFTER INSERT ON transfers WHEN NEW.status = \'completed\' BEGIN UPDATE cash_accounts SET balance = balance + NEW.amount WHERE id = NEW.to_cash_account_id; UPDATE bank_accounts SET balance = balance + NEW.amount WHERE id = NEW.to_bank_account_id; END',
    ];
    for (final sql in triggers) {
      try { db.execute(sql); } catch (_) {}
    }
  }

  Future<void> _seedDefaults(Database db) async {
    final batch = db.batch();

    final userCount = await db
        .rawQuery('SELECT COUNT(*) AS c FROM users WHERE id = 0');
    if (Sqflite.firstIntValue(userCount) == 0) {
      batch.insert('users', {
        'id': 0,
        'name': 'ডিফল্ট',
        'is_active': 1,
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    }

    final bizCount = await db
        .rawQuery('SELECT COUNT(*) AS c FROM businesses WHERE id = 0');
    if (Sqflite.firstIntValue(bizCount) == 0) {
      batch.insert('businesses', {
        'id': 0,
        'user_id': 0,
        'name': 'আমার ব্যবসা',
        'currency': 'BDT',
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    }

    final incomeCats = [
      'বেতন', 'ব্যবসা', 'ফ্রিল্যান্সিং', 'বিনিয়োগ',
      'উপহার', 'কমিশন', 'অন্যান্য আয়',
    ];
    for (var i = 0; i < incomeCats.length; i++) {
      batch.insert('income_categories', {
        'business_id': 0,
        'name': incomeCats[i],
        'icon': _incomeIcon(i),
        'color': _incomeColor(i),
        'sort_order': i + 1,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
    final expenseCats = [
      'খাদ্য', 'পরিবহন', 'বাসা ভাড়া', 'ইউটিলিটি',
      'বিনোদন', 'স্বাস্থ্য', 'শিক্ষা', 'শপিং',
      'ইন্টারনেট', 'ফোন বিল', 'অন্যান্য ব্যয়',
    ];
    for (var i = 0; i < expenseCats.length; i++) {
      batch.insert('expense_categories', {
        'business_id': 0,
        'name': expenseCats[i],
        'icon': _expenseIcon(i),
        'color': _expenseColor(i),
        'sort_order': i + 1,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
    await batch.commit(noResult: true);
  }

  String _incomeIcon(int i) {
    const icons = ['work', 'store', 'laptop', 'trending_up', 'card_giftcard', 'paid', 'more_horiz'];
    return icons[i % icons.length];
  }

  String _incomeColor(int i) {
    const colors = ['#8E24AA', '#1E88E5', '#43A047', '#FB8C00', '#E53935', '#00ACC1', '#757575'];
    return colors[i % colors.length];
  }

  String _expenseIcon(int i) {
    const icons = ['restaurant', 'directions_bus', 'home', 'bolt', 'movie', 'local_hospital', 'school', 'shopping_bag', 'wifi', 'phone', 'more_horiz'];
    return icons[i % icons.length];
  }

  String _expenseColor(int i) {
    const colors = ['#E53935', '#FB8C00', '#8E24AA', '#039BE5', '#43A047', '#E53935', '#1E88E5', '#FB8C00', '#00ACC1', '#757575', '#757575'];
    return colors[i % colors.length];
  }

  Future<void> _recordMigration(Database db, int version, String name) async {
    await db.insert('_migrations', {'version': version, 'name': name});
  }

  Future<void> _applyMigrations() async {}

  Future<void> _upgradeSchema(Database db, int oldVersion, int newVersion) async {
    for (var v = oldVersion + 1; v <= newVersion; v++) {
      await _applyMigration(db, v);
    }
  }

  Future<void> _applyMigration(Database db, int version) async {
    if (version == 2) {
      await db.execute('ALTER TABLE incomes ADD COLUMN image_path TEXT');
    }
    if (version == 3) {
      await db.execute('ALTER TABLE expenses ADD COLUMN image_path TEXT');
    }
    if (version == 4) {
      await db.execute(
        "UPDATE incomes SET income_date = substr(income_date, 1, 10) "
        "WHERE length(income_date) > 10",
      );
      await db.execute(
        "UPDATE expenses SET expense_date = substr(expense_date, 1, 10) "
        "WHERE length(expense_date) > 10",
      );
      await db.execute(
        "UPDATE transfers SET transfer_date = substr(transfer_date, 1, 10) "
        "WHERE length(transfer_date) > 10",
      );
    }
  }

  Future<T> runTxn<T>(DbTxnCallback<T> callback, {bool exclusive = false}) async {
    return db.transaction((t) => callback(t), exclusive: exclusive);
  }

  Future<void> runBatch(DbBatchCallback callback) async {
    final batch = db.batch();
    await callback(batch);
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    return db.query(table,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy,
        limit: limit,
        offset: offset);
  }

  Future<Map<String, dynamic>?> byId(String table, int id) async {
    final r = await db.query(table, where: 'id = ?', whereArgs: [id], limit: 1);
    return r.isNotEmpty ? r.first : null;
  }

  Future<int> insert(String table, Map<String, dynamic> values) async {
    return db.insert(table, values);
  }

  Future<int> update(String table, Map<String, dynamic> values, int id) async {
    return db.update(table, values, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateWhere(String table, Map<String, dynamic> values,
      {required String where, required List<Object?> whereArgs}) async {
    return db.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(String table, int id) async {
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteWhere(String table,
      {required String where, required List<Object?> whereArgs}) async {
    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<int> count(String table,
      {String? where, List<Object?>? whereArgs}) async {
    final r = await db.rawQuery(
        'SELECT COUNT(*) as c FROM $table${where != null ? ' WHERE $where' : ''}',
        whereArgs);
    return Sqflite.firstIntValue(r) ?? 0;
  }

  Future<double> sum(String table, String column,
      {String? where, List<Object?>? whereArgs}) async {
    final r = await db.rawQuery(
        'SELECT COALESCE(SUM($column),0) as t FROM $table${where != null ? ' WHERE $where' : ''}',
        whereArgs);
    return (r.first['t'] as num?)?.toDouble() ?? 0;
  }

  Future<bool> exists(String table,
      {required String where, required List<Object?> whereArgs}) async {
    return (await count(table, where: where, whereArgs: whereArgs)) > 0;
  }

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
