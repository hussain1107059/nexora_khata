import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:nexora_khata/features/transactions/data/models/income_model.dart';
import 'package:nexora_khata/features/transactions/data/models/expense_model.dart';
import 'package:nexora_khata/features/reports/domain/entities/report.dart';

class ExcelReportService {
  ExcelReportService._();

  static final _headerBg = ExcelColor.fromHexString('#E53935');
  static final _greenColor = ExcelColor.fromHexString('#43A047');
  static final _redColor = ExcelColor.fromHexString('#E53935');
  static final _blueColor = ExcelColor.fromHexString('#1E88E5');
  static final _greyColor = ExcelColor.fromHexString('#757575');

  static final _headerStyle = CellStyle(
    bold: true, fontColorHex: ExcelColor.white,
    backgroundColorHex: _headerBg,
  );
  static final _greenStyle = CellStyle(fontColorHex: _greenColor);
  static final _redStyle = CellStyle(fontColorHex: _redColor);
  static final _blueBoldStyle = CellStyle(fontColorHex: _blueColor, bold: true);
  static final _titleStyle = CellStyle(
    bold: true, fontColorHex: ExcelColor.fromHexString('#E53935'), fontSize: 14,
  );
  static final _subtitleStyle = CellStyle(fontColorHex: _greyColor);

  static Uint8List? generateIncomeReport({
    required List<IncomeModel> incomes,
    required String title,
    String? dateRange,
  }) {
    final excel = Excel.createExcel();
    final sheet = excel['আয়'];
    _setupSheet(sheet, 6);
    _writeTitle(sheet, title, dateRange, 6);
    _writeHeaders(sheet, ['তারিখ', 'ক্যাটাগরি', 'গ্রাহক', 'বিবরণ', 'পরিমাণ', 'অবস্থা'], 2);

    double total = 0;
    for (var i = 0; i < incomes.length; i++) {
      final row = i + 3;
      final inc = incomes[i];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue('${inc.incomeDate.day}/${inc.incomeDate.month}/${inc.incomeDate.year}');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = TextCellValue(inc.catName ?? '-');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = TextCellValue(inc.customerName ?? '-');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = TextCellValue(inc.description ?? '-');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value = DoubleCellValue(inc.amount);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).cellStyle = _greenStyle;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row)).value = TextCellValue(_st(inc.status));
      total += inc.amount;
    }
    _writeTotal(sheet, incomes.length + 3, total, 'মোট আয়');
    final encoded = excel.encode();
    return encoded != null ? Uint8List.fromList(encoded) : null;
  }

  static Uint8List? generateExpenseReport({
    required List<ExpenseModel> expenses,
    required String title,
    String? dateRange,
  }) {
    final excel = Excel.createExcel();
    final sheet = excel['ব্যয়'];
    _setupSheet(sheet, 6);
    _writeTitle(sheet, title, dateRange, 6);
    _writeHeaders(sheet, ['তারিখ', 'ক্যাটাগরি', 'সরবরাহকারী', 'বিবরণ', 'পরিমাণ', 'অবস্থা'], 2);

    double total = 0;
    for (var i = 0; i < expenses.length; i++) {
      final row = i + 3;
      final exp = expenses[i];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue('${exp.expenseDate.day}/${exp.expenseDate.month}/${exp.expenseDate.year}');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = TextCellValue(exp.catName ?? '-');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = TextCellValue(exp.supplierName ?? '-');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = TextCellValue(exp.description ?? '-');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value = DoubleCellValue(exp.amount);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).cellStyle = _redStyle;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row)).value = TextCellValue(_st(exp.status));
      total += exp.amount;
    }
    _writeTotal(sheet, expenses.length + 3, total, 'মোট ব্যয়');
    final encoded = excel.encode();
    return encoded != null ? Uint8List.fromList(encoded) : null;
  }

  static Uint8List? generateMonthlyReport({
    required List<DailyReportItem> data,
    required int year,
    required int month,
    required ReportSummary summary,
  }) {
    final monthNames = ['জানুয়ারি','ফেব্রুয়ারি','মার্চ','এপ্রিল','মে','জুন','জুলাই','আগস্ট','সেপ্টেম্বর','অক্টোবর','নভেম্বর','ডিসেম্বর'];
    final excel = Excel.createExcel();
    final sheet = excel['মাসিক'];
    _setupSheet(sheet, 4);
    _writeTitle(sheet, 'মাসিক রিপোর্ট - ${monthNames[month - 1]} $year', null, 4);
    _writeSummary(sheet, 1, summary);
    _writeHeaders(sheet, ['তারিখ', 'আয়', 'ব্যয়', 'নেট'], 3);

    for (var i = 0; i < data.length; i++) {
      final row = i + 4;
      final d = data[i];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue('${d.date.day}/${d.date.month}/${d.date.year}');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = DoubleCellValue(d.income);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).cellStyle = _greenStyle;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = DoubleCellValue(d.expense);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).cellStyle = _redStyle;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = DoubleCellValue(d.net);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).cellStyle = d.net >= 0 ? _greenStyle : _redStyle;
    }
    _writeTotalRow(sheet, data.length + 4, summary.totalIncome, summary.totalExpense, summary.netAmount);
    final encoded = excel.encode();
    return encoded != null ? Uint8List.fromList(encoded) : null;
  }

  static Uint8List? generateYearlyReport({
    required List<MonthlyReportItem> data,
    required int year,
    required ReportSummary summary,
  }) {
    final monthNames = ['জানুয়ারি','ফেব্রুয়ারি','মার্চ','এপ্রিল','মে','জুন','জুলাই','আগস্ট','সেপ্টেম্বর','অক্টোবর','নভেম্বর','ডিসেম্বর'];
    final excel = Excel.createExcel();
    final sheet = excel['বার্ষিক'];
    _setupSheet(sheet, 4);
    _writeTitle(sheet, 'বার্ষিক রিপোর্ট - $year', null, 4);
    _writeSummary(sheet, 1, summary);
    _writeHeaders(sheet, ['মাস', 'আয়', 'ব্যয়', 'নেট'], 3);

    for (var i = 0; i < data.length; i++) {
      final row = i + 4;
      final m = data[i];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue(monthNames[m.month - 1]);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = DoubleCellValue(m.income);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).cellStyle = _greenStyle;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = DoubleCellValue(m.expense);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).cellStyle = _redStyle;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = DoubleCellValue(m.net);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).cellStyle = m.net >= 0 ? _greenStyle : _redStyle;
    }
    _writeTotalRow(sheet, data.length + 4, summary.totalIncome, summary.totalExpense, summary.netAmount);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: data.length + 5))
      .value = TextCellValue('মোট লেনদেন: ${summary.totalTransactions}');
    final encoded = excel.encode();
    return encoded != null ? Uint8List.fromList(encoded) : null;
  }

  static Uint8List? generateCashFlowReport({
    required List<CashFlowItem> data,
    required int year,
    required int month,
  }) {
    final monthNames = ['জানুয়ারি','ফেব্রুয়ারি','মার্চ','এপ্রিল','মে','জুন','জুলাই','আগস্ট','সেপ্টেম্বর','অক্টোবর','নভেম্বর','ডিসেম্বর'];
    final last = data.isNotEmpty ? data.last : null;
    final excel = Excel.createExcel();
    final sheet = excel['ক্যাশ ফ্লো'];
    _setupSheet(sheet, 4);
    _writeTitle(sheet, 'ক্যাশ ফ্লো রিপোর্ট - ${monthNames[month - 1]} $year', null, 4);

    if (last != null) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
        .value = TextCellValue('নগদ ব্যালেন্স: ৳${last.cashBalance.toStringAsFixed(2)}');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 1))
        .value = TextCellValue('ব্যাংক ব্যালেন্স: ৳${last.bankBalance.toStringAsFixed(2)}');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2))
        .value = TextCellValue('মোট ব্যালেন্স: ৳${last.totalBalance.toStringAsFixed(2)}');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2)).cellStyle = _blueBoldStyle;
    }

    _writeHeaders(sheet, ['তারিখ', 'নগদ', 'ব্যাংক', 'মোট'], 4);

    for (var i = 0; i < data.length; i++) {
      final row = i + 5;
      final d = data[i];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue('${d.date.day}/${d.date.month}/${d.date.year}');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = DoubleCellValue(d.cashBalance);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = DoubleCellValue(d.bankBalance);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = DoubleCellValue(d.totalBalance);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).cellStyle = _blueBoldStyle;
    }
    final encoded = excel.encode();
    return encoded != null ? Uint8List.fromList(encoded) : null;
  }

  static void _setupSheet(Sheet sheet, int cols) {
    sheet.setDefaultColumnWidth(18);
    for (var i = 0; i < cols; i++) {
      sheet.setColumnWidth(i, i == 3 ? 30 : 16);
    }
  }

  static void _writeTitle(Sheet sheet, String title, String? subtitle, int cols) {
    sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
        CellIndex.indexByColumnRow(columnIndex: cols - 1, rowIndex: 0));
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = TextCellValue(title);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).cellStyle = _titleStyle;

    if (subtitle != null) {
      sheet.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
          CellIndex.indexByColumnRow(columnIndex: cols - 1, rowIndex: 1));
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1)).value = TextCellValue(subtitle);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1)).cellStyle = _subtitleStyle;
    }
  }

  static void _writeHeaders(Sheet sheet, List<String> headers, int startRow) {
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: startRow));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = _headerStyle;
    }
  }

  static void _writeSummary(Sheet sheet, int row, ReportSummary s) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue(
      'আয়: ৳${s.totalIncome.toStringAsFixed(2)}  ব্যয়: ৳${s.totalExpense.toStringAsFixed(2)}  নেট: ৳${s.netAmount.toStringAsFixed(2)}  লেনদেন: ${s.totalTransactions}');
  }

  static void _writeTotal(Sheet sheet, int row, double total, String label) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = TextCellValue('$label:');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value = DoubleCellValue(total);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).cellStyle = _blueBoldStyle;
  }

  static void _writeTotalRow(Sheet sheet, int row, double income, double expense, double net) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue('মোট আয়');
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = DoubleCellValue(income);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).cellStyle = _greenStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = DoubleCellValue(expense);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).cellStyle = _redStyle;
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = DoubleCellValue(net);
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).cellStyle = net >= 0 ? _greenStyle : _redStyle;
  }

  static String _st(String status) {
    switch (status) {
      case 'completed': return 'সম্পন্ন';
      case 'pending': return 'মুলতুবি';
      case 'cancelled': return 'বাতিল';
      default: return status;
    }
  }

  static Future<void> shareExcel(Uint8List bytes, String fileName) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)], text: fileName.replaceAll('.xlsx', ''));
  }
}
