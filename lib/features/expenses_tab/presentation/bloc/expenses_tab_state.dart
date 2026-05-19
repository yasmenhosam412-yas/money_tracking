part of 'expenses_tab_bloc.dart';

enum ExpensesTabStatus {
  initial,
  loadingAdd,
  loadingDelete,
  loadingUpdate,
  loadingAll,
  loaded,
  errorAdd,
  errorDelete,
  errorUpdate,
  errorAll,
}

class ExpensesTabState extends Equatable {
  final ExpensesTabStatus status;
  final String error;
  final List<ExpenseModel> expenses;
  final String? deletingExpenseId;
  const ExpensesTabState({
    this.status = ExpensesTabStatus.initial,
    this.error = '',
    this.expenses = const [],
    this.deletingExpenseId = '',
  });

  ExpensesTabState copyWith({
    ExpensesTabStatus? status,
    String? error,
    String? deletingExpenseId,
    List<ExpenseModel>? expenses,
  }) {
    return ExpensesTabState(
      status: status ?? this.status,
      error: error ?? this.error,
      deletingExpenseId: deletingExpenseId ?? this.deletingExpenseId,
      expenses: expenses ?? this.expenses,
    );
  }

  @override
  List<Object?> get props => [status, error, expenses, deletingExpenseId];
}
