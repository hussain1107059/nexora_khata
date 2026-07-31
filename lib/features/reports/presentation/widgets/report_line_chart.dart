import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/utils/number_utils.dart';
import 'package:nexora_khata/features/reports/domain/entities/report.dart';

class ReportLineChart extends StatelessWidget {
  final List<CashFlowItem> data;
  final String title;

  const ReportLineChart({
    super.key,
    required this.data,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTypography.subtitle2.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    _Legend(color: AppColors.info, label: 'ক্যাশ'),
                    AppSpacing.boxWSM,
                    _Legend(color: AppColors.success, label: 'ব্যাংক'),
                  ],
                ),
              ],
            ),
            AppSpacing.boxHLG,
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: _maxValue * 1.2,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final isCash = spot.barIndex == 0;
                          final label = isCash ? 'ক্যাশ' : 'ব্যাংক';
                          final day = spot.x.toInt();
                          final dateLabel = day < data.length
                              ? _formatDateLabel(data[day].date)
                              : '';
                          return LineTooltipItem(
                            '$dateLabel\n$label: ${AppNumberUtils.formatCurrency(spot.y)}',
                            TextStyle(
                              color: isCash ? AppColors.white : AppColors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }).toList();
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
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(
                              AppNumberUtils.formatCompact(value),
                              style: AppTypography.overline.copyWith(
                                color: AppColors.textHint,
                                fontSize: 9,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: _xInterval(),
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= data.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _formatXLabel(data[i].date),
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
                  lineBarsData: [
                    _cashLine(),
                    _bankLine(),
                  ],
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _maxValue / 4,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: AppColors.divider,
                      strokeWidth: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartBarData _cashLine() {
    return LineChartBarData(
      spots: data.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.cashBalance);
      }).toList(),
      color: AppColors.info,
      barWidth: 2.5,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 3,
            color: AppColors.info,
            strokeWidth: 1.5,
            strokeColor: AppColors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        color: AppColors.info.withValues(alpha: 0.08),
      ),
      isCurved: true,
      curveSmoothness: 0.3,
    );
  }

  LineChartBarData _bankLine() {
    return LineChartBarData(
      spots: data.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value.bankBalance);
      }).toList(),
      color: AppColors.success,
      barWidth: 2.5,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 3,
            color: AppColors.success,
            strokeWidth: 1.5,
            strokeColor: AppColors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        color: AppColors.success.withValues(alpha: 0.08),
      ),
      isCurved: true,
      curveSmoothness: 0.3,
    );
  }

  double get _maxValue {
    double max = 0;
    for (final d in data) {
      if (d.cashBalance > max) max = d.cashBalance;
      if (d.bankBalance > max) max = d.bankBalance;
      if (d.totalBalance > max) max = d.totalBalance;
    }
    return max > 0 ? max : 100;
  }

  double _xInterval() {
    if (data.length <= 7) return 1;
    if (data.length <= 15) return 2;
    if (data.length <= 31) return 5;
    return (data.length / 6).ceil().toDouble();
  }

  String _formatXLabel(DateTime date) {
    return '${date.day}/${date.month}';
  }

  String _formatDateLabel(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        AppSpacing.boxWXS,
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
