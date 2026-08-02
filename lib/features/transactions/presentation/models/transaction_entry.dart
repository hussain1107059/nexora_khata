class TransactionEntry {
  final String type;
  final int id;
  final double amount;
  final String? description;
  final DateTime date;
  final String? categoryName;
  final String status;

  const TransactionEntry({
    required this.type,
    required this.id,
    required this.amount,
    this.description,
    required this.date,
    this.categoryName,
    required this.status,
  });

  bool get isIncome => type == 'income';

  bool get isExpense => type == 'expense';
}
