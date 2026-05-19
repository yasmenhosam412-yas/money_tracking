import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imrpo/features/expenses_tab/data/models/expense_model.dart';
import 'package:imrpo/core/l10n/l10n_entity_strings.dart';
import 'package:imrpo/core/services/home_date_filter.dart';
import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/core/theme/app_decorations.dart';
import 'package:imrpo/core/utils/app_colors.dart';
import 'package:imrpo/core/widgets/tab_refresh_overlay.dart';
import 'package:imrpo/core/utils/money_format.dart';
import 'package:imrpo/features/expenses_tab/presentation/bloc/expenses_tab_bloc.dart';
import 'package:imrpo/features/expenses_tab/presentation/widgets/add_expense_sheet.dart';
import 'package:imrpo/features/expenses_tab/presentation/widgets/expense_list_tile.dart';
import 'package:imrpo/l10n/app_localizations.dart';

class ExpensesTab extends StatefulWidget {
  const ExpensesTab({super.key});

  @override
  State<ExpensesTab> createState() => _ExpensesTabState();
}

class _ExpensesTabState extends State<ExpensesTab>
    with AutomaticKeepAliveClientMixin {
  static const _expenseColor = AppColors.expense;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    context.read<ExpensesTabBloc>().add(const LoadExpensesEvent());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-expenses',
        onPressed: _openAddSheet,
        backgroundColor: _expenseColor,
        elevation: 2,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          l10n.addExpense,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocConsumer<ExpensesTabBloc, ExpensesTabState>(
        listenWhen: (previous, current) =>
            current.status == ExpensesTabStatus.errorDelete ||
            current.status == ExpensesTabStatus.errorAll ||
            current.status == ExpensesTabStatus.errorClearAll ||
            (previous.status == ExpensesTabStatus.loadingClearAll &&
                current.status == ExpensesTabStatus.loaded),
        listener: (BuildContext context, ExpensesTabState state) {
          if (state.status == ExpensesTabStatus.errorDelete ||
              state.status == ExpensesTabStatus.errorAll ||
              state.status == ExpensesTabStatus.errorClearAll) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizeApiError(l10n, state.error)),
                backgroundColor: AppColors.error,
              ),
            );
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.clearAllExpensesSuccess),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        builder: (context, state) {
          if (state.expenses.isEmpty &&
              state.status == ExpensesTabStatus.loadingAll) {
            return const Center(
              child: CircularProgressIndicator(color: _expenseColor),
            );
          }

          if (state.expenses.isEmpty &&
              state.status == ExpensesTabStatus.errorAll) {
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
                      onPressed: () => context
                          .read<ExpensesTabBloc>()
                          .add(const LoadExpensesEvent()),
                      style: FilledButton.styleFrom(
                        backgroundColor: _expenseColor,
                      ),
                      child: Text(l10n.errorTryAgainGeneric),
                    ),
                  ],
                ),
              ),
            );
          }

          final sorted = List.of(state.expenses)
            ..sort((a, b) => b.date.compareTo(a.date));

          final isRefreshing = state.expenses.isNotEmpty &&
              state.status == ExpensesTabStatus.loadingAll;
          final isClearingAll =
              state.status == ExpensesTabStatus.loadingClearAll;

          return ListenableBuilder(
            listenable: getIt<HomeDateFilter>(),
            builder: (context, _) {
              final dateFilter = getIt<HomeDateFilter>();
              final filtered = sorted
                  .where((expense) => dateFilter.matches(expense.date))
                  .toList();
              final periodTotal = filtered.fold<double>(
                0,
                (sum, expense) => sum + expense.amount,
              );

              return Stack(
            children: [
              TabRefreshOverlay(
            isRefreshing: isRefreshing,
            indicatorColor: _expenseColor,
            child: RefreshIndicator(
              color: _expenseColor,
              onRefresh: () async {
                context.read<ExpensesTabBloc>().add(const LoadExpensesEvent());
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

                  /// HEADER
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.recentExpenses,
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
                                foregroundColor: AppColors.expense,
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                              child: Text(l10n.clearAllExpenses),
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
                          : _FilteredEmptyState(
                              message: l10n.homeFilterNoEntries,
                            ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final expense = filtered[index];

                          return ExpenseListTile(
                            expense: expense,
                            onTap: () => _openEditSheet(expense),
                            onDelete: () {
                              context.read<ExpensesTabBloc>().add(
                                DeleteExpenseEvent(expense.id),
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
                      child: CircularProgressIndicator(color: _expenseColor),
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
        title: Text(l10n.clearAllExpensesConfirmTitle),
        content: Text(l10n.clearAllExpensesConfirmMessage(count)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: _expenseColor),
            child: Text(l10n.clearAllExpenses),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    context.read<ExpensesTabBloc>().add(const ClearAllExpensesEvent());
  }

  void _openAddSheet() => _showExpenseSheet(const AddExpenseSheet());

  void _openEditSheet(ExpenseModel expense) =>
      _showExpenseSheet(AddExpenseSheet(expense: expense));

  Future<void> _showExpenseSheet(Widget sheet) async {
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
          value: context.read<ExpensesTabBloc>(),
          child: sheet,
        ),
      ),
    );

    if (!mounted || result == null) return;

    final message = switch (result) {
      'added' => l10n.expenseAddedSuccess,
      'updated' => l10n.expenseUpdatedSuccess,
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
        AppColors.expenseDark,
        AppColors.expense,
        AppColors.primary,
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
                  Icons.trending_down_rounded,
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
            l10n.totalExpenses,
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

  static const _expenseColor = AppColors.expense;

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
                color: AppColors.expenseLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 40,
                color: _expenseColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.noExpensesTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noExpensesSubtitle,
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
              label: Text(l10n.addExpense),
              style: TextButton.styleFrom(foregroundColor: _expenseColor),
            ),
          ],
        ),
      ),
    );
  }
}
