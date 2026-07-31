import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora_khata/di/injection_container.dart';
import 'package:nexora_khata/features/categories/domain/entities/income_category.dart';
import 'package:nexora_khata/features/categories/domain/repositories/income_category_repository.dart';

final incomeCategoryRepositoryProvider = Provider<IncomeCategoryRepository>((ref) {
  return getIt<IncomeCategoryRepository>();
});

final incomeCategoryListProvider = FutureProvider<List<IncomeCategory>>((ref) async {
  final repo = ref.read(incomeCategoryRepositoryProvider);
  final result = await repo.getAll();
  return result.fold((l) => throw l, (r) => r);
});

final incomeCategoryRefreshProvider = StateProvider<int>((ref) => 0);

class IncomeCategoryFormNotifier extends StateNotifier<AsyncValue<void>> {
  final IncomeCategoryRepository _repo;
  IncomeCategoryFormNotifier(this._repo) : super(const AsyncData(null));

  Future<void> create(IncomeCategory category) async {
    state = const AsyncLoading();
    final result = await _repo.create(category);
    state = result.fold(
      (l) => AsyncError(l.message, StackTrace.current),
      (_) => const AsyncData(null),
    );
  }

  Future<void> update(IncomeCategory category) async {
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

final incomeCategoryFormProvider = StateNotifierProvider<IncomeCategoryFormNotifier, AsyncValue<void>>((ref) {
  return IncomeCategoryFormNotifier(ref.read(incomeCategoryRepositoryProvider));
});
