import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/router/route_names.dart';
import 'package:nexora_khata/core/services/app_strings.dart';
import 'package:nexora_khata/core/widgets/app_empty_state.dart';
import 'package:nexora_khata/core/widgets/app_error_widget.dart';
import 'package:nexora_khata/core/widgets/app_loading.dart';
import 'package:nexora_khata/core/widgets/app_search_field.dart';
import 'package:nexora_khata/features/loans/presentation/models/loan_summary.dart';
import 'package:nexora_khata/features/loans/presentation/providers/loan_provider.dart';
import 'package:nexora_khata/features/loans/presentation/widgets/loan_contact_card.dart';

class LoanListPage extends ConsumerWidget {
  const LoanListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(loanDashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(AppStrings.s.loanTitle, style: AppTypography.subtitle1),
        centerTitle: true,
      ),
      body: dashboardAsync.when(
        loading: () => AppLoading(message: AppStrings.s.loanLoading),
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
        label: Text(AppStrings.s.loanNew),
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
        title: AppStrings.s.loanEmpty,
        subtitle: AppStrings.s.loanEmptySubtitle,
        actionLabel: AppStrings.s.loanNew,
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
          Padding(
            padding: AppSpacing.paddingHSm,
            child: AppSearchField(
              hintText: AppStrings.s.loanSearch,
              onChanged: (value) =>
                  ref.read(loanSearchProvider.notifier).state = value,
            ),
          ),
          AppSpacing.boxHSM,
          ..._buildContactCards(context, ref),
        ],
      ),
    );
  }

  List<Widget> _buildContactCards(BuildContext context, WidgetRef ref) {
    final query = ref.watch(loanSearchProvider).trim().toLowerCase();
    final filtered = query.isEmpty
        ? dashboard.contacts
        : dashboard.contacts.where((s) {
            final name = s.contact.name.toLowerCase();
            final phone = (s.contact.phone ?? '').toLowerCase();
            return name.contains(query) || phone.contains(query);
          }).toList();

    if (filtered.isEmpty) {
      return [
        AppSpacing.boxHLG,
        AppEmptyState(
          icon: Icons.search_off_rounded,
          title: AppStrings.s.loanEmpty,
          subtitle: AppStrings.s.loanSearchEmpty,
        ),
      ];
    }

    return filtered.map((summary) {
      return LoanContactCard(
        summary: summary,
        onTap: () => context.push(
          '${RouteNames.loanDetail}/${summary.contact.id}',
        ),
      );
    }).toList();
  }
}
