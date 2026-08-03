import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:bangla_pdf/bangla_pdf.dart' as bpdf;
import 'package:nexora_khata/core/services/app_strings.dart';
import 'package:nexora_khata/core/services/file_share_service.dart';
import 'package:nexora_khata/core/utils/number_utils.dart';
import 'package:nexora_khata/features/transactions/data/models/income_model.dart';
import 'package:nexora_khata/features/transactions/data/models/expense_model.dart';
import 'package:nexora_khata/features/reports/domain/entities/report.dart';
import 'package:nexora_khata/features/transactions/presentation/models/transaction_entry.dart';

class PdfReportService {
  pw.Widget _b(String text, double size,
      {PdfColor? color, pw.FontWeight? weight, pw.TextAlign? align}) {
    return bpdf.Text(
      text,
      fontSize: size,
      color: color ?? PdfColors.black,
      fontWeight: weight ?? pw.FontWeight.normal,
      textAlign: align,
    );
  }

  Future<Uint8List> generateIncomeReport({
    required List<IncomeModel> incomes,
    required String title,
    String? dateRange,
  }) async {
    final doc = pw.Document();
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      header: (ctx) => _buildHeader(title, dateRange),
      footer: (ctx) => _buildFooter(),
      build: (ctx) => [
        _buildSummaryRow(incomes.fold<double>(0, (s, i) => s + i.amount), incomes.length),
        pw.SizedBox(height: 16),
        _buildTableHeaders([AppStrings.s.rptHeaderDate, AppStrings.s.rptHeaderCategory, AppStrings.s.rptHeaderCustomer, AppStrings.s.rptHeaderDescription, AppStrings.s.rptHeaderAmount, AppStrings.s.rptHeaderStatus]),
        ...incomes.map((i) => _buildIncomeRow(i)),
        pw.Divider(thickness: 1, color: PdfColors.grey300),
        _buildTotalRow(AppStrings.s.dashboardTotalIncome, incomes.fold<double>(0, (s, i) => s + i.amount)),
      ],
    ));
    return doc.save();
  }

  Future<Uint8List> generateExpenseReport({
    required List<ExpenseModel> expenses,
    required String title,
    String? dateRange,
  }) async {
    final doc = pw.Document();
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      header: (ctx) => _buildHeader(title, dateRange),
      footer: (ctx) => _buildFooter(),
      build: (ctx) => [
        _buildSummaryRow(expenses.fold<double>(0, (s, e) => s + e.amount), expenses.length),
        pw.SizedBox(height: 16),
        _buildTableHeaders([AppStrings.s.rptHeaderDate, AppStrings.s.rptHeaderCategory, AppStrings.s.rptHeaderSupplier, AppStrings.s.rptHeaderDescription, AppStrings.s.rptHeaderAmount, AppStrings.s.rptHeaderStatus]),
        ...expenses.map((e) => _buildExpenseRow(e)),
        pw.Divider(thickness: 1, color: PdfColors.grey300),
        _buildTotalRow(AppStrings.s.dashboardTotalExpense, expenses.fold<double>(0, (s, e) => s + e.amount)),
      ],
    ));
    return doc.save();
  }

  Future<Uint8List> generateMonthlyReport({
    required List<DailyReportItem> data,
    required int year,
    required int month,
    required ReportSummary summary,
  }) async {
    final monthNames = [AppStrings.s.monthJanuary, AppStrings.s.monthFebruary, AppStrings.s.monthMarch, AppStrings.s.monthApril, AppStrings.s.monthMay, AppStrings.s.monthJune, AppStrings.s.monthJuly, AppStrings.s.monthAugust, AppStrings.s.monthSeptember, AppStrings.s.monthOctober, AppStrings.s.monthNovember, AppStrings.s.monthDecember];
    final doc = pw.Document();
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      header: (ctx) => _buildHeader(AppStrings.s.rptMonthlyReportTitle(monthNames[month - 1], _localized(year)), null),
      footer: (ctx) => _buildFooter(),
      build: (ctx) => [
        _buildMonthlySummary(summary),
        pw.SizedBox(height: 16),
        _buildTableHeaders([AppStrings.s.rptHeaderDate, AppStrings.s.rptHeaderIncome, AppStrings.s.rptHeaderExpense, AppStrings.s.rptHeaderNet]),
        ...data.map((d) => _buildDailyRow(d)),
        pw.Divider(thickness: 1, color: PdfColors.grey300),
        _buildTotalRow(AppStrings.s.dashboardTotalIncome, summary.totalIncome),
        _buildTotalRow(AppStrings.s.dashboardTotalExpense, summary.totalExpense),
        _buildTotalRow(AppStrings.s.rptNet, summary.netAmount, bold: true),
      ],
    ));
    return doc.save();
  }

  Future<Uint8List> generateYearlyReport({
    required List<MonthlyReportItem> data,
    required int year,
    required ReportSummary summary,
  }) async {
    final monthNames = [AppStrings.s.monthJanuary, AppStrings.s.monthFebruary, AppStrings.s.monthMarch, AppStrings.s.monthApril, AppStrings.s.monthMay, AppStrings.s.monthJune, AppStrings.s.monthJuly, AppStrings.s.monthAugust, AppStrings.s.monthSeptember, AppStrings.s.monthOctober, AppStrings.s.monthNovember, AppStrings.s.monthDecember];
    final doc = pw.Document();
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      header: (ctx) => _buildHeader(AppStrings.s.rptYearlyReportTitle(_localized(year)), null),
      footer: (ctx) => _buildFooter(),
      build: (ctx) => [
        _buildMonthlySummary(summary),
        pw.SizedBox(height: 16),
        _buildTableHeaders([AppStrings.s.rptHeaderMonth, AppStrings.s.rptHeaderIncome, AppStrings.s.rptHeaderExpense, AppStrings.s.rptHeaderNet]),
        ...data.map((m) => pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
          ),
          child: pw.Row(
            children: [
              pw.Expanded(child: _b(monthNames[m.month - 1], 10)),
              pw.Expanded(child: _b(_f(m.income), 10, color: PdfColors.green700, align: pw.TextAlign.right)),
              pw.Expanded(child: _b(_f(m.expense), 10, color: PdfColors.red700, align: pw.TextAlign.right)),
              pw.Expanded(child: _b(_f(m.net), 10, color: m.net >= 0 ? PdfColors.blue700 : PdfColors.red700, align: pw.TextAlign.right)),
            ],
          ),
        )),
        pw.Divider(thickness: 1, color: PdfColors.grey300),
        _buildTotalRow(AppStrings.s.dashboardTotalIncome, summary.totalIncome),
        _buildTotalRow(AppStrings.s.dashboardTotalExpense, summary.totalExpense),
        _buildTotalRow(AppStrings.s.rptNet, summary.netAmount, bold: true),
        pw.SizedBox(height: 12),
        _b(AppStrings.s.rptTotalTxnsLabel(_localized(summary.totalTransactions)), 10, color: PdfColors.grey700),
      ],
    ));
    return doc.save();
  }

  Future<Uint8List> generateCashFlowReport({
    required List<CashFlowItem> data,
    required int year,
    required int month,
  }) async {
    final monthNames = [AppStrings.s.monthJanuary, AppStrings.s.monthFebruary, AppStrings.s.monthMarch, AppStrings.s.monthApril, AppStrings.s.monthMay, AppStrings.s.monthJune, AppStrings.s.monthJuly, AppStrings.s.monthAugust, AppStrings.s.monthSeptember, AppStrings.s.monthOctober, AppStrings.s.monthNovember, AppStrings.s.monthDecember];
    final last = data.isNotEmpty ? data.last : null;
    final doc = pw.Document();
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      header: (ctx) => _buildHeader(AppStrings.s.rptCashflowReportTitle(monthNames[month - 1], _localized(year)), null),
      footer: (ctx) => _buildFooter(),
      build: (ctx) => [
        if (last != null) pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue50,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _statBox(AppStrings.s.rptCashBalance, last.cashBalance, PdfColors.blue700),
              _statBox(AppStrings.s.rptBankBalance, last.bankBalance, PdfColors.green700),
              _statBox(AppStrings.s.rptTotalBalance, last.totalBalance, PdfColors.blue700),
            ],
          ),
        ),
        pw.SizedBox(height: 16),
        _buildTableHeaders([AppStrings.s.rptHeaderDate, AppStrings.s.rptHeaderCash, AppStrings.s.rptHeaderBank, AppStrings.s.rptHeaderTotal]),
        ...data.map((d) => pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 8),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
          ),
          child: pw.Row(
            children: [
pw.Expanded(child: _b(_localized('${d.date.day}/${d.date.month}/${d.date.year}'), 10)),
              pw.Expanded(child: _b(_f(d.cashBalance), 10, align: pw.TextAlign.right)),
              pw.Expanded(child: _b(_f(d.bankBalance), 10, align: pw.TextAlign.right)),
              pw.Expanded(child: _b(_f(d.totalBalance), 10, weight: pw.FontWeight.bold, align: pw.TextAlign.right)),
            ],
          ),
        )),
      ],
    ));
    return doc.save();
  }

  Future<Uint8List> generateFilteredReport({
    required List<TransactionEntry> data,
    required ReportSummary summary,
    required String title,
    String? dateRange,
  }) async {
    final doc = pw.Document();
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      header: (ctx) => _buildHeader(title, dateRange),
      footer: (ctx) => _buildFooter(),
      build: (ctx) => [
        _buildMonthlySummary(summary),
        pw.SizedBox(height: 16),
        _buildTableHeaders([
          AppStrings.s.rptHeaderDate,
          AppStrings.s.txnType,
          AppStrings.s.rptHeaderCategory,
          AppStrings.s.rptHeaderDescription,
          AppStrings.s.rptHeaderAmount,
          AppStrings.s.rptHeaderStatus,
        ]),
        ...data.map(_buildEntryRow),
        pw.Divider(thickness: 1, color: PdfColors.grey300),
        _buildTotalRow(AppStrings.s.dashboardTotalIncome, summary.totalIncome),
        _buildTotalRow(AppStrings.s.dashboardTotalExpense, summary.totalExpense),
        _buildTotalRow(AppStrings.s.rptNet, summary.netAmount, bold: true),
      ],
    ));
    return doc.save();
  }

  pw.Widget _buildEntryRow(TransactionEntry e) {
    final amountColor = e.isExpense
        ? PdfColors.red700
        : (e.isIncome ? PdfColors.green700 : PdfColors.blue700);
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(child: _b(_localized('${e.date.day}/${e.date.month}/${e.date.year}'), 9)),
          pw.Expanded(child: _b(_typeLabel(e), 9)),
          pw.Expanded(child: _b(e.categoryName ?? '-', 9)),
          pw.Expanded(child: _b(e.description ?? '-', 9)),
          pw.Expanded(child: _b(_f(e.amount), 9, color: amountColor, align: pw.TextAlign.right)),
          pw.Expanded(child: _b(_statusBn(e.status), 9, align: pw.TextAlign.center)),
        ],
      ),
    );
  }

  String _typeLabel(TransactionEntry e) {
    if (e.isLoan) {
      if (e.isLoanRepay) return AppStrings.s.txnRepay;
      return e.isLoanBorrow
          ? AppStrings.s.rptLoanTaken
          : AppStrings.s.rptLoanGiven;
    }
    return e.isIncome ? AppStrings.s.rptIncome : AppStrings.s.rptExpense;
  }

  pw.Widget _buildHeader(String title, String? subtitle) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _b(AppStrings.s.appTitle, 16, weight: pw.FontWeight.bold, color: PdfColors.red700),
                _b(title, 12, color: PdfColors.grey700),
              ],
            ),
            if (subtitle != null) _b(subtitle, 10, color: PdfColors.grey600),
          ],
        ),
        pw.Divider(thickness: 1.5, color: PdfColors.red300),
        pw.SizedBox(height: 8),
      ],
    );
  }

  pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _b('BadhonByte', 8, color: PdfColors.grey500),
          _b(AppStrings.s.appTitle, 8, color: PdfColors.grey500),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryRow(double total, int count) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _statBox(AppStrings.s.rptTotalAmount, total, PdfColors.blue700),
          _statBox(AppStrings.s.rptTotalTransactions, count.toDouble(), PdfColors.grey700),
        ],
      ),
    );
  }

  pw.Widget _statBox(String label, double value, PdfColor color) {
    return pw.Column(
      children: [
        _b(label, 9, color: PdfColors.grey600),
        pw.SizedBox(height: 4),
        _b(_f(value), 14, weight: pw.FontWeight.bold, color: color),
      ],
    );
  }

  pw.Widget _buildMonthlySummary(ReportSummary s) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _statBox(AppStrings.s.dashboardTotalIncome, s.totalIncome, PdfColors.green700),
          _statBox(AppStrings.s.dashboardTotalExpense, s.totalExpense, PdfColors.red700),
          _statBox(AppStrings.s.rptNet, s.netAmount, s.netAmount >= 0 ? PdfColors.blue700 : PdfColors.red700),
        ],
      ),
    );
  }

  pw.Widget _buildTableHeaders(List<String> headers) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: pw.BoxDecoration(
        color: PdfColors.red50,
        borderRadius: const pw.BorderRadius.only(
          topLeft: pw.Radius.circular(4), topRight: pw.Radius.circular(4),
        ),
      ),
      child: pw.Row(
        children: headers.map((h) => pw.Expanded(
          child: _b(h, 9, weight: pw.FontWeight.bold, color: PdfColors.red800),
        )).toList(),
      ),
    );
  }

  pw.Widget _buildIncomeRow(IncomeModel i) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(child: _b(_localized('${i.incomeDate.day}/${i.incomeDate.month}/${i.incomeDate.year}'), 9)),
          pw.Expanded(child: _b(i.catName ?? '-', 9)),
          pw.Expanded(child: _b(i.customerName ?? '-', 9)),
          pw.Expanded(child: _b(i.description ?? '-', 9)),
          pw.Expanded(child: _b(_f(i.amount), 9, color: PdfColors.green700, align: pw.TextAlign.right)),
          pw.Expanded(child: _b(_statusBn(i.status), 9, align: pw.TextAlign.center)),
        ],
      ),
    );
  }

  pw.Widget _buildExpenseRow(ExpenseModel e) {
    final supplierName = e.supplierName;
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(child: _b(_localized('${e.expenseDate.day}/${e.expenseDate.month}/${e.expenseDate.year}'), 9)),
          pw.Expanded(child: _b(e.catName ?? '-', 9)),
          pw.Expanded(child: _b(supplierName ?? '-', 9)),
          pw.Expanded(child: _b(e.description ?? '-', 9)),
          pw.Expanded(child: _b(_f(e.amount), 9, color: PdfColors.red700, align: pw.TextAlign.right)),
          pw.Expanded(child: _b(_statusBn(e.status), 9, align: pw.TextAlign.center)),
        ],
      ),
    );
  }

  pw.Widget _buildDailyRow(DailyReportItem d) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(child: _b(_localized('${d.date.day}/${d.date.month}/${d.date.year}'), 10)),
          pw.Expanded(child: _b(_f(d.income), 10, color: PdfColors.green700, align: pw.TextAlign.right)),
          pw.Expanded(child: _b(_f(d.expense), 10, color: PdfColors.red700, align: pw.TextAlign.right)),
          pw.Expanded(child: _b(_f(d.net), 10, color: d.net >= 0 ? PdfColors.blue700 : PdfColors.red700, align: pw.TextAlign.right)),
        ],
      ),
    );
  }

  pw.Widget _buildTotalRow(String label, double amount, {bool bold = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          _b('$label: ', 10, weight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
          _b(_f(amount), 10, weight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
        ],
      ),
    );
  }

  String _f(double v) {
    final abs = v.abs();
    final sign = v < 0 ? '-' : '';
    String raw;
    if (abs >= 10000000) {
      raw = '$sign৳${(abs / 10000000).toStringAsFixed(2)}Cr';
    } else if (abs >= 100000) {
      raw = '$sign৳${(abs / 100000).toStringAsFixed(2)}L';
    } else {
      raw = '${sign}৳${abs.toStringAsFixed(2)}';
    }
    return AppNumberUtils.localizeDigits(raw);
  }

  String _localized(Object text) => AppNumberUtils.localizeDigits('$text');

  String _statusBn(String status) {
    switch (status) {
      case 'completed': return AppStrings.s.statusCompleted;
      case 'pending': return AppStrings.s.statusPendingAlt;
      case 'cancelled': return AppStrings.s.statusCancelled;
      default: return status;
    }
  }

  static Future<void> sharePdf(Uint8List bytes, String fileName) async {
    await shareOrDownloadFile(
      bytes: bytes,
      fileName: fileName,
      shareText: fileName.replaceAll('.pdf', ''),
    );
  }

  static String defaultFileName([DateTime? now]) {
    final t = now ?? DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return 'nexorakhata_'
        '${t.year}${two(t.month)}${two(t.day)}'
        '_${two(t.hour)}${two(t.minute)}${two(t.second)}.pdf';
  }
}