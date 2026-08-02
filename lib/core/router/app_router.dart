import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_shell.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/about_page.dart';
import '../../features/settings/presentation/pages/privacy_page.dart';
import '../../features/settings/presentation/pages/terms_page.dart';
import '../../features/settings/presentation/pages/backup_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/loans/presentation/pages/loan_list_page.dart';
import '../../features/loans/presentation/pages/loan_contact_form_page.dart';
import '../../features/loans/presentation/pages/loan_detail_page.dart';
import '../../features/loans/presentation/pages/loan_transaction_form_page.dart';
import '../../features/transactions/presentation/pages/all_transactions_page.dart';
import '../../features/transactions/presentation/pages/income_list_page.dart';
import '../../features/transactions/presentation/pages/transfer_form_page.dart';
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
  refreshListenable: authUserNotifier,
  debugLogDiagnostics: false,
  redirect: (context, state) {
    final loggedIn = authUserNotifier.value != null;
    final atAuthPage = state.matchedLocation == RouteNames.login ||
        state.matchedLocation == RouteNames.signup;
    if (!loggedIn && !atAuthPage) return RouteNames.login;
    if (loggedIn && atAuthPage) return RouteNames.dashboard;
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) {
        if (authUserNotifier.value == null) return RouteNames.login;
        return RouteNames.dashboard;
      },
    ),
    GoRoute(
      path: RouteNames.login,
      name: RouteNames.login,
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: LoginPage(),
      ),
    ),
    GoRoute(
      path: RouteNames.signup,
      name: RouteNames.signup,
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => const NoTransitionPage(
        child: SignupPage(),
      ),
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
            child: AllTransactionsPage(),
          ),
        ),
        GoRoute(
          path: RouteNames.loanList,
          name: RouteNames.loanList,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: LoanListPage(),
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
    GoRoute(
      path: RouteNames.transferAdd,
      name: RouteNames.transferAdd,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const TransferFormPage(),
    ),
    GoRoute(
      path: '${RouteNames.loanDetail}/:id',
      name: RouteNames.loanDetail,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return LoanDetailPage(contactId: id);
      },
    ),
    GoRoute(
      path: RouteNames.loanContactAdd,
      name: RouteNames.loanContactAdd,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LoanContactFormPage(),
    ),
    GoRoute(
      path: RouteNames.loanContactEdit,
      name: RouteNames.loanContactEdit,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final contact = state.extra as dynamic;
        return LoanContactFormPage(contact: contact);
      },
    ),
    GoRoute(
      path: RouteNames.loanTxnAdd,
      name: RouteNames.loanTxnAdd,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final contactId = extra?['contactId'] as int? ?? 0;
        final name = extra?['name'] as String? ?? '';
        final type = extra?['type'] as String? ?? 'borrow';
        return LoanTransactionFormPage(
          contactId: contactId,
          contactName: name,
          initialType: type,
        );
      },
    ),
  ],
);
