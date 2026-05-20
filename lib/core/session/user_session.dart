import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imrpo/core/helpers/supabase_auth_helper.dart';
import 'package:imrpo/core/services/app_lock_service.dart';
import 'package:imrpo/core/services/home_date_filter.dart';
import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:imrpo/features/balance_tab/presentation/bloc/balance_tab_bloc.dart';
import 'package:imrpo/features/budgets/domain/entities/budget_period.dart';
import 'package:imrpo/features/budgets/presentation/bloc/budgets_bloc.dart';
import 'package:imrpo/features/expenses_tab/presentation/bloc/expenses_tab_bloc.dart';
import 'package:imrpo/features/incomes_tab/presentation/bloc/incomes_tab_bloc.dart';
import 'package:imrpo/features/home/presentation/bloc/home_bloc.dart';
import 'package:imrpo/features/plans_tab/presentation/bloc/plans_tab_bloc.dart';

/// Clears cached user-specific state when signing out or switching accounts.
class UserSession {
  UserSession._();

  static void clearAll(BuildContext context) {
    getIt<AppLockService>().onLoggedOut();
    getIt<HomeDateFilter>().reset(notify: false);
    context.read<HomeBloc>().add(const ClearUserProfileEvent());
    context.read<IncomesTabBloc>().add(const ResetIncomesTabEvent());
    context.read<ExpensesTabBloc>().add(const ResetExpensesTabEvent());
    context.read<BudgetsBloc>().add(const ResetBudgetsEvent());
    context.read<BalanceTabBloc>().add(const ResetBalanceTabEvent());
    context.read<PlansTabBloc>().add(const ResetPlansTabEvent());
    context.read<AuthBloc>().add(const ResetAuthEvent());
  }

  static void loadAll(BuildContext context) {
    context.read<HomeBloc>().add(const LoadUserProfileEvent());
    context.read<IncomesTabBloc>().add(const LoadIncomesEvent());
    context.read<ExpensesTabBloc>().add(const LoadExpensesEvent());
    final dateFilter = getIt<HomeDateFilter>();
    final budgetPeriod = BudgetPeriod.fromDateFilter(dateFilter);
    context.read<BudgetsBloc>().add(
          LoadBudgetsEvent(
            year: budgetPeriod.year,
            month: budgetPeriod.month,
          ),
        );
    context.read<BalanceTabBloc>().add(
          LoadBalanceEvent(
            reference: dateFilter.date,
            filterByDay: dateFilter.isDayMode,
            includeAllDates: dateFilter.isAllMode,
          ),
        );
    context.read<PlansTabBloc>().add(const LoadPlansEvent());
  }

  /// Reloads transaction tabs after background SMS auto-import.
  static void refreshAfterAutoImport(BuildContext context) {
    if (!SupabaseAuthHelper.isSignedIn) return;
    context.read<IncomesTabBloc>().add(const LoadIncomesEvent(force: true));
    context.read<ExpensesTabBloc>().add(const LoadExpensesEvent(force: true));
    final dateFilter = getIt<HomeDateFilter>();
    context.read<BalanceTabBloc>().add(
          LoadBalanceEvent(
            reference: dateFilter.date,
            filterByDay: dateFilter.isDayMode,
            includeAllDates: dateFilter.isAllMode,
          ),
        );
  }

  /// Reloads all tabs after the display currency changes.
  static void refreshForDisplayCurrency(BuildContext context) {
    if (!SupabaseAuthHelper.isSignedIn) return;
    context.read<IncomesTabBloc>().add(const LoadIncomesEvent(force: true));
    context.read<ExpensesTabBloc>().add(const LoadExpensesEvent(force: true));
    final dateFilter = getIt<HomeDateFilter>();
    final budgetPeriod = BudgetPeriod.fromDateFilter(dateFilter);
    context.read<BudgetsBloc>().add(
          LoadBudgetsEvent(
            year: budgetPeriod.year,
            month: budgetPeriod.month,
            force: true,
          ),
        );
    context.read<BalanceTabBloc>().add(
          LoadBalanceEvent(
            reference: dateFilter.date,
            filterByDay: dateFilter.isDayMode,
            includeAllDates: dateFilter.isAllMode,
          ),
        );
    context.read<PlansTabBloc>().add(const LoadPlansEvent(force: true));
  }
}
