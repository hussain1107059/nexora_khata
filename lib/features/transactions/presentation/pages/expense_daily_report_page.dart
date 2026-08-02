import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/utils/number_utils.dart';
import 'package:nexora_khata/core/widgets/app_empty_state.dart';
import 'package:nexora_khata/core/widgets/app_loading.dart';
import 'package:nexora_khata/core/widgets/app_error_widget.dart';
import 'package:nexora_khata/features/transactions/presentation/providers/expense_provider.dart';
import 'package:nexora_khata/features/transactions/presentation/widgets/transaction_card.dart';

class ExpenseDailyReportPage extends ConsumerStatefulWidget {
  const ExpenseDailyReportPage({super.key});

  @override
  ConsumerState<ExpenseDailyReportPage> createState() => _ExpenseDailyReportPageState();
}

class _ExpenseDailyReportPageState extends ConsumerState<ExpenseDailyReportPage> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  String get _dateStr => '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('bn', 'BD'),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = _dateStr;
    final expensesAsync = ref.watch(expenseDailyReportProvider(date));
    final summaryAsync = ref.watch(expenseDailySummaryProvider(date));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text('দৈনিক ব্যয় রিপোর্ট', style: AppTypography.subtitle1),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          summaryAsync.when(
            loading: () => const AppLoading(),
            error: (_, _) => const SizedBox.shrink(),
            data: (summary) => _buildSummary(summary),
          ),
          Expanded(
            child: expensesAsync.when(
              loading: () => const AppLoading(),
              error: (e, _) => AppErrorWidget(message: e.toString()),
              data: (expenses) {
                if (expenses.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'কোনো ব্যয় নেই',
                    subtitle: 'এই তারিখে কোনো ব্যয় পাওয়া যায়নি',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(expenseDailyReportProvider(date));
                    ref.invalidate(expenseDailySummaryProvider(date));
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: AppSpacing.huge),
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      return TransactionCard(
                        description: expense.description ?? '',
                        date: expense.expenseDate,
                        categoryName: expense.catName,
                        amount: expense.amount,
                        status: expense.status,
                        iconBackground: AppColors.errorLight,
                        iconColor: AppColors.error,
                        icon: Icons.arrow_upward_rounded,
                        amountColor: AppColors.error,
                        completedStatusText: 'পরিশোধিত',
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: InkWell(
        onTap: _pickDate,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 2, offset: const Offset(0, 1))],
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_month_rounded, color: AppColors.primary),
              AppSpacing.boxMD,
              Text(
                '${_selectedDate.day.toString().padLeft(2, '0')} ${_monthName(_selectedDate.month)} ${_selectedDate.year}',
                style: AppTypography.subtitle2,
              ),
              const Spacer(),
              Icon(Icons.arrow_drop_down_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(Map<String, dynamic> summary) {
    final total = (summary['total'] as num?)?.toDouble() ?? 0;
    final count = summary['count'] as int? ?? 0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('মোট ব্যয়', style: AppTypography.caption.copyWith(color: Colors.white70)),
                AppSpacing.boxXS,
                Text(AppNumberUtils.formatCurrency(total), style: AppTypography.heading3.copyWith(
                  color: AppColors.white, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Column(
              children: [
                Text('$count', style: AppTypography.subtitle1.copyWith(color: AppColors.white, fontWeight: FontWeight.w700)),
                Text('টি', style: AppTypography.caption.copyWith(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const names = ['', 'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন', 'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'];
    return month >= 1 && month <= 12 ? names[month] : '';
  }
}
