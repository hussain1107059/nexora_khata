import 'package:nexora_khata/core/services/database_helper.dart';
import 'package:nexora_khata/features/transactions/data/models/income_model.dart';

class IncomeDataSource {
  final DatabaseHelper _dbHelper;
  IncomeDataSource(this._dbHelper);

  Future<List<IncomeModel>> getAll({
    String? search,
    String? status,
    int? categoryId,
    String? dateFrom,
    String? dateTo,
    int? limit,
    int? offset,
  }) async {
    print('[IncomeDataSource] getAll called, db initialized: ${_dbHelper.isInitialized}');
    final db = _dbHelper.db;
    final conditions = <String>[];
    final args = <Object?>[];

    if (search != null && search.isNotEmpty) {
      conditions.add('(i.description LIKE ? OR i.reference LIKE ?)');
      final p = '%$search%';
      args.add(p);
      args.add(p);
    }
    if (status != null && status.isNotEmpty) {
      conditions.add('i.status = ?');
      args.add(status);
    }
    if (categoryId != null) {
      conditions.add('i.category_id = ?');
      args.add(categoryId);
    }
    if (dateFrom != null && dateFrom.isNotEmpty) {
      conditions.add('i.income_date >= ?');
      args.add(dateFrom);
    }
    if (dateTo != null && dateTo.isNotEmpty) {
      conditions.add('i.income_date <= ?');
      args.add(dateTo);
    }

    final where =
        conditions.isNotEmpty ? 'WHERE ${conditions.join(' AND ')}' : '';

    final sql = '''
      SELECT i.*, ic.name AS cat_name, c.name AS customer_name
      FROM incomes i
      LEFT JOIN income_categories ic ON ic.id = i.category_id
      LEFT JOIN customers c ON c.id = i.customer_id
      $where
      ORDER BY i.income_date DESC, i.id DESC
      ${limit != null ? 'LIMIT ?' : ''}
      ${offset != null ? 'OFFSET ?' : ''}
    ''';

    if (limit != null) args.add(limit);
    if (offset != null) args.add(offset);

    final rows = await db.rawQuery(sql, args);
    return rows.map((r) => IncomeModel.fromMap(r)).toList();
  }

  Future<IncomeModel?> getById(int id) async {
    final db = _dbHelper.db;
    final rows = await db.rawQuery('''
      SELECT i.*, ic.name AS cat_name, c.name AS customer_name
      FROM incomes i
      LEFT JOIN income_categories ic ON ic.id = i.category_id
      LEFT JOIN customers c ON c.id = i.customer_id
      WHERE i.id = ?
    ''', [id]);
    if (rows.isEmpty) return null;
    return IncomeModel.fromMap(rows.first);
  }

  Future<IncomeModel> create(Map<String, dynamic> data) async {
    final db = _dbHelper.db;
    final id = await db.insert('incomes', data);
    return (await getById(id))!;
  }

  Future<IncomeModel> update(int id, Map<String, dynamic> data) async {
    final db = _dbHelper.db;
    data['updated_at'] = DateTime.now().toIso8601String();
    await db.update('incomes', data, where: 'id = ?', whereArgs: [id]);
    return (await getById(id))!;
  }

  Future<void> delete(int id) async {
    final db = _dbHelper.db;
    await db.delete('incomes', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<IncomeModel>> getByMonth(int year, int month) async {
    final db = _dbHelper.db;
    final m = month.toString().padLeft(2, '0');
    final rows = await db.rawQuery('''
      SELECT i.*, ic.name AS cat_name, c.name AS customer_name
      FROM incomes i
      LEFT JOIN income_categories ic ON ic.id = i.category_id
      LEFT JOIN customers c ON c.id = i.customer_id
      WHERE strftime('%Y', i.income_date) = ? AND strftime('%m', i.income_date) = ?
      ORDER BY i.income_date DESC, i.id DESC
    ''', [year.toString(), m]);
    return rows.map((r) => IncomeModel.fromMap(r)).toList();
  }

  Future<Map<String, dynamic>> getMonthlySummary(int year, int month) async {
    final db = _dbHelper.db;
    final m = month.toString().padLeft(2, '0');
    final rows = await db.rawQuery('''
      SELECT
        COUNT(*) AS count,
        COALESCE(SUM(amount), 0) AS total,
        COALESCE(AVG(amount), 0) AS avgAmount
      FROM incomes
      WHERE status = 'completed'
        AND strftime('%Y', income_date) = ?
        AND strftime('%m', income_date) = ?
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
        strftime('%m', income_date) AS month,
        COUNT(*) AS count,
        COALESCE(SUM(amount), 0) AS total
      FROM incomes
      WHERE status = 'completed' AND strftime('%Y', income_date) = ?
      GROUP BY month
      ORDER BY month
    ''', [year.toString()]);
  }

  Future<List<IncomeModel>> search(String query) async {
    final db = _dbHelper.db;
    final p = '%$query%';
    final rows = await db.rawQuery('''
      SELECT i.*, ic.name AS cat_name, c.name AS customer_name
      FROM incomes i
      LEFT JOIN income_categories ic ON ic.id = i.category_id
      LEFT JOIN customers c ON c.id = i.customer_id
      WHERE i.description LIKE ? OR i.reference LIKE ?
      ORDER BY i.income_date DESC, i.id DESC
    ''', [p, p]);
    return rows.map((r) => IncomeModel.fromMap(r)).toList();
  }
}
