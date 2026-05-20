import 'package:imrpo/features/budgets/data/models/budget_model.dart';

abstract class BudgetDatasource {
  Future<List<BudgetModel>> getBudgets({
    required int year,
    required int month,
  });

  Future<BudgetModel> upsertBudget({
    required String category,
    required double amount,
    required int year,
    required int month,
    String? budgetId,
  });

  Future<void> deleteBudget(String budgetId);
  Future<void> renameCategory(String fromCategory, String toCategory);
}
