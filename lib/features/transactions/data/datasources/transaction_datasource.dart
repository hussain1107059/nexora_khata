import 'package:nexora_khata/core/services/current_user_scope.dart';
import 'package:nexora_khata/core/services/database_helper.dart';
import 'package:nexora_khata/core/utils/date_utils.dart';

class TransactionTableConfig<T> {
  final String table;
  final String alias;
  final String dateColumn;
  final String categoryTable;
  final String categoryAlias;
  final String partnerTable;
  final String partnerAlias;
  final String partnerColumn;
  final String partnerNameColumn;
  final T Function(Map<String, dynamic> row) fromMap;

  const TransactionTableConfig({
    required this.table,
    required this.alias,
    required this.dateColumn,
    required this.categoryTable,
    required this.categoryAlias,
    required this.partnerTable,
    required this.partnerAlias,
    required this.partnerColumn,
    required this.partnerNameColumn,
    required this.fromMap,
  });
}

class TransactionDataSource<T> {
  final DatabaseHelper _dbHelper;
  final TransactionTableConfig<T> _config;

  TransactionDataSource(this._dbHelper, this._config);

  int get _tenantId => CurrentUserScope.activeId;

  String get _select {
    final c = _config;
    return '''
      SELECT ${c.alias}.*, ${c.categoryAlias}.name AS cat_name, ${c.partnerAlias}.name AS ${c.partnerNameColumn}
      FROM ${c.table} ${c.alias}
      LEFT JOIN ${c.categoryTable} ${c.categoryAlias} ON ${c.categoryAlias}.id = ${c.alias}.category_id
      LEFT JOIN ${c.partnerTable} ${c.partnerAlias} ON ${c.partnerAlias}.id = ${c.alias}.${c.partnerColumn}
    ''';
  }

  Future<List<T>> getAll({
    String? search,
    String? status,
    int? categoryId,
    String? dateFrom,
    String? dateTo,
    int? limit,
    int? offset,
  }) async {
    final c = _config;
    final db = _dbHelper.db;
    final conditions = <String>['${c.alias}.business_id = ?'];
    final args = <Object?>[_tenantId];

    if (search != null && search.isNotEmpty) {
      conditions.add('(${c.alias}.description LIKE ? OR ${c.alias}.reference LIKE ?)');
      final p = '%$search%';
      args.add(p);
      args.add(p);
    }
    if (status != null && status.isNotEmpty) {
      conditions.add('${c.alias}.status = ?');
      args.add(status);
    }
    if (categoryId != null) {
      conditions.add('${c.alias}.category_id = ?');
      args.add(categoryId);
    }
    if (dateFrom != null && dateFrom.isNotEmpty) {
      conditions.add('${c.alias}.${c.dateColumn} >= ?');
      args.add(dateFrom);
    }
    if (dateTo != null && dateTo.isNotEmpty) {
      conditions.add('${c.alias}.${c.dateColumn} <= ?');
      args.add(dateTo);
    }

    final where =
        conditions.isNotEmpty ? 'WHERE ${conditions.join(' AND ')}' : '';

    final sql = '''
      $_select
      $where
      ORDER BY ${c.alias}.${c.dateColumn} DESC, ${c.alias}.id DESC
      ${limit != null ? 'LIMIT ?' : ''}
      ${offset != null ? 'OFFSET ?' : ''}
    ''';

    if (limit != null) args.add(limit);
    if (offset != null) args.add(offset);

    final rows = await db.rawQuery(sql, args);
    return rows.map((r) => c.fromMap(r)).toList();
  }

  Future<T?> getById(int id) async {
    final db = _dbHelper.db;
    final c = _config;
    final rows = await db.rawQuery(
        '$_select WHERE ${c.alias}.id = ? AND ${c.alias}.business_id = ?',
        [id, _tenantId]);
    if (rows.isEmpty) return null;
    return c.fromMap(rows.first);
  }

  Future<T> create(Map<String, dynamic> data) async {
    final db = _dbHelper.db;
    data['business_id'] = _tenantId;
    final id = await db.insert(_config.table, data);
    return (await getById(id))!;
  }

  Future<T> update(int id, Map<String, dynamic> data) async {
    final db = _dbHelper.db;
    data['updated_at'] = DateTime.now().toIso8601String();
    data['business_id'] = _tenantId;
    await db.update(_config.table, data,
        where: 'id = ? AND business_id = ?', whereArgs: [id, _tenantId]);
    return (await getById(id))!;
  }

  Future<void> delete(int id) async {
    final db = _dbHelper.db;
    await db.delete(_config.table,
        where: 'id = ? AND business_id = ?', whereArgs: [id, _tenantId]);
  }

  Future<List<T>> getByMonth(int year, int month) async {
    final c = _config;
    final db = _dbHelper.db;
    final rows = await db.rawQuery('''
      $_select
      WHERE ${c.alias}.${c.dateColumn} >= ? AND ${c.alias}.${c.dateColumn} < ?
        AND ${c.alias}.business_id = ?
      ORDER BY ${c.alias}.${c.dateColumn} DESC, ${c.alias}.id DESC
    ''', [
      AppDateUtils.monthStart(year, month),
      AppDateUtils.monthEndExclusive(year, month),
      _tenantId,
    ]);
    return rows.map((r) => c.fromMap(r)).toList();
  }

  Future<Map<String, dynamic>> getMonthlySummary(int year, int month) async {
    final c = _config;
    final db = _dbHelper.db;
    final rows = await db.rawQuery('''
      SELECT
        COUNT(*) AS count,
        COALESCE(SUM(amount), 0) AS total,
        COALESCE(AVG(amount), 0) AS avgAmount
      FROM ${c.table}
      WHERE status = 'completed'
        AND ${c.dateColumn} >= ?
        AND ${c.dateColumn} < ?
        AND business_id = ?
    ''', [
      AppDateUtils.monthStart(year, month),
      AppDateUtils.monthEndExclusive(year, month),
      _tenantId,
    ]);
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
    final c = _config;
    final db = _dbHelper.db;
    return db.rawQuery('''
      SELECT
        strftime('%m', ${c.dateColumn}) AS month,
        COUNT(*) AS count,
        COALESCE(SUM(amount), 0) AS total
      FROM ${c.table}
      WHERE status = 'completed' AND ${c.dateColumn} >= ? AND ${c.dateColumn} < ?
        AND business_id = ?
      GROUP BY month
      ORDER BY month
    ''', [
      AppDateUtils.yearStart(year),
      AppDateUtils.yearEndExclusive(year),
      _tenantId,
    ]);
  }

  Future<List<T>> search(String query) async {
    final c = _config;
    final db = _dbHelper.db;
    final p = '%$query%';
    final rows = await db.rawQuery('''
      $_select
      WHERE (${c.alias}.description LIKE ? OR ${c.alias}.reference LIKE ?)
        AND ${c.alias}.business_id = ?
      ORDER BY ${c.alias}.${c.dateColumn} DESC, ${c.alias}.id DESC
    ''', [p, p, _tenantId]);
    return rows.map((r) => c.fromMap(r)).toList();
  }

  Future<List<T>> getByDate(String date) async {
    final c = _config;
    final db = _dbHelper.db;
    final rows = await db.rawQuery('''
      $_select
      WHERE ${c.alias}.${c.dateColumn} = ? AND ${c.alias}.business_id = ?
      ORDER BY ${c.alias}.id DESC
    ''', [date, _tenantId]);
    return rows.map((r) => c.fromMap(r)).toList();
  }

  Future<Map<String, dynamic>> getDailySummary(String date) async {
    final c = _config;
    final db = _dbHelper.db;
    final rows = await db.rawQuery('''
      SELECT
        COUNT(*) AS count,
        COALESCE(SUM(amount), 0) AS total,
        COALESCE(AVG(amount), 0) AS avgAmount
      FROM ${c.table}
      WHERE status = 'completed' AND ${c.dateColumn} = ? AND business_id = ?
    ''', [date, _tenantId]);
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
