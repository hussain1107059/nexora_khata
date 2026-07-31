import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora_khata/di/injection_container.dart';
import 'package:nexora_khata/features/categories/domain/entities/expense_category.dart';
import 'package:nexora_khata/features/categories/domain/repositories/expense_category_repository.dart';

final expenseCategoryRepositoryProvider = Provider<ExpenseCategoryRepository>((ref) {
  return getIt<ExpenseCategoryRepository>();
});

final expenseCategoryListProvider = FutureProvider<List<ExpenseCategory>>((ref) async {
  final repo = ref.read(expenseCategoryRepositoryProvider);
  final result = await repo.getAll();
  return result.fold((l) => throw l, (r) => r);
});

final expenseCategoryRefreshProvider = StateProvider<int>((ref) => 0);

class ExpenseCategoryFormNotifier extends StateNotifier<AsyncValue<void>> {
  final ExpenseCategoryRepository _repo;
  ExpenseCategoryFormNotifier(this._repo) : super(const AsyncData(null));

  Future<void> create(ExpenseCategory category) async {
    state = const AsyncLoading();
    final result = await _repo.create(category);
    state = result.fold(
      (l) => AsyncError(l.message, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }

  Future<void> update(ExpenseCategory category) async {
    state = const AsyncLoading();
    final result = await _repo.update(category);
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

final expenseCategoryFormProvider = StateNotifierProvider<ExpenseCategoryFormNotifier, AsyncValue<void>>((ref) {
  return ExpenseCategoryFormNotifier(ref.read(expenseCategoryRepositoryProvider));
});
