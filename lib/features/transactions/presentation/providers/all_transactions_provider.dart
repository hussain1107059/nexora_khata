import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora_khata/features/transactions/presentation/models/transaction_entry.dart';
import 'package:nexora_khata/features/transactions/presentation/providers/expense_provider.dart';
import 'package:nexora_khata/features/transactions/presentation/providers/income_provider.dart';

final allTxSearchProvider = StateProvider<String>((ref) => '');
final allTxStatusProvider = StateProvider<String?>((ref) => null);
final allTxTypeProvider = StateProvider<String?>((ref) => null);
final allTxRefreshProvider = StateProvider<int>((ref) => 0);

final allTransactionsProvider = FutureProvider<List<TransactionEntry>>((ref) async {
  final incomeRepo = ref.read(incomeRepositoryProvider);
  final expenseRepo = ref.read(expenseRepositoryProvider);
  final search = ref.watch(allTxSearchProvider);
  final status = ref.watch(allTxStatusProvider);
  final type = ref.watch(allTxTypeProvider);
  ref.watch(allTxRefreshProvider);

  final incomeResult = await incomeRepo.getAll();
  final expenseResult = await expenseRepo.getAll();

  final incomes = incomeResult.fold((l) => throw l, (r) => r);
  final expenses = expenseResult.fold((l) => throw l, (r) => r);

  var list = <TransactionEntry>[
    for (final inc in incomes)
      TransactionEntry(
        type: 'income',
        id: inc.id,
        amount: inc.amount,
        description: inc.description,
        date: inc.incomeDate,
        categoryName: inc.catName,
        status: inc.status,
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
      ),
  ];

  if (type != null) {
    list = list.where((e) => e.type == type).toList();
  }
  if (status != null && status.isNotEmpty) {
    list = list.where((e) => e.status == status).toList();
  }
  if (search.isNotEmpty) {
    final q = search.toLowerCase();
    list = list
        .where((e) =>
            (e.description?.toLowerCase().contains(q) ?? false) ||
            (e.categoryName?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  list.sort((a, b) {
    final d = b.date.compareTo(a.date);
    if (d != 0) return d;
    return b.id.compareTo(a.id);
  });

  return list;
});
