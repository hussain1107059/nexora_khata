import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/services/app_strings.dart';
import 'package:nexora_khata/core/services/csv_export_service.dart';
import 'package:nexora_khata/core/utils/number_utils.dart';
import 'package:nexora_khata/core/widgets/app_button.dart';
import 'package:nexora_khata/core/widgets/app_empty_state.dart';
import 'package:nexora_khata/core/widgets/app_loading.dart';
import 'package:nexora_khata/core/widgets/app_error_widget.dart';
import 'package:nexora_khata/core/widgets/app_snackbar.dart';
import 'package:nexora_khata/features/transactions/presentation/providers/income_provider.dart';

class IncomeMonthlyReportPage extends ConsumerStatefulWidget {
  const IncomeMonthlyReportPage({super.key});

  @override
  ConsumerState<IncomeMonthlyReportPage> createState() => _IncomeMonthlyReportPageState();
}

class _IncomeMonthlyReportPageState extends ConsumerState<IncomeMonthlyReportPage> {
  int _selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(incomeMonthlyReportProvider(_selectedYear));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(AppStrings.s.incMonthlyReportTooltip, style: AppTypography.subtitle1),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share_rounded),
            onPressed: () => _exportCSV(reportAsync.valueOrNull ?? []),
            tooltip: AppStrings.s.incExportCsv,
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
                    title: AppStrings.s.incNoData,
                    subtitle: AppStrings.s.incNoDataSubtitle,
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
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: Center(
                              child: Text(month.toString().padLeft(2, '0'), style: AppTypography.subtitle1.copyWith(
                                color: AppColors.primary, fontWeight: FontWeight.w700)),
                            ),
                          ),
                          AppSpacing.boxMD,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(monthName, style: AppTypography.subtitle2),
                                Text(AppStrings.s.incCount(count), style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          Flexible(
                            child: Text(AppNumberUtils.formatCurrency(total),
                              style: AppTypography.subtitle1.copyWith(
                                color: AppColors.success, fontWeight: FontWeight.w700),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
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
            AppStrings.s.incExportCsv,
            icon: Icons.download_rounded,
            onPressed: () => _exportCSV(ref.read(incomeMonthlyReportProvider(_selectedYear)).valueOrNull ?? []),
          ),
        ],
      ),
    );
  }

  Future<void> _exportCSV(List<Map<String, dynamic>> data) async {
    if (data.isEmpty) {
      AppSnackBar.warning(context, AppStrings.s.incExportEmpty);
      return;
    }

    try {
      await CsvExportService.exportMonthlyReport(
        data: data,
        year: _selectedYear,
        fileName: 'income_report_$_selectedYear.csv',
        header: AppStrings.s.incCsvHeader,
        shareText: AppStrings.s.incShareText(_selectedYear),
        monthName: _monthName,
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.error(context, AppStrings.s.incExportError(e));
    }
  }

  String _monthName(int month) {
    final names = [
      '',
      AppStrings.s.monthJanuary,
      AppStrings.s.monthFebruary,
      AppStrings.s.monthMarch,
      AppStrings.s.monthApril,
      AppStrings.s.monthMay,
      AppStrings.s.monthJune,
      AppStrings.s.monthJuly,
      AppStrings.s.monthAugust,
      AppStrings.s.monthSeptember,
      AppStrings.s.monthOctober,
      AppStrings.s.monthNovember,
      AppStrings.s.monthDecember,
    ];
    return month >= 1 && month <= 12 ? names[month] : '';
  }
}
