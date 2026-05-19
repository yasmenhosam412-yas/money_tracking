part of 'incomes_tab_bloc.dart';

abstract class IncomesTabEvent extends Equatable {
  const IncomesTabEvent();

  @override
  List<Object> get props => [];
}

class LoadIncomesEvent extends IncomesTabEvent {
  final bool force;

  const LoadIncomesEvent({this.force = false});

  @override
  List<Object> get props => [force];
}

class ResetIncomesTabEvent extends IncomesTabEvent {
  const ResetIncomesTabEvent();
}

class AddIncomeEvent extends IncomesTabEvent {
  final String title;
  final String category;
  final double amount;
  final DateTime date;

  const AddIncomeEvent({
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
  });

  @override
  List<Object> get props => [title, category, amount, date];
}

class UpdateIncomeEvent extends IncomesTabEvent {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;

  const UpdateIncomeEvent({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
  });

  @override
  List<Object> get props => [id, title, category, amount, date];
}

class DeleteIncomeEvent extends IncomesTabEvent {
  final String id;

  const DeleteIncomeEvent(this.id);

  @override
  List<Object> get props => [id];
}

class ClearAllIncomesEvent extends IncomesTabEvent {
  const ClearAllIncomesEvent();
}
