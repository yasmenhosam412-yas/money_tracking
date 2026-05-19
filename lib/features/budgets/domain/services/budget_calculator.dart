import 'package:imrpo/features/budgets/domain/entities/budget.dart';
import 'package:imrpo/features/budgets/domain/entities/category_budget_status.dart';
import 'package:imrpo/features/expenses_tab/domain/entities/expense.dart';

class BudgetCalculator {
  static String categoryKey(String category) {
    final trimmed = category.trim();
    return trimmed.isEmpty ? 'Other' : trimmed;
  }

  static Map<String, double> spentByCategoryForMonth(
    List<Expense> expenses, {
    required int year,
    required int month,
  }) {
    final totals = <String, double>{};
    for (final expense in expenses) {
      if (expense.date.year != year || expense.date.month != month) continue;
      final key = categoryKey(expense.category);
      totals[key] = (totals[key] ?? 0) + expense.amount;
    }
    return totals;
  }

  static List<CategoryBudgetStatus> merge({
    required List<Budget> budgets,
    required Map<String, double> spentByCategory,
  }) {
    final limits = <String, ({double limit, String? id})>{};
    for (final budget in budgets) {
      final key = categoryKey(budget.category);
      limits[key] = (limit: budget.amount, id: budget.id);
    }

    final categories = <String>{...limits.keys, ...spentByCategory.keys};
    final rows = categories.map((category) {
      final limitInfo = limits[category];
      final limit = limitInfo?.limit ?? 0;
      final spent = spentByCategory[category] ?? 0;
      return CategoryBudgetStatus(
        category: category,
        limit: limit,
        spent: spent,
        budgetId: limitInfo?.id,
      );
    }).toList();

    rows.sort((a, b) {
      if (a.limit > 0 && b.limit == 0) return -1;
      if (b.limit > 0 && a.limit == 0) return 1;
      return b.spent.compareTo(a.spent);
    });
    return rows;
  }

  static double totalLimit(List<CategoryBudgetStatus> rows) {
    return rows.fold<double>(0, (sum, row) => sum + row.limit);
  }

  static double totalSpentWithBudget(List<CategoryBudgetStatus> rows) {
    return rows
        .where((row) => row.limit > 0)
        .fold<double>(0, (sum, row) => sum + row.spent);
  }
}
