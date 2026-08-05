import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexora_khata/core/services/app_strings.dart';
import 'package:nexora_khata/features/reports/data/services/pdf_report_service.dart';
import 'package:nexora_khata/features/reports/domain/entities/report.dart';
import 'package:nexora_khata/features/transactions/data/models/expense_model.dart';
import 'package:nexora_khata/features/transactions/data/models/income_model.dart';
import 'package:nexora_khata/features/transactions/presentation/models/transaction_entry.dart';
import 'package:nexora_khata/generated/l10n/app_localizations.dart';

void main() {
  Future<void> generateAll(String name, Future<Uint8List> Function() fn) async {
    final bytes = await fn();
    // ignore: avoid_print
    print('SUCCESS [$name]: PDF bytes = ${bytes.length}');
  }

  testWidgets('all PDF generators produce bytes without throwing', (tester) async {
    AppStrings.current =
        await AppLocalizations.delegate.load(const Locale('bn'));

    const summary = ReportSummary(
      totalIncome: 50000,
      totalExpense: 20000,
      netAmount: 30000,
      totalTransactions: 3,
      period: '2026-08-01 - 2026-08-03',
    );

    final entries = <TransactionEntry>[
      TransactionEntry(
        type: 'income',
        id: 1,
        amount: 50000,
        description: 'বিক্রয় আয়',
        date: DateTime(2026, 8, 1),
        categoryName: 'ব্যবসা',
        status: 'completed',
        createdAt: DateTime(2026, 8, 1, 9),
      ),
      TransactionEntry(
        type: 'expense',
        id: 2,
        amount: 20000,
        description: 'বাজার কেনাকাটা',
        date: DateTime(2026, 8, 2),
        categoryName: 'খাদ্য',
        status: 'pending',
        createdAt: DateTime(2026, 8, 2, 10),
      ),
      TransactionEntry(
        type: 'loan',
        id: 3,
        amount: 10000,
        description: 'লোন দেওয়া',
        date: DateTime(2026, 8, 3),
        categoryName: 'বন্ধু',
        status: 'completed',
        loanType: 'lend',
        createdAt: DateTime(2026, 8, 3, 11),
      ),
    ];

    final service = PdfReportService();
    final now = DateTime(2026, 8, 3);

    await generateAll('filtered', () => service.generateFilteredReport(
          data: entries,
          summary: summary,
          title: AppStrings.s.customReportTitle,
          dateRange: '2026-08-01 - 2026-08-03',
        ));

    final income = IncomeModel(
      id: 1,
      businessId: 1,
      categoryId: 1,
      amount: 50000,
      description: 'বিক্রয় আয়',
      catName: 'ব্যবসা',
      customerName: 'কবির',
      incomeDate: now,
      status: 'completed',
      createdAt: now,
      updatedAt: now,
    );
    await generateAll('income', () => service.generateIncomeReport(
          incomes: [income],
          title: AppStrings.s.rptIncome,
          dateRange: '2026-08-01 - 2026-08-03',
        ));

    final expense = ExpenseModel(
      id: 1,
      businessId: 1,
      categoryId: 1,
      amount: 20000,
      description: 'বাজার কেনাকাটা',
      catName: 'খাদ্য',
      supplierName: 'মার্কেট',
      expenseDate: now,
      status: 'pending',
      createdAt: now,
      updatedAt: now,
    );
    await generateAll('expense', () => service.generateExpenseReport(
          expenses: [expense],
          title: AppStrings.s.rptExpense,
          dateRange: '2026-08-01 - 2026-08-03',
        ));

    await generateAll('monthly', () => service.generateMonthlyReport(
          data: [
            DailyReportItem(date: now, income: 50000, expense: 20000, net: 30000),
          ],
          year: 2026,
          month: 8,
          summary: summary,
        ));

    await generateAll('yearly', () => service.generateYearlyReport(
          data: const [
            MonthlyReportItem(month: 8, year: 2026, income: 50000, expense: 20000, net: 30000),
          ],
          year: 2026,
          summary: summary,
        ));

    await generateAll('cashflow', () => service.generateCashFlowReport(
          data: [
            CashFlowItem(date: now, cashBalance: 1000, bankBalance: 2000, totalBalance: 3000),
          ],
          year: 2026,
          month: 8,
        ));
  });
}
