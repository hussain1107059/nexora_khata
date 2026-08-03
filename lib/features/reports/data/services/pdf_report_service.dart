import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:nexora_khata/core/services/app_strings.dart';
import 'package:nexora_khata/core/services/file_share_service.dart';
import 'package:nexora_khata/features/transactions/data/models/income_model.dart';
import 'package:nexora_khata/features/transactions/data/models/expense_model.dart';
import 'package:nexora_khata/features/reports/domain/entities/report.dart';
import 'package:nexora_khata/features/transactions/presentation/models/transaction_entry.dart';

class PdfReportService {
  pw.Font? _font;
  bool _loaded = false;

  Future<void> _loadFont() async {
    if (_loaded) return;
    final data = await rootBundle.load('assets/fonts/NotoSansBengali.ttf');
    _font = pw.Font.ttf(data.buffer.asByteData());
    _loaded = true;
  }

  pw.TextStyle _s(double size, {PdfColor? color, pw.FontWeight? weight}) {
    return pw.TextStyle(
      font: _font, fontSize: size,
      color: color ?? PdfColors.black,
      fontWeight: weight ?? pw.FontWeight.normal,
    );
  }

  Future<Uint8List> generateIncomeReport({
    required List<IncomeModel> incomes,
    required String title,
    String? dateRange,
  }) async {
    await _loadFont();
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
    await _loadFont();
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
    await _loadFont();
    final monthNames = [AppStrings.s.monthJanuary, AppStrings.s.monthFebruary, AppStrings.s.monthMarch, AppStrings.s.monthApril, AppStrings.s.monthMay, AppStrings.s.monthJune, AppStrings.s.monthJuly, AppStrings.s.monthAugust, AppStrings.s.monthSeptember, AppStrings.s.monthOctober, AppStrings.s.monthNovember, AppStrings.s.monthDecember];
    final doc = pw.Document();
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      header: (ctx) => _buildHeader(AppStrings.s.rptMonthlyReportTitle(monthNames[month - 1], year), null),
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
    await _loadFont();
    final monthNames = [AppStrings.s.monthJanuary, AppStrings.s.monthFebruary, AppStrings.s.monthMarch, AppStrings.s.monthApril, AppStrings.s.monthMay, AppStrings.s.monthJune, AppStrings.s.monthJuly, AppStrings.s.monthAugust, AppStrings.s.monthSeptember, AppStrings.s.monthOctober, AppStrings.s.monthNovember, AppStrings.s.monthDecember];
    final doc = pw.Document();
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      header: (ctx) => _buildHeader(AppStrings.s.rptYearlyReportTitle(year), null),
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
              pw.Expanded(child: pw.Text(monthNames[m.month - 1], style: _s(10))),
              pw.Expanded(child: pw.Text(_f(m.income), style: _s(10, color: PdfColors.green700), textAlign: pw.TextAlign.right)),
              pw.Expanded(child: pw.Text(_f(m.expense), style: _s(10, color: PdfColors.red700), textAlign: pw.TextAlign.right)),
              pw.Expanded(child: pw.Text(_f(m.net), style: _s(10, color: m.net >= 0 ? PdfColors.blue700 : PdfColors.red700), textAlign: pw.TextAlign.right)),
            ],
          ),
        )),
        pw.Divider(thickness: 1, color: PdfColors.grey300),
        _buildTotalRow(AppStrings.s.dashboardTotalIncome, summary.totalIncome),
        _buildTotalRow(AppStrings.s.dashboardTotalExpense, summary.totalExpense),
        _buildTotalRow(AppStrings.s.rptNet, summary.netAmount, bold: true),
        pw.SizedBox(height: 12),
        pw.Text(AppStrings.s.rptTotalTxnsLabel(summary.totalTransactions), style: _s(10, color: PdfColors.grey700)),
      ],
    ));
    return doc.save();
  }

  Future<Uint8List> generateCashFlowReport({
    required List<CashFlowItem> data,
    required int year,
    required int month,
  }) async {
    await _loadFont();
    final monthNames = [AppStrings.s.monthJanuary, AppStrings.s.monthFebruary, AppStrings.s.monthMarch, AppStrings.s.monthApril, AppStrings.s.monthMay, AppStrings.s.monthJune, AppStrings.s.monthJuly, AppStrings.s.monthAugust, AppStrings.s.monthSeptember, AppStrings.s.monthOctober, AppStrings.s.monthNovember, AppStrings.s.monthDecember];
    final last = data.isNotEmpty ? data.last : null;
    final doc = pw.Document();
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      header: (ctx) => _buildHeader(AppStrings.s.rptCashflowReportTitle(monthNames[month - 1], year), null),
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
              pw.Expanded(child: pw.Text(
                '${d.date.day}/${d.date.month}/${d.date.year}',
                style: _s(10),
              )),
              pw.Expanded(child: pw.Text(
                _f(d.cashBalance), style: _s(10), textAlign: pw.TextAlign.right,
              )),
              pw.Expanded(child: pw.Text(
                _f(d.bankBalance), style: _s(10), textAlign: pw.TextAlign.right,
              )),
              pw.Expanded(child: pw.Text(
                _f(d.totalBalance), style: _s(10, weight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.right,
              )),
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
    await _loadFont();
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
          pw.Expanded(child: pw.Text(
            '${e.date.day}/${e.date.month}/${e.date.year}', style: _s(9),
          )),
          pw.Expanded(child: pw.Text(_typeLabel(e), style: _s(9))),
          pw.Expanded(child: pw.Text(e.categoryName ?? '-', style: _s(9))),
          pw.Expanded(child: pw.Text(e.description ?? '-', style: _s(9))),
          pw.Expanded(child: pw.Text(
            _f(e.amount), style: _s(9, color: amountColor),
            textAlign: pw.TextAlign.right,
          )),
          pw.Expanded(child: pw.Text(
            _statusBn(e.status), style: _s(9), textAlign: pw.TextAlign.center,
          )),
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
                pw.Text(AppStrings.s.appTitle, style: _s(16, weight: pw.FontWeight.bold, color: PdfColors.red700)),
                pw.Text(title, style: _s(12, color: PdfColors.grey700)),
              ],
            ),
            if (subtitle != null) pw.Text(subtitle, style: _s(10, color: PdfColors.grey600)),
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
          pw.Text('BadhonByte', style: _s(8, color: PdfColors.grey500)),
          pw.Text(AppStrings.s.appTitle, style: _s(8, color: PdfColors.grey500)),
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
        pw.Text(label, style: _s(8, color: PdfColors.grey600)),
        pw.SizedBox(height: 4),
        pw.Text(_f(value), style: _s(14, weight: pw.FontWeight.bold, color: color)),
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
          child: pw.Text(h, style: _s(9, weight: pw.FontWeight.bold, color: PdfColors.red800)),
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
          pw.Expanded(child: pw.Text(
            '${i.incomeDate.day}/${i.incomeDate.month}/${i.incomeDate.year}',
            style: _s(9),
          )),
          pw.Expanded(child: pw.Text(i.catName ?? '-', style: _s(9))),
          pw.Expanded(child: pw.Text(i.customerName ?? '-', style: _s(9))),
          pw.Expanded(child: pw.Text(i.description ?? '-', style: _s(9))),
          pw.Expanded(child: pw.Text(_f(i.amount), style: _s(9, color: PdfColors.green700), textAlign: pw.TextAlign.right)),
          pw.Expanded(child: pw.Text(_statusBn(i.status), style: _s(9), textAlign: pw.TextAlign.center)),
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
          pw.Expanded(child: pw.Text(
            '${e.expenseDate.day}/${e.expenseDate.month}/${e.expenseDate.year}',
            style: _s(9),
          )),
          pw.Expanded(child: pw.Text(e.catName ?? '-', style: _s(9))),
          pw.Expanded(child: pw.Text(supplierName ?? '-', style: _s(9))),
          pw.Expanded(child: pw.Text(e.description ?? '-', style: _s(9))),
          pw.Expanded(child: pw.Text(_f(e.amount), style: _s(9, color: PdfColors.red700), textAlign: pw.TextAlign.right)),
          pw.Expanded(child: pw.Text(_statusBn(e.status), style: _s(9), textAlign: pw.TextAlign.center)),
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
          pw.Expanded(child: pw.Text(
            '${d.date.day}/${d.date.month}/${d.date.year}', style: _s(10),
          )),
          pw.Expanded(child: pw.Text(_f(d.income), style: _s(10, color: PdfColors.green700), textAlign: pw.TextAlign.right)),
          pw.Expanded(child: pw.Text(_f(d.expense), style: _s(10, color: PdfColors.red700), textAlign: pw.TextAlign.right)),
          pw.Expanded(child: pw.Text(_f(d.net), style: _s(10, color: d.net >= 0 ? PdfColors.blue700 : PdfColors.red700), textAlign: pw.TextAlign.right)),
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
          pw.Text('$label: ', style: _s(10, weight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(_f(amount), style: _s(10, weight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      ),
    );
  }

  String _f(double v) {
    final abs = v.abs();
    final sign = v < 0 ? '-' : '';
    if (abs >= 10000000) return '$sign৳${(abs / 10000000).toStringAsFixed(2)}Cr';
    if (abs >= 100000) return '$sign৳${(abs / 100000).toStringAsFixed(2)}L';
    return '${sign}৳${abs.toStringAsFixed(2)}';
  }

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
}
