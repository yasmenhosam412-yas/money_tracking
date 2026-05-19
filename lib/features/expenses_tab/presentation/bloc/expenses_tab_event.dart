part of 'expenses_tab_bloc.dart';

abstract class ExpensesTabEvent extends Equatable {
  const ExpensesTabEvent();

  @override
  List<Object> get props => [];
}

class LoadExpensesEvent extends ExpensesTabEvent {
  final bool force;

  const LoadExpensesEvent({this.force = false});

  @override
  List<Object> get props => [force];
}

class ResetExpensesTabEvent extends ExpensesTabEvent {
  const ResetExpensesTabEvent();
}

class AddExpenseEvent extends ExpensesTabEvent {
  final String title;
  final String category;
  final double amount;
  final DateTime date;

  const AddExpenseEvent({
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
  });

  @override
  List<Object> get props => [title, category, amount, date];
}

class UpdateExpenseEvent extends ExpensesTabEvent {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;

  const UpdateExpenseEvent({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
  });

  @override
  List<Object> get props => [id, title, category, amount, date];
}

class DeleteExpenseEvent extends ExpensesTabEvent {
  final String id;

  const DeleteExpenseEvent(this.id);

  @override
  List<Object> get props => [id];
}

class ClearAllExpensesEvent extends ExpensesTabEvent {
  const ClearAllExpensesEvent();
}
