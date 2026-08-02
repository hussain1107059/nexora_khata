import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/utils/number_utils.dart';
import 'package:nexora_khata/core/widgets/core_card.dart';
import 'package:nexora_khata/features/reports/domain/entities/report.dart';

class ReportPieChart extends StatelessWidget {
  final List<CategoryReportItem> data;
  final String title;

  static const List<Color> chartColors = [
    Color(0xFFE53935),
    Color(0xFF43A047),
    Color(0xFF1E88E5),
    Color(0xFFFB8C00),
    Color(0xFF8E24AA),
    Color(0xFF00ACC1),
    Color(0xFF3949AB),
    Color(0xFFD81B60),
  ];

  const ReportPieChart({
    super.key,
    required this.data,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final total = data.fold<double>(0, (sum, item) => sum + item.amount);

    return CoreCard(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 220,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: _buildSections(total),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {},
                      ),
                    ),
                  ),
                ),
                AppSpacing.boxWLG,
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'মোট',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    AppSpacing.boxHXS,
                    Text(
                      AppNumberUtils.formatCompactBn(total),
                      style: AppTypography.subtitle1.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppSpacing.boxHSM,
                    Text(
                      '${data.length} টি ক্যাটাগরি',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppSpacing.boxHLG,
          ...data.asMap().entries.map((entry) {
            final item = entry.value;
            final color = chartColors[entry.key % chartColors.length];
            return _LegendRow(
              color: color,
              label: item.category,
              amount: item.amount,
              percentage: item.percentage,
            );
          }),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(double total) {
    return data.asMap().entries.map((entry) {
      final item = entry.value;
      final color = chartColors[entry.key % chartColors.length];
      final pct = total > 0 ? item.amount / total * 100 : 0.0;
      return PieChartSectionData(
        value: item.amount,
        color: color,
        radius: 60,
        title: '${pct.toStringAsFixed(0)}%',
        titleStyle: AppTypography.caption.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        badgeWidget: null,
      );
    }).toList();
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final double amount;
  final double percentage;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.amount,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          AppSpacing.boxWSM,
          Expanded(
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          AppSpacing.boxWSM,
          Text(
            AppNumberUtils.formatCompactBn(amount),
            style: AppTypography.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 40,
            child: Text(
              AppNumberUtils.formatPercentage(percentage),
              style: AppTypography.overline.copyWith(
                color: AppColors.textHint,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
