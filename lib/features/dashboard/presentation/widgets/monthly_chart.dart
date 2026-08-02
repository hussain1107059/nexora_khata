import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nexora_khata/core/services/app_strings.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/config/theme/app_spacing.dart';
import '../../../../core/config/theme/app_typography.dart';
import '../../../../core/utils/number_utils.dart';
import '../../../../core/widgets/core_card.dart';
import '../../domain/entities/dashboard_summary.dart';

class MonthlyChart extends StatelessWidget {
  final List<MonthlyData> data;

  const MonthlyChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    return CoreCard(
      margin: AppSpacing.paddingHSm,
      title: AppStrings.s.dashboardMonthlyChart,
      trailing: Row(
        children: [
          ChartLegend(
            color: AppColors.success,
            label: AppStrings.s.dashboardIncome,
            padding: EdgeInsets.only(left: 8),
          ),
          ChartLegend(
            color: AppColors.error,
            label: AppStrings.s.dashboardExpense,
            padding: EdgeInsets.only(left: 8),
          ),
        ],
      ),
      child: SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _maxValue * 1.2,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final m = data[groupIndex];
                        final monthName = _monthName(m.month);
                        final label = rodIndex == 0 ? AppStrings.s.dashboardIncome : AppStrings.s.dashboardExpense;
                        return BarTooltipItem(
                          '$monthName\n$label: ${AppNumberUtils.formatCurrency(rod.toY)}',
                          const TextStyle(
                            color: AppColors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            AppNumberUtils.formatCompact(value),
                            style: AppTypography.overline.copyWith(
                              color: AppColors.textHint,
                              fontSize: 9,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= data.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _shortMonth(data[i].month),
                              style: AppTypography.overline.copyWith(
                                color: AppColors.textHint,
                                fontSize: 9,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: data.asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value.income,
                          color: AppColors.success,
                          width: 8,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                        BarChartRodData(
                          toY: e.value.expense,
                          color: AppColors.error,
                          width: 8,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _maxValue / 4,
                    getDrawingHorizontalLine: (value) => const FlLine(
                      color: AppColors.divider,
                      strokeWidth: 1,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  double get _maxValue {
    double max = 0;
    for (final d in data) {
      if (d.income > max) max = d.income;
      if (d.expense > max) max = d.expense;
    }
    return max > 0 ? max : 100;
  }

  String _monthName(int m) {
    final months = [
      AppStrings.s.monthJanuary, AppStrings.s.monthFebruary, AppStrings.s.monthMarch, AppStrings.s.monthApril,
      AppStrings.s.monthMay, AppStrings.s.monthJune, AppStrings.s.monthJuly, AppStrings.s.monthAugust,
      AppStrings.s.monthSeptember, AppStrings.s.monthOctober, AppStrings.s.monthNovember, AppStrings.s.monthDecember,
    ];
    return months[m - 1];
  }

  String _shortMonth(int m) {
    final months = [
      AppStrings.s.monthShort1, AppStrings.s.monthShort2, AppStrings.s.monthShort3, AppStrings.s.monthShort4,
      AppStrings.s.monthShort5, AppStrings.s.monthShort6, AppStrings.s.monthShort7, AppStrings.s.monthShort8,
      AppStrings.s.monthShort9, AppStrings.s.monthShort10, AppStrings.s.monthShort11, AppStrings.s.monthShort12,
    ];
    return months[m - 1];
  }
}
