import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/database_helper.dart';
import '../../../../di/injection_container.dart';
import '../../domain/entities/dashboard_summary.dart';

final dashboardProvider = FutureProvider<DashboardSummary>((ref) async {
  final db = ref.read(databaseHelperProvider);
  return _loadDashboard(db);
});

final dashboardRefreshProvider = StateProvider<int>((ref) => 0);

Future<DashboardSummary> _loadDashboard(DatabaseHelper db) async {
  final today = DateTime.now();
  final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

  final results = await Future.wait([
    _safeQuery(db, () => _todayIncome(db, dateStr)),
    _safeQuery(db, () => _todayExpense(db, dateStr)),
    _safeQuery(db, () => _cashBalance(db)),
    _safeQuery(db, () => _bankBalance(db)),
    _safeQuery(db, () => _totalIncome(db)),
    _safeQuery(db, () => _totalExpense(db)),
    _safeMonthlyReport(db),
    _safeRecentTransactions(db),
  ]);

  return DashboardSummary(
    todayIncome: results[0] as double,
    todayExpense: results[1] as double,
    cashBalance: results[2] as double,
    bankBalance: results[3] as double,
    totalIncome: results[4] as double,
    totalExpense: results[5] as double,
    monthlyReport: results[6] as List<MonthlyData>,
    recentTransactions: results[7] as List<RecentTransaction>,
  );
}

Future<double> _safeQuery(DatabaseHelper db, Future<double> Function() fn) async {
  try {
    return await fn();
  } catch (_) {
    return 0;
  }
}

Future<List<MonthlyData>> _safeMonthlyReport(DatabaseHelper db) async {
  try {
    return await _monthlyReport(db);
  } catch (_) {
    return [];
  }
}

Future<List<RecentTransaction>> _safeRecentTransactions(DatabaseHelper db) async {
  try {
    return await _recentTransactions(db);
  } catch (_) {
    return [];
  }
}

Future<double> _todayIncome(DatabaseHelper db, String date) async {
  final r = await db.db.rawQuery(
    "SELECT COALESCE(SUM(amount),0) as t FROM incomes WHERE income_date = ? AND status = 'completed'",
    [date],
  );
  return (r.first['t'] as num?)?.toDouble() ?? 0;
}

Future<double> _todayExpense(DatabaseHelper db, String date) async {
  final r = await db.db.rawQuery(
    "SELECT COALESCE(SUM(amount),0) as t FROM expenses WHERE expense_date = ? AND status = 'completed'",
    [date],
  );
  return (r.first['t'] as num?)?.toDouble() ?? 0;
}

Future<double> _cashBalance(DatabaseHelper db) async {
  final r = await db.db.rawQuery(
    "SELECT COALESCE(SUM(balance),0) as t FROM cash_accounts WHERE status = 'active'",
  );
  return (r.first['t'] as num?)?.toDouble() ?? 0;
}

Future<double> _bankBalance(DatabaseHelper db) async {
  final r = await db.db.rawQuery(
    "SELECT COALESCE(SUM(balance),0) as t FROM bank_accounts WHERE status = 'active'",
  );
  return (r.first['t'] as num?)?.toDouble() ?? 0;
}

Future<double> _totalIncome(DatabaseHelper db) async {
  final r = await db.db.rawQuery(
    "SELECT COALESCE(SUM(amount),0) as t FROM incomes WHERE status = 'completed'",
  );
  return (r.first['t'] as num?)?.toDouble() ?? 0;
}

Future<double> _totalExpense(DatabaseHelper db) async {
  final r = await db.db.rawQuery(
    "SELECT COALESCE(SUM(amount),0) as t FROM expenses WHERE status = 'completed'",
  );
  return (r.first['t'] as num?)?.toDouble() ?? 0;
}

Future<List<MonthlyData>> _monthlyReport(DatabaseHelper db) async {
  final last6 = List.generate(6, (i) {
    final d = DateTime(DateTime.now().year, DateTime.now().month - i, 1);
    return '${d.year}-${d.month.toString().padLeft(2, '0')}';
  });

  final incomeRows = await db.db.rawQuery('''
    SELECT strftime('%Y',income_date) as y, strftime('%m',income_date) as m,
      COALESCE(SUM(amount),0) as t
    FROM incomes
    WHERE status = 'completed' AND income_date >= ?
    GROUP BY y,m ORDER BY y DESC, m DESC
  ''', [last6.last + '-01']);

  final expenseRows = await db.db.rawQuery('''
    SELECT strftime('%Y',expense_date) as y, strftime('%m',expense_date) as m,
      COALESCE(SUM(amount),0) as t
    FROM expenses
    WHERE status = 'completed' AND expense_date >= ?
    GROUP BY y,m ORDER BY y DESC, m DESC
  ''', [last6.last + '-01']);

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

Future<List<RecentTransaction>> _recentTransactions(DatabaseHelper db) async {
  final rows = await db.db.rawQuery('''
    SELECT 'income' as type, i.id, i.amount, i.description,
      i.income_date as txn_date, i.category_id, i.customer_id as party_id,
      ic.name as cat_name, c.name as party_name
    FROM incomes i
    LEFT JOIN income_categories ic ON ic.id = i.category_id
    LEFT JOIN customers c ON c.id = i.customer_id
    WHERE i.status = 'completed'
    UNION ALL
    SELECT 'expense' as type, e.id, e.amount, e.description,
      e.expense_date as txn_date, e.category_id, e.supplier_id as party_id,
      ec.name as cat_name, s.name as party_name
    FROM expenses e
    LEFT JOIN expense_categories ec ON ec.id = e.category_id
    LEFT JOIN suppliers s ON s.id = e.supplier_id
    WHERE e.status = 'completed'
    ORDER BY txn_date DESC, id DESC
    LIMIT 10
  ''');

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
  )).toList();
}
