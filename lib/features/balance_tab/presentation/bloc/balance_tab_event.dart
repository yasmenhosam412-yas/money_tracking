part of 'balance_tab_bloc.dart';

abstract class BalanceTabEvent extends Equatable {
  const BalanceTabEvent();

  @override
  List<Object?> get props => [];
}

class LoadBalanceEvent extends BalanceTabEvent {
  final DateTime reference;
  final bool filterByDay;

  const LoadBalanceEvent({
    required this.reference,
    this.filterByDay = false,
  });

  @override
  List<Object?> get props => [reference, filterByDay];
}

class ResetBalanceTabEvent extends BalanceTabEvent {
  const ResetBalanceTabEvent();
}
