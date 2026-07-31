import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora_khata/di/injection_container.dart';
import 'package:nexora_khata/features/transactions/domain/entities/expense.dart';
import 'package:nexora_khata/features/transactions/domain/repositories/expense_repository.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return getIt<ExpenseRepository>();
});

final expenseListProvider = FutureProvider<List<Expense>>((ref) async {
  final repo = ref.read(expenseRepositoryProvider);
  final result = await repo.getAll();
  return result.fold((l) => throw l, (r) => r);
});

final expenseSearchProvider = StateProvider<String>((ref) => '');
final expenseStatusFilterProvider = StateProvider<String?>((ref) => null);
final expenseCategoryFilterProvider = StateProvider<int?>((ref) => null);
final expenseDateFromFilterProvider = StateProvider<String?>((ref) => null);
final expenseDateToFilterProvider = StateProvider<String?>((ref) => null);

final expenseFilteredListProvider = FutureProvider<List<Expense>>((ref) async {
  final repo = ref.read(expenseRepositoryProvider);
  final search = ref.watch(expenseSearchProvider);
  final status = ref.watch(expenseStatusFilterProvider);
  final categoryId = ref.watch(expenseCategoryFilterProvider);
  final dateFrom = ref.watch(expenseDateFromFilterProvider);
  final dateTo = ref.watch(expenseDateToFilterProvider);
  ref.watch(expenseRefreshProvider);

  final result = await repo.getAll(
    search: search.isEmpty ? null : search,
    status: status,
    categoryId: categoryId,
    dateFrom: dateFrom,
    dateTo: dateTo,
  );
  return result.fold((l) => throw l, (r) => r);
});

final expenseRefreshProvider = StateProvider<int>((ref) => 0);

final expenseDetailProvider = FutureProvider.family<Expense?, int>((ref, id) async {
  final repo = ref.read(expenseRepositoryProvider);
  final result = await repo.getById(id);
  return result.fold((l) => throw l, (r) => r);
});

class ExpenseFormNotifier extends StateNotifier<AsyncValue<void>> {
  final ExpenseRepository _repo;
  ExpenseFormNotifier(this._repo) : super(const AsyncData(null));

  Future<void> create(Expense expense) async {
    state = const AsyncLoading();
    final result = await _repo.create(expense);
    state = result.fold(
      (l) => AsyncError(l.message, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }

  Future<void> update(Expense expense) async {
    state = const AsyncLoading();
    final result = await _repo.update(expense);
    state = result.fold(
      (l) => AsyncError(l.message, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }

  Future<void> delete(int id) async {
    state = const AsyncLoading();
    final result = await _repo.delete(id);
    state = result.fold(
      (l) => AsyncError(l.message, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }
}

final expenseFormProvider = StateNotifierProvider<ExpenseFormNotifier, AsyncValue<void>>((ref) {
  return ExpenseFormNotifier(ref.read(expenseRepositoryProvider));
});

final expenseMonthlyReportProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, year) async {
  final repo = ref.read(expenseRepositoryProvider);
  final result = await repo.getMonthlyReport(year);
  return result.fold((l) => throw l, (r) => r);
});

final expenseMonthlySummaryProvider = FutureProvider.family<Map<String, dynamic>, Map<String, int>>((ref, params) async {
  final repo = ref.read(expenseRepositoryProvider);
  final result = await repo.getMonthlySummary(params['year']!, params['month']!);
  return result.fold((l) => throw l, (r) => r);
});

final expenseByMonthProvider = FutureProvider.family<List<Expense>, Map<String, int>>((ref, params) async {
  final repo = ref.read(expenseRepositoryProvider);
  final result = await repo.getByMonth(params['year']!, params['month']!);
  return result.fold((l) => throw l, (r) => r);
});

final expenseDailyReportProvider = FutureProvider.family<List<Expense>, String>((ref, date) async {
  final repo = ref.read(expenseRepositoryProvider);
  final result = await repo.getByDate(date);
  return result.fold((l) => throw l, (r) => r);
});

final expenseDailySummaryProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, date) async {
  final repo = ref.read(expenseRepositoryProvider);
  final result = await repo.getDailySummary(date);
  return result.fold((l) => throw l, (r) => r);
});
