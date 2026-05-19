import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imrpo/core/services/home_date_filter.dart';
import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:imrpo/features/balance_tab/presentation/bloc/balance_tab_bloc.dart';
import 'package:imrpo/features/expenses_tab/presentation/bloc/expenses_tab_bloc.dart';
import 'package:imrpo/features/incomes_tab/presentation/bloc/incomes_tab_bloc.dart';
import 'package:imrpo/features/home/presentation/bloc/home_bloc.dart';
import 'package:imrpo/features/plans_tab/presentation/bloc/plans_tab_bloc.dart';

/// Clears cached user-specific state when signing out or switching accounts.
class UserSession {
  UserSession._();

  static void clearAll(BuildContext context) {
    getIt<HomeDateFilter>().reset();
    context.read<HomeBloc>().add(const ClearUserProfileEvent());
    context.read<IncomesTabBloc>().add(const ResetIncomesTabEvent());
    context.read<ExpensesTabBloc>().add(const ResetExpensesTabEvent());
    context.read<BalanceTabBloc>().add(const ResetBalanceTabEvent());
    context.read<PlansTabBloc>().add(const ResetPlansTabEvent());
    context.read<AuthBloc>().add(const ResetAuthEvent());
  }

  static void loadAll(BuildContext context) {
    context.read<HomeBloc>().add(const LoadUserProfileEvent());
    context.read<IncomesTabBloc>().add(const LoadIncomesEvent());
    context.read<ExpensesTabBloc>().add(const LoadExpensesEvent());
    final dateFilter = getIt<HomeDateFilter>();
    context.read<BalanceTabBloc>().add(
          LoadBalanceEvent(
            reference: dateFilter.date,
            filterByDay: dateFilter.isDayMode,
          ),
        );
    context.read<PlansTabBloc>().add(const LoadPlansEvent());
  }
}
