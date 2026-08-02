import 'package:nexora_khata/core/services/app_strings.dart';
import 'package:nexora_khata/core/services/database_helper.dart';
import 'package:nexora_khata/core/utils/date_utils.dart';
import 'package:nexora_khata/features/reports/domain/entities/report.dart';

class ReportDataSource {
  final DatabaseHelper _dbHelper;
  ReportDataSource(this._dbHelper);

  Future<List<DailyReportItem>> getDailyReport(String date) async {
    final db = _dbHelper.db;
    final rows = await db.rawQuery('''
      SELECT
        COALESCE(SUM(CASE WHEN t.type = 'income' THEN t.amount ELSE 0 END), 0) AS income,
        COALESCE(SUM(CASE WHEN t.type = 'expense' THEN t.amount ELSE 0 END), 0) AS expense
      FROM (
        SELECT amount, 'income' AS type FROM incomes WHERE income_date = ? AND status = 'completed'
        UNION ALL
        SELECT amount, 'expense' AS type FROM expenses WHERE expense_date = ? AND status = 'completed'
        UNION ALL
        SELECT amount, 'income' AS type FROM loan_transactions
        WHERE date = ? AND (type = 'borrow' OR (type = 'repay' AND repay_type = 'lend'))
        UNION ALL
        SELECT amount, 'expense' AS type FROM loan_transactions
        WHERE date = ? AND (type = 'lend' OR (type = 'repay' AND repay_type = 'borrow'))
      ) t
    ''', [date, date, date, date]);
    final income = (rows.first['income'] as num).toDouble();
    final expense = (rows.first['expense'] as num).toDouble();
    final parsedDate = DateTime.parse(date);
    return [
      DailyReportItem(date: parsedDate, income: income, expense: expense, net: income - expense),
    ];
  }

  Future<List<DailyReportItem>> getWeeklyReport(String date) async {
    final parsedDate = DateTime.parse(date);
    final weekday = parsedDate.weekday;
    final startOfWeek = parsedDate.subtract(Duration(days: weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    final startStr = startOfWeek.toIso8601String().substring(0, 10);
    final endStr = endOfWeek.toIso8601String().substring(0, 10);

    final db = _dbHelper.db;
    final rows = await db.rawQuery('''
      SELECT date, SUM(income) AS income, SUM(expense) AS expense
      FROM (
        SELECT income_date AS date, SUM(amount) AS income, 0 AS expense
        FROM incomes
        WHERE income_date >= ? AND income_date <= ? AND status = 'completed'
        GROUP BY income_date
        UNION ALL
        SELECT expense_date AS date, 0 AS income, SUM(amount) AS expense
        FROM expenses
        WHERE expense_date >= ? AND expense_date <= ? AND status = 'completed'
        GROUP BY expense_date
        UNION ALL
        SELECT date AS date, SUM(amount) AS income, 0 AS expense
        FROM loan_transactions
        WHERE date >= ? AND date <= ? AND (type = 'borrow' OR (type = 'repay' AND repay_type = 'lend'))
        GROUP BY date
        UNION ALL
        SELECT date AS date, 0 AS income, SUM(amount) AS expense
        FROM loan_transactions
        WHERE date >= ? AND date <= ? AND (type = 'lend' OR (type = 'repay' AND repay_type = 'borrow'))
        GROUP BY date
      )
      GROUP BY date
      ORDER BY date
    ''', [startStr, endStr, startStr, endStr, startStr, endStr, startStr, endStr]);

    final dateMap = <String, DailyReportItem>{};
    for (var i = 0; i < 7; i++) {
      final d = startOfWeek.add(Duration(days: i));
      final dStr = d.toIso8601String().substring(0, 10);
      dateMap[dStr] = DailyReportItem(date: d);
    }

    for (final r in rows) {
      final dStr = r['date'] as String;
      final income = (r['income'] as num).toDouble();
      final expense = (r['expense'] as num).toDouble();
      dateMap[dStr] = DailyReportItem(
        date: DateTime.parse(dStr),
        income: income,
        expense: expense,
        net: income - expense,
      );
    }

    return dateMap.values.toList();
  }

  Future<ReportSummary> getWeeklySummary(String date) async {
    final parsedDate = DateTime.parse(date);
    final weekday = parsedDate.weekday;
    final startOfWeek = parsedDate.subtract(Duration(days: weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    final startStr = startOfWeek.toIso8601String().substring(0, 10);
    final endStr = endOfWeek.toIso8601String().substring(0, 10);

    final db = _dbHelper.db;
    final rows = await db.rawQuery('''
      SELECT
        COALESCE(SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END), 0) AS total_income,
        COALESCE(SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END), 0) AS total_expense,
        COUNT(*) AS total_transactions
      FROM (
        SELECT amount, 'income' AS type FROM incomes WHERE income_date >= ? AND income_date <= ? AND status = 'completed'
        UNION ALL
        SELECT amount, 'expense' AS type FROM expenses WHERE expense_date >= ? AND expense_date <= ? AND status = 'completed'
        UNION ALL
        SELECT amount, 'income' AS type FROM loan_transactions
        WHERE date >= ? AND date <= ? AND (type = 'borrow' OR (type = 'repay' AND repay_type = 'lend'))
        UNION ALL
        SELECT amount, 'expense' AS type FROM loan_transactions
        WHERE date >= ? AND date <= ? AND (type = 'lend' OR (type = 'repay' AND repay_type = 'borrow'))
      )
    ''', [startStr, endStr, startStr, endStr, startStr, endStr, startStr, endStr]);

    final r = rows.first;
    final totalIncome = (r['total_income'] as num).toDouble();
    final totalExpense = (r['total_expense'] as num).toDouble();
    return ReportSummary(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netAmount: totalIncome - totalExpense,
      totalTransactions: (r['total_transactions'] as int),
      period: '$startStr - $endStr',
    );
  }

  Future<List<DailyReportItem>> getMonthlyReport(int year, int month) async {
    final startStr = AppDateUtils.monthStart(year, month);
    final endStr = AppDateUtils.monthEndExclusive(year, month);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    final db = _dbHelper.db;
    final rows = await db.rawQuery('''
      SELECT date, SUM(income) AS income, SUM(expense) AS expense
      FROM (
        SELECT income_date AS date, SUM(amount) AS income, 0 AS expense
        FROM incomes
        WHERE status = 'completed' AND income_date >= ? AND income_date < ?
        GROUP BY income_date
        UNION ALL
        SELECT expense_date AS date, 0 AS income, SUM(amount) AS expense
        FROM expenses
        WHERE status = 'completed' AND expense_date >= ? AND expense_date < ?
        GROUP BY expense_date
        UNION ALL
        SELECT date AS date, SUM(amount) AS income, 0 AS expense
        FROM loan_transactions
        WHERE date >= ? AND date < ? AND (type = 'borrow' OR (type = 'repay' AND repay_type = 'lend'))
        GROUP BY date
        UNION ALL
        SELECT date AS date, 0 AS income, SUM(amount) AS expense
        FROM loan_transactions
        WHERE date >= ? AND date < ? AND (type = 'lend' OR (type = 'repay' AND repay_type = 'borrow'))
        GROUP BY date
      )
      GROUP BY date
      ORDER BY date
    ''', [startStr, endStr, startStr, endStr, startStr, endStr, startStr, endStr]);

    final dateMap = <String, DailyReportItem>{};
    for (var day = 1; day <= daysInMonth; day++) {
      final d = DateTime(year, month, day);
      final dStr = d.toIso8601String().substring(0, 10);
      dateMap[dStr] = DailyReportItem(date: d);
    }

    for (final r in rows) {
      final dStr = r['date'] as String;
      final income = (r['income'] as num).toDouble();
      final expense = (r['expense'] as num).toDouble();
      dateMap[dStr] = DailyReportItem(
        date: DateTime.parse(dStr),
        income: income,
        expense: expense,
        net: income - expense,
      );
    }

    return dateMap.values.toList();
  }

  Future<ReportSummary> getMonthlySummary(int year, int month) async {
    final startStr = AppDateUtils.monthStart(year, month);
    final endStr = AppDateUtils.monthEndExclusive(year, month);

    final db = _dbHelper.db;
    final rows = await db.rawQuery('''
      SELECT
        COALESCE(SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END), 0) AS total_income,
        COALESCE(SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END), 0) AS total_expense,
        COUNT(*) AS total_transactions
      FROM (
        SELECT amount, 'income' AS type FROM incomes WHERE status = 'completed' AND income_date >= ? AND income_date < ?
        UNION ALL
        SELECT amount, 'expense' AS type FROM expenses WHERE status = 'completed' AND expense_date >= ? AND expense_date < ?
        UNION ALL
        SELECT amount, 'income' AS type FROM loan_transactions
        WHERE date >= ? AND date < ? AND (type = 'borrow' OR (type = 'repay' AND repay_type = 'lend'))
        UNION ALL
        SELECT amount, 'expense' AS type FROM loan_transactions
        WHERE date >= ? AND date < ? AND (type = 'lend' OR (type = 'repay' AND repay_type = 'borrow'))
      )
    ''', [startStr, endStr, startStr, endStr, startStr, endStr, startStr, endStr]);

    final r = rows.first;
    final totalIncome = (r['total_income'] as num).toDouble();
    final totalExpense = (r['total_expense'] as num).toDouble();
    return ReportSummary(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netAmount: totalIncome - totalExpense,
      totalTransactions: (r['total_transactions'] as int),
      period: '${year.toString()}-${month.toString().padLeft(2, '0')}',
    );
  }

  Future<List<MonthlyReportItem>> getYearlyReport(int year) async {
    final startStr = AppDateUtils.yearStart(year);
    final endStr = AppDateUtils.yearEndExclusive(year);

    final db = _dbHelper.db;
    final rows = await db.rawQuery('''
      SELECT
        CAST(strftime('%m', t.date) AS INTEGER) AS month,
        SUM(CASE WHEN t.type = 'income' THEN t.amount ELSE 0 END) AS income,
        SUM(CASE WHEN t.type = 'expense' THEN t.amount ELSE 0 END) AS expense
      FROM (
        SELECT income_date AS date, amount, 'income' AS type FROM incomes WHERE status = 'completed' AND income_date >= ? AND income_date < ?
        UNION ALL
        SELECT expense_date AS date, amount, 'expense' AS type FROM expenses WHERE status = 'completed' AND expense_date >= ? AND expense_date < ?
        UNION ALL
        SELECT date AS date, amount, 'income' AS type FROM loan_transactions
        WHERE date >= ? AND date < ? AND (type = 'borrow' OR (type = 'repay' AND repay_type = 'lend'))
        UNION ALL
        SELECT date AS date, amount, 'expense' AS type FROM loan_transactions
        WHERE date >= ? AND date < ? AND (type = 'lend' OR (type = 'repay' AND repay_type = 'borrow'))
      ) t
      GROUP BY month
      ORDER BY month
    ''', [startStr, endStr, startStr, endStr, startStr, endStr, startStr, endStr]);

    final monthMap = <int, MonthlyReportItem>{};
    for (var m = 1; m <= 12; m++) {
      monthMap[m] = MonthlyReportItem(month: m, year: year);
    }

    for (final r in rows) {
      final m = (r['month'] as int);
      final income = (r['income'] as num).toDouble();
      final expense = (r['expense'] as num).toDouble();
      monthMap[m] = MonthlyReportItem(
        month: m,
        year: year,
        income: income,
        expense: expense,
        net: income - expense,
      );
    }

    return monthMap.values.toList();
  }

  Future<ReportSummary> getYearlySummary(int year) async {
    final startStr = AppDateUtils.yearStart(year);
    final endStr = AppDateUtils.yearEndExclusive(year);

    final db = _dbHelper.db;
    final rows = await db.rawQuery('''
      SELECT
        COALESCE(SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END), 0) AS total_income,
        COALESCE(SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END), 0) AS total_expense,
        COUNT(*) AS total_transactions
      FROM (
        SELECT amount, 'income' AS type FROM incomes WHERE status = 'completed' AND income_date >= ? AND income_date < ?
        UNION ALL
        SELECT amount, 'expense' AS type FROM expenses WHERE status = 'completed' AND expense_date >= ? AND expense_date < ?
        UNION ALL
        SELECT amount, 'income' AS type FROM loan_transactions
        WHERE date >= ? AND date < ? AND (type = 'borrow' OR (type = 'repay' AND repay_type = 'lend'))
        UNION ALL
        SELECT amount, 'expense' AS type FROM loan_transactions
        WHERE date >= ? AND date < ? AND (type = 'lend' OR (type = 'repay' AND repay_type = 'borrow'))
      )
    ''', [startStr, endStr, startStr, endStr, startStr, endStr, startStr, endStr]);

    final r = rows.first;
    final totalIncome = (r['total_income'] as num).toDouble();
    final totalExpense = (r['total_expense'] as num).toDouble();
    return ReportSummary(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netAmount: totalIncome - totalExpense,
      totalTransactions: (r['total_transactions'] as int),
      period: year.toString(),
    );
  }

  Future<List<CategoryReportItem>> getCategoryWiseIncome({int? year, int? month}) async {
    final db = _dbHelper.db;
    final conditions = <String>["i.status = 'completed'"];
    final args = <Object?>[];

    if (year != null) {
      if (month != null) {
        conditions.add('i.income_date >= ?');
        conditions.add('i.income_date < ?');
        args.add(AppDateUtils.monthStart(year, month));
        args.add(AppDateUtils.monthEndExclusive(year, month));
      } else {
        conditions.add('i.income_date >= ?');
        conditions.add('i.income_date < ?');
        args.add(AppDateUtils.yearStart(year));
        args.add(AppDateUtils.yearEndExclusive(year));
      }
    }

    final where = conditions.join(' AND ');

    final rows = await db.rawQuery('''
      SELECT ic.name AS category, SUM(i.amount) AS amount, COUNT(*) AS count
      FROM incomes i
      JOIN income_categories ic ON ic.id = i.category_id
      WHERE $where
      GROUP BY ic.id, ic.name
      ORDER BY amount DESC
    ''', args);

    final loanArgs = <Object?>[];
    if (year != null) {
      if (month != null) {
        loanArgs.add(AppDateUtils.monthStart(year, month));
        loanArgs.add(AppDateUtils.monthEndExclusive(year, month));
      } else {
        loanArgs.add(AppDateUtils.yearStart(year));
        loanArgs.add(AppDateUtils.yearEndExclusive(year));
      }
    }
    final loanWhere = loanArgs.isEmpty
        ? ''
        : 'AND date >= ? AND date < ?';
    final loanRows = await db.rawQuery('''
      SELECT SUM(amount) AS amount, COUNT(*) AS count
      FROM loan_transactions
      WHERE (type = 'borrow' OR (type = 'repay' AND repay_type = 'lend')) $loanWhere
    ''', loanArgs);

    final result = <Map<String, Object?>>[];
    for (final r in rows) {
      result.add(r);
    }
    if (loanRows.isNotEmpty) {
      final loanAmount = (loanRows.first['amount'] as num).toDouble();
      final loanCount = (loanRows.first['count'] as int);
      if (loanAmount > 0) {
        result.add({
          'category': AppStrings.s.rptLoanTaken,
          'amount': loanAmount,
          'count': loanCount,
        });
      }
    }

    final totalAmount = result.fold<double>(
      0,
      (sum, r) => sum + (r['amount'] as num).toDouble(),
    );

    return result.map((r) {
      final amount = (r['amount'] as num).toDouble();
      return CategoryReportItem(
        category: r['category'] as String,
        amount: amount,
        percentage: totalAmount > 0 ? (amount / totalAmount) * 100 : 0,
        count: (r['count'] as int),
      );
    }).toList();
  }

  Future<List<CategoryReportItem>> getCategoryWiseExpense({int? year, int? month}) async {
    final db = _dbHelper.db;
    final conditions = <String>["e.status = 'completed'"];
    final args = <Object?>[];

    if (year != null) {
      if (month != null) {
        conditions.add('e.expense_date >= ?');
        conditions.add('e.expense_date < ?');
        args.add(AppDateUtils.monthStart(year, month));
        args.add(AppDateUtils.monthEndExclusive(year, month));
      } else {
        conditions.add('e.expense_date >= ?');
        conditions.add('e.expense_date < ?');
        args.add(AppDateUtils.yearStart(year));
        args.add(AppDateUtils.yearEndExclusive(year));
      }
    }

    final where = conditions.join(' AND ');

    final rows = await db.rawQuery('''
      SELECT ec.name AS category, SUM(e.amount) AS amount, COUNT(*) AS count
      FROM expenses e
      JOIN expense_categories ec ON ec.id = e.category_id
      WHERE $where
      GROUP BY ec.id, ec.name
      ORDER BY amount DESC
    ''', args);

    final loanArgs = <Object?>[];
    if (year != null) {
      if (month != null) {
        loanArgs.add(AppDateUtils.monthStart(year, month));
        loanArgs.add(AppDateUtils.monthEndExclusive(year, month));
      } else {
        loanArgs.add(AppDateUtils.yearStart(year));
        loanArgs.add(AppDateUtils.yearEndExclusive(year));
      }
    }
    final loanWhere = loanArgs.isEmpty
        ? ''
        : 'AND date >= ? AND date < ?';
    final loanRows = await db.rawQuery('''
      SELECT SUM(amount) AS amount, COUNT(*) AS count
      FROM loan_transactions
      WHERE (type = 'lend' OR (type = 'repay' AND repay_type = 'borrow')) $loanWhere
    ''', loanArgs);

    final result = <Map<String, Object?>>[];
    for (final r in rows) {
      result.add(r);
    }
    if (loanRows.isNotEmpty) {
      final loanAmount = (loanRows.first['amount'] as num).toDouble();
      final loanCount = (loanRows.first['count'] as int);
      if (loanAmount > 0) {
        result.add({
          'category': AppStrings.s.rptLoanGiven,
          'amount': loanAmount,
          'count': loanCount,
        });
      }
    }

    final totalAmount = result.fold<double>(
      0,
      (sum, r) => sum + (r['amount'] as num).toDouble(),
    );

    return result.map((r) {
      final amount = (r['amount'] as num).toDouble();
      return CategoryReportItem(
        category: r['category'] as String,
        amount: amount,
        percentage: totalAmount > 0 ? (amount / totalAmount) * 100 : 0,
        count: (r['count'] as int),
      );
    }).toList();
  }

  Future<List<IncomeVsExpenseItem>> getIncomeVsExpense(int year) async {
    final startStr = AppDateUtils.yearStart(year);
    final endStr = AppDateUtils.yearEndExclusive(year);

    final db = _dbHelper.db;
    final rows = await db.rawQuery('''
      SELECT
        CAST(strftime('%m', t.date) AS INTEGER) AS month,
        SUM(CASE WHEN t.type = 'income' THEN t.amount ELSE 0 END) AS income,
        SUM(CASE WHEN t.type = 'expense' THEN t.amount ELSE 0 END) AS expense
      FROM (
        SELECT income_date AS date, amount, 'income' AS type FROM incomes WHERE status = 'completed' AND income_date >= ? AND income_date < ?
        UNION ALL
        SELECT expense_date AS date, amount, 'expense' AS type FROM expenses WHERE status = 'completed' AND expense_date >= ? AND expense_date < ?
        UNION ALL
        SELECT date AS date, amount, 'income' AS type FROM loan_transactions
        WHERE date >= ? AND date < ? AND (type = 'borrow' OR (type = 'repay' AND repay_type = 'lend'))
        UNION ALL
        SELECT date AS date, amount, 'expense' AS type FROM loan_transactions
        WHERE date >= ? AND date < ? AND (type = 'lend' OR (type = 'repay' AND repay_type = 'borrow'))
      ) t
      GROUP BY month
      ORDER BY month
    ''', [startStr, endStr, startStr, endStr, startStr, endStr, startStr, endStr]);

    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    final monthMap = <int, IncomeVsExpenseItem>{};
    for (var m = 1; m <= 12; m++) {
      monthMap[m] = IncomeVsExpenseItem(label: monthNames[m - 1]);
    }

    for (final r in rows) {
      final m = (r['month'] as int);
      final income = (r['income'] as num).toDouble();
      final expense = (r['expense'] as num).toDouble();
      monthMap[m] = IncomeVsExpenseItem(
        label: monthNames[m - 1],
        income: income,
        expense: expense,
      );
    }

    return monthMap.values.toList();
  }

  Future<List<CashFlowItem>> getCashFlow(int year, int month) async {
    final startStr = AppDateUtils.monthStart(year, month);
    final endStr = AppDateUtils.monthEndExclusive(year, month);

    final db = _dbHelper.db;
    final rows = await db.rawQuery('''
      SELECT date, SUM(cash_delta) AS cash_delta, SUM(bank_delta) AS bank_delta
      FROM (
        SELECT income_date AS date,
          CASE WHEN cash_account_id IS NOT NULL THEN amount ELSE 0 END AS cash_delta,
          CASE WHEN bank_account_id IS NOT NULL THEN amount ELSE 0 END AS bank_delta
        FROM incomes WHERE status = 'completed' AND income_date >= ? AND income_date < ?
        UNION ALL
        SELECT expense_date AS date,
          CASE WHEN cash_account_id IS NOT NULL THEN -amount ELSE 0 END AS cash_delta,
          CASE WHEN bank_account_id IS NOT NULL THEN -amount ELSE 0 END AS bank_delta
        FROM expenses WHERE status = 'completed' AND expense_date >= ? AND expense_date < ?
        UNION ALL
        SELECT transfer_date AS date,
          CASE
            WHEN from_type = 'cash' THEN -(amount + COALESCE(fee, 0))
            WHEN to_type = 'cash' THEN amount
            ELSE 0
          END AS cash_delta,
          CASE
            WHEN from_type = 'bank' THEN -(amount + COALESCE(fee, 0))
            WHEN to_type = 'bank' THEN amount
            ELSE 0
          END AS bank_delta
        FROM transfers WHERE status = 'completed' AND transfer_date >= ? AND transfer_date < ?
        UNION ALL
        SELECT date AS date,
          CASE WHEN cash_account_id IS NOT NULL THEN amount ELSE 0 END AS cash_delta,
          CASE WHEN bank_account_id IS NOT NULL THEN amount ELSE 0 END AS bank_delta
        FROM loan_transactions
        WHERE (type = 'borrow' OR (type = 'repay' AND repay_type = 'lend'))
          AND date >= ? AND date < ?
        UNION ALL
        SELECT date AS date,
          CASE WHEN cash_account_id IS NOT NULL THEN -amount ELSE 0 END AS cash_delta,
          CASE WHEN bank_account_id IS NOT NULL THEN -amount ELSE 0 END AS bank_delta
        FROM loan_transactions
        WHERE (type = 'lend' OR (type = 'repay' AND repay_type = 'borrow'))
          AND date >= ? AND date < ?
      )
      GROUP BY date
      ORDER BY date
    ''', [startStr, endStr, startStr, endStr, startStr, endStr, startStr, endStr, startStr, endStr]);

    final daysInMonth = DateTime(year, month + 1, 0).day;
    final dateMap = <String, CashFlowItem>{};
    for (var day = 1; day <= daysInMonth; day++) {
      final d = DateTime(year, month, day);
      final dStr = d.toIso8601String().substring(0, 10);
      dateMap[dStr] = CashFlowItem(date: d);
    }

    var cashBalance = 0.0;
    var bankBalance = 0.0;
    for (final r in rows) {
      final dStr = r['date'] as String;
      final cashDelta = (r['cash_delta'] as num).toDouble();
      final bankDelta = (r['bank_delta'] as num).toDouble();
      cashBalance += cashDelta;
      bankBalance += bankDelta;
      dateMap[dStr] = CashFlowItem(
        date: DateTime.parse(dStr),
        cashBalance: cashBalance,
        bankBalance: bankBalance,
        totalBalance: cashBalance + bankBalance,
      );
    }

    return dateMap.values.toList();
  }

  Future<List<int>> getAvailableYears() async {
    final db = _dbHelper.db;
    final rows = await db.rawQuery('''
      SELECT DISTINCT year FROM (
        SELECT DISTINCT CAST(substr(income_date, 1, 4) AS INTEGER) AS year FROM incomes WHERE status = 'completed'
        UNION
        SELECT DISTINCT CAST(substr(expense_date, 1, 4) AS INTEGER) AS year FROM expenses WHERE status = 'completed'
        UNION
        SELECT DISTINCT CAST(substr(date, 1, 4) AS INTEGER) AS year FROM loan_transactions
      )
      ORDER BY year DESC
    ''');
    return rows.map((r) => r['year'] as int).toList();
  }
}
