import 'package:nexora_khata/core/services/current_user_scope.dart';
import 'package:nexora_khata/core/services/database_helper.dart';
import 'package:nexora_khata/features/transactions/data/models/transfer_model.dart';

class TransferDataSource {
  final DatabaseHelper _dbHelper;
  TransferDataSource(this._dbHelper);

  int get _tenantId => CurrentUserScope.activeId;

  Future<List<Map<String, dynamic>>> getCashAccounts() async {
    return _dbHelper.db.rawQuery(
      '''
      SELECT id, name, balance
      FROM cash_accounts
      WHERE business_id = ? AND status = 'active'
      ORDER BY id
      ''',
      [_tenantId],
    );
  }

  Future<List<Map<String, dynamic>>> getBankAccounts() async {
    return _dbHelper.db.rawQuery(
      '''
      SELECT id, account_name, balance
      FROM bank_accounts
      WHERE business_id = ? AND status = 'active'
      ORDER BY id
      ''',
      [_tenantId],
    );
  }

  Future<int?> getDefaultCashAccountId() async {
    final rows = await _dbHelper.db.rawQuery(
      '''
      SELECT id FROM cash_accounts
      WHERE business_id = ? AND status = 'active'
      ORDER BY is_default DESC, id ASC
      LIMIT 1
      ''',
      [_tenantId],
    );
    if (rows.isEmpty) return null;
    return rows.first['id'] as int;
  }

  Future<int?> getDefaultBankAccountId() async {
    final rows = await _dbHelper.db.rawQuery(
      '''
      SELECT id FROM bank_accounts
      WHERE business_id = ? AND status = 'active'
      ORDER BY is_default DESC, id ASC
      LIMIT 1
      ''',
      [_tenantId],
    );
    if (rows.isEmpty) return null;
    return rows.first['id'] as int;
  }

  Future<List<TransferModel>> getAll() async {
    final rows = await _dbHelper.db.rawQuery(
      '''
      SELECT * FROM transfers
      WHERE business_id = ?
      ORDER BY created_at DESC, id DESC
      ''',
      [_tenantId],
    );
    return rows.map(TransferModel.fromMap).toList();
  }

  Future<TransferModel> create(Map<String, dynamic> data) async {
    final db = _dbHelper.db;
    data['business_id'] = _tenantId;
    final id = await db.insert('transfers', data);
    final rows = await db.rawQuery(
      'SELECT * FROM transfers WHERE id = ? AND business_id = ?',
      [id, _tenantId],
    );
    return TransferModel.fromMap(rows.first);
  }

  Future<void> delete(int id) async {
    await _dbHelper.db.delete('transfers',
        where: 'id = ? AND business_id = ?', whereArgs: [id, _tenantId]);
  }
}
