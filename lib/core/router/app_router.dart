import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/theme/app_colors.dart';
import '../widgets/app_shell.dart';
import '../widgets/app_text.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/about_page.dart';
import '../../features/settings/presentation/pages/privacy_page.dart';
import '../../features/settings/presentation/pages/terms_page.dart';
import '../../features/settings/presentation/pages/backup_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/transactions/presentation/pages/income_list_page.dart';
import '../../features/transactions/presentation/pages/income_form_page.dart';
import '../../features/transactions/presentation/pages/income_detail_page.dart';
import '../../features/transactions/presentation/pages/income_monthly_report_page.dart';
import '../../features/transactions/presentation/pages/income_categories_page.dart';
import '../../features/transactions/presentation/pages/income_category_form_page.dart';
import '../../features/transactions/presentation/pages/expense_list_page.dart';
import '../../features/transactions/presentation/pages/expense_form_page.dart';
import '../../features/transactions/presentation/pages/expense_detail_page.dart';
import '../../features/transactions/presentation/pages/expense_monthly_report_page.dart';
import '../../features/transactions/presentation/pages/expense_daily_report_page.dart';
import '../../features/transactions/presentation/pages/expense_categories_page.dart';
import '../../features/transactions/presentation/pages/expense_category_form_page.dart';
import 'route_names.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RouteNames.dashboard,
  debugLogDiagnostics: false,
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => RouteNames.dashboard,
    ),
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: RouteNames.dashboard,
          name: RouteNames.dashboard,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DashboardPage(),
          ),
        ),
        GoRoute(
          path: RouteNames.transactions,
          name: RouteNames.transactions,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long_rounded, size: 48, color: AppColors.textHint),
                    SizedBox(height: 16),
                    AppText('শীঘ্রই আসছে', type: AppTextType.subtitle2, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
          ),
        ),
        GoRoute(
          path: RouteNames.customers,
          name: RouteNames.customers,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people_outline_rounded, size: 48, color: AppColors.textHint),
                    SizedBox(height: 16),
                    AppText('শীঘ্রই আসছে', type: AppTextType.subtitle2, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
          ),
        ),
        GoRoute(
          path: RouteNames.reports,
          name: RouteNames.reports,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ReportsPage(),
          ),
        ),
        GoRoute(
          path: RouteNames.settings,
          name: RouteNames.settings,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsPage(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: RouteNames.incomeList,
      name: RouteNames.incomeList,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const IncomeListPage(),
    ),
    GoRoute(
      path: RouteNames.incomeAdd,
      name: RouteNames.incomeAdd,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const IncomeFormPage(),
    ),
    GoRoute(
      path: '${RouteNames.incomeEdit}/:id',
      name: RouteNames.incomeEdit,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final income = state.extra as dynamic;
        return IncomeFormPage(income: income);
      },
    ),
    GoRoute(
      path: '${RouteNames.incomeDetail}/:id',
      name: RouteNames.incomeDetail,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return IncomeDetailPage(id: id);
      },
    ),
    GoRoute(
      path: RouteNames.incomeMonthlyReport,
      name: RouteNames.incomeMonthlyReport,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const IncomeMonthlyReportPage(),
    ),
    GoRoute(
      path: RouteNames.incomeCategories,
      name: RouteNames.incomeCategories,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const IncomeCategoriesPage(),
    ),
    GoRoute(
      path: RouteNames.incomeCategoryAdd,
      name: RouteNames.incomeCategoryAdd,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const IncomeCategoryFormPage(),
    ),
    GoRoute(
      path: '${RouteNames.incomeCategoryEdit}/:id',
      name: RouteNames.incomeCategoryEdit,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final category = state.extra as dynamic;
        return IncomeCategoryFormPage(category: category);
      },
    ),
    GoRoute(
      path: RouteNames.expenseList,
      name: RouteNames.expenseList,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ExpenseListPage(),
    ),
    GoRoute(
      path: RouteNames.expenseAdd,
      name: RouteNames.expenseAdd,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ExpenseFormPage(),
    ),
    GoRoute(
      path: '${RouteNames.expenseEdit}/:id',
      name: RouteNames.expenseEdit,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final expense = state.extra as dynamic;
        return ExpenseFormPage(expense: expense);
      },
    ),
    GoRoute(
      path: '${RouteNames.expenseDetail}/:id',
      name: RouteNames.expenseDetail,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return ExpenseDetailPage(id: id);
      },
    ),
    GoRoute(
      path: RouteNames.expenseMonthlyReport,
      name: RouteNames.expenseMonthlyReport,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ExpenseMonthlyReportPage(),
    ),
    GoRoute(
      path: RouteNames.expenseDailyReport,
      name: RouteNames.expenseDailyReport,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ExpenseDailyReportPage(),
    ),
    GoRoute(
      path: RouteNames.expenseCategories,
      name: RouteNames.expenseCategories,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ExpenseCategoriesPage(),
    ),
    GoRoute(
      path: RouteNames.expenseCategoryAdd,
      name: RouteNames.expenseCategoryAdd,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ExpenseCategoryFormPage(),
    ),
    GoRoute(
      path: '${RouteNames.expenseCategoryEdit}/:id',
      name: RouteNames.expenseCategoryEdit,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final category = state.extra as dynamic;
        return ExpenseCategoryFormPage(category: category);
      },
    ),
    GoRoute(
      path: RouteNames.about,
      name: RouteNames.about,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AboutPage(),
    ),
    GoRoute(
      path: RouteNames.privacy,
      name: RouteNames.privacy,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PrivacyPage(),
    ),
    GoRoute(
      path: RouteNames.terms,
      name: RouteNames.terms,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const TermsPage(),
    ),
    GoRoute(
      path: RouteNames.backup,
      name: RouteNames.backup,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const BackupPage(),
    ),
  ],
);
