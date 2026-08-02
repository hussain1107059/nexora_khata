import 'package:nexora_khata/features/loans/domain/entities/loan_contact.dart';

class LoanContactSummary {
  final LoanContact contact;
  final double totalLend;
  final double totalBorrow;
  final double repaidLend;
  final double repaidBorrow;
  final double cashLend;
  final double cashBorrow;
  final double bankLend;
  final double bankBorrow;

  const LoanContactSummary({
    required this.contact,
    required this.totalLend,
    required this.totalBorrow,
    this.repaidLend = 0,
    this.repaidBorrow = 0,
    this.cashLend = 0,
    this.cashBorrow = 0,
    this.bankLend = 0,
    this.bankBorrow = 0,
  });

  double get remainingLend => totalLend - repaidLend;

  double get remainingBorrow => totalBorrow - repaidBorrow;

  double get balance => remainingLend - remainingBorrow;

  bool get isReceivable => balance > 0;

  bool get isPayable => balance < 0;

  bool get isSettled => balance == 0;
}

class LoanDashboard {
  final List<LoanContactSummary> contacts;
  final double totalLend;
  final double totalBorrow;

  const LoanDashboard({
    required this.contacts,
    required this.totalLend,
    required this.totalBorrow,
  });

  double get netBalance =>
      contacts.fold<double>(0, (sum, c) => sum + c.balance);
}
