import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:imrpo/core/l10n/l10n_entity_strings.dart';
import 'package:imrpo/core/services/home_date_filter.dart';
import 'package:imrpo/core/services/service_locator.dart';
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
        listener: (context, state) {
          if (state.status == IncomesTabStatus.errorDelete ||
              state.status == IncomesTabStatus.errorAll) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizeApiError(l10n, state.message)),
                backgroundColor: Colors.red,
              ),
            );
          }
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

              return TabRefreshOverlay(
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
                  child: _SummaryCard(total: periodTotal),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.recentIncomes,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
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
          );
            },
          );
        },
      ),
    );
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

  const _SummaryCard({required this.total});

  @override
  Widget build(BuildContext context) {
    final month = _currentMonthLabel(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.incomeDark, AppColors.income],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.income.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
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
                  month,
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

  String _currentMonthLabel(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.MMMM(locale).format(DateTime.now());
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
