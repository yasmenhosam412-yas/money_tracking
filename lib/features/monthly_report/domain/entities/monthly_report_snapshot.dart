import 'package:imrpo/features/budgets/domain/entities/budget_period.dart';
import 'package:imrpo/features/budgets/domain/entities/category_budget_status.dart';

class MonthlyReportSnapshot {
  final BudgetPeriod period;
  final double income;
  final double expenses;
  final double net;
  final double savingsRate;
  final Map<String, double> incomeBySource;
  final Map<String, double> expenseByCategory;
  final List<CategoryBudgetStatus> budgetRows;
  final double previousIncome;
  final double previousExpenses;
  final double previousNet;

  const MonthlyReportSnapshot({
    required this.period,
    required this.income,
    required this.expenses,
    required this.net,
    required this.savingsRate,
    required this.incomeBySource,
    required this.expenseByCategory,
    required this.budgetRows,
    required this.previousIncome,
    required this.previousExpenses,
    required this.previousNet,
  });

  double get incomeChange => income - previousIncome;

  double get expensesChange => expenses - previousExpenses;

  double get netChange => net - previousNet;

  int get incomeEntryCount =>
      incomeBySource.values.where((v) => v > 0).length;

  int get expenseEntryCount =>
      expenseByCategory.values.where((v) => v > 0).length;

  List<CategoryBudgetStatus> get budgetedRows =>
      budgetRows.where((row) => row.limit > 0).toList();
}
