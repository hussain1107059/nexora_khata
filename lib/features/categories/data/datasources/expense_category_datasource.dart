import 'package:nexora_khata/core/services/database_helper.dart';
import 'package:nexora_khata/features/categories/data/models/expense_category_model.dart';

class ExpenseCategoryDataSource {
  final DatabaseHelper _dbHelper;
  ExpenseCategoryDataSource(this._dbHelper);

  Future<List<ExpenseCategoryModel>> getAll({String? status}) async {
    final db = _dbHelper.db;
    final conditions = <String>[];
    final args = <Object?>[];

    if (status != null && status.isNotEmpty) {
      conditions.add('status = ?');
      args.add(status);
    } else {
      conditions.add("status != 'inactive'");
    }

    final where =
        conditions.isNotEmpty ? 'WHERE ${conditions.join(' AND ')}' : '';

    final rows = await db.rawQuery('''
      SELECT * FROM expense_categories
      $where
      ORDER BY sort_order ASC, name ASC
    ''', args);
    return rows.map((r) => ExpenseCategoryModel.fromMap(r)).toList();
  }

  Future<ExpenseCategoryModel?> getById(int id) async {
    final db = _dbHelper.db;
    final rows = await db.rawQuery(
      'SELECT * FROM expense_categories WHERE id = ?',
      [id],
    );
    if (rows.isEmpty) return null;
    return ExpenseCategoryModel.fromMap(rows.first);
  }

  Future<ExpenseCategoryModel> create(Map<String, dynamic> data) async {
    final db = _dbHelper.db;
    final id = await db.insert('expense_categories', data);
    return (await getById(id))!;
  }

  Future<ExpenseCategoryModel> update(
      int id, Map<String, dynamic> data) async {
    final db = _dbHelper.db;
    data['updated_at'] = DateTime.now().toIso8601String();
    await db.update(
      'expense_categories',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
    return (await getById(id))!;
  }

  Future<void> delete(int id) async {
    final db = _dbHelper.db;
    await db.delete(
      'expense_categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
