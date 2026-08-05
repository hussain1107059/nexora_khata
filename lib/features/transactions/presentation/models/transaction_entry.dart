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
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? referenceId;
  final String? sourceTable;
  final String? accountName;

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
    required this.createdAt,
    this.updatedAt,
    this.referenceId,
    this.sourceTable,
    this.accountName,
  });

  bool get isIncome => type == 'income';

  bool get isExpense => type == 'expense';

  bool get isLoan => type == 'loan';

  bool get isTransfer => type == 'transfer';

  bool get isLoanBorrow => isLoan && loanType == 'borrow';

  bool get isLoanLend => isLoan && loanType == 'lend';

  bool get isLoanRepay => isLoan && loanType == 'repay';
}

/// Global sort used for every unified transaction timeline.
///
/// Ordering is based ONLY on the creation time of the transaction.
/// If `createdAt` is identical, the record with the higher `id` wins
/// (created later in the same instant). Transaction type is never
/// considered.
int compareTransactionEntries(TransactionEntry a, TransactionEntry b) {
  final d = b.createdAt.compareTo(a.createdAt);
  if (d != 0) return d;
  return b.id.compareTo(a.id);
}
