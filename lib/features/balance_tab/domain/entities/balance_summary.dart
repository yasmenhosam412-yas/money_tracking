import 'package:equatable/equatable.dart';
import 'package:imrpo/features/balance_tab/domain/entities/balance_activity.dart';

class BalanceSummary extends Equatable {
  final double monthlyIncome;
  final double monthlyExpenses;
  final List<BalanceActivity> activities;

  const BalanceSummary({
    required this.monthlyIncome,
    required this.monthlyExpenses,
    required this.activities,
  });

  @override
  List<Object> get props => [monthlyIncome, monthlyExpenses, activities];
}
