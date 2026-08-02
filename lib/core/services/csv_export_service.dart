import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart' as share;

class CsvExportService {
  CsvExportService._();

  static Future<void> exportMonthlyReport({
    required List<Map<String, dynamic>> data,
    required int year,
    required String fileName,
    required String header,
    required String shareText,
    required String Function(int month) monthName,
  }) async {
    if (data.isEmpty) return;

    final buffer = StringBuffer();
    buffer.writeln(header);
    for (final r in data) {
      final month = int.tryParse(r['month']?.toString() ?? '0') ?? 0;
      final count = r['count'] as int? ?? 0;
      final total = (r['total'] as num?)?.toDouble() ?? 0;
      buffer.writeln('${monthName(month)},$count,$total');
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(buffer.toString());

    await share.Share.shareXFiles(
      [share.XFile(file.path)],
      text: shareText,
    );
  }
}
