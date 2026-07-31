import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/utils/date_utils.dart';
import 'package:nexora_khata/core/utils/number_utils.dart';
import 'package:nexora_khata/core/widgets/app_error_widget.dart';
import 'package:nexora_khata/core/widgets/app_loading.dart';
import 'package:nexora_khata/features/reports/domain/entities/report.dart';
import 'package:nexora_khata/features/reports/presentation/providers/report_provider.dart';
import 'package:nexora_khata/features/reports/presentation/widgets/report_bar_chart.dart';
import 'package:nexora_khata/features/reports/presentation/widgets/report_line_chart.dart';
import 'package:nexora_khata/features/reports/presentation/widgets/report_pie_chart.dart';
import 'package:nexora_khata/features/reports/presentation/widgets/report_summary_card.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  static const _tabs = [
    'দৈনিক',
    'সাপ্তাহিক',
    'মাসিক',
    'বার্ষিক',
    'ক্যাটাগরি',
    'আয়-ব্যয়',
    'ক্যাশ ফ্লো',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(reportTabProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'রিপোর্ট',
          style: AppTypography.subtitle1.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (tab >= 3)
            _YearSelector(
              selectedYear: ref.watch(reportYearProvider),
              onChanged: (y) => ref.read(reportYearProvider.notifier).state = y,
            ),
        ],
      ),
      body: Column(
        children: [
          _TabBar(),
          Expanded(
            child: _buildBody(tab, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(int tab, WidgetRef ref) {
    switch (tab) {
      case 0:
        return const _DailyReportView();
      case 1:
        return const _WeeklyReportView();
      case 2:
        return const _MonthlyReportView();
      case 3:
        return const _YearlyReportView();
      case 4:
        return const _CategoryReportView();
      case 5:
        return const _IncomeVsExpenseView();
      case 6:
        return const _CashFlowView();
      default:
        return const SizedBox.shrink();
    }
  }
}

class _TabBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(reportTabProvider);

    return Container(
      color: AppColors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.paddingHSm.copyWith(
          top: AppSpacing.sm,
          bottom: AppSpacing.sm,
        ),
        child: Row(
          children: ReportsPage._tabs.asMap().entries.map((entry) {
            final i = entry.key;
            final label = entry.value;
            final isSelected = tab == i;
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: GestureDetector(
                onTap: () => ref.read(reportTabProvider.notifier).state = i,
                child: Container(
                  padding: AppSpacing.paddingHSm.copyWith(
                    top: AppSpacing.sm,
                    bottom: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.chipBackground,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  ),
                  child: Text(
                    label,
                    style: AppTypography.labelMedium.copyWith(
                      color: isSelected
                          ? AppColors.white
                          : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _YearSelector extends ConsumerWidget {
  final int selectedYear;
  final ValueChanged<int> onChanged;

  const _YearSelector({
    required this.selectedYear,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yearsAsync = ref.watch(availableYearsProvider);

    return yearsAsync.when(
      loading: () => Padding(
        padding: AppSpacing.paddingHSm,
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, _) => Padding(
        padding: AppSpacing.paddingHSm,
        child: Text(
          '$selectedYear',
          style: AppTypography.subtitle1.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      data: (years) {
        final allYears = years.toSet();
        if (selectedYear != 0 && !allYears.contains(selectedYear)) {
          allYears.add(selectedYear);
        }
        final sorted = allYears.toList()..sort((a, b) => b.compareTo(a));
        if (sorted.isEmpty) sorted.add(DateTime.now().year);

        return PopupMenuButton<int>(
          initialValue: selectedYear,
          onSelected: onChanged,
          child: Padding(
            padding: AppSpacing.paddingHSm,
            child: Row(
              children: [
                Text(
                  '$selectedYear',
                  style: AppTypography.subtitle1.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
          itemBuilder: (_) => sorted.map((y) {
            return PopupMenuItem<int>(
              value: y,
              child: Text(y.toString()),
            );
          }).toList(),
        );
      },
    );
  }
}

class _DailyReportView extends ConsumerWidget {
  const _DailyReportView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(reportDateProvider);
    final effectiveDate = date ?? AppDateUtils.formatDate(
      DateTime.now(),
      format: 'yyyy-MM-dd',
    );

    final reportAsync = ref.watch(dailyReportProvider(effectiveDate));

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: AppSpacing.screenPadding.copyWith(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DatePickerTile(
            label: 'তারিখ নির্বাচন',
            date: effectiveDate,
            onTap: () => _pickDate(context, ref),
          ),
          AppSpacing.boxHLG,
          reportAsync.when(
            loading: () => const AppShimmerLoading(itemCount: 2),
            error: (err, _) => AppErrorWidget(
              message: err.toString(),
              onRetry: () => ref.invalidate(dailyReportProvider(effectiveDate)),
            ),
            data: (items) {
              final summary = _computeDailySummary(items);
              return Column(
                children: [
                  ReportSummaryCard(summary: summary),
                  AppSpacing.boxHLG,
                  _DailyBarChart(items: items),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  ReportSummary _computeDailySummary(List<DailyReportItem> items) {
    double income = 0, expense = 0;
    int count = 0;
    for (final item in items) {
      income += item.income;
      expense += item.expense;
      count++;
    }
    return ReportSummary(
      totalIncome: income,
      totalExpense: expense,
      netAmount: income - expense,
      totalTransactions: count,
      period: 'দৈনিক রিপোর্ট',
    );
  }

  Future<void> _pickDate(BuildContext context, WidgetRef ref) async {
    final initial = ref.read(reportDateProvider);
    final parsed = initial != null
        ? DateTime.tryParse(initial) ?? DateTime.now()
        : DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: parsed,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('bn'),
    );
    if (picked != null) {
      ref.read(reportDateProvider.notifier).state =
          AppDateUtils.formatDate(picked, format: 'yyyy-MM-dd');
    }
  }
}

class _WeeklyReportView extends ConsumerWidget {
  const _WeeklyReportView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(reportDateProvider);
    final effectiveDate = date ?? AppDateUtils.formatDate(
      DateTime.now(),
      format: 'yyyy-MM-dd',
    );

    final reportAsync = ref.watch(weeklyReportProvider(effectiveDate));
    final summaryAsync = ref.watch(weeklySummaryProvider(effectiveDate));

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: AppSpacing.screenPadding.copyWith(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DatePickerTile(
            label: 'সপ্তাহ নির্বাচন (যেকোনো দিন)',
            date: effectiveDate,
            onTap: () => _pickDate(context, ref),
          ),
          AppSpacing.boxHLG,
          summaryAsync.when(
            loading: () => const AppShimmerLoading(itemCount: 1),
            error: (err, _) => AppErrorWidget(
              message: err.toString(),
              onRetry: () => ref.invalidate(weeklySummaryProvider(effectiveDate)),
            ),
            data: (summary) => ReportSummaryCard(summary: summary),
          ),
          AppSpacing.boxHLG,
          reportAsync.when(
            loading: () => const AppLoading(message: 'লোড হচ্ছে...'),
            error: (err, _) => AppErrorWidget(
              message: err.toString(),
              onRetry: () => ref.invalidate(weeklyReportProvider(effectiveDate)),
            ),
            data: (items) => _DailyBarChart(items: items),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, WidgetRef ref) async {
    final initial = ref.read(reportDateProvider);
    final parsed = initial != null
        ? DateTime.tryParse(initial) ?? DateTime.now()
        : DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: parsed,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('bn'),
    );
    if (picked != null) {
      ref.read(reportDateProvider.notifier).state =
          AppDateUtils.formatDate(picked, format: 'yyyy-MM-dd');
    }
  }
}

class _MonthlyReportView extends ConsumerWidget {
  const _MonthlyReportView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = ref.watch(reportMonthProvider);
    final reportAsync = ref.watch(monthlyReportProvider(params));
    final summaryAsync = ref.watch(monthlySummaryProvider(params));

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: AppSpacing.screenPadding.copyWith(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MonthPickerTile(
            year: params['year']!,
            month: params['month']!,
            onChanged: (y, m) => ref.read(reportMonthProvider.notifier).state = {
              'year': y,
              'month': m,
            },
          ),
          AppSpacing.boxHLG,
          summaryAsync.when(
            loading: () => const AppShimmerLoading(itemCount: 1),
            error: (err, _) => AppErrorWidget(
              message: err.toString(),
              onRetry: () => ref.invalidate(monthlySummaryProvider(params)),
            ),
            data: (summary) => ReportSummaryCard(summary: summary),
          ),
          AppSpacing.boxHLG,
          reportAsync.when(
            loading: () => const AppLoading(message: 'লোড হচ্ছে...'),
            error: (err, _) => AppErrorWidget(
              message: err.toString(),
              onRetry: () => ref.invalidate(monthlyReportProvider(params)),
            ),
            data: (items) => _DailyBarChart(items: items),
          ),
        ],
      ),
    );
  }
}

class _YearlyReportView extends ConsumerWidget {
  const _YearlyReportView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final year = ref.watch(reportYearProvider);
    final reportAsync = ref.watch(yearlyReportProvider(year));
    final summaryAsync = ref.watch(yearlySummaryProvider(year));

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: AppSpacing.screenPadding.copyWith(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          summaryAsync.when(
            loading: () => const AppShimmerLoading(itemCount: 1),
            error: (err, _) => AppErrorWidget(
              message: err.toString(),
              onRetry: () => ref.invalidate(yearlySummaryProvider(year)),
            ),
            data: (summary) => ReportSummaryCard(summary: summary),
          ),
          AppSpacing.boxHLG,
          reportAsync.when(
            loading: () => const AppLoading(message: 'লোড হচ্ছে...'),
            error: (err, _) => AppErrorWidget(
              message: err.toString(),
              onRetry: () => ref.invalidate(yearlyReportProvider(year)),
            ),
            data: (items) {
              final chartData = items.map((m) {
                return IncomeVsExpenseItem(
                  label: AppDateUtils.monthNameBn(m.month).substring(0, 3),
                  income: m.income,
                  expense: m.expense,
                );
              }).toList();
              return ReportBarChart(
                data: chartData,
                title: 'বার্ষিক রিপোর্ট - $year',
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryReportView extends ConsumerWidget {
  const _CategoryReportView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toggle = ref.watch(reportCategoryToggleProvider);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: AppSpacing.screenPadding.copyWith(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => ref.read(reportCategoryToggleProvider.notifier).state = 0,
                  child: Container(
                    padding: AppSpacing.paddingSm,
                    decoration: BoxDecoration(
                      color: toggle == 0 ? AppColors.success : AppColors.chipBackground,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Center(
                      child: Text(
                        'আয়',
                        style: AppTypography.labelMedium.copyWith(
                          color: toggle == 0 ? AppColors.white : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              AppSpacing.boxWSM,
              Expanded(
                child: GestureDetector(
                  onTap: () => ref.read(reportCategoryToggleProvider.notifier).state = 1,
                  child: Container(
                    padding: AppSpacing.paddingSm,
                    decoration: BoxDecoration(
                      color: toggle == 1 ? AppColors.error : AppColors.chipBackground,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Center(
                      child: Text(
                        'ব্যয়',
                        style: AppTypography.labelMedium.copyWith(
                          color: toggle == 1 ? AppColors.white : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.boxHLG,
          if (toggle == 0)
            _buildCategoryContent(ref, true, 'ক্যাটাগরি অনুযায়ী আয়')
          else
            _buildCategoryContent(ref, false, 'ক্যাটাগরি অনুযায়ী ব্যয়'),
        ],
      ),
    );
  }

  Widget _buildCategoryContent(
    WidgetRef ref,
    bool isIncome,
    String title,
  ) {
    final params = <String, int?>{'year': null, 'month': null};
    final async = isIncome
        ? ref.watch(categoryIncomeProvider(params))
        : ref.watch(categoryExpenseProvider(params));

    return async.when(
      loading: () => const AppShimmerLoading(itemCount: 3),
      error: (err, _) => AppErrorWidget(
        message: err.toString(),
        onRetry: () {
          ref.invalidate(categoryIncomeProvider(params));
          ref.invalidate(categoryExpenseProvider(params));
        },
      ),
      data: (items) => items.isEmpty
          ? const AppLoading(message: 'কোনো ডাটা নেই')
          : ReportPieChart(data: items, title: title),
    );
  }
}

class _IncomeVsExpenseView extends ConsumerWidget {
  const _IncomeVsExpenseView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final year = ref.watch(reportYearProvider);
    final async = ref.watch(incomeVsExpenseProvider(year));

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: AppSpacing.screenPadding.copyWith(bottom: 100),
      child: async.when(
        loading: () => const AppShimmerLoading(itemCount: 1),
        error: (err, _) => AppErrorWidget(
          message: err.toString(),
          onRetry: () => ref.invalidate(incomeVsExpenseProvider(year)),
        ),
        data: (items) => items.isEmpty
            ? const AppLoading(message: 'কোনো ডাটা নেই')
            : ReportBarChart(
                data: items,
                title: 'আয় vs ব্যয় - $year',
              ),
      ),
    );
  }
}

class _CashFlowView extends ConsumerWidget {
  const _CashFlowView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = ref.watch(reportMonthProvider);
    final async = ref.watch(cashFlowProvider(params));

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: AppSpacing.screenPadding.copyWith(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MonthPickerTile(
            year: params['year']!,
            month: params['month']!,
            onChanged: (y, m) => ref.read(reportMonthProvider.notifier).state = {
              'year': y,
              'month': m,
            },
          ),
          AppSpacing.boxHLG,
          async.when(
            loading: () => const AppShimmerLoading(itemCount: 1),
            error: (err, _) => AppErrorWidget(
              message: err.toString(),
              onRetry: () => ref.invalidate(cashFlowProvider(params)),
            ),
            data: (items) => items.isEmpty
                ? const AppLoading(message: 'কোনো ডাটা নেই')
                : ReportLineChart(
                    data: items,
                    title: 'ক্যাশ ফ্লো - ${AppDateUtils.monthNameBn(params['month']!)} ${params['year']}',
                  ),
          ),
        ],
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final String label;
  final String date;
  final VoidCallback onTap;

  const _DatePickerTile({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayDate = AppDateUtils.formatDate(
      DateTime.tryParse(date) ?? DateTime.now(),
    );
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
      child: ListTile(
        leading: const Icon(Icons.calendar_today_rounded, color: AppColors.primary),
        title: Text(label, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
        subtitle: Text(displayDate, style: AppTypography.bodyText1.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textHint),
        onTap: onTap,
      ),
    );
  }
}

class _MonthPickerTile extends StatelessWidget {
  final int year;
  final int month;
  final void Function(int year, int month) onChanged;

  const _MonthPickerTile({
    required this.year,
    required this.month,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
            AppSpacing.boxWMD,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'মাস নির্বাচন',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${AppDateUtils.monthNameBn(month)} $year',
                    style: AppTypography.bodyText1.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: () {
                if (month == 1) {
                  onChanged(year - 1, 12);
                } else {
                  onChanged(year, month - 1);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: () {
                if (month == 12) {
                  onChanged(year + 1, 1);
                } else {
                  onChanged(year, month + 1);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyBarChart extends StatelessWidget {
  final List<DailyReportItem> items;

  const _DailyBarChart({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final maxVal = items.fold<double>(0, (max, item) {
      final m = item.income > item.expense ? item.income : item.expense;
      return m > max ? m : max;
    });

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
                  'দিনভিত্তিক রিপোর্ট',
                  style: AppTypography.subtitle2.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    _BarLegend(color: AppColors.success, label: 'আয়'),
                    AppSpacing.boxWSM,
                    _BarLegend(color: AppColors.error, label: 'ব্যয়'),
                  ],
                ),
              ],
            ),
            AppSpacing.boxHLG,
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxVal * 1.2,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final item = items[groupIndex];
                        final label = rodIndex == 0 ? 'আয়' : 'ব্যয়';
                        final day = item.date.day;
                        return BarTooltipItem(
                          '$day তারিখ\n$label: ${AppNumberUtils.formatCurrency(rod.toY)}',
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
                        interval: _xInterval(items.length),
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= items.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${items[i].date.day}',
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
                  barGroups: items.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.income,
                          color: AppColors.success,
                          width: 6,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                        BarChartRodData(
                          toY: entry.value.expense,
                          color: AppColors.error,
                          width: 6,
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
                    horizontalInterval: maxVal / 4,
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

  double _xInterval(int count) {
    if (count <= 10) return 1;
    if (count <= 20) return 2;
    return 5;
  }
}

class _BarLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _BarLegend({required this.color, required this.label});

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
