import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora_khata/features/loans/domain/entities/loan_contact.dart';
import 'package:nexora_khata/features/loans/domain/entities/loan_transaction.dart';
import 'package:nexora_khata/features/loans/presentation/providers/loan_provider.dart';
import 'package:nexora_khata/features/transactions/domain/entities/expense.dart';
import 'package:nexora_khata/features/transactions/domain/entities/income.dart';
import 'package:nexora_khata/features/transactions/domain/entities/transfer.dart';
import 'package:nexora_khata/features/transactions/presentation/models/transaction_entry.dart';
import 'package:nexora_khata/features/transactions/presentation/providers/expense_provider.dart';
import 'package:nexora_khata/features/transactions/presentation/providers/income_provider.dart';
import 'package:nexora_khata/features/transactions/presentation/providers/transfer_provider.dart';

final allTxSearchProvider = StateProvider<String>((ref) => '');
final allTxStatusProvider = StateProvider<String?>((ref) => null);
final allTxTypeProvider = StateProvider<String?>((ref) => null);
final allTxRefreshProvider = StateProvider<int>((ref) => 0);

final allTransactionsProvider =
    FutureProvider<List<TransactionEntry>>((ref) async {
  final incomeRepo = ref.read(incomeRepositoryProvider);
  final expenseRepo = ref.read(expenseRepositoryProvider);
  final loanRepo = ref.read(loanRepositoryProvider);
  final transferRepo = ref.read(transferRepositoryProvider);
  final search = ref.watch(allTxSearchProvider);
  final status = ref.watch(allTxStatusProvider);
  final type = ref.watch(allTxTypeProvider);
  ref.watch(allTxRefreshProvider);

  final includeIncome = type == null || type == 'income';
  final includeExpense = type == null || type == 'expense';
  final includeLoan = type == null || type == 'loan';
  final includeTransfer = type == null || type == 'transfer';

  var incomes = <Income>[];
  var expenses = <Expense>[];
  var loanContacts = <LoanContact>[];
  var loanTxns = <LoanTransaction>[];
  var transfers = <Transfer>[];

  if (includeIncome) {
    incomes = (await incomeRepo.getAll()).fold((l) => throw l, (r) => r);
  }
  if (includeExpense) {
    expenses = (await expenseRepo.getAll()).fold((l) => throw l, (r) => r);
  }
  if (includeLoan) {
    loanContacts = (await loanRepo.getContacts()).fold((l) => throw l, (r) => r);
    loanTxns = (await loanRepo.getAllTransactions()).fold((l) => throw l, (r) => r);
  }
  if (includeTransfer) {
    transfers = (await transferRepo.getAll()).fold((l) => throw l, (r) => r);
  }

  final contactNames = {for (final c in loanContacts) c.id: c.name};

  final list = <TransactionEntry>[
    for (final inc in incomes)
      TransactionEntry(
        type: 'income',
        id: inc.id,
        amount: inc.amount,
        description: inc.description,
        date: inc.incomeDate,
        categoryName: inc.catName,
        status: inc.status,
        createdAt: inc.createdAt,
        updatedAt: inc.updatedAt,
        referenceId: inc.reference,
        sourceTable: 'incomes',
        accountName: inc.customerName,
      ),
    for (final exp in expenses)
      TransactionEntry(
        type: 'expense',
        id: exp.id,
        amount: exp.amount,
        description: exp.description,
        date: exp.expenseDate,
        categoryName: exp.catName,
        status: exp.status,
        createdAt: exp.createdAt,
        updatedAt: exp.updatedAt,
        referenceId: exp.reference,
        sourceTable: 'expenses',
        accountName: exp.supplierName,
      ),
    for (final txn in loanTxns)
      TransactionEntry(
        type: 'loan',
        id: txn.id,
        amount: txn.amount,
        description: txn.note,
        date: txn.date,
        categoryName: contactNames[txn.contactId],
        status: 'completed',
        contactName: contactNames[txn.contactId],
        contactId: txn.contactId,
        loanType: txn.isRepay ? 'repay' : (txn.isBorrow ? 'borrow' : 'lend'),
        createdAt: txn.createdAt,
        updatedAt: txn.updatedAt,
        sourceTable: 'loan_transactions',
        accountName: contactNames[txn.contactId],
      ),
    for (final trf in transfers)
      TransactionEntry(
        type: 'transfer',
        id: trf.id,
        amount: trf.amount,
        description: trf.description,
        date: trf.transferDate,
        status: trf.status,
        fromType: trf.fromType,
        toType: trf.toType,
        createdAt: trf.createdAt,
        updatedAt: trf.updatedAt,
        referenceId: trf.reference,
        sourceTable: 'transfers',
      ),
  ];

  if (status != null && status.isNotEmpty) {
    list.removeWhere((e) => e.status != status);
  }
  if (search.isNotEmpty) {
    final q = search.toLowerCase();
    list.removeWhere((e) {
      final desc = e.description?.toLowerCase() ?? '';
      final cat = e.categoryName?.toLowerCase() ?? '';
      return !desc.contains(q) && !cat.contains(q);
    });
  }

  list.sort(compareTransactionEntries);

  return list;
});
