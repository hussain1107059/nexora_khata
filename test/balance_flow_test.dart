import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:nexora_khata/core/services/database_helper.dart';
import 'package:nexora_khata/features/dashboard/data/datasources/dashboard_datasource.dart';
import 'package:nexora_khata/features/transactions/data/datasources/expense_datasource.dart';
import 'package:nexora_khata/features/transactions/data/datasources/income_datasource.dart';
import 'package:nexora_khata/features/transactions/data/datasources/transfer_datasource.dart';
import 'package:nexora_khata/features/transactions/data/models/expense_model.dart';
import 'package:nexora_khata/features/transactions/data/models/income_model.dart';

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

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('nexora_bal_');
    PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
    db = DatabaseHelper();
    await db.open();
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('seeded accounts exist', () async {
    final cash = await db.db.rawQuery('SELECT * FROM cash_accounts');
    final bank = await db.db.rawQuery('SELECT * FROM bank_accounts');
    expect(cash, hasLength(1), reason: 'cash account should be seeded');
    expect(bank, hasLength(1), reason: 'bank account should be seeded');
  });

  test('income with default cash account updates dashboard balance', () async {
    final transferDs = TransferDataSource(db);
    final cashId = await transferDs.getDefaultCashAccountId();
    expect(cashId, isNotNull);

    final now = DateTime.now();
    final income = IncomeModel(
      id: 0,
      businessId: 0,
      categoryId: 1,
      amount: 5000,
      cashAccountId: cashId,
      incomeDate: DateTime.now(),
      status: 'completed',
      createdAt: now,
      updatedAt: now,
    );
    await IncomeDataSource(db).create(income.toMap());

    final dash = DashboardDataSource(db);
    final cashBal = await dash.getCashBalance();
    expect(cashBal, 5000, reason: 'cash balance should reflect income');
    final todayInc = await dash.getTodayIncome(
        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}');
    expect(todayInc, 5000);
  });

  test('updating income adjusts cash balance', () async {
    final transferDs = TransferDataSource(db);
    final cashId = await transferDs.getDefaultCashAccountId();
    final now = DateTime.now();
    final income = IncomeModel(
      id: 0,
      businessId: 0,
      categoryId: 1,
      amount: 5000,
      cashAccountId: cashId,
      incomeDate: DateTime.now(),
      status: 'completed',
      createdAt: now,
      updatedAt: now,
    );
    final ds = IncomeDataSource(db);
    final created = await ds.create(income.toMap());
    final id = created.id;

    await ds.update(id, {'amount': 8000});
    final dash = DashboardDataSource(db);
    expect(await dash.getCashBalance(), 8000,
        reason: 'update should adjust balance (5000 - 8000)');

    await ds.update(id, {'status': 'cancelled'});
    expect(await dash.getCashBalance(), 0,
        reason: 'cancelling should remove amount from balance');
  });

  test('deleting income reverts cash balance', () async {
    final transferDs = TransferDataSource(db);
    final cashId = await transferDs.getDefaultCashAccountId();
    final now = DateTime.now();
    final income = IncomeModel(
      id: 0,
      businessId: 0,
      categoryId: 1,
      amount: 5000,
      cashAccountId: cashId,
      incomeDate: DateTime.now(),
      status: 'completed',
      createdAt: now,
      updatedAt: now,
    );
    final ds = IncomeDataSource(db);
    final created = await ds.create(income.toMap());
    final id = created.id;
    await ds.delete(id);
    expect(await DashboardDataSource(db).getCashBalance(), 0,
        reason: 'delete should revert balance');
  });

  test('editing expense adjusts cash balance', () async {
    final transferDs = TransferDataSource(db);
    final cashId = await transferDs.getDefaultCashAccountId();
    final now = DateTime.now();
    final expense = ExpenseModel(
      id: 0,
      businessId: 0,
      categoryId: 1,
      amount: 2000,
      cashAccountId: cashId,
      expenseDate: DateTime.now(),
      status: 'completed',
      createdAt: now,
      updatedAt: now,
    );
    final ds = ExpenseDataSource(db);
    final created = await ds.create(expense.toMap());
    final id = created.id;
    expect(await DashboardDataSource(db).getCashBalance(), -2000);

    await ds.update(id, {'amount': 3000});
    expect(await DashboardDataSource(db).getCashBalance(), -3000);

    await ds.delete(id);
    expect(await DashboardDataSource(db).getCashBalance(), 0);
  });

  test('non-cash payment method goes to bank account', () async {
    final transferDs = TransferDataSource(db);
    final bankId = await transferDs.getDefaultBankAccountId();
    expect(bankId, isNotNull);

    final now = DateTime.now();
    final income = IncomeModel(
      id: 0,
      businessId: 0,
      categoryId: 1,
      amount: 10000,
      bankAccountId: bankId,
      incomeDate: DateTime.now(),
      paymentMethod: 'bkash',
      status: 'completed',
      createdAt: now,
      updatedAt: now,
    );
    await IncomeDataSource(db).create(income.toMap());

    final dash = DashboardDataSource(db);
    expect(await dash.getCashBalance(), 0,
        reason: 'bkash income should not touch cash balance');
    expect(await dash.getBankBalance(), 10000,
        reason: 'bkash income should increase bank balance');
  });
}
