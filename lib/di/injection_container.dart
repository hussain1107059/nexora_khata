import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import '../core/network/connectivity_service.dart';
import '../core/services/database_helper.dart';
import '../features/categories/data/datasources/expense_category_datasource.dart';
import '../features/categories/data/datasources/income_category_datasource.dart';
import '../features/categories/data/repositories/expense_category_repository_impl.dart';
import '../features/categories/data/repositories/income_category_repository_impl.dart';
import '../features/categories/domain/repositories/expense_category_repository.dart';
import '../features/categories/domain/repositories/income_category_repository.dart';
import '../features/transactions/data/datasources/expense_datasource.dart';
import '../features/transactions/data/datasources/income_datasource.dart';
import '../features/transactions/data/repositories/expense_repository_impl.dart';
import '../features/transactions/data/repositories/income_repository_impl.dart';
import '../features/transactions/domain/repositories/expense_repository.dart';
import '../features/transactions/domain/repositories/income_repository.dart';
import '../features/reports/data/datasources/report_datasource.dart';
import '../features/reports/data/repositories/report_repository_impl.dart';
import '../features/reports/domain/repositories/report_repository.dart';
import '../features/settings/data/datasources/settings_datasource.dart';
import '../features/settings/data/repositories/settings_repository_impl.dart';
import '../features/settings/domain/repositories/settings_repository.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  final dbHelper = DatabaseHelper();
  try {
    print('[INIT] Opening database...');
    await dbHelper.open();
    print('[INIT] Database opened successfully');
  } catch (e) {
    print('[INIT] Database open failed: $e');
  }

  getIt.registerLazySingleton<DatabaseHelper>(() => dbHelper);
  getIt.registerLazySingleton<ConnectivityService>(
    () => ConnectivityService(),
  );

  final incomeDataSource = IncomeDataSource(dbHelper);
  getIt.registerLazySingleton<IncomeDataSource>(() => incomeDataSource);
  getIt.registerLazySingleton<IncomeRepository>(
    () => IncomeRepositoryImpl(incomeDataSource),
  );

  final incomeCategoryDataSource = IncomeCategoryDataSource(dbHelper);
  getIt.registerLazySingleton<IncomeCategoryDataSource>(
    () => incomeCategoryDataSource,
  );
  getIt.registerLazySingleton<IncomeCategoryRepository>(
    () => IncomeCategoryRepositoryImpl(incomeCategoryDataSource),
  );

  final expenseDataSource = ExpenseDataSource(dbHelper);
  getIt.registerLazySingleton<ExpenseDataSource>(() => expenseDataSource);
  getIt.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(expenseDataSource),
  );

  final expenseCategoryDataSource = ExpenseCategoryDataSource(dbHelper);
  getIt.registerLazySingleton<ExpenseCategoryDataSource>(
    () => expenseCategoryDataSource,
  );
  getIt.registerLazySingleton<ExpenseCategoryRepository>(
    () => ExpenseCategoryRepositoryImpl(expenseCategoryDataSource),
  );

  final reportDataSource = ReportDataSource(dbHelper);
  getIt.registerLazySingleton<ReportDataSource>(() => reportDataSource);
  getIt.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(reportDataSource),
  );

  final settingsDataSource = SettingsDataSource(dbHelper);
  getIt.registerLazySingleton<SettingsDataSource>(() => settingsDataSource);
  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(settingsDataSource),
  );
}

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return getIt<DatabaseHelper>();
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return getIt<ConnectivityService>();
});
