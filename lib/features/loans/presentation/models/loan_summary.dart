import 'package:nexora_khata/features/loans/domain/entities/loan_contact.dart';

class LoanContactSummary {
  final LoanContact contact;
  final double totalLend;
  final double totalBorrow;

  const LoanContactSummary({
    required this.contact,
    required this.totalLend,
    required this.totalBorrow,
  });

  double get balance => totalLend - totalBorrow;

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

  double get netBalance => totalLend - totalBorrow;
}
