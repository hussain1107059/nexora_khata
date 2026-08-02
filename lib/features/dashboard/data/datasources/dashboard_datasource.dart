import 'package:nexora_khata/core/services/current_user_scope.dart';
import 'package:nexora_khata/core/services/database_helper.dart';
import 'package:nexora_khata/features/dashboard/domain/entities/dashboard_summary.dart';

class DashboardDataSource {
  final DatabaseHelper _dbHelper;
  DashboardDataSource(this._dbHelper);

  int get _tenantId => CurrentUserScope.activeId;

  Future<double> getTodayIncome(String date) async {
    final r = await _dbHelper.db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount),0) as t FROM (
        SELECT amount FROM incomes WHERE income_date = ? AND status = 'completed' AND business_id = ?
        UNION ALL
        SELECT amount FROM loan_transactions
        WHERE date = ? AND (type = 'borrow' OR (type = 'repay' AND repay_type = 'lend'))
          AND business_id = ?
      )
      ''',
      [date, _tenantId, date, _tenantId],
    );
    return (r.first['t'] as num?)?.toDouble() ?? 0;
  }

  Future<double> getTodayExpense(String date) async {
    final r = await _dbHelper.db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount),0) as t FROM (
        SELECT amount FROM expenses WHERE expense_date = ? AND status = 'completed' AND business_id = ?
        UNION ALL
        SELECT amount FROM loan_transactions
        WHERE date = ? AND (type = 'lend' OR (type = 'repay' AND repay_type = 'borrow'))
          AND business_id = ?
      )
      ''',
      [date, _tenantId, date, _tenantId],
    );
    return (r.first['t'] as num?)?.toDouble() ?? 0;
  }

  Future<double> getCashBalance() async {
    final r = await _dbHelper.db.rawQuery(
      '''
      SELECT
        COALESCE((SELECT SUM(balance) FROM cash_accounts WHERE status = 'active' AND business_id = ?), 0)
        + COALESCE((SELECT SUM(amount) FROM loan_transactions
            WHERE cash_account_id IS NOT NULL
              AND (type = 'borrow' OR (type = 'repay' AND repay_type = 'lend'))
              AND business_id = ?), 0)
        - COALESCE((SELECT SUM(amount) FROM loan_transactions
            WHERE cash_account_id IS NOT NULL
              AND (type = 'lend' OR (type = 'repay' AND repay_type = 'borrow'))
              AND business_id = ?), 0)
        AS t
      ''',
      [_tenantId, _tenantId, _tenantId],
    );
    return (r.first['t'] as num?)?.toDouble() ?? 0;
  }

  Future<double> getBankBalance() async {
    final r = await _dbHelper.db.rawQuery(
      '''
      SELECT
        COALESCE((SELECT SUM(balance) FROM bank_accounts WHERE status = 'active' AND business_id = ?), 0)
        + COALESCE((SELECT SUM(amount) FROM loan_transactions
            WHERE bank_account_id IS NOT NULL
              AND (type = 'borrow' OR (type = 'repay' AND repay_type = 'lend'))
              AND business_id = ?), 0)
        - COALESCE((SELECT SUM(amount) FROM loan_transactions
            WHERE bank_account_id IS NOT NULL
              AND (type = 'lend' OR (type = 'repay' AND repay_type = 'borrow'))
              AND business_id = ?), 0)
        AS t
      ''',
      [_tenantId, _tenantId, _tenantId],
    );
    return (r.first['t'] as num?)?.toDouble() ?? 0;
  }

  Future<double> getTotalIncome() async {
    final r = await _dbHelper.db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount),0) as t FROM (
        SELECT amount FROM incomes WHERE status = 'completed' AND business_id = ?
        UNION ALL
        SELECT amount FROM loan_transactions
        WHERE (type = 'borrow' OR (type = 'repay' AND repay_type = 'lend')) AND business_id = ?
      )
      ''',
      [_tenantId, _tenantId],
    );
    return (r.first['t'] as num?)?.toDouble() ?? 0;
  }

  Future<double> getTotalExpense() async {
    final r = await _dbHelper.db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount),0) as t FROM (
        SELECT amount FROM expenses WHERE status = 'completed' AND business_id = ?
        UNION ALL
        SELECT amount FROM loan_transactions
        WHERE (type = 'lend' OR (type = 'repay' AND repay_type = 'borrow')) AND business_id = ?
      )
      ''',
      [_tenantId, _tenantId],
    );
    return (r.first['t'] as num?)?.toDouble() ?? 0;
  }

  Future<List<MonthlyData>> getMonthlyReport() async {
    final last6 = List.generate(6, (i) {
      final d = DateTime(DateTime.now().year, DateTime.now().month - i, 1);
      return '${d.year}-${d.month.toString().padLeft(2, '0')}';
    });

    final incomeRows = await _dbHelper.db.rawQuery('''
      SELECT strftime('%Y',txn_date) as y, strftime('%m',txn_date) as m,
        COALESCE(SUM(amount),0) as t
      FROM (
        SELECT income_date as txn_date, amount FROM incomes
        WHERE status = 'completed' AND income_date >= ? AND business_id = ?
        UNION ALL
        SELECT date as txn_date, amount FROM loan_transactions
        WHERE (type = 'borrow' OR (type = 'repay' AND repay_type = 'lend'))
          AND date >= ? AND business_id = ?
      )
      GROUP BY y,m ORDER BY y DESC, m DESC
    ''', [last6.last + '-01', _tenantId, last6.last + '-01', _tenantId]);

    final expenseRows = await _dbHelper.db.rawQuery('''
      SELECT strftime('%Y',txn_date) as y, strftime('%m',txn_date) as m,
        COALESCE(SUM(amount),0) as t
      FROM (
        SELECT expense_date as txn_date, amount FROM expenses
        WHERE status = 'completed' AND expense_date >= ? AND business_id = ?
        UNION ALL
        SELECT date as txn_date, amount FROM loan_transactions
        WHERE (type = 'lend' OR (type = 'repay' AND repay_type = 'borrow'))
          AND date >= ? AND business_id = ?
      )
      GROUP BY y,m ORDER BY y DESC, m DESC
    ''', [last6.last + '-01', _tenantId, last6.last + '-01', _tenantId]);

    final incomeMap = <String, double>{};
    final expenseMap = <String, double>{};
    for (final r in incomeRows) {
      incomeMap['${r['y']}-${r['m']}'] = (r['t'] as num).toDouble();
    }
    for (final r in expenseRows) {
      expenseMap['${r['y']}-${r['m']}'] = (r['t'] as num).toDouble();
    }

    return last6.reversed.map((key) {
      final parts = key.split('-');
      final month = int.parse(parts[1]);
      final year = int.parse(parts[0]);
      return MonthlyData(
        month: month,
        year: year,
        income: incomeMap[key] ?? 0,
        expense: expenseMap[key] ?? 0,
      );
    }).toList();
  }

  Future<List<RecentTransaction>> getRecentTransactions() async {
    final rows = await _dbHelper.db.rawQuery('''
      SELECT * FROM (
        SELECT 'income' as type, i.id, i.amount, i.description,
          i.income_date as txn_date, i.category_id, i.customer_id as party_id,
          ic.name as cat_name, c.name as party_name, NULL as loan_type,
          NULL as contact_id
        FROM incomes i
        LEFT JOIN income_categories ic ON ic.id = i.category_id
        LEFT JOIN customers c ON c.id = i.customer_id
        WHERE i.status = 'completed' AND i.business_id = ?
        UNION ALL
        SELECT 'expense' as type, e.id, e.amount, e.description,
          e.expense_date as txn_date, e.category_id, e.supplier_id as party_id,
          ec.name as cat_name, s.name as party_name, NULL as loan_type,
          NULL as contact_id
        FROM expenses e
        LEFT JOIN expense_categories ec ON ec.id = e.category_id
        LEFT JOIN suppliers s ON s.id = e.supplier_id
        WHERE e.status = 'completed' AND e.business_id = ?
        UNION ALL
        SELECT 'loan' as type, lt.id, lt.amount, lt.note,
          lt.date as txn_date, NULL as category_id, lt.contact_id as party_id,
          NULL as cat_name, lc.name as party_name, lt.type as loan_type,
          lt.contact_id as contact_id
        FROM loan_transactions lt
        LEFT JOIN loan_contacts lc ON lc.id = lt.contact_id
        WHERE lt.business_id = ?
      ) r
      ORDER BY txn_date DESC, id DESC
      LIMIT 10
    ''', [_tenantId, _tenantId, _tenantId]);

    return rows.map((r) => RecentTransaction(
      id: r['id'] as int,
      type: r['type'] as String,
      amount: (r['amount'] as num).toDouble(),
      description: r['description'] as String?,
      date: DateTime.parse(r['txn_date'] as String),
      categoryId: r['category_id'] as int?,
      customerId: r['party_id'] as int?,
      categoryName: r['cat_name'] as String?,
      customerName: r['party_name'] as String?,
      loanType: r['loan_type'] as String?,
      contactId: r['contact_id'] as int?,
      contactName: r['party_name'] as String?,
    )).toList();
  }
}