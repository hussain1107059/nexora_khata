import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:nexora_khata/features/transactions/data/models/income_model.dart';
import 'package:nexora_khata/features/transactions/data/models/expense_model.dart';
import 'package:nexora_khata/features/reports/domain/entities/report.dart';

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
        _buildTableHeaders(['তারিখ', 'ক্যাটাগরি', 'গ্রাহক', 'বিবরণ', 'পরিমাণ', 'অবস্থা']),
        ...incomes.map((i) => _buildIncomeRow(i)),
        pw.Divider(thickness: 1, color: PdfColors.grey300),
        _buildTotalRow('মোট আয়', incomes.fold<double>(0, (s, i) => s + i.amount)),
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
        _buildTableHeaders(['তারিখ', 'ক্যাটাগরি', 'সরবরাহকারী', 'বিবরণ', 'পরিমাণ', 'অবস্থা']),
        ...expenses.map((e) => _buildExpenseRow(e)),
        pw.Divider(thickness: 1, color: PdfColors.grey300),
        _buildTotalRow('মোট ব্যয়', expenses.fold<double>(0, (s, e) => s + e.amount)),
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
    final monthNames = ['জানুয়ারি','ফেব্রুয়ারি','মার্চ','এপ্রিল','মে','জুন','জুলাই','আগস্ট','সেপ্টেম্বর','অক্টোবর','নভেম্বর','ডিসেম্বর'];
    final doc = pw.Document();
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      header: (ctx) => _buildHeader('মাসিক রিপোর্ট', '${monthNames[month - 1]} $year'),
      footer: (ctx) => _buildFooter(),
      build: (ctx) => [
        _buildMonthlySummary(summary),
        pw.SizedBox(height: 16),
        _buildTableHeaders(['তারিখ', 'আয়', 'ব্যয়', 'নেট']),
        ...data.map((d) => _buildDailyRow(d)),
        pw.Divider(thickness: 1, color: PdfColors.grey300),
        _buildTotalRow('মোট আয়', summary.totalIncome),
        _buildTotalRow('মোট ব্যয়', summary.totalExpense),
        _buildTotalRow('নেট', summary.netAmount, bold: true),
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
    final monthNames = ['জানুয়ারি','ফেব্রুয়ারি','মার্চ','এপ্রিল','মে','জুন','জুলাই','আগস্ট','সেপ্টেম্বর','অক্টোবর','নভেম্বর','ডিসেম্বর'];
    final doc = pw.Document();
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      header: (ctx) => _buildHeader('বার্ষিক রিপোর্ট', '$year'),
      footer: (ctx) => _buildFooter(),
      build: (ctx) => [
        _buildMonthlySummary(summary),
        pw.SizedBox(height: 16),
        _buildTableHeaders(['মাস', 'আয়', 'ব্যয়', 'নেট']),
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
        _buildTotalRow('মোট আয়', summary.totalIncome),
        _buildTotalRow('মোট ব্যয়', summary.totalExpense),
        _buildTotalRow('নেট', summary.netAmount, bold: true),
        pw.SizedBox(height: 12),
        pw.Text('মোট লেনদেন: ${summary.totalTransactions}', style: _s(10, color: PdfColors.grey700)),
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
    final monthNames = ['জানুয়ারি','ফেব্রুয়ারি','মার্চ','এপ্রিল','মে','জুন','জুলাই','আগস্ট','সেপ্টেম্বর','অক্টোবর','নভেম্বর','ডিসেম্বর'];
    final last = data.isNotEmpty ? data.last : null;
    final doc = pw.Document();
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      header: (ctx) => _buildHeader('ক্যাশ ফ্লো রিপোর্ট', '${monthNames[month - 1]} $year'),
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
              _statBox('নগদ ব্যালেন্স', last.cashBalance, PdfColors.blue700),
              _statBox('ব্যাংক ব্যালেন্স', last.bankBalance, PdfColors.green700),
              _statBox('মোট ব্যালেন্স', last.totalBalance, PdfColors.blue700),
            ],
          ),
        ),
        pw.SizedBox(height: 16),
        _buildTableHeaders(['তারিখ', 'নগদ', 'ব্যাংক', 'মোট']),
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

  pw.Widget _buildHeader(String title, String? subtitle) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('নেক্সোরা খাতা', style: _s(16, weight: pw.FontWeight.bold, color: PdfColors.red700)),
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
          pw.Text('নেক্সোরা খাতা', style: _s(8, color: PdfColors.grey500)),
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
          _statBox('মোট পরিমাণ', total, PdfColors.blue700),
          _statBox('মোট লেনদেন', count.toDouble(), PdfColors.grey700),
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
          _statBox('মোট আয়', s.totalIncome, PdfColors.green700),
          _statBox('মোট ব্যয়', s.totalExpense, PdfColors.red700),
          _statBox('নেট', s.netAmount, s.netAmount >= 0 ? PdfColors.blue700 : PdfColors.red700),
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
      case 'completed': return 'সম্পন্ন';
      case 'pending': return 'মুলতুবি';
      case 'cancelled': return 'বাতিল';
      default: return status;
    }
  }

  static Future<void> sharePdf(Uint8List bytes, String fileName) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)], text: fileName.replaceAll('.pdf', ''));
  }
}
