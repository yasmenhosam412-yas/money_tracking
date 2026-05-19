part of 'budgets_bloc.dart';

enum BudgetsStatus { initial, loading, loaded, saving, error }

class BudgetsState extends Equatable {
  final BudgetsStatus status;
  final List<Budget> budgets;
  final int? year;
  final int? month;
  final String error;

  const BudgetsState({
    this.status = BudgetsStatus.initial,
    this.budgets = const [],
    this.year,
    this.month,
    this.error = '',
  });

  bool get hasBudgets => budgets.isNotEmpty;

  BudgetsState copyWith({
    BudgetsStatus? status,
    List<Budget>? budgets,
    int? year,
    int? month,
    String? error,
    bool clearError = false,
  }) {
    return BudgetsState(
      status: status ?? this.status,
      budgets: budgets ?? this.budgets,
      year: year ?? this.year,
      month: month ?? this.month,
      error: clearError ? '' : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [status, budgets, year, month, error];
}
