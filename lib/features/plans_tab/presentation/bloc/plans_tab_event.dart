part of 'plans_tab_bloc.dart';

abstract class PlansTabEvent extends Equatable {
  const PlansTabEvent();

  @override
  List<Object> get props => [];
}

class LoadPlansEvent extends PlansTabEvent {
  final bool force;

  const LoadPlansEvent({this.force = false});

  @override
  List<Object> get props => [force];
}

class ResetPlansTabEvent extends PlansTabEvent {
  const ResetPlansTabEvent();
}

class AddPlanEvent extends PlansTabEvent {
  final String title;
  final String category;
  final double targetAmount;
  final double savedAmount;
  final DateTime? deadline;

  const AddPlanEvent({
    required this.title,
    required this.category,
    required this.targetAmount,
    required this.savedAmount,
    this.deadline,
  });

  @override
  List<Object> get props => [
    title,
    category,
    targetAmount,
    savedAmount,
    deadline ?? '',
  ];
}

class UpdatePlanEvent extends PlansTabEvent {
  final String id;
  final String title;
  final String category;
  final double targetAmount;
  final double savedAmount;
  final DateTime? deadline;

  const UpdatePlanEvent({
    required this.id,
    required this.title,
    required this.category,
    required this.targetAmount,
    required this.savedAmount,
    this.deadline,
  });

  @override
  List<Object> get props => [
    id,
    title,
    category,
    targetAmount,
    savedAmount,
    deadline ?? '',
  ];
}

class UpdatePlanSavedEvent extends PlansTabEvent {
  final String id;
  final double savedAmount;

  const UpdatePlanSavedEvent({
    required this.id,
    required this.savedAmount,
  });

  @override
  List<Object> get props => [id, savedAmount];
}

/// Adds [amountToAdd] (base currency) to a plan's current saved amount.
class AddAmountToPlanEvent extends PlansTabEvent {
  final String id;
  final double amountToAdd;
  final String expenseTitle;

  const AddAmountToPlanEvent({
    required this.id,
    required this.amountToAdd,
    required this.expenseTitle,
  });

  @override
  List<Object> get props => [id, amountToAdd, expenseTitle];
}

class DeletePlanEvent extends PlansTabEvent {
  final String id;

  const DeletePlanEvent(this.id);

  @override
  List<Object> get props => [id];
}
