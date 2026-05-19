part of 'balance_tab_bloc.dart';

enum BalanceTabStatus { initial, loading, loaded, error }

abstract class BalanceTabState extends Equatable {
  const BalanceTabState();

  @override
  List<Object?> get props => [];
}

class BalanceTabInitial extends BalanceTabState {
  const BalanceTabInitial();
}

class BalanceTabLoaded extends BalanceTabState {
  final double monthlyIncome;
  final double monthlyExpenses;
  final List<BalanceActivity> activities;
  final BalanceTabStatus status;
  final String error;

  const BalanceTabLoaded({
    required this.monthlyIncome,
    required this.monthlyExpenses,
    required this.activities,
    this.status = BalanceTabStatus.loaded,
    this.error = '',
  });

  double get netBalance => monthlyIncome - monthlyExpenses;

  double get savingsRate {
    if (monthlyIncome <= 0) return 0;
    return ((monthlyIncome - monthlyExpenses) / monthlyIncome).clamp(0.0, 1.0);
  }

  bool get hasData => activities.isNotEmpty;

  BalanceTabLoaded copyWith({
    double? monthlyIncome,
    double? monthlyExpenses,
    List<BalanceActivity>? activities,
    BalanceTabStatus? status,
    String? error,
  }) {
    return BalanceTabLoaded(
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyExpenses: monthlyExpenses ?? this.monthlyExpenses,
      activities: activities ?? this.activities,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        monthlyIncome,
        monthlyExpenses,
        activities,
        status,
        error,
      ];
}
