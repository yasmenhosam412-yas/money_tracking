import 'package:imrpo/features/budgets/domain/entities/budget.dart';

class BudgetModel extends Budget {
  const BudgetModel({
    required super.id,
    required super.category,
    required super.amount,
    required super.year,
    required super.month,
  });

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['budget_id'] as String,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      year: map['year'] as int,
      month: map['month'] as int,
    );
  }
}
