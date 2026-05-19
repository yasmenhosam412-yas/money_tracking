part of 'budgets_bloc.dart';

abstract class BudgetsEvent extends Equatable {
  const BudgetsEvent();

  @override
  List<Object?> get props => [];
}

class ResetBudgetsEvent extends BudgetsEvent {
  const ResetBudgetsEvent();
}

class LoadBudgetsEvent extends BudgetsEvent {
  final int year;
  final int month;
  final bool force;

  const LoadBudgetsEvent({
    required this.year,
    required this.month,
    this.force = false,
  });

  @override
  List<Object?> get props => [year, month, force];
}

class UpsertBudgetEvent extends BudgetsEvent {
  final String category;
  final double amount;
  final int year;
  final int month;

  const UpsertBudgetEvent({
    required this.category,
    required this.amount,
    required this.year,
    required this.month,
  });

  @override
  List<Object?> get props => [category, amount, year, month];
}

class DeleteBudgetEvent extends BudgetsEvent {
  final String budgetId;

  const DeleteBudgetEvent(this.budgetId);

  @override
  List<Object?> get props => [budgetId];
}
