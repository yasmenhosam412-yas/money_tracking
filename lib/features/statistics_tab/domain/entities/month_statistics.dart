import 'package:imrpo/features/budgets/domain/entities/budget_period.dart';

class MonthStatistics {
  final BudgetPeriod period;
  final double income;
  final double expenses;

  const MonthStatistics({
    required this.period,
    required this.income,
    required this.expenses,
  });

  double get net => income - expenses;
}

class StatisticsSnapshot {
  final List<MonthStatistics> months;
  final double totalIncome;
  final double totalExpenses;
  final Map<String, double> expenseByCategory;
  final Map<String, double> incomeBySource;

  const StatisticsSnapshot({
    required this.months,
    required this.totalIncome,
    required this.totalExpenses,
    required this.expenseByCategory,
    required this.incomeBySource,
  });

  double get totalNet => totalIncome - totalExpenses;

  double get averageMonthlyNet =>
      months.isEmpty ? 0 : totalNet / months.length;

  double get maxMonthlyValue {
    var max = 0.0;
    for (final m in months) {
      if (m.income > max) max = m.income;
      if (m.expenses > max) max = m.expenses;
    }
    return max;
  }

  bool get hasData => totalIncome > 0 || totalExpenses > 0;
}
