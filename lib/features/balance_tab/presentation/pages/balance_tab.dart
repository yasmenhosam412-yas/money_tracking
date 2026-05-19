import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imrpo/core/helpers/supabase_auth_helper.dart';
import 'package:imrpo/core/services/home_date_filter.dart';
import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/core/utils/app_colors.dart';
import 'package:imrpo/core/utils/money_format.dart';
import 'package:imrpo/core/widgets/tab_centered_scroll.dart';
import 'package:imrpo/core/widgets/tab_refresh_overlay.dart';
import 'package:imrpo/features/balance_tab/presentation/bloc/balance_tab_bloc.dart';
import 'package:imrpo/features/balance_tab/domain/entities/balance_activity.dart';
import 'package:imrpo/features/balance_tab/presentation/widgets/balance_activity_filter_bar.dart';
import 'package:imrpo/features/balance_tab/presentation/widgets/balance_activity_tile.dart';
import 'package:imrpo/features/balance_tab/presentation/widgets/balance_breakdown_chart.dart';
import 'package:imrpo/features/balance_tab/presentation/widgets/balance_category_breakdown.dart';
import 'package:imrpo/core/l10n/l10n_entity_strings.dart';
import 'package:imrpo/features/balance_tab/presentation/widgets/balance_stat_tile.dart';
import 'package:imrpo/features/expenses_tab/presentation/bloc/expenses_tab_bloc.dart';
import 'package:imrpo/features/plans_tab/presentation/bloc/plans_tab_bloc.dart';
import 'package:imrpo/features/plans_tab/presentation/widgets/add_to_plan_from_balance_sheet.dart';
import 'package:imrpo/l10n/app_localizations.dart';

class BalanceTab extends StatefulWidget {
  const BalanceTab({super.key});

  @override
  State<BalanceTab> createState() => _BalanceTabState();
}

class _BalanceTabState extends State<BalanceTab>
    with AutomaticKeepAliveClientMixin {
  BalanceActivityFilter _activityFilter = BalanceActivityFilter.all;
  String? _selectedIncomeSource;
  String? _selectedExpenseCategory;

  @override
  bool get wantKeepAlive => true;

  late final HomeDateFilter _dateFilter;

  static String _categoryKey(BalanceActivity activity) {
    final category = activity.category.trim();
    return category.isEmpty ? 'Other' : category;
  }

  static Map<String, double> _totalsByCategory(
    List<BalanceActivity> activities,
    BalanceActivityType type,
  ) {
    final totals = <String, double>{};
    for (final activity in activities.where((a) => a.type == type)) {
      final key = _categoryKey(activity);
      totals[key] = (totals[key] ?? 0) + activity.amount;
    }
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(entries);
  }

  List<BalanceActivity> _filterActivities(List<BalanceActivity> activities) {
    return activities.where((activity) {
      if (_activityFilter == BalanceActivityFilter.income &&
          activity.type != BalanceActivityType.income) {
        return false;
      }
      if (_activityFilter == BalanceActivityFilter.expense &&
          activity.type != BalanceActivityType.expense) {
        return false;
      }
      if (_selectedIncomeSource != null &&
          activity.type == BalanceActivityType.income) {
        return _categoryKey(activity) == _selectedIncomeSource;
      }
      if (_selectedExpenseCategory != null &&
          activity.type == BalanceActivityType.expense) {
        return _categoryKey(activity) == _selectedExpenseCategory;
      }
      if (_selectedIncomeSource != null &&
          activity.type == BalanceActivityType.expense) {
        return false;
      }
      if (_selectedExpenseCategory != null &&
          activity.type == BalanceActivityType.income) {
        return false;
      }
      return true;
    }).toList();
  }

  void _clearCategoryFilters() {
    setState(() {
      _selectedIncomeSource = null;
      _selectedExpenseCategory = null;
    });
  }

  void _onIncomeSourceSelected(String source) {
    setState(() {
      _activityFilter = BalanceActivityFilter.income;
      _selectedExpenseCategory = null;
      _selectedIncomeSource =
          _selectedIncomeSource == source ? null : source;
    });
  }

  void _onExpenseCategorySelected(String category) {
    setState(() {
      _activityFilter = BalanceActivityFilter.expense;
      _selectedIncomeSource = null;
      _selectedExpenseCategory =
          _selectedExpenseCategory == category ? null : category;
    });
  }

  void _onActivityFilterChanged(BalanceActivityFilter filter) {
    setState(() {
      _activityFilter = filter;
      if (filter == BalanceActivityFilter.all) {
        _selectedIncomeSource = null;
        _selectedExpenseCategory = null;
      } else if (filter == BalanceActivityFilter.income) {
        _selectedExpenseCategory = null;
      } else {
        _selectedIncomeSource = null;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _dateFilter = getIt<HomeDateFilter>();
    _dateFilter.addListener(_onDateFilterChanged);
    _loadBalance();
  }

  @override
  void dispose() {
    _dateFilter.removeListener(_onDateFilterChanged);
    super.dispose();
  }

  void _onDateFilterChanged() {
    if (mounted) _loadBalance();
  }

  void _loadBalance() {
    if (!SupabaseAuthHelper.isSignedIn) return;
    context.read<BalanceTabBloc>().add(
          LoadBalanceEvent(
            reference: _dateFilter.date,
            filterByDay: _dateFilter.isDayMode,
            includeAllDates: _dateFilter.isAllMode,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocConsumer<BalanceTabBloc, BalanceTabState>(
        listener: (context, state) {
          if (state is BalanceTabLoaded &&
              state.status == BalanceTabStatus.error &&
              state.error.isNotEmpty) {
            final l10n = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizeApiError(l10n, state.error)),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is! BalanceTabLoaded) {
            return tabCenteredScroll(
              const CircularProgressIndicator(color: AppColors.balance),
            );
          }

          final isRefreshing =
              state.status == BalanceTabStatus.loading && state.hasData;

          if (!state.hasData && state.status == BalanceTabStatus.loading) {
            return tabCenteredScroll(
              const CircularProgressIndicator(color: AppColors.balance),
            );
          }

          if (!state.hasData && state.status == BalanceTabStatus.error) {
            final l10n = AppLocalizations.of(context)!;
            return tabCenteredScroll(
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: AppColors.textColor.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      localizeApiError(l10n, state.error),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textColor.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _loadBalance,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.balance,
                      ),
                      child: Text(l10n.errorTryAgainGeneric),
                    ),
                  ],
                ),
              ),
            );
          }

          final sorted = List.of(state.activities)
            ..sort((a, b) => b.date.compareTo(a.date));
          final incomeBySource =
              _totalsByCategory(sorted, BalanceActivityType.income);
          final expenseByCategory =
              _totalsByCategory(sorted, BalanceActivityType.expense);
          final filteredActivities = _filterActivities(sorted);
          final incomeSources = incomeBySource.keys.toList()..sort();
          final expenseCategories = expenseByCategory.keys.toList()..sort();

          final l10n = AppLocalizations.of(context)!;

          return ListenableBuilder(
            listenable: _dateFilter,
            builder: (context, _) {
              final periodLabel = _dateFilter.summaryPeriodLabel(context);
              final activeIncomeSource =
                  _selectedIncomeSource != null &&
                      incomeSources.contains(_selectedIncomeSource)
                  ? _selectedIncomeSource
                  : null;
              final activeExpenseCategory =
                  _selectedExpenseCategory != null &&
                      expenseCategories.contains(_selectedExpenseCategory)
                  ? _selectedExpenseCategory
                  : null;

              return TabRefreshOverlay(
            isRefreshing: isRefreshing,
            indicatorColor: AppColors.balance,
            child: RefreshIndicator(
            color: AppColors.balance,
            onRefresh: () async {
              _loadBalance();
              await Future.delayed(const Duration(milliseconds: 350));
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: _NetBalanceCard(
                      balance: state.netBalance,
                      savingsRate: state.savingsRate,
                      periodLabel: periodLabel,
                      onAddToPlan: state.netBalance > 0
                          ? () => _openAddToPlanSheet(
                                context,
                                state.netBalance,
                              )
                          : null,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                    child: Row(
                      children: [
                        BalanceStatTile(
                          label: l10n.balanceStatIncome,
                          amount: state.monthlyIncome,
                          icon: Icons.trending_up_rounded,
                          color: AppColors.income,
                        ),
                        const SizedBox(width: 12),
                        BalanceStatTile(
                          label: l10n.balanceStatExpense,
                          amount: state.monthlyExpenses,
                          icon: Icons.trending_down_rounded,
                          color: AppColors.expense,
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                    child: BalanceBreakdownChart(
                      income: state.monthlyIncome,
                      expenses: state.monthlyExpenses,
                    ),
                  ),
                ),
                if (incomeBySource.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: BalanceCategoryBreakdown(
                        title: l10n.incomeBySource,
                        totals: incomeBySource,
                        accentColor: AppColors.income,
                        accentLight: AppColors.incomeLight,
                        accentDark: AppColors.incomeDark,
                        selectedKey: activeIncomeSource,
                        onSelected: _onIncomeSourceSelected,
                        localizeKey: localizeIncomeCategory,
                      ),
                    ),
                  ),
                if (expenseByCategory.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: BalanceCategoryBreakdown(
                        title: l10n.expenseByCategory,
                        totals: expenseByCategory,
                        accentColor: AppColors.expense,
                        accentLight: AppColors.expenseLight,
                        accentDark: AppColors.expenseDark,
                        selectedKey: activeExpenseCategory,
                        onSelected: _onExpenseCategorySelected,
                        localizeKey: localizeExpenseCategory,
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.balanceRecentActivity,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            Text(
                              l10n.itemsCount(filteredActivities.length),
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textColor
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        BalanceActivityFilterBar(
                          selected: _activityFilter,
                          onTypeChanged: _onActivityFilterChanged,
                        ),
                        if (_activityFilter == BalanceActivityFilter.income &&
                            incomeSources.length > 1) ...[
                          const SizedBox(height: 12),
                          BalanceCategoryFilterChips(
                            categories: incomeSources,
                            selectedCategory: activeIncomeSource,
                            accentColor: AppColors.income,
                            allLabel: l10n.incomeFilterAllSources,
                            onSelected: (source) {
                              setState(() => _selectedIncomeSource = source);
                            },
                            localizeKey: localizeIncomeCategory,
                          ),
                        ],
                        if (_activityFilter == BalanceActivityFilter.expense &&
                            expenseCategories.length > 1) ...[
                          const SizedBox(height: 12),
                          BalanceCategoryFilterChips(
                            categories: expenseCategories,
                            selectedCategory: activeExpenseCategory,
                            accentColor: AppColors.expense,
                            allLabel: l10n.expenseFilterAllCategories,
                            onSelected: (category) {
                              setState(
                                () => _selectedExpenseCategory = category,
                              );
                            },
                            localizeKey: localizeExpenseCategory,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (filteredActivities.isEmpty && sorted.isNotEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.filter_alt_off_outlined,
                              size: 48,
                              color: AppColors.textColor.withValues(
                                alpha: 0.35,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.balanceNoFilteredActivity,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.textColor.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _activityFilter = BalanceActivityFilter.all;
                                  _clearCategoryFilters();
                                });
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.balance,
                              ),
                              child: Text(l10n.balanceFilterAll),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => BalanceActivityTile(
                          activity: filteredActivities[index],
                        ),
                        childCount: filteredActivities.length,
                      ),
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

  Future<void> _openAddToPlanSheet(
    BuildContext context,
    double availableBalance,
  ) async {
    context.read<PlansTabBloc>().add(const LoadPlansEvent());
    final added = await showModalBottomSheet<bool>(
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
          value: context.read<PlansTabBloc>(),
          child: AddToPlanFromBalanceSheet(
            availableBalanceBase: availableBalance,
          ),
        ),
      ),
    );

    if (!context.mounted) return;
    if (added == true) {
      _loadBalance();
      context.read<ExpensesTabBloc>().add(const LoadExpensesEvent());
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.balanceAddToPlanSuccess),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _NetBalanceCard extends StatelessWidget {
  final double balance;
  final double savingsRate;
  final String periodLabel;
  final VoidCallback? onAddToPlan;

  const _NetBalanceCard({
    required this.balance,
    required this.savingsRate,
    required this.periodLabel,
    this.onAddToPlan,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = balance >= 0;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPositive
              ? [AppColors.balanceDark, AppColors.balance, AppColors.secondary]
              : [AppColors.expenseDark, AppColors.expense],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.stroke.withValues(alpha: 0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isPositive ? AppColors.balance : AppColors.expenseDark)
                .withValues(alpha: 0.25),
            blurRadius: 0,
            offset: const Offset(0, 4),
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
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            l10n.balanceNetBalance,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${isPositive ? '' : '-'}${Money.format(balance.abs())}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: savingsRate,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.balanceSavedPercent((savingsRate * 100).round()),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
          if (onAddToPlan != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAddToPlan,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.savings_outlined, size: 20),
                label: Text(
                  l10n.balanceAddToPlan,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
