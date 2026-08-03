import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/services/app_strings.dart';
import 'package:nexora_khata/core/widgets/app_button.dart';
import 'package:nexora_khata/core/widgets/app_snackbar.dart';
import 'package:nexora_khata/features/reports/data/services/pdf_report_service.dart';
import 'package:printing/printing.dart';

class PdfPreviewPage extends StatefulWidget {
  const PdfPreviewPage({
    super.key,
    required this.bytes,
    required this.fileName,
  });

  final Uint8List bytes;
  final String fileName;

  @override
  State<PdfPreviewPage> createState() => _PdfPreviewPageState();
}

class _PdfPreviewPageState extends State<PdfPreviewPage> {
  bool _printing = false;
  bool _sharing = false;

  Future<void> _print() async {
    setState(() => _printing = true);
    try {
      await Printing.layoutPdf(
        onLayout: (_) async => widget.bytes,
        name: widget.fileName.replaceAll('.pdf', ''),
      );
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, AppStrings.s.setErrorPrefix(e));
      }
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  Future<void> _share() async {
    setState(() => _sharing = true);
    try {
      await PdfReportService.sharePdf(widget.bytes, widget.fileName);
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, AppStrings.s.setErrorPrefix(e));
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(widget.fileName, style: Theme.of(context).textTheme.titleMedium),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: PdfPreview(
              useActions: false,
              allowPrinting: false,
              allowSharing: false,
              canChangePageFormat: false,
              canChangeOrientation: false,
              canDebug: false,
              pdfFileName: widget.fileName,
              build: (_) async => widget.bytes,
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: AppSpacing.screenPadding.copyWith(top: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton.outlined(
                      AppStrings.s.rptPrintPdf,
                      icon: Icons.print_rounded,
                      isLoading: _printing,
                      onPressed: _printing ? null : _print,
                    ),
                  ),
                  AppSpacing.boxSM,
                  Expanded(
                    child: AppButton.primary(
                      AppStrings.s.rptSharePdf,
                      icon: Icons.share_rounded,
                      isLoading: _sharing,
                      onPressed: _sharing ? null : _share,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
