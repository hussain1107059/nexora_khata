import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora_khata/di/injection_container.dart';
import 'package:nexora_khata/features/transactions/data/datasources/transfer_datasource.dart';
import 'package:nexora_khata/features/transactions/domain/entities/transfer.dart';
import 'package:nexora_khata/features/transactions/domain/repositories/transfer_repository.dart';
import 'package:nexora_khata/features/transactions/presentation/models/account_option.dart';

final transferRepositoryProvider = Provider<TransferRepository>((ref) {
  return getIt<TransferRepository>();
});

final transferRefreshProvider = StateProvider<int>((ref) => 0);

final transferAccountOptionsProvider = FutureProvider<List<AccountOption>>((ref) async {
  final ds = getIt<TransferDataSource>();
  final cash = await ds.getCashAccounts();
  final bank = await ds.getBankAccounts();
  return [
    for (final r in cash)
      AccountOption(
        type: 'cash',
        id: r['id'] as int,
        name: r['name'] as String,
        balance: (r['balance'] as num).toDouble(),
      ),
    for (final r in bank)
      AccountOption(
        type: 'bank',
        id: r['id'] as int,
        name: r['account_name'] as String,
        balance: (r['balance'] as num).toDouble(),
      ),
  ];
});

final transferListProvider = FutureProvider<List<Transfer>>((ref) async {
  final repo = ref.read(transferRepositoryProvider);
  ref.watch(transferRefreshProvider);
  final result = await repo.getAll();
  return result.fold((l) => throw l, (r) => r);
});

class TransferFormNotifier extends StateNotifier<AsyncValue<void>> {
  final TransferRepository _repo;
  TransferFormNotifier(this._repo) : super(const AsyncData(null));

  Future<bool> create(Transfer transfer) async {
    state = const AsyncLoading();
    final result = await _repo.create(transfer);
    state = result.fold(
      (l) => AsyncError(l.message, StackTrace.current),
      (_) => const AsyncData(null),
    );
    return result.isRight();
  }

  Future<bool> delete(int id) async {
    state = const AsyncLoading();
    final result = await _repo.delete(id);
    state = result.fold(
      (l) => AsyncError(l.message, StackTrace.current),
      (_) => const AsyncData(null),
    );
    return result.isRight();
  }
}

final transferFormProvider = StateNotifierProvider<TransferFormNotifier, AsyncValue<void>>((ref) {
  return TransferFormNotifier(ref.read(transferRepositoryProvider));
});
