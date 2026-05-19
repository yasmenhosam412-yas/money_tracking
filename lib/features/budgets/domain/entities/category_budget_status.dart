import 'package:equatable/equatable.dart';

class CategoryBudgetStatus extends Equatable {
  final String category;
  final double limit;
  final double spent;
  final String? budgetId;

  const CategoryBudgetStatus({
    required this.category,
    required this.limit,
    required this.spent,
    this.budgetId,
  });

  double get remaining => limit - spent;

  double get progress => limit > 0 ? spent / limit : 0;

  bool get isOverBudget => spent > limit;

  bool get isNearLimit => !isOverBudget && progress >= 0.8;

  @override
  List<Object?> get props => [category, limit, spent, budgetId];
}
