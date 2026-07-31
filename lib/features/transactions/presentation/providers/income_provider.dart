import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora_khata/di/injection_container.dart';
import 'package:nexora_khata/features/transactions/domain/entities/income.dart';
import 'package:nexora_khata/features/transactions/domain/repositories/income_repository.dart';

final incomeRepositoryProvider = Provider<IncomeRepository>((ref) {
  return getIt<IncomeRepository>();
});

final incomeListProvider = FutureProvider<List<Income>>((ref) async {
  final repo = ref.read(incomeRepositoryProvider);
  final result = await repo.getAll();
  return result.fold((l) => throw l, (r) => r);
});

final incomeSearchProvider = StateProvider<String>((ref) => '');
final incomeStatusFilterProvider = StateProvider<String?>((ref) => null);
final incomeCategoryFilterProvider = StateProvider<int?>((ref) => null);
final incomeDateFromFilterProvider = StateProvider<String?>((ref) => null);
final incomeDateToFilterProvider = StateProvider<String?>((ref) => null);

final incomeFilteredListProvider = FutureProvider<List<Income>>((ref) async {
  final repo = ref.read(incomeRepositoryProvider);
  final search = ref.watch(incomeSearchProvider);
  final status = ref.watch(incomeStatusFilterProvider);
  final categoryId = ref.watch(incomeCategoryFilterProvider);
  final dateFrom = ref.watch(incomeDateFromFilterProvider);
  final dateTo = ref.watch(incomeDateToFilterProvider);
  ref.watch(incomeRefreshProvider);

  final result = await repo.getAll(
    search: search.isEmpty ? null : search,
    status: status,
    categoryId: categoryId,
    dateFrom: dateFrom,
    dateTo: dateTo,
  );
  return result.fold((l) => throw l, (r) => r);
});

final incomeRefreshProvider = StateProvider<int>((ref) => 0);

final incomeDetailProvider = FutureProvider.family<Income?, int>((ref, id) async {
  final repo = ref.read(incomeRepositoryProvider);
  final result = await repo.getById(id);
  return result.fold((l) => throw l, (r) => r);
});

class IncomeFormNotifier extends StateNotifier<AsyncValue<void>> {
  final IncomeRepository _repo;
  IncomeFormNotifier(this._repo) : super(const AsyncData(null));

  Future<void> create(Income income) async {
    state = const AsyncLoading();
    final result = await _repo.create(income);
    state = result.fold(
      (l) => AsyncError(l.message, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }

  Future<void> update(Income income) async {
    state = const AsyncLoading();
    final result = await _repo.update(income);
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

final incomeFormProvider = StateNotifierProvider<IncomeFormNotifier, AsyncValue<void>>((ref) {
  return IncomeFormNotifier(ref.read(incomeRepositoryProvider));
});

final incomeMonthlyReportProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, year) async {
  final repo = ref.read(incomeRepositoryProvider);
  final result = await repo.getMonthlyReport(year);
  return result.fold((l) => throw l, (r) => r);
});

final incomeMonthlySummaryProvider = FutureProvider.family<Map<String, dynamic>, Map<String, int>>((ref, params) async {
  final repo = ref.read(incomeRepositoryProvider);
  final result = await repo.getMonthlySummary(params['year']!, params['month']!);
  return result.fold((l) => throw l, (r) => r);
});

final incomeByMonthProvider = FutureProvider.family<List<Income>, Map<String, int>>((ref, params) async {
  final repo = ref.read(incomeRepositoryProvider);
  final result = await repo.getByMonth(params['year']!, params['month']!);
  return result.fold((l) => throw l, (r) => r);
});
