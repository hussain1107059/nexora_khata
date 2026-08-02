import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/services/csv_export_service.dart';
import 'package:nexora_khata/core/utils/number_utils.dart';
import 'package:nexora_khata/core/widgets/app_button.dart';
import 'package:nexora_khata/core/widgets/app_empty_state.dart';
import 'package:nexora_khata/core/widgets/app_loading.dart';
import 'package:nexora_khata/core/widgets/app_error_widget.dart';
import 'package:nexora_khata/core/widgets/app_snackbar.dart';
import 'package:nexora_khata/features/transactions/presentation/providers/expense_provider.dart';

class ExpenseMonthlyReportPage extends ConsumerStatefulWidget {
  const ExpenseMonthlyReportPage({super.key});

  @override
  ConsumerState<ExpenseMonthlyReportPage> createState() => _ExpenseMonthlyReportPageState();
}

class _ExpenseMonthlyReportPageState extends ConsumerState<ExpenseMonthlyReportPage> {
  int _selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(expenseMonthlyReportProvider(_selectedYear));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text('মাসিক ব্যয় রিপোর্ট', style: AppTypography.subtitle1),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share_rounded),
            onPressed: () => _exportCSV(reportAsync.valueOrNull ?? []),
            tooltip: 'এক্সপোর্ট',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildYearSelector(),
          Expanded(
            child: reportAsync.when(
              loading: () => const AppLoading(),
              error: (e, _) => AppErrorWidget(message: e.toString()),
              data: (report) {
                if (report.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.bar_chart_rounded,
                    title: 'কোনো তথ্য নেই',
                    subtitle: 'এই বছরের জন্য কোনো ব্যয় পাওয়া যায়নি',
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  itemCount: report.length,
                  separatorBuilder: (_, _) => AppSpacing.boxSM,
                  itemBuilder: (context, index) {
                    final r = report[index];
                    final month = int.tryParse(r['month']?.toString() ?? '0') ?? 0;
                    final count = r['count'] as int? ?? 0;
                    final total = (r['total'] as num?)?.toDouble() ?? 0;
                    final monthName = _monthName(month);

                    return Container(
                      padding: AppSpacing.paddingLg,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 2, offset: const Offset(0, 1))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.errorLight,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: Center(
                              child: Text(month.toString().padLeft(2, '0'), style: AppTypography.subtitle1.copyWith(
                                color: AppColors.error, fontWeight: FontWeight.w700)),
                            ),
                          ),
                          AppSpacing.boxMD,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(monthName, style: AppTypography.subtitle2),
                                Text('$count টি লেনদেন', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          Text(AppNumberUtils.formatCurrency(total), style: AppTypography.subtitle1.copyWith(
                            color: AppColors.error, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearSelector() {
    final years = List.generate(10, (i) => DateTime.now().year - 5 + i);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(Icons.calendar_month_rounded, color: AppColors.primary),
          AppSpacing.boxSM,
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedYear,
              items: years.map((y) => DropdownMenuItem(value: y, child: Text(y.toString(), style: AppTypography.subtitle2))).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedYear = v);
              },
            ),
          ),
          Spacer(),
          AppButton.outlined(
            'এক্সপোর্ট CSV',
            icon: Icons.download_rounded,
            onPressed: () => _exportCSV(ref.read(expenseMonthlyReportProvider(_selectedYear)).valueOrNull ?? []),
          ),
        ],
      ),
    );
  }

  Future<void> _exportCSV(List<Map<String, dynamic>> data) async {
    if (data.isEmpty) {
      AppSnackBar.warning(context, 'এক্সপোর্ট করার মতো কোনো তথ্য নেই');
      return;
    }

    try {
      await CsvExportService.exportMonthlyReport(
        data: data,
        year: _selectedYear,
        fileName: 'expense_report_$_selectedYear.csv',
        header: 'মাস,লেনদেন সংখ্যা,মোট ব্যয়',
        shareText: 'ব্যয়ের মাসিক রিপোর্ট $_selectedYear',
        monthName: _monthName,
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.error(context, 'এক্সপোর্ট করতে সমস্যা: $e');
    }
  }

  String _monthName(int month) {
    const names = ['', 'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন', 'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'];
    return month >= 1 && month <= 12 ? names[month] : '';
  }
}
