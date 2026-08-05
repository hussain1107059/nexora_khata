import 'package:nexora_khata/core/services/current_user_scope.dart';
import 'package:nexora_khata/core/services/database_helper.dart';
import 'package:nexora_khata/features/loans/data/models/loan_contact_model.dart';
import 'package:nexora_khata/features/loans/data/models/loan_transaction_model.dart';

class LoanDataSource {
  final DatabaseHelper _dbHelper;
  LoanDataSource(this._dbHelper);

  int get _tenantId => CurrentUserScope.activeId;

  Future<List<LoanContactModel>> getContacts() async {
    final rows = await _dbHelper.db.rawQuery(
      '''
      SELECT * FROM loan_contacts
      WHERE business_id = ?
      ORDER BY name COLLATE NOCASE ASC
      ''',
      [_tenantId],
    );
    return rows.map(LoanContactModel.fromMap).toList();
  }

  Future<LoanContactModel?> getContact(int id) async {
    final rows = await _dbHelper.db.rawQuery(
      'SELECT * FROM loan_contacts WHERE id = ? AND business_id = ?',
      [id, _tenantId],
    );
    if (rows.isEmpty) return null;
    return LoanContactModel.fromMap(rows.first);
  }

  Future<LoanContactModel> createContact(Map<String, dynamic> data) async {
    final db = _dbHelper.db;
    data['business_id'] = _tenantId;
    final id = await db.insert('loan_contacts', data);
    return (await getContact(id))!;
  }

  Future<LoanContactModel> updateContact(
    int id,
    Map<String, dynamic> data,
  ) async {
    final db = _dbHelper.db;
    data['updated_at'] = DateTime.now().toIso8601String();
    data['business_id'] = _tenantId;
    await db.update('loan_contacts', data,
        where: 'id = ? AND business_id = ?', whereArgs: [id, _tenantId]);
    return (await getContact(id))!;
  }

  Future<void> deleteContact(int id) async {
    final db = _dbHelper.db;
    await db.delete('loan_transactions',
        where: 'contact_id = ? AND business_id = ?',
        whereArgs: [id, _tenantId]);
    await db.delete('loan_contacts',
        where: 'id = ? AND business_id = ?', whereArgs: [id, _tenantId]);
  }

  Future<List<LoanTransactionModel>> getTransactions(int contactId) async {
    final rows = await _dbHelper.db.rawQuery(
      '''
      SELECT * FROM loan_transactions
      WHERE contact_id = ? AND business_id = ?
      ORDER BY created_at DESC, id DESC
      ''',
      [contactId, _tenantId],
    );
    return rows.map(LoanTransactionModel.fromMap).toList();
  }

  Future<List<LoanTransactionModel>> getAllTransactions() async {
    final rows = await _dbHelper.db.rawQuery(
      '''
      SELECT * FROM loan_transactions
      WHERE business_id = ?
      ORDER BY created_at DESC, id DESC
      ''',
      [_tenantId],
    );
    return rows.map(LoanTransactionModel.fromMap).toList();
  }

  Future<LoanTransactionModel> createTransaction(
    Map<String, dynamic> data,
  ) async {
    final db = _dbHelper.db;
    data['business_id'] = _tenantId;
    final id = await db.insert('loan_transactions', data);
    final rows = await db.rawQuery(
      'SELECT * FROM loan_transactions WHERE id = ? AND business_id = ?',
      [id, _tenantId],
    );
    return LoanTransactionModel.fromMap(rows.first);
  }

  Future<LoanTransactionModel> updateTransaction(
    int id,
    Map<String, dynamic> data,
  ) async {
    final db = _dbHelper.db;
    data['updated_at'] = DateTime.now().toIso8601String();
    data['business_id'] = _tenantId;
    await db.update(
      'loan_transactions',
      data,
      where: 'id = ? AND business_id = ?',
      whereArgs: [id, _tenantId],
    );
    final rows = await db.rawQuery(
      'SELECT * FROM loan_transactions WHERE id = ? AND business_id = ?',
      [id, _tenantId],
    );
    return LoanTransactionModel.fromMap(rows.first);
  }

  Future<void> deleteTransaction(int id) async {
    final db = _dbHelper.db;
    await db.delete('loan_transactions',
        where: 'id = ? AND business_id = ?', whereArgs: [id, _tenantId]);
  }
}
