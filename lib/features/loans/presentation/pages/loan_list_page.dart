import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/router/route_names.dart';
import 'package:nexora_khata/core/widgets/app_empty_state.dart';
import 'package:nexora_khata/core/widgets/app_error_widget.dart';
import 'package:nexora_khata/core/widgets/app_loading.dart';
import 'package:nexora_khata/features/loans/presentation/models/loan_summary.dart';
import 'package:nexora_khata/features/loans/presentation/providers/loan_provider.dart';
import 'package:nexora_khata/features/loans/presentation/widgets/loan_contact_card.dart';
import 'package:nexora_khata/features/loans/presentation/widgets/loan_summary_header.dart';

class LoanListPage extends ConsumerWidget {
  const LoanListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(loanDashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text('ঋণ', style: AppTypography.subtitle1),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(loanDashboardProvider),
            tooltip: 'রিফ্রেশ',
          ),
        ],
      ),
      body: dashboardAsync.when(
        loading: () => const AppLoading(message: 'ঋণের হিসাব লোড হচ্ছে...'),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(loanDashboardProvider),
        ),
        data: (dashboard) => _LoanContent(dashboard: dashboard),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await context.push<bool>(RouteNames.loanContactAdd);
          if (result == true) {
            ref.invalidate(loanDashboardProvider);
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('নতুন হিসাব'),
      ),
    );
  }
}

class _LoanContent extends ConsumerWidget {
  final LoanDashboard dashboard;

  const _LoanContent({required this.dashboard});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (dashboard.contacts.isEmpty) {
      return AppEmptyState(
        icon: Icons.currency_exchange_rounded,
        title: 'কোনো হিসাব নেই',
        subtitle: 'বন্ধু বা পরিচিতজনের কাছ থেকে টাকা নেওয়া বা দেওয়ার হিসাব রাখতে নতুন হিসাব যোগ করুন',
        actionLabel: 'নতুন হিসাব',
        onAction: () => context.push(RouteNames.loanContactAdd),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(loanDashboardProvider);
      },
      child: ListView(
        padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.huge),
        children: [
          LoanSummaryHeader(dashboard: dashboard),
          AppSpacing.boxHLG,
          Padding(
            padding: AppSpacing.paddingHSm,
            child: Text(
              'সব হিসাব',
              style: AppTypography.subtitle2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          AppSpacing.boxHSM,
          for (final summary in dashboard.contacts)
            LoanContactCard(
              summary: summary,
              onTap: () => context.push(
                '${RouteNames.loanDetail}/${summary.contact.id}',
              ),
            ),
        ],
      ),
    );
  }
}
