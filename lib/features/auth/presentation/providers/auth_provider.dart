import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora_khata/core/services/current_user_scope.dart';
import 'package:nexora_khata/core/services/notification_service.dart';
import 'package:nexora_khata/di/injection_container.dart';
import 'package:nexora_khata/features/auth/domain/entities/auth_user.dart';
import 'package:nexora_khata/features/auth/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return getIt<AuthRepository>();
});

/// Exposed so the GoRouter redirect can react to auth changes.
final ValueNotifier<AuthUser?> authUserNotifier = ValueNotifier<AuthUser?>(null);

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<AuthUser?>>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<AuthUser?>> {
  final AuthRepository _repo;
  AuthNotifier(this._repo) : super(const AsyncLoading()) {
    _restore();
  }

  void _apply(AuthUser? user) {
    state = AsyncData(user);
    authUserNotifier.value = user;
    CurrentUserScope.setUserId(user?.id);
    if (user != null) {
      getIt<NotificationService>().syncSchedules();
    }
  }

  Future<void> _restore() async {
    final result = await _repo.getCurrentUser();
    result.fold(
      (failure) {
        state = AsyncError<AuthUser?>(failure, StackTrace.current);
        authUserNotifier.value = null;
      },
      _apply,
    );
  }

  Future<bool> login(String username, String password) async {
    state = const AsyncLoading();
    final result = await _repo.login(username, password);
    result.fold(
      (failure) => state = AsyncError<AuthUser?>(failure, StackTrace.current),
      _apply,
    );
    return result.isRight();
  }

  Future<bool> signup({
    required String name,
    required String username,
    required String password,
    String? email,
    String? phone,
  }) async {
    state = const AsyncLoading();
    final result = await _repo.signup(
      name: name,
      username: username,
      password: password,
      email: email,
      phone: phone,
    );
    result.fold(
      (failure) => state = AsyncError<AuthUser?>(failure, StackTrace.current),
      _apply,
    );
    return result.isRight();
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AsyncData(null);
    authUserNotifier.value = null;
    await getIt<NotificationService>().cancelAll();
  }
}
