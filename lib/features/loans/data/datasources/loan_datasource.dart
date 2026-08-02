import 'package:nexora_khata/core/services/database_helper.dart';
import 'package:nexora_khata/features/loans/data/models/loan_contact_model.dart';
import 'package:nexora_khata/features/loans/data/models/loan_transaction_model.dart';

class LoanDataSource {
  final DatabaseHelper _dbHelper;
  LoanDataSource(this._dbHelper);

  Future<List<LoanContactModel>> getContacts() async {
    final rows = await _dbHelper.db.rawQuery(
      '''
      SELECT * FROM loan_contacts
      WHERE business_id = 0
      ORDER BY name COLLATE NOCASE ASC
      ''',
    );
    return rows.map(LoanContactModel.fromMap).toList();
  }

  Future<LoanContactModel?> getContact(int id) async {
    final rows = await _dbHelper.db.rawQuery(
      'SELECT * FROM loan_contacts WHERE id = ?',
      [id],
    );
    if (rows.isEmpty) return null;
    return LoanContactModel.fromMap(rows.first);
  }

  Future<LoanContactModel> createContact(Map<String, dynamic> data) async {
    final db = _dbHelper.db;
    final id = await db.insert('loan_contacts', data);
    return (await getContact(id))!;
  }

  Future<LoanContactModel> updateContact(
    int id,
    Map<String, dynamic> data,
  ) async {
    final db = _dbHelper.db;
    data['updated_at'] = DateTime.now().toIso8601String();
    await db.update('loan_contacts', data, where: 'id = ?', whereArgs: [id]);
    return (await getContact(id))!;
  }

  Future<void> deleteContact(int id) async {
    final db = _dbHelper.db;
    await db.delete('loan_transactions',
        where: 'contact_id = ?', whereArgs: [id]);
    await db.delete('loan_contacts', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<LoanTransactionModel>> getTransactions(int contactId) async {
    final rows = await _dbHelper.db.rawQuery(
      '''
      SELECT * FROM loan_transactions
      WHERE contact_id = ?
      ORDER BY date DESC, id DESC
      ''',
      [contactId],
    );
    return rows.map(LoanTransactionModel.fromMap).toList();
  }

  Future<List<LoanTransactionModel>> getAllTransactions() async {
    final rows = await _dbHelper.db.rawQuery(
      '''
      SELECT * FROM loan_transactions
      WHERE business_id = 0
      ORDER BY date DESC, id DESC
      ''',
    );
    return rows.map(LoanTransactionModel.fromMap).toList();
  }

  Future<LoanTransactionModel> createTransaction(
    Map<String, dynamic> data,
  ) async {
    final db = _dbHelper.db;
    final id = await db.insert('loan_transactions', data);
    final rows = await db.rawQuery(
      'SELECT * FROM loan_transactions WHERE id = ?',
      [id],
    );
    return LoanTransactionModel.fromMap(rows.first);
  }

  Future<void> deleteTransaction(int id) async {
    final db = _dbHelper.db;
    await db.delete('loan_transactions', where: 'id = ?', whereArgs: [id]);
  }
}
