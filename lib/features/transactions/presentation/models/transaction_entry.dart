class TransactionEntry {
  final String type;
  final int id;
  final double amount;
  final String? description;
  final DateTime date;
  final String? categoryName;
  final String status;
  final String? contactName;
  final String? loanType;
  final int? contactId;
  final String? fromType;
  final String? toType;

  const TransactionEntry({
    required this.type,
    required this.id,
    required this.amount,
    this.description,
    required this.date,
    this.categoryName,
    required this.status,
    this.contactName,
    this.loanType,
    this.contactId,
    this.fromType,
    this.toType,
  });

  bool get isIncome => type == 'income';

  bool get isExpense => type == 'expense';

  bool get isLoan => type == 'loan';

  bool get isTransfer => type == 'transfer';

  bool get isLoanBorrow => isLoan && loanType == 'borrow';

  bool get isLoanLend => isLoan && loanType == 'lend';

  bool get isLoanRepay => isLoan && loanType == 'repay';
}
