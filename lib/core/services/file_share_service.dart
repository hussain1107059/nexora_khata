import 'dart:typed_data';
import 'package:nexora_khata/core/services/file_share_io.dart'
    if (dart.library.js_interop) 'package:nexora_khata/core/services/file_share_web.dart'
    as impl;

Future<void> shareOrDownloadFile({
  required Uint8List bytes,
  required String fileName,
  String? shareText,
}) {
  return impl.shareOrDownloadFile(
    bytes: bytes,
    fileName: fileName,
    shareText: shareText,
  );
}
