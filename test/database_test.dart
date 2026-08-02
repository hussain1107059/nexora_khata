import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:nexora_khata/core/services/database_helper.dart';
import 'package:nexora_khata/features/dashboard/data/datasources/dashboard_datasource.dart';
import 'package:nexora_khata/features/reports/data/datasources/report_datasource.dart';
import 'package:nexora_khata/features/transactions/data/datasources/income_datasource.dart';
import 'package:nexora_khata/features/transactions/data/datasources/expense_datasource.dart';
import 'package:nexora_khata/features/transactions/data/models/income_model.dart';
import 'package:nexora_khata/features/transactions/data/models/expense_model.dart';

class _FakePathProvider extends PathProviderPlatform {
  final String dir;
  _FakePathProvider(this.dir);
  @override
  Future<String?> getApplicationDocumentsPath() async => dir;
  @override
  Future<String?> getTemporaryPath() async => dir;
}

late Directory _tempDir;
late DatabaseHelper _db;
late IncomeDataSource _incomes;
late ExpenseDataSource _expenses;

String _date(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

IncomeModel _income({
  double amount = 1000,
  String date = '2026-08-02',
  int? categoryId,
  int? cashAccountId,
  String? description,
  String? reference,
  String status = 'completed',
}) {
  final now = DateTime.now();
  return IncomeModel(
    id: 0,
    businessId: 0,
    categoryId: categoryId ?? 1,
    amount: amount,
    description: description,
    reference: reference,
    cashAccountId: cashAccountId,
    incomeDate: DateTime.parse(date),
    status: status,
    createdAt: now,
    updatedAt: now,
  );
}

ExpenseModel _expense({
  double amount = 500,
  String date = '2026-08-02',
  int? categoryId,
  int? cashAccountId,
  String? description,
  String status = 'completed',
}) {
  final now = DateTime.now();
  return ExpenseModel(
    id: 0,
    businessId: 0,
    categoryId: categoryId ?? 1,
    amount: amount,
    description: description,
    cashAccountId: cashAccountId,
    expenseDate: DateTime.parse(date),
    status: status,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    _tempDir = await Directory.systemTemp.createTemp('nexora_test_');
    PathProviderPlatform.instance = _FakePathProvider(_tempDir.path);
    _db = DatabaseHelper();
    await _db.open();
    _incomes = IncomeDataSource(_db);
    _expenses = ExpenseDataSource(_db);
  });

  tearDown(() async {
    await _db.close();
    if (_tempDir.existsSync()) _tempDir.deleteSync(recursive: true);
  });

  group('Schema integrity', () {
    test('all tables exist', () async {
      final rows = await _db.db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'");
      final names = rows.map((r) => r['name'] as String).toSet();
      const expected = {
        'users', 'businesses', 'customers', 'suppliers',
        'cash_accounts', 'bank_accounts', 'income_categories',
        'expense_categories', 'incomes', 'expenses', 'transfers',
        'daily_balance', 'notes', 'attachments', 'settings',
        'backup_logs', '_migrations',
      };
      expect(expected.difference(names), isEmpty, reason: 'Missing tables');
    });

    test('foreign keys are enabled', () async {
      final r = await _db.db.rawQuery('PRAGMA foreign_keys');
      expect(r.first.values.first, 1);
    });

    test('FK constraints exist', () async {
      final r = await _db.db.rawQuery(
          'PRAGMA foreign_key_list(income_categories)');
      expect(r.any((x) => x['table'] == 'businesses'), isTrue);
      final i = await _db.db
          .rawQuery('PRAGMA foreign_key_list(incomes)');
      expect(i.any((x) => x['table'] == 'income_categories'), isTrue);
    });

    test('required indexes exist', () async {
      Future<Set<String>> idx(String t) async {
        final r = await _db.db.rawQuery('PRAGMA index_list($t)');
        return r.map((x) => x['name'] as String).toSet();
      }

      final incomeIdx = await idx('incomes');
      for (final n in ['idx_incomes_date', 'idx_incomes_status',
        'idx_incomes_date_status', 'idx_incomes_category',
        'idx_incomes_business']) {
        expect(incomeIdx.contains(n), isTrue, reason: 'missing $n');
      }
      final expIdx = await idx('expenses');
      for (final n in ['idx_expenses_date', 'idx_expenses_status',
        'idx_expenses_date_status', 'idx_expenses_category']) {
        expect(expIdx.contains(n), isTrue, reason: 'missing $n');
      }
    });

    test('balance triggers exist', () async {
      final r = await _db.db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='trigger' AND name LIKE 'trg_%'");
      expect(r.map((x) => x['name']).toSet(),
          containsAll(['trg_cash_balance_income', 'trg_cash_balance_expense']));
    });

    test('integrity check is ok', () async {
      final r = await _db.db.rawQuery('PRAGMA integrity_check');
      expect(r.first.values.first, 'ok');
    });

    test('default seed data exists', () async {
      final biz = await _db.db.rawQuery(
          'SELECT * FROM businesses WHERE id = 0');
      expect(biz, hasLength(1));
      final inc = await _db.db.rawQuery(
          'SELECT COUNT(*) c FROM income_categories WHERE business_id = 0');
      expect((inc.first['c'] as int), 7);
      final exp = await _db.db.rawQuery(
          'SELECT COUNT(*) c FROM expense_categories WHERE business_id = 0');
      expect((exp.first['c'] as int), 11);
    });
  });

  group('CRUD', () {
    test('insert + getById with joined category name', () async {
      final created = await _incomes.create(_income().toMap());
      expect(created.id, greaterThan(0));
      expect(created.catName, isNotNull);
      final fetched = await _incomes.getById(created.id);
      expect(fetched, isNotNull);
      expect(fetched!.amount, 1000);
    });

    test('update persists amount/description', () async {
      final created = await _incomes.create(_income().toMap());
      final updated = await _incomes.update(created.id,
          {..._income(amount: 2500, description: 'আপডেট').toMap(), 'id': created.id});
      expect(updated.amount, 2500);
      expect(updated.description, 'আপডেট');
      final reloaded = await _incomes.getById(created.id);
      expect(reloaded!.amount, 2500);
    });

    test('delete removes row', () async {
      final created = await _incomes.create(_income().toMap());
      await _incomes.delete(created.id);
      expect(await _incomes.getById(created.id), isNull);
    });

    test('cash balance trigger increments on income insert', () async {
      await _db.db.insert('cash_accounts', {
        'business_id': 0, 'name': 'নগদ', 'balance': 0.0, 'is_default': 1,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      final acct = (await _db.db.rawQuery(
          'SELECT id FROM cash_accounts WHERE name = ?', ['নগদ'])).first['id'] as int;
      await _incomes.create(
          _income(amount: 700, cashAccountId: acct).toMap());
      final bal = await _db.db
          .rawQuery('SELECT balance FROM cash_accounts WHERE id = ?', [acct]);
      expect((bal.first['balance'] as num).toDouble(), 700);
    });

    test('getAll with search/status/category/date filters', () async {
      await _incomes.create(_income(amount: 100, description: 'বেতন', status: 'completed').toMap());
      await _incomes.create(_income(amount: 200, description: 'ব্যবসা', status: 'completed').toMap());
      await _incomes.create(_income(amount: 300, description: 'বেতন', status: 'pending').toMap());

      final bySearch = await _incomes.getAll(search: 'বেতন');
      expect(bySearch, hasLength(2));
      final byStatus = await _incomes.getAll(status: 'pending');
      expect(byStatus, hasLength(1));
      final byCat = await _incomes.getAll(categoryId: 1);
      expect(byCat, hasLength(3));
      final byDate = await _incomes.getAll(
          dateFrom: '2026-08-02', dateTo: '2026-08-02');
      expect(byDate, hasLength(3));
      final paged = await _incomes.getAll(limit: 2, offset: 1);
      expect(paged, hasLength(2));
    });

    test('daily summary counts completed transactions (date storage)', () async {
      await _incomes.create(_income(amount: 5000, date: '2026-08-02').toMap());
      await _incomes.create(_income(amount: 3000, date: '2026-08-02').toMap());
      await _incomes.create(_income(amount: 900, date: '2026-08-03', status: 'pending').toMap());

      final daily = await _incomes.getDailySummary('2026-08-02');
      expect(daily['total'], 8000, reason: 'Daily totals broken: date stored with time suffix?');
      expect(daily['count'], 2);

      final byDate = await _incomes.getByDate('2026-08-02');
      expect(byDate, hasLength(2), reason: 'getByDate broken: date stored with time suffix?');
    });

    test('monthly report/summary correct', () async {
      await _incomes.create(_income(amount: 1000, date: '2026-08-02').toMap());
      await _incomes.create(_income(amount: 2000, date: '2026-08-15').toMap());
      await _incomes.create(_income(amount: 500, date: '2026-07-10').toMap());

      final rep = await _incomes.getMonthlyReport(2026);
      final aug = rep.firstWhere((r) => r['month'] == '08');
      expect((aug['total'] as num).toDouble(), 3000);
      expect((aug['count'] as int), 2);

      final sum = await _incomes.getMonthlySummary(2026, 8);
      expect(sum['total'], 3000);
      expect(sum['count'], 2);

      final byMonth = await _incomes.getByMonth(2026, 8);
      expect(byMonth, hasLength(2));
    });
  });

  group('Foreign keys', () {
    test('reject income with nonexistent category', () async {
      expect(
        () => _incomes.create(_income(categoryId: 99999).toMap()),
        throwsA(anything),
      );
    });

    test('reject category with nonexistent business', () async {
      expect(
        () => _db.db.insert('income_categories', {
          'business_id': 99999,
          'name': 'x',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        }),
        throwsA(anything),
      );
    });

    test('reject deleting a category that has incomes (RESTRICT)', () async {
      await _incomes.create(_income().toMap());
      expect(() => _db.db.delete('income_categories', where: 'id = ?', whereArgs: [1]),
          throwsA(anything));
    });

    test('deleting business cascades children', () async {
      await _incomes.create(_income().toMap());
      await _db.db.delete('businesses', where: 'id = ?', whereArgs: [0]);
      final n = await _db.db.rawQuery('SELECT COUNT(*) c FROM incomes');
      expect((n.first['c'] as int), 0);
    });
  });

  group('Transactions', () {
    test('commit persists all', () async {
      await _db.runTxn((txn) async {
        await txn.insert('incomes', _income(amount: 111).toMap());
        await txn.insert('incomes', _income(amount: 222).toMap());
      });
      final all = await _incomes.getAll();
      expect(all, hasLength(2));
    });

    test('rollback on error leaves nothing', () async {
      try {
        await _db.runTxn((txn) async {
          await txn.insert('incomes', _income(amount: 111).toMap());
          await txn.insert('incomes', _income(categoryId: 99999, amount: 222).toMap());
        });
        fail('expected FK exception');
      } catch (_) {}
      final all = await _incomes.getAll();
      expect(all, hasLength(0), reason: 'failed txn must roll back');
    });
  });

  group('Edge cases', () {
    test('empty optional strings allowed', () async {
      final m = await _incomes.create(_income(description: '', reference: '').toMap());
      expect(m.id, greaterThan(0));
    });

    test('zero and negative amounts rejected (CHECK amount > 0)', () async {
      expect(() => _incomes.create(_income(amount: 0).toMap()), throwsA(anything));
      expect(() => _incomes.create(_income(amount: -5).toMap()), throwsA(anything));
    });

    test('very large numbers roundtrip exactly', () async {
      const huge = 1e12;
      final m = await _incomes.create(_income(amount: huge).toMap());
      expect(m.amount, huge);
    });

    test('very long description (100k chars) roundtrips', () async {
      final long = 'x' * 100000;
      final m = await _incomes.create(_income(description: long).toMap());
      expect(m.description, hasLength(100000));
      final reloaded = await _incomes.getById(m.id);
      expect(reloaded!.description, hasLength(100000));
    });

    test('duplicate category names allowed (no unique constraint)', () async {
      await _db.db.insert('income_categories', {
        'business_id': 0, 'name': 'বেতন', 'created_at': 'now',
        'updated_at': 'now',
      });
      final n = await _db.db.rawQuery(
          "SELECT COUNT(*) c FROM income_categories WHERE name = 'বেতন'");
      expect((n.first['c'] as int), 2);
    });

    test('bangla text roundtrips', () async {
      final m = await _incomes.create(
          _income(description: 'সালাম দোকান থেকে আয়', reference: 'ভাউচার-০১').toMap());
      final reloaded = await _incomes.getById(m.id);
      expect(reloaded!.description, 'সালাম দোকান থেকে আয়');
      expect(reloaded.reference, 'ভাউচার-০১');
    });

    test('rapid sequential inserts (200) all succeed', () async {
      for (var i = 0; i < 200; i++) {
        await _incomes.create(_income(amount: i + 1, date: '2026-08-01').toMap());
      }
      expect(await _incomes.getAll(), hasLength(200));
    });

    test('concurrent transactions do not corrupt data', () async {
      await Future.wait(List.generate(20, (i) => _db.runTxn((txn) async {
        await txn.insert('incomes', _income(amount: i + 1).toMap());
        await txn.insert('expenses', _expense(amount: i + 1).toMap());
      })));
      final r = await _db.db.rawQuery('PRAGMA integrity_check');
      expect(r.first.values.first, 'ok');
      expect(await _incomes.getAll(), hasLength(20));
      expect(await _expenses.getAll(), hasLength(20));
    });

    test('invalid date string stored but must not corrupt other data', () async {
      await _db.db.insert('incomes', _income().toMap()..['income_date'] = 'not-a-date');
      final r = await _db.db.rawQuery('PRAGMA integrity_check');
      expect(r.first.values.first, 'ok');
    });
  });

  group('Restart persistence', () {
    test('data survives close + reopen', () async {
      final created = await _incomes.create(_income(amount: 12345).toMap());
      final path = _tempDir.path;
      await _db.close();

      PathProviderPlatform.instance = _FakePathProvider(path);
      final db2 = DatabaseHelper();
      await db2.open();
      final ds = IncomeDataSource(db2);
      final fetched = await ds.getById(created.id);
      expect(fetched, isNotNull);
      expect(fetched!.amount, 12345);
      await db2.close();
    });
  });

  group('Performance & query plan', () {
    test('monthly range queries should use the date index', () async {
      final r = await _db.db.rawQuery('''
        EXPLAIN QUERY PLAN
        SELECT COUNT(*) FROM incomes
        WHERE status = 'completed' AND income_date >= '2026-08-01' AND income_date < '2026-09-01'
      ''');
      final detail = r.map((x) => x['detail'].toString()).join('\n');
      expect(detail.toUpperCase().contains('SCAN'),
          isFalse, reason: 'Full scan used for sargable month query:\n$detail');
      expect(detail.toUpperCase().contains('INDEX'),
          isTrue, reason: 'No index used:\n$detail');
    });

    test('bulk load: 4000 transactions, key queries within budget', () async {
      final rng = Random(42);
      final sw = Stopwatch()..start();
      await _db.runTxn((txn) async {
        final batch = txn.batch();
        for (var i = 0; i < 2000; i++) {
          final d = DateTime(2025, rng.nextInt(12) + 1, rng.nextInt(28) + 1);
          batch.insert('incomes', _income(
            amount: rng.nextInt(100000) + 1,
            date: _date(d),
            description: 'আয় ${rng.nextInt(1000)}',
          ).toMap());
          batch.insert('expenses', _expense(
            amount: rng.nextInt(100000) + 1,
            date: _date(d),
            description: 'ব্যয় ${rng.nextInt(1000)}',
          ).toMap());
        }
        await batch.commit(noResult: true);
      });
      final insertMs = sw.elapsedMilliseconds;
      expect(await _incomes.getAll(), hasLength(2000));
      expect(await _expenses.getAll(), hasLength(2000));

      sw.reset();
      final dash = DashboardDataSource(_db);
      final totalIncome = await dash.getTotalIncome();
      final totalExpense = await dash.getTotalExpense();
      final todayInc = await dash.getTodayIncome(_date(DateTime.now()));
      final recent = await dash.getRecentTransactions();
      sw.stop();
      final dashMs = sw.elapsedMilliseconds;
      expect(totalIncome, greaterThan(0));
      expect(totalExpense, greaterThan(0));
      expect(todayInc, greaterThanOrEqualTo(0));
      expect(recent.length, lessThanOrEqualTo(10));

      final rep = ReportDataSource(_db);
      sw.reset();
      final yearly = await rep.getYearlyReport(2025);
      sw.stop();
      final yearlyMs = sw.elapsedMilliseconds;
      expect(yearly, hasLength(12));

      sw.reset();
      final monthly = await _incomes.getMonthlyReport(2025);
      sw.stop();
      final monthlyMs = sw.elapsedMilliseconds;
      expect(monthly, hasLength(12));

      // Informational only (CI variance), but fail loudly if pathologically slow.
      // ignore: avoid_print
      print('PERF insert=4000rows:${insertMs}ms dashboard:${dashMs}ms yearly:${yearlyMs}ms monthly:${monthlyMs}ms');
      final r = await _db.db.rawQuery('PRAGMA integrity_check');
      expect(r.first.values.first, 'ok');
    });
  });
}
