import 'package:dartz/dartz.dart';
import 'package:nexora_khata/core/errors/failures.dart';
import 'package:nexora_khata/features/dashboard/data/datasources/dashboard_datasource.dart';
import 'package:nexora_khata/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:nexora_khata/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardDataSource _dataSource;
  DashboardRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, DashboardSummary>> getDashboardSummary() async {
    try {
      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final results = await Future.wait([
        _dataSource.getTodayIncome(dateStr),
        _dataSource.getTodayExpense(dateStr),
        _dataSource.getCashBalance(),
        _dataSource.getBankBalance(),
        _dataSource.getTotalIncome(),
        _dataSource.getTotalExpense(),
        _dataSource.getMonthlyReport(),
        _dataSource.getRecentTransactions(),
      ]);

      return Right(DashboardSummary(
        todayIncome: results[0] as double,
        todayExpense: results[1] as double,
        cashBalance: results[2] as double,
        bankBalance: results[3] as double,
        totalIncome: results[4] as double,
        totalExpense: results[5] as double,
        monthlyReport: results[6] as List<MonthlyData>,
        recentTransactions: results[7] as List<RecentTransaction>,
      ));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}
