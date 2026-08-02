import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:nexora_khata/core/services/database_helper.dart';
import 'package:nexora_khata/features/loans/data/datasources/loan_datasource.dart';
import 'package:nexora_khata/features/loans/data/models/loan_contact_model.dart';
import 'package:nexora_khata/features/loans/data/models/loan_transaction_model.dart';

class _FakePathProvider extends PathProviderPlatform {
  final String dir;
  _FakePathProvider(this.dir);
  @override
  Future<String?> getApplicationDocumentsPath() async => dir;
  @override
  Future<String?> getTemporaryPath() async => dir;
}

void main() {
  late Directory tempDir;
  late DatabaseHelper db;
  late LoanDataSource ds;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('nexora_loan_');
    PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
    db = DatabaseHelper();
    await db.open();
    ds = LoanDataSource(db);
    final now = DateTime.now();
    await ds.createContact(LoanContactModel(
      id: 0,
      businessId: 0,
      name: 'রহিম',
      createdAt: now,
      updatedAt: now,
    ).toMap());
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  Future<int> contactId() async {
    final contacts = await ds.getContacts();
    return contacts.first.id;
  }

  Future<void> addTxn(String type, double amount, {String? repayType}) async {
    final cid = await contactId();
    final now = DateTime.now();
    await ds.createTransaction(LoanTransactionModel(
      id: 0,
      businessId: 0,
      contactId: cid,
      type: type,
      repayType: repayType,
      amount: amount,
      date: now,
      createdAt: now,
      updatedAt: now,
    ).toMap());
  }

  Future<List<LoanTransactionModel>> txns() async =>
      ds.getTransactions(await contactId());

  test('repay_type column exists and accepts repay transactions', () async {
    await addTxn('lend', 5000);
    await addTxn('repay', 2000, repayType: 'lend');
    final all = await ds.getAllTransactions();
    expect(all, hasLength(2));
    final repay = all.firstWhere((t) => t.isRepay);
    expect(repay.repaysLend, isTrue);
    expect(repay.amount, 2000);
  });

  test('payment_method and account ids persist on loan transactions', () async {
    final cid = await contactId();
    final now = DateTime.now();
    final bankId = await db.db.insert('bank_accounts', {
      'business_id': 0,
      'bank_name': 'ব্যাংক',
      'account_name': 'ব্যাংক',
      'balance': 0.0,
      'currency': 'BDT',
      'is_default': 1,
      'status': 'active',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
    await ds.createTransaction(LoanTransactionModel(
      id: 0,
      businessId: 0,
      contactId: cid,
      type: 'borrow',
      amount: 2000,
      date: now,
      paymentMethod: 'bank',
      cashAccountId: null,
      bankAccountId: bankId,
      createdAt: now,
      updatedAt: now,
    ).toMap());
    final all = await ds.getTransactions(cid);
    expect(all, hasLength(1));
    expect(all.first.paymentMethod, 'bank');
    expect(all.first.bankAccountId, bankId);
    expect(all.first.isCash, isFalse);
  });

  test('borrow + repay-borrow nets out', () async {
    await addTxn('borrow', 3000);
    await addTxn('repay', 1000, repayType: 'borrow');
    final all = await txns();
    final totalBorrow = all
        .where((t) => t.isBorrow)
        .fold<double>(0, (s, t) => s + t.amount);
    final repaidBorrow = all
        .where((t) => t.repaysBorrow)
        .fold<double>(0, (s, t) => s + t.amount);
    expect(totalBorrow, 3000);
    expect(repaidBorrow, 1000);
    expect(totalBorrow - repaidBorrow, 2000,
        reason: 'remaining borrow after repayment should be 2000');
  });

  test('lend + repay-lend nets out', () async {
    await addTxn('lend', 10000);
    await addTxn('repay', 4000, repayType: 'lend');
    await addTxn('repay', 6000, repayType: 'lend');
    final all = await txns();
    final totalLend = all
        .where((t) => t.isLend)
        .fold<double>(0, (s, t) => s + t.amount);
    final repaidLend = all
        .where((t) => t.repaysLend)
        .fold<double>(0, (s, t) => s + t.amount);
    expect(totalLend, 10000);
    expect(repaidLend, 10000);
    expect(totalLend - repaidLend, 0,
        reason: 'loan fully repaid should leave zero outstanding');
  });

  test('repay with wrong repay_type is distinguishable', () async {
    await addTxn('borrow', 5000);
    await addTxn('repay', 5000, repayType: 'lend');
    final all = await txns();
    final repaidBorrow = all
        .where((t) => t.repaysBorrow)
        .fold<double>(0, (s, t) => s + t.amount);
    final repaidLend = all
        .where((t) => t.repaysLend)
        .fold<double>(0, (s, t) => s + t.amount);
    expect(repaidBorrow, 0);
    expect(repaidLend, 5000);
  });

  test('delete repay transaction reverts outstanding', () async {
    await addTxn('lend', 5000);
    await addTxn('repay', 2000, repayType: 'lend');
    final all = await txns();
    final repay = all.firstWhere((t) => t.isRepay);
    await ds.deleteTransaction(repay.id);
    final after = await txns();
    expect(after, hasLength(1));
    expect(after.first.isLend, isTrue);
  });

  test('v8 to v9 upgrade rebuilds loan_transactions and keeps data', () async {
    final oldDir = await Directory.systemTemp.createTemp('nexora_upgrade_');
    addTearDown(() => oldDir.deleteSync(recursive: true));
    final path = '${oldDir.path}${Platform.pathSeparator}upgrade_test.db';

    databaseFactory = databaseFactoryFfi;
    final oldDb = await openDatabase(
      path,
      version: 8,
      onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL, email TEXT, phone TEXT,
            password_hash TEXT, pin TEXT, avatar_path TEXT,
            is_active INTEGER NOT NULL DEFAULT 1,
            last_login_at TEXT,
            status TEXT NOT NULL DEFAULT 'active'
              CHECK(status IN ('active','inactive','suspended')),
            created_at TEXT NOT NULL DEFAULT (datetime('now')),
            updated_at TEXT NOT NULL DEFAULT (datetime('now'))
          )
        ''');
        await db.execute('''
          CREATE TABLE businesses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER, name TEXT NOT NULL, currency TEXT NOT NULL DEFAULT 'BDT',
            status TEXT NOT NULL DEFAULT 'active',
            created_at TEXT NOT NULL DEFAULT (datetime('now')),
            updated_at TEXT NOT NULL DEFAULT (datetime('now'))
          )
        ''');
        await db.execute('''
          CREATE TABLE loan_contacts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            business_id INTEGER NOT NULL, name TEXT NOT NULL,
            phone TEXT, note TEXT,
            created_at TEXT NOT NULL DEFAULT (datetime('now')),
            updated_at TEXT NOT NULL DEFAULT (datetime('now')),
            FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE loan_transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            business_id INTEGER NOT NULL,
            contact_id INTEGER NOT NULL,
            type TEXT NOT NULL CHECK(type IN ('borrow','lend')),
            amount REAL NOT NULL CHECK(amount > 0),
            date TEXT NOT NULL,
            note TEXT,
            created_at TEXT NOT NULL DEFAULT (datetime('now')),
            updated_at TEXT NOT NULL DEFAULT (datetime('now')),
            FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
            FOREIGN KEY (contact_id) REFERENCES loan_contacts(id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE incomes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            business_id INTEGER NOT NULL,
            customer_id INTEGER, category_id INTEGER,
            amount REAL NOT NULL, description TEXT, reference TEXT,
            image_path TEXT, cash_account_id INTEGER, bank_account_id INTEGER,
            income_date TEXT NOT NULL, payment_method TEXT,
            is_recurring INTEGER NOT NULL DEFAULT 0,
            status TEXT NOT NULL DEFAULT 'completed',
            created_at TEXT NOT NULL DEFAULT (datetime('now')),
            updated_at TEXT NOT NULL DEFAULT (datetime('now'))
          )
        ''');
        await db.execute('''
          CREATE TABLE expenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            business_id INTEGER NOT NULL,
            supplier_id INTEGER, category_id INTEGER,
            amount REAL NOT NULL, description TEXT, reference TEXT,
            image_path TEXT, cash_account_id INTEGER, bank_account_id INTEGER,
            expense_date TEXT NOT NULL, payment_method TEXT,
            is_recurring INTEGER NOT NULL DEFAULT 0,
            status TEXT NOT NULL DEFAULT 'completed',
            created_at TEXT NOT NULL DEFAULT (datetime('now')),
            updated_at TEXT NOT NULL DEFAULT (datetime('now'))
          )
        ''');
        await db.execute('''
          CREATE TABLE transfers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            business_id INTEGER NOT NULL,
            from_cash_account_id INTEGER, from_bank_account_id INTEGER,
            to_cash_account_id INTEGER, to_bank_account_id INTEGER,
            amount REAL NOT NULL, fee REAL NOT NULL DEFAULT 0,
            description TEXT, transfer_date TEXT NOT NULL,
            status TEXT NOT NULL DEFAULT 'completed',
            created_at TEXT NOT NULL DEFAULT (datetime('now')),
            updated_at TEXT NOT NULL DEFAULT (datetime('now'))
          )
        ''');
        await db.execute('''
          CREATE TABLE cash_accounts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            business_id INTEGER NOT NULL, name TEXT NOT NULL,
            balance REAL NOT NULL DEFAULT 0, currency TEXT NOT NULL DEFAULT 'BDT',
            is_default INTEGER NOT NULL DEFAULT 0, status TEXT NOT NULL DEFAULT 'active',
            created_at TEXT NOT NULL DEFAULT (datetime('now')),
            updated_at TEXT NOT NULL DEFAULT (datetime('now'))
          )
        ''');
        await db.execute('''
          CREATE TABLE bank_accounts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            business_id INTEGER NOT NULL, bank_name TEXT NOT NULL,
            account_name TEXT NOT NULL, account_number TEXT,
            balance REAL NOT NULL DEFAULT 0, currency TEXT NOT NULL DEFAULT 'BDT',
            is_default INTEGER NOT NULL DEFAULT 0, status TEXT NOT NULL DEFAULT 'active',
            created_at TEXT NOT NULL DEFAULT (datetime('now')),
            updated_at TEXT NOT NULL DEFAULT (datetime('now'))
          )
        ''');
        await db.execute('''
          CREATE TABLE income_categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            business_id INTEGER NOT NULL, name TEXT NOT NULL,
            icon TEXT, color TEXT, sort_order INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL DEFAULT (datetime('now')),
            updated_at TEXT NOT NULL DEFAULT (datetime('now'))
          )
        ''');
        await db.execute('''
          CREATE TABLE expense_categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            business_id INTEGER NOT NULL, name TEXT NOT NULL,
            icon TEXT, color TEXT, sort_order INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL DEFAULT (datetime('now')),
            updated_at TEXT NOT NULL DEFAULT (datetime('now'))
          )
        ''');
        await db.execute('''
          CREATE TABLE _migrations (
            version INTEGER PRIMARY KEY, name TEXT NOT NULL,
            applied_at TEXT NOT NULL DEFAULT (datetime('now'))
          )
        ''');
        await db.execute(
            'INSERT INTO _migrations (version, name) VALUES (1, \'initial_schema\')');
      },
    );
    await oldDb.insert('businesses', {
      'id': 0, 'user_id': 0, 'name': 'আমার ব্যবসা', 'currency': 'BDT',
      'status': 'active',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
    await oldDb.insert('loan_contacts', {
      'business_id': 0, 'name': 'করিম',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
    await oldDb.insert('loan_transactions', {
      'business_id': 0, 'contact_id': 1, 'type': 'lend', 'amount': 7000,
      'date': '2026-08-01',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
    await oldDb.close();

    await db.close();

    PathProviderPlatform.instance = _FakePathProvider(oldDir.path);
    final dbh = DatabaseHelper();
    await dbh.open(dbName: 'upgrade_test.db');
    addTearDown(() => dbh.close());

    final upgradedDs = LoanDataSource(dbh);
    final contacts = await upgradedDs.getContacts();
    expect(contacts, hasLength(1));
    expect(contacts.first.name, 'করিম');
    final txnsUpgraded = await upgradedDs.getTransactions(contacts.first.id);
    expect(txnsUpgraded, hasLength(1));
    expect(txnsUpgraded.first.amount, 7000);

    final columns = await dbh.db.rawQuery(
        'PRAGMA table_info(loan_transactions)');
    final colNames = columns.map((c) => c['name']).toSet();
    expect(colNames, contains('repay_type'), reason: 'repay_type added by v9');
    expect(colNames, contains('payment_method'),
        reason: 'payment_method added by v10');
    expect(colNames, contains('cash_account_id'),
        reason: 'cash_account_id added by v10');
    expect(colNames, contains('bank_account_id'),
        reason: 'bank_account_id added by v10');

    await upgradedDs.createTransaction(LoanTransactionModel(
      id: 0,
      businessId: 0,
      contactId: contacts.first.id,
      type: 'repay',
      repayType: 'lend',
      amount: 2000,
      date: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ).toMap());
    final after = await upgradedDs.getTransactions(contacts.first.id);
    expect(after, hasLength(2));
    expect(after.first.isRepay, isTrue);
  });
}
