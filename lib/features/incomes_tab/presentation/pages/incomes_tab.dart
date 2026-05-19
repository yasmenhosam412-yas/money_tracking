import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imrpo/core/l10n/l10n_entity_strings.dart';
import 'package:imrpo/core/services/home_date_filter.dart';
import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/core/theme/app_decorations.dart';
import 'package:imrpo/core/utils/app_colors.dart';
import 'package:imrpo/core/widgets/tab_refresh_overlay.dart';
import 'package:imrpo/core/utils/money_format.dart';
import 'package:imrpo/features/incomes_tab/domain/entities/income.dart';
import 'package:imrpo/features/incomes_tab/presentation/bloc/incomes_tab_bloc.dart';
import 'package:imrpo/features/incomes_tab/presentation/widgets/add_income_sheet.dart';
import 'package:imrpo/features/incomes_tab/presentation/widgets/income_list_tile.dart';
import 'package:imrpo/l10n/app_localizations.dart';

class IncomesTab extends StatefulWidget {
  const IncomesTab({super.key});

  @override
  State<IncomesTab> createState() => _IncomesTabState();
}

class _IncomesTabState extends State<IncomesTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    context.read<IncomesTabBloc>().add(const LoadIncomesEvent());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-incomes',
        onPressed: _openAddSheet,
        backgroundColor: AppColors.income,
        elevation: 2,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          l10n.addIncome,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocConsumer<IncomesTabBloc, IncomesTabState>(
        listenWhen: (previous, current) =>
            current.status == IncomesTabStatus.errorDelete ||
            current.status == IncomesTabStatus.errorAll ||
            current.status == IncomesTabStatus.errorClearAll ||
            (previous.status == IncomesTabStatus.loadingClearAll &&
                current.status == IncomesTabStatus.loaded),
        listener: (context, state) {
          if (state.status == IncomesTabStatus.errorDelete ||
              state.status == IncomesTabStatus.errorAll ||
              state.status == IncomesTabStatus.errorClearAll) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizeApiError(l10n, state.message)),
                backgroundColor: AppColors.error,
              ),
            );
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.clearAllIncomesSuccess),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        builder: (context, state) {
          if (state.incomes.isEmpty &&
              state.status == IncomesTabStatus.loadingAll) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.income),
            );
          }

          final sorted = [...state.incomes]
            ..sort((a, b) => b.date.compareTo(a.date));

          final isRefreshing = state.incomes.isNotEmpty &&
              state.status == IncomesTabStatus.loadingAll;
          final isClearingAll =
              state.status == IncomesTabStatus.loadingClearAll;

          return ListenableBuilder(
            listenable: getIt<HomeDateFilter>(),
            builder: (context, _) {
              final dateFilter = getIt<HomeDateFilter>();
              final filtered = sorted
                  .where((income) => dateFilter.matches(income.date))
                  .toList();
              final periodTotal = filtered.fold<double>(
                0,
                (sum, income) => sum + income.amount,
              );

              return Stack(
            children: [
              TabRefreshOverlay(
            isRefreshing: isRefreshing,
            indicatorColor: AppColors.income,
            child: RefreshIndicator(
              color: AppColors.income,
              onRefresh: () async {
                context.read<IncomesTabBloc>().add(const LoadIncomesEvent());
                await Future.delayed(const Duration(milliseconds: 350));
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: _SummaryCard(
                    total: periodTotal,
                    periodLabel: dateFilter.summaryPeriodLabel(context),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.recentIncomes,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                      ),
                      if (sorted.isNotEmpty) ...[
                        TextButton(
                          onPressed: isClearingAll
                              ? null
                              : () => _confirmClearAll(sorted.length),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.income,
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: Text(l10n.clearAllIncomes),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        l10n.listEntryCount(filtered.length),
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: sorted.isEmpty
                      ? _EmptyState(onAdd: _openAddSheet)
                      : _FilteredEmptyState(message: l10n.homeFilterNoEntries),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final income = filtered[index];

                      return IncomeListTile(
                        income: income,
                        onTap: () => _openEditSheet(income),
                        onDelete: () {
                          context.read<IncomesTabBloc>().add(
                            DeleteIncomeEvent(income.id),
                          );
                        },
                      );
                    }, childCount: filtered.length),
                  ),
                ),
              ],
            ),
            ),
          ),
              if (isClearingAll)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x33000000),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.income),
                    ),
                  ),
                ),
            ],
          );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmClearAll(int count) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.clearAllIncomesConfirmTitle),
        content: Text(l10n.clearAllIncomesConfirmMessage(count)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.income),
            child: Text(l10n.clearAllIncomes),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    context.read<IncomesTabBloc>().add(const ClearAllIncomesEvent());
  }

  void _openAddSheet() => _showIncomeSheet(const AddIncomeSheet());

  void _openEditSheet(Income income) =>
      _showIncomeSheet(AddIncomeSheet(income: income));

  Future<void> _showIncomeSheet(Widget sheet) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => AnimatedPadding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: BlocProvider.value(
          value: context.read<IncomesTabBloc>(),
          child: sheet,
        ),
      ),
    );

    if (!mounted || result == null) return;

    final message = switch (result) {
      'added' => l10n.incomeAddedSuccess,
      'updated' => l10n.incomeUpdatedSuccess,
      _ => null,
    };
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final double total;
  final String periodLabel;

  const _SummaryCard({
    required this.total,
    required this.periodLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AppDecorations.summaryCard([
        AppColors.incomeDark,
        AppColors.income,
        AppColors.incomeBill,
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  periodLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            l10n.totalIncome,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            Money.format(total),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilteredEmptyState extends StatelessWidget {
  final String message;

  const _FilteredEmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_alt_off_outlined,
              size: 48,
              color: AppColors.textColor.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: AppColors.incomeLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 40,
                color: AppColors.income,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.noIncomesTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noIncomesSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textColor.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.addIncome),
              style: TextButton.styleFrom(foregroundColor: AppColors.income),
            ),
          ],
        ),
      ),
    );
  }
}
