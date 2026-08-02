import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora_khata/core/services/logger.dart';
import 'package:nexora_khata/core/services/notification_service.dart';
import 'package:nexora_khata/di/injection_container.dart';
import 'package:nexora_khata/features/loans/domain/entities/loan_contact.dart';
import 'package:nexora_khata/features/loans/domain/entities/loan_transaction.dart';
import 'package:nexora_khata/features/loans/domain/repositories/loan_repository.dart';
import 'package:nexora_khata/features/loans/presentation/models/loan_summary.dart';

final loanRepositoryProvider = Provider<LoanRepository>((ref) {
  return getIt<LoanRepository>();
});

final loanRefreshProvider = StateProvider<int>((ref) => 0);

final loanContactListProvider = FutureProvider<List<LoanContact>>((ref) async {
  final repo = ref.read(loanRepositoryProvider);
  ref.watch(loanRefreshProvider);
  final result = await repo.getContacts();
  return result.fold((l) => throw l, (r) => r);
});

final loanDashboardProvider = FutureProvider<LoanDashboard>((ref) async {
  final repo = ref.read(loanRepositoryProvider);
  ref.watch(loanRefreshProvider);
  final contactsResult = await repo.getContacts();
  final txnResult = await repo.getAllTransactions();

  final contacts = contactsResult.fold(
    (l) => throw l,
    (r) => r,
  );
  final txns = txnResult.fold(
    (l) => throw l,
    (r) => r,
  );

  final byContact = <int, List<LoanTransaction>>{};
  for (final t in txns) {
    byContact.putIfAbsent(t.contactId, () => []).add(t);
  }

  double totalLend = 0;
  double totalBorrow = 0;

  final summaries = contacts.map((c) {
    final list = byContact[c.id] ?? const <LoanTransaction>[];
    final lend = list
        .where((t) => t.isLend)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final borrow = list
        .where((t) => t.isBorrow)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final repaidLend = list
        .where((t) => t.repaysLend)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final repaidBorrow = list
        .where((t) => t.repaysBorrow)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final cashLend = list
        .where((t) => t.isLend && t.isCash)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final cashBorrow = list
        .where((t) => t.isBorrow && t.isCash)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final bankLend = list
        .where((t) => t.isLend && !t.isCash)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final bankBorrow = list
        .where((t) => t.isBorrow && !t.isCash)
        .fold<double>(0, (sum, t) => sum + t.amount);
    totalLend += lend;
    totalBorrow += borrow;
    return LoanContactSummary(
      contact: c,
      totalLend: lend,
      totalBorrow: borrow,
      repaidLend: repaidLend,
      repaidBorrow: repaidBorrow,
      cashLend: cashLend,
      cashBorrow: cashBorrow,
      bankLend: bankLend,
      bankBorrow: bankBorrow,
    );
  }).toList()
    ..sort((a, b) {
      final aName = a.contact.name.toLowerCase();
      final bName = b.contact.name.toLowerCase();
      return aName.compareTo(bName);
    });

  return LoanDashboard(
    contacts: summaries,
    totalLend: totalLend,
    totalBorrow: totalBorrow,
  );
});

final loanContactDetailProvider =
    FutureProvider.family<LoanContact?, int>((ref, id) async {
  final repo = ref.read(loanRepositoryProvider);
  ref.watch(loanRefreshProvider);
  final result = await repo.getContact(id);
  return result.fold((l) => throw l, (r) => r);
});

final loanTransactionsProvider =
    FutureProvider.family<List<LoanTransaction>, int>((ref, contactId) async {
  final repo = ref.read(loanRepositoryProvider);
  ref.watch(loanRefreshProvider);
  final result = await repo.getTransactions(contactId);
  return result.fold((l) => throw l, (r) => r);
});

class LoanContactFormNotifier extends StateNotifier<AsyncValue<void>> {
  final LoanRepository _repo;
  LoanContactFormNotifier(this._repo) : super(const AsyncData(null));

  Future<bool> create(LoanContact contact) async {
    state = const AsyncLoading();
    final result = await _repo.createContact(contact);
    state = result.fold(
      (l) => AsyncError(l.message, StackTrace.current),
      (_) => const AsyncData(null),
    );
    return result.isRight();
  }

  Future<bool> update(LoanContact contact) async {
    state = const AsyncLoading();
    final result = await _repo.updateContact(contact);
    state = result.fold(
      (l) => AsyncError(l.message, StackTrace.current),
      (_) => const AsyncData(null),
    );
    return result.isRight();
  }

  Future<bool> delete(int id) async {
    state = const AsyncLoading();
    final result = await _repo.deleteContact(id);
    state = result.fold(
      (l) => AsyncError(l.message, StackTrace.current),
      (_) => const AsyncData(null),
    );
    return result.isRight();
  }
}

final loanContactFormProvider =
    StateNotifierProvider<LoanContactFormNotifier, AsyncValue<void>>((ref) {
  return LoanContactFormNotifier(ref.read(loanRepositoryProvider));
});

class LoanTransactionFormNotifier extends StateNotifier<AsyncValue<void>> {
  final LoanRepository _repo;
  LoanTransactionFormNotifier(this._repo) : super(const AsyncData(null));

  Future<bool> create(LoanTransaction transaction) async {
    state = const AsyncLoading();
    final result = await _repo.createTransaction(transaction);
    state = result.fold(
      (l) => AsyncError(l.message, StackTrace.current),
      (_) => const AsyncData(null),
    );
    final success = result.isRight();
    if (success) {
      final created = result.getOrElse(() => transaction);
      await _scheduleLoanReminder(created);
    }
    return success;
  }

  Future<void> _scheduleLoanReminder(LoanTransaction txn) async {
    if (txn.type != 'borrow' && txn.type != 'lend') return;
    try {
      final contactResult = await _repo.getContact(txn.contactId);
      final name = contactResult.fold((l) => '', (r) => r?.name ?? '');
      await getIt<NotificationService>().scheduleLoanReminder(
        txnId: txn.id,
        contactName: name,
        amount: txn.amount,
        date: txn.date,
        type: txn.type,
      );
    } catch (e) {
      log.e('Failed to schedule loan reminder: $e');
    }
  }

  Future<bool> delete(int id) async {
    state = const AsyncLoading();
    final result = await _repo.deleteTransaction(id);
    state = result.fold(
      (l) => AsyncError(l.message, StackTrace.current),
      (_) => const AsyncData(null),
    );
    final success = result.isRight();
    if (success) {
      try {
        await getIt<NotificationService>().cancelLoanReminder(id);
      } catch (e) {
        log.e('Failed to cancel loan reminder: $e');
      }
    }
    return success;
  }
}

final loanTransactionFormProvider =
    StateNotifierProvider<LoanTransactionFormNotifier, AsyncValue<void>>(
  (ref) => LoanTransactionFormNotifier(ref.read(loanRepositoryProvider)),
);
