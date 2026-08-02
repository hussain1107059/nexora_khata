import 'dart:convert';
import 'dart:typed_data';
import 'package:nexora_khata/core/services/file_share_service.dart';

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

    final bytes = Uint8List.fromList(utf8.encode(buffer.toString()));
    await shareOrDownloadFile(
      bytes: bytes,
      fileName: fileName,
      shareText: shareText,
    );
  }
}
