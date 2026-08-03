import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/router/route_names.dart';
import 'package:nexora_khata/core/services/app_strings.dart';
import 'package:nexora_khata/core/utils/date_utils.dart';
import 'package:nexora_khata/core/widgets/app_button.dart';
import 'package:nexora_khata/core/widgets/app_empty_state.dart';
import 'package:nexora_khata/core/widgets/app_error_widget.dart';
import 'package:nexora_khata/core/widgets/app_loading.dart';
import 'package:nexora_khata/core/widgets/app_snackbar.dart';
import 'package:nexora_khata/features/categories/domain/entities/expense_category.dart';
import 'package:nexora_khata/features/categories/domain/entities/income_category.dart';
import 'package:nexora_khata/features/categories/presentation/providers/expense_category_provider.dart';
import 'package:nexora_khata/features/categories/presentation/providers/income_category_provider.dart';
import 'package:nexora_khata/features/reports/data/services/pdf_report_service.dart';
import 'package:nexora_khata/features/reports/presentation/pages/pdf_preview_page.dart';
import 'package:nexora_khata/features/reports/presentation/providers/report_provider.dart';
import 'package:nexora_khata/features/reports/presentation/widgets/report_summary_card.dart';
import 'package:nexora_khata/features/transactions/presentation/models/transaction_entry.dart';
import 'package:nexora_khata/features/transactions/presentation/widgets/transaction_card.dart';

class CustomReportPage extends ConsumerStatefulWidget {
  const CustomReportPage({super.key});

  @override
  ConsumerState<CustomReportPage> createState() => _CustomReportPageState();
}

class _CustomReportPageState extends ConsumerState<CustomReportPage> {
  late String _from;
  late String _to;
  String? _type;
  int? _incomeCategoryId;
  int? _expenseCategoryId;

  @override
  void initState() {
    super.initState();
    final committed = ref.read(customReportFilterProvider);
    if (committed != null) {
      _from = committed.from;
      _to = committed.to;
      _type = committed.type;
      _incomeCategoryId = committed.incomeCategoryId;
      _expenseCategoryId = committed.expenseCategoryId;
    } else {
      final now = DateTime.now();
      _from = AppDateUtils.formatDate(
        DateTime(now.year, now.month, 1),
        format: AppDateUtils.dateFormat,
      );
      _to = AppDateUtils.formatDate(now, format: AppDateUtils.dateFormat);
      WidgetsBinding.instance.addPostFrameCallback((_) => _apply());
    }
  }

  void _apply() {
    ref.read(customReportFilterProvider.notifier).state = CustomReportFilter(
      from: _from,
      to: _to,
      type: _type,
      incomeCategoryId: _incomeCategoryId,
      expenseCategoryId: _expenseCategoryId,
    );
  }

  Future<void> _showFilterSheet() async {
    List<IncomeCategory> incomeCats;
    List<ExpenseCategory> expenseCats;
    try {
      final results = await Future.wait([
        ref.read(incomeCategoryListProvider.future),
        ref.read(expenseCategoryListProvider.future),
      ]);
      incomeCats = results[0] as List<IncomeCategory>;
      expenseCats = results[1] as List<ExpenseCategory>;
    } catch (_) {
      incomeCats = const [];
      expenseCats = const [];
    }
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      barrierColor: AppColors.scrim,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXxl)),
      ),
      builder: (ctx) => _ReportFilterSheet(
        initialType: _type,
        initialIncomeCategoryId: _incomeCategoryId,
        initialExpenseCategoryId: _expenseCategoryId,
        incomeCategories: incomeCats.map((c) => MapEntry(c.id, c.name)).toList(),
        expenseCategories:
            expenseCats.map((c) => MapEntry(c.id, c.name)).toList(),
        onApply: (type, incomeCategoryId, expenseCategoryId) {
          setState(() {
            _type = type;
            _incomeCategoryId = incomeCategoryId;
            _expenseCategoryId = expenseCategoryId;
          });
          _apply();
        },
      ),
    );
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = DateTime.tryParse(isFrom ? _from : _to) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('bn'),
    );
    if (picked == null || !mounted) return;
    final str = AppDateUtils.formatDate(picked, format: AppDateUtils.dateFormat);
    setState(() {
      if (isFrom) {
        _from = str;
      } else {
        _to = str;
      }
    });
    _apply();
  }

  Future<void> _openPdf() async {
    final data = ref.read(customReportProvider).valueOrNull;
    if (data == null || data.entries.isEmpty) {
      AppSnackBar.warning(context, AppStrings.s.rptNoDataForRange);
      return;
    }
    try {
      final dateRange = _formatRange();
      final bytes = await PdfReportService().generateFilteredReport(
        data: data.entries,
        summary: data.summary,
        title: AppStrings.s.customReportTitle,
        dateRange: dateRange,
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PdfPreviewPage(
            bytes: bytes,
            fileName: PdfReportService.defaultFileName(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.error(context, AppStrings.s.setErrorPrefix(e));
    }
  }

  String _formatRange() {
    final fromD = DateTime.tryParse(_from);
    final toD = DateTime.tryParse(_to);
    if (fromD == null || toD == null) return '$_from - $_to';
    final sepx = AppStrings.s.rptRangeTo;
    return '${AppDateUtils.formatDate(fromD)} $sepx ${AppDateUtils.formatDate(toD)}';
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(customReportProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(AppStrings.s.customReportTitle, style: AppTypography.subtitle1),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            tooltip: AppStrings.s.rptPreviewPdf,
            onPressed: _openPdf,
          ),
        ],
      ),
      body: reportAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: _apply,
        ),
        data: (data) {
          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: AppSpacing.huge),
            children: [
              Padding(
                padding: AppSpacing.screenPadding,
                child: _buildFilterCard(),
              ),
              AppSpacing.boxHXS,
              if (data.entries.isEmpty)
                Padding(
                  padding: AppSpacing.screenPadding,
                  child: AppEmptyState(
                    icon: Icons.insert_chart_rounded,
                    title: AppStrings.s.rptNoDataForRange,
                    subtitle: AppStrings.s.rptSelectRange,
                  ),
                )
              else ...[
                Padding(
                  padding: AppSpacing.screenPadding,
                  child: ReportSummaryCard(
                    summary: data.summary,
                    periodText: _formatRange(),
                  ),
                ),
                AppSpacing.boxHXS,
                ...data.entries.map(_buildCard),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterCard() {
    final hasFilter =
        _type != null || _incomeCategoryId != null || _expenseCategoryId != null;
    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.divider, width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _DateTile(
              label: AppStrings.s.rptFromDate,
              date: _from,
              onTap: () => _pickDate(isFrom: true),
            ),
          ),
          AppSpacing.boxSM,
          Expanded(
            child: _DateTile(
              label: AppStrings.s.rptToDate,
              date: _to,
              onTap: () => _pickDate(isFrom: false),
            ),
          ),
          AppSpacing.boxSM,
          _FilterButton(active: hasFilter, onTap: _showFilterSheet),
        ],
      ),
    );
  }

  Widget _buildCard(TransactionEntry entry) {
    if (entry.isLoan) {
      final isRepay = entry.isLoanRepay;
      final isBorrow = entry.isLoanBorrow;
      final color = isRepay
          ? AppColors.info
          : (isBorrow ? AppColors.error : AppColors.success);
      final icon = isRepay
          ? Icons.autorenew_rounded
          : (isBorrow ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded);
      final title = isRepay
          ? AppStrings.s.txnRepay
          : (isBorrow ? AppStrings.s.loanBorrowLabel : AppStrings.s.loanLendLabel);
      return TransactionCard(
        description: entry.contactName ?? '',
        date: entry.date,
        categoryName: title,
        amount: entry.amount,
        status: entry.status,
        iconBackground: color.withValues(alpha: 0.1),
        iconColor: color,
        icon: icon,
        amountColor: color,
        compact: true,
        completedStatusText: AppStrings.s.statusCompleted,
        onTap: () {
          final contactId = entry.contactId;
          if (contactId == null) return;
          context.push('${RouteNames.loanDetail}/$contactId');
        },
      );
    }
    final isIncome = entry.isIncome;
    final color = isIncome ? AppColors.success : AppColors.error;
    return TransactionCard(
      description: entry.categoryName ?? entry.description ?? '',
      date: entry.date,
      categoryName: entry.categoryName != null ? entry.description : null,
      amount: entry.amount,
      status: entry.status,
      iconBackground: color.withValues(alpha: 0.1),
      iconColor: color,
      icon: isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
      amountColor: color,
      compact: true,
      completedStatusText: isIncome ? AppStrings.s.statusReceived : AppStrings.s.statusPaid,
      onTap: () {
        final route = isIncome
            ? '${RouteNames.incomeDetail}/${entry.id}'
            : '${RouteNames.expenseDetail}/${entry.id}';
        context.push(route);
      },
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final String date;
  final VoidCallback onTap;

  const _DateTile({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayDate = AppDateUtils.formatDate(
      DateTime.tryParse(date) ?? DateTime.now(),
    );
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: AppSpacing.paddingSm,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.primary),
            AppSpacing.boxSM,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.overline.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    displayDate,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;

  const _FilterButton({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: active ? AppColors.primary : AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            side: BorderSide(
              color: active ? AppColors.primary : AppColors.border,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(
                Icons.filter_alt_rounded,
                color: active ? AppColors.white : AppColors.textPrimary,
                size: 22,
              ),
            ),
          ),
        ),
        if (active)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.cardBackground,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ReportFilterSheet extends StatefulWidget {
  final String? initialType;
  final int? initialIncomeCategoryId;
  final int? initialExpenseCategoryId;
  final List<MapEntry<int, String>> incomeCategories;
  final List<MapEntry<int, String>> expenseCategories;
  final void Function(String?, int?, int?) onApply;

  const _ReportFilterSheet({
    required this.initialType,
    required this.initialIncomeCategoryId,
    required this.initialExpenseCategoryId,
    required this.incomeCategories,
    required this.expenseCategories,
    required this.onApply,
  });

  @override
  State<_ReportFilterSheet> createState() => _ReportFilterSheetState();
}

class _ReportFilterSheetState extends State<_ReportFilterSheet> {
  static const int _allCategories = -1;

  late String? _type = widget.initialType;
  late int? _incomeCategoryId = widget.initialIncomeCategoryId;
  late int? _expenseCategoryId = widget.initialExpenseCategoryId;

  bool get _includeIncome => _type == null || _type == 'income';
  bool get _includeExpense => _type == null || _type == 'expense';

  @override
  Widget build(BuildContext context) {
    final hasFilter =
        _type != null || _incomeCategoryId != null || _expenseCategoryId != null;
    return SafeArea(
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.s.commonFilter,
                  style: AppTypography.subtitle1.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (hasFilter)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _type = null;
                        _incomeCategoryId = null;
                        _expenseCategoryId = null;
                      });
                    },
                    child: Text(AppStrings.s.txnClearAll),
                  ),
              ],
            ),
            AppSpacing.boxMD,
            Text(
              AppStrings.s.txnType,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.boxSM,
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _buildOption(
                  label: AppStrings.s.txnAll,
                  value: null,
                  selected: _type,
                  onSelected: (v) => setState(() => _type = v),
                ),
                _buildOption(
                  label: AppStrings.s.txnIncomeTitle,
                  value: 'income',
                  selected: _type,
                  onSelected: (v) => setState(() => _type = v),
                ),
                _buildOption(
                  label: AppStrings.s.txnExpenseTitle,
                  value: 'expense',
                  selected: _type,
                  onSelected: (v) => setState(() => _type = v),
                ),
                _buildOption(
                  label: AppStrings.s.txnLoan,
                  value: 'loan',
                  selected: _type,
                  onSelected: (v) => setState(() => _type = v),
                ),
              ],
            ),
            if (_includeIncome) ...[
              AppSpacing.boxMD,
              Text(
                AppStrings.s.rptIncomeCategory,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              AppSpacing.boxSM,
              _buildCategoryDropdown(
                keyPrefix: 'inc',
                categories: widget.incomeCategories,
                selected: _incomeCategoryId,
                onChanged: (v) => setState(() => _incomeCategoryId = v),
              ),
            ],
            if (_includeExpense) ...[
              AppSpacing.boxMD,
              Text(
                AppStrings.s.rptExpenseCategory,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              AppSpacing.boxSM,
              _buildCategoryDropdown(
                keyPrefix: 'exp',
                categories: widget.expenseCategories,
                selected: _expenseCategoryId,
                onChanged: (v) => setState(() => _expenseCategoryId = v),
              ),
            ],
            AppSpacing.boxLG,
            AppButton.primary(
              AppStrings.s.rptApplyFilter,
              icon: Icons.filter_alt_rounded,
              onPressed: () {
                widget.onApply(_type, _incomeCategoryId, _expenseCategoryId);
                Navigator.pop(context);
              },
            ),
            AppSpacing.boxSM,
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown({
    required String keyPrefix,
    required List<MapEntry<int, String>> categories,
    required int? selected,
    required ValueChanged<int?> onChanged,
  }) {
    return DropdownButtonFormField<int>(
      key: ValueKey('$keyPrefix-$selected'),
      initialValue: selected ?? _allCategories,
      decoration: InputDecoration(
        labelText: AppStrings.s.rptAllCategories,
        labelStyle: AppTypography.bodyText2.copyWith(
          color: AppColors.textSecondary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        isDense: true,
      ),
      items: [
        DropdownMenuItem(value: _allCategories, child: Text(AppStrings.s.txnAll)),
        for (final c in categories)
          DropdownMenuItem(value: c.key, child: Text(c.value)),
      ],
      onChanged: (v) => onChanged(v == _allCategories ? null : v),
    );
  }

  Widget _buildOption({
    required String label,
    required String? value,
    required String? selected,
    required ValueChanged<String?> onSelected,
  }) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onSelected(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? AppColors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
