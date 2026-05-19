import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:imrpo/core/services/home_date_filter.dart';
import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/core/utils/app_colors.dart';
import 'package:imrpo/core/utils/money_format.dart';
import 'package:imrpo/core/widgets/tab_refresh_overlay.dart';
import 'package:imrpo/features/balance_tab/presentation/bloc/balance_tab_bloc.dart';
import 'package:imrpo/features/balance_tab/presentation/widgets/balance_activity_tile.dart';
import 'package:imrpo/features/balance_tab/presentation/widgets/balance_breakdown_chart.dart';
import 'package:imrpo/core/l10n/l10n_entity_strings.dart';
import 'package:imrpo/features/balance_tab/presentation/widgets/balance_stat_tile.dart';
import 'package:imrpo/l10n/app_localizations.dart';

class BalanceTab extends StatefulWidget {
  const BalanceTab({super.key});

  @override
  State<BalanceTab> createState() => _BalanceTabState();
}

class _BalanceTabState extends State<BalanceTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final HomeDateFilter _dateFilter;

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
    context.read<BalanceTabBloc>().add(
          LoadBalanceEvent(
            reference: _dateFilter.date,
            filterByDay: _dateFilter.isDayMode,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      body: BlocConsumer<BalanceTabBloc, BalanceTabState>(
        listener: (context, state) {
          if (state is BalanceTabLoaded &&
              state.status == BalanceTabStatus.error &&
              state.error.isNotEmpty) {
            final l10n = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizeApiError(l10n, state.error)),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is! BalanceTabLoaded) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.balance),
            );
          }

          final isRefreshing =
              state.status == BalanceTabStatus.loading && state.hasData;

          if (!state.hasData && state.status == BalanceTabStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.balance),
            );
          }

          if (!state.hasData && state.status == BalanceTabStatus.error) {
            final l10n = AppLocalizations.of(context)!;
            return Center(
              child: Padding(
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

          final l10n = AppLocalizations.of(context)!;

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
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Row(
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
                          l10n.itemsCount(sorted.length),
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textColor.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          BalanceActivityTile(activity: sorted[index]),
                      childCount: sorted.length,
                    ),
                  ),
                ),
              ],
            ),
            ),
          );
        },
      ),
    );
  }
}

class _NetBalanceCard extends StatelessWidget {
  final double balance;
  final double savingsRate;

  const _NetBalanceCard({
    required this.balance,
    required this.savingsRate,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = balance >= 0;
    final month = _currentMonthLabel(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPositive
              ? [AppColors.balanceDark, AppColors.balance]
              : [AppColors.expenseDark, AppColors.expense],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isPositive ? AppColors.balance : AppColors.expenseDark)
                .withValues(alpha: 0.35),
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
            l10n.balanceSavedThisMonth((savingsRate * 100).round()),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
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
