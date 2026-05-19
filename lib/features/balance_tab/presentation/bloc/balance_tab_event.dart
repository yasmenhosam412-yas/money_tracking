part of 'balance_tab_bloc.dart';

abstract class BalanceTabEvent extends Equatable {
  const BalanceTabEvent();

  @override
  List<Object?> get props => [];
}

class LoadBalanceEvent extends BalanceTabEvent {
  final DateTime reference;
  final bool filterByDay;
  final bool includeAllDates;

  const LoadBalanceEvent({
    required this.reference,
    this.filterByDay = false,
    this.includeAllDates = false,
  });

  @override
  List<Object?> get props => [reference, filterByDay, includeAllDates];
}

class ResetBalanceTabEvent extends BalanceTabEvent {
  const ResetBalanceTabEvent();
}
