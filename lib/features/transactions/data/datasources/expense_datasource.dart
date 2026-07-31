import 'package:nexora_khata/core/services/database_helper.dart';
import 'package:nexora_khata/features/transactions/data/models/expense_model.dart';

class ExpenseDataSource {
  final DatabaseHelper _dbHelper;
  ExpenseDataSource(this._dbHelper);

  Future<List<ExpenseModel>> getAll({
    String? search,
    String? status,
    int? categoryId,
    String? dateFrom,
    String? dateTo,
    int? limit,
    int? offset,
  }) async {
    final db = _dbHelper.db;
    final conditions = <String>[];
    final args = <Object?>[];

    if (search != null && search.isNotEmpty) {
      conditions.add('(e.description LIKE ? OR e.reference LIKE ?)');
      final p = '%$search%';
      args.add(p);
      args.add(p);
    }
    if (status != null && status.isNotEmpty) {
      conditions.add('e.status = ?');
      args.add(status);
    }
    if (categoryId != null) {
      conditions.add('e.category_id = ?');
      args.add(categoryId);
    }
    if (dateFrom != null && dateFrom.isNotEmpty) {
      conditions.add('e.expense_date >= ?');
      args.add(dateFrom);
    }
    if (dateTo != null && dateTo.isNotEmpty) {
      conditions.add('e.expense_date <= ?');
      args.add(dateTo);
    }

    final where =
        conditions.isNotEmpty ? 'WHERE ${conditions.join(' AND ')}' : '';

    final sql = '''
      SELECT e.*, ec.name AS cat_name, s.name AS supplier_name
      FROM expenses e
      LEFT JOIN expense_categories ec ON ec.id = e.category_id
      LEFT JOIN suppliers s ON s.id = e.supplier_id
      $where
      ORDER BY e.expense_date DESC, e.id DESC
      ${limit != null ? 'LIMIT ?' : ''}
      ${offset != null ? 'OFFSET ?' : ''}
    ''';

    if (limit != null) args.add(limit);
    if (offset != null) args.add(offset);

    final rows = await db.rawQuery(sql, args);
    return rows.map((r) => ExpenseModel.fromMap(r)).toList();
  }

  Future<ExpenseModel?> getById(int id) async {
    final db = _dbHelper.db;
    final rows = await db.rawQuery('''
      SELECT e.*, ec.name AS cat_name, s.name AS supplier_name
      FROM expenses e
      LEFT JOIN expense_categories ec ON ec.id = e.category_id
      LEFT JOIN suppliers s ON s.id = e.supplier_id
      WHERE e.id = ?
    ''', [id]);
    if (rows.isEmpty) return null;
    return ExpenseModel.fromMap(rows.first);
  }

  Future<ExpenseModel> create(Map<String, dynamic> data) async {
    final db = _dbHelper.db;
    final id = await db.insert('expenses', data);
    return (await getById(id))!;
  }

  Future<ExpenseModel> update(int id, Map<String, dynamic> data) async {
    final db = _dbHelper.db;
    data['updated_at'] = DateTime.now().toIso8601String();
    await db.update('expenses', data, where: 'id = ?', whereArgs: [id]);
    return (await getById(id))!;
  }

  Future<void> delete(int id) async {
    final db = _dbHelper.db;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ExpenseModel>> getByMonth(int year, int month) async {
    final db = _dbHelper.db;
    final m = month.toString().padLeft(2, '0');
    final rows = await db.rawQuery('''
      SELECT e.*, ec.name AS cat_name, s.name AS supplier_name
      FROM expenses e
      LEFT JOIN expense_categories ec ON ec.id = e.category_id
      LEFT JOIN suppliers s ON s.id = e.supplier_id
      WHERE strftime('%Y', e.expense_date) = ? AND strftime('%m', e.expense_date) = ?
      ORDER BY e.expense_date DESC, e.id DESC
    ''', [year.toString(), m]);
    return rows.map((r) => ExpenseModel.fromMap(r)).toList();
  }

  Future<Map<String, dynamic>> getMonthlySummary(int year, int month) async {
    final db = _dbHelper.db;
    final m = month.toString().padLeft(2, '0');
    final rows = await db.rawQuery('''
      SELECT
        COUNT(*) AS count,
        COALESCE(SUM(amount), 0) AS total,
        COALESCE(AVG(amount), 0) AS avgAmount
      FROM expenses
      WHERE status = 'completed'
        AND strftime('%Y', expense_date) = ?
        AND strftime('%m', expense_date) = ?
    ''', [year.toString(), m]);
    if (rows.isEmpty) {
      return {'total': 0.0, 'count': 0, 'avgAmount': 0.0};
    }
    final r = rows.first;
    return {
      'total': (r['total'] as num?)?.toDouble() ?? 0.0,
      'count': (r['count'] as int?) ?? 0,
      'avgAmount': (r['avgAmount'] as num?)?.toDouble() ?? 0.0,
    };
  }

  Future<List<Map<String, dynamic>>> getMonthlyReport(int year) async {
    final db = _dbHelper.db;
    return db.rawQuery('''
      SELECT
        strftime('%m', expense_date) AS month,
        COUNT(*) AS count,
        COALESCE(SUM(amount), 0) AS total
      FROM expenses
      WHERE status = 'completed' AND strftime('%Y', expense_date) = ?
      GROUP BY month
      ORDER BY month
    ''', [year.toString()]);
  }

  Future<List<ExpenseModel>> search(String query) async {
    final db = _dbHelper.db;
    final p = '%$query%';
    final rows = await db.rawQuery('''
      SELECT e.*, ec.name AS cat_name, s.name AS supplier_name
      FROM expenses e
      LEFT JOIN expense_categories ec ON ec.id = e.category_id
      LEFT JOIN suppliers s ON s.id = e.supplier_id
      WHERE e.description LIKE ? OR e.reference LIKE ?
      ORDER BY e.expense_date DESC, e.id DESC
    ''', [p, p]);
    return rows.map((r) => ExpenseModel.fromMap(r)).toList();
  }

  Future<List<ExpenseModel>> getByDate(String date) async {
    final db = _dbHelper.db;
    final rows = await db.rawQuery('''
      SELECT e.*, ec.name AS cat_name, s.name AS supplier_name
      FROM expenses e
      LEFT JOIN expense_categories ec ON ec.id = e.category_id
      LEFT JOIN suppliers s ON s.id = e.supplier_id
      WHERE e.expense_date = ?
      ORDER BY e.id DESC
    ''', [date]);
    return rows.map((r) => ExpenseModel.fromMap(r)).toList();
  }

  Future<Map<String, dynamic>> getDailySummary(String date) async {
    final db = _dbHelper.db;
    final rows = await db.rawQuery('''
      SELECT
        COUNT(*) AS count,
        COALESCE(SUM(amount), 0) AS total,
        COALESCE(AVG(amount), 0) AS avgAmount
      FROM expenses
      WHERE status = 'completed' AND expense_date = ?
    ''', [date]);
    if (rows.isEmpty) {
      return {'total': 0.0, 'count': 0, 'avgAmount': 0.0};
    }
    final r = rows.first;
    return {
      'total': (r['total'] as num?)?.toDouble() ?? 0.0,
      'count': (r['count'] as int?) ?? 0,
      'avgAmount': (r['avgAmount'] as num?)?.toDouble() ?? 0.0,
    };
  }
}
