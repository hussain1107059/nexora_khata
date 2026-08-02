import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../di/injection_container.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return getIt<DashboardRepository>();
});

final dashboardProvider = FutureProvider<DashboardSummary>((ref) async {
  final repo = ref.read(dashboardRepositoryProvider);
  final result = await repo.getDashboardSummary();
  return result.fold(
    (failure) => throw failure,
    (summary) => summary,
  );
});

final dashboardRefreshProvider = StateProvider<int>((ref) => 0);
