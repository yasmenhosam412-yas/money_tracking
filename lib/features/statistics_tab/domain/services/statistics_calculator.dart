import 'package:imrpo/features/budgets/domain/entities/budget_period.dart';
import 'package:imrpo/features/budgets/domain/services/budget_calculator.dart';
import 'package:imrpo/features/expenses_tab/domain/entities/expense.dart';
import 'package:imrpo/features/incomes_tab/domain/entities/income.dart';
import 'package:imrpo/features/statistics_tab/domain/entities/month_statistics.dart';

class StatisticsCalculator {
  static const defaultMonthCount = 3;

  static List<BudgetPeriod> lastPeriods({
    int count = defaultMonthCount,
    DateTime? reference,
  }) {
    final now = reference ?? DateTime.now();
    var period = BudgetPeriod(year: now.year, month: now.month);
    final periods = <BudgetPeriod>[period];
    for (var i = 1; i < count; i++) {
      period = period.previous;
      periods.insert(0, period);
    }
    return periods;
  }

  static StatisticsSnapshot build({
    required List<Income> incomes,
    required List<Expense> expenses,
    int monthCount = defaultMonthCount,
    DateTime? reference,
  }) {
    final periods = lastPeriods(count: monthCount, reference: reference);
    final months = periods
        .map(
          (period) => MonthStatistics(
            period: period,
            income: _sumIncomes(incomes, period),
            expenses: _sumExpenses(expenses, period),
          ),
        )
        .toList();

    final expenseTotals = <String, double>{};
    final incomeTotals = <String, double>{};

    for (final period in periods) {
      for (final entry in _expenseByCategory(expenses, period).entries) {
        expenseTotals[entry.key] =
            (expenseTotals[entry.key] ?? 0) + entry.value;
      }
      for (final entry in _incomeBySource(incomes, period).entries) {
        incomeTotals[entry.key] =
            (incomeTotals[entry.key] ?? 0) + entry.value;
      }
    }

    final totalIncome =
        months.fold<double>(0, (sum, m) => sum + m.income);
    final totalExpenses =
        months.fold<double>(0, (sum, m) => sum + m.expenses);

    return StatisticsSnapshot(
      months: months,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      expenseByCategory: _sortedMap(expenseTotals, limit: 6),
      incomeBySource: _sortedMap(incomeTotals, limit: 6),
    );
  }

  static double _sumIncomes(List<Income> incomes, BudgetPeriod period) {
    return incomes
        .where(
          (i) => i.date.year == period.year && i.date.month == period.month,
        )
        .fold<double>(0, (sum, i) => sum + i.amount);
  }

  static double _sumExpenses(List<Expense> expenses, BudgetPeriod period) {
    return expenses
        .where(
          (e) => e.date.year == period.year && e.date.month == period.month,
        )
        .fold<double>(0, (sum, e) => sum + e.amount);
  }

  static Map<String, double> _expenseByCategory(
    List<Expense> expenses,
    BudgetPeriod period,
  ) {
    return BudgetCalculator.spentByCategoryForMonth(
      expenses,
      year: period.year,
      month: period.month,
    );
  }

  static Map<String, double> _incomeBySource(
    List<Income> incomes,
    BudgetPeriod period,
  ) {
    final totals = <String, double>{};
    for (final income in incomes) {
      if (income.date.year != period.year ||
          income.date.month != period.month) {
        continue;
      }
      final key = BudgetCalculator.categoryKey(income.category);
      totals[key] = (totals[key] ?? 0) + income.amount;
    }
    return totals;
  }

  static Map<String, double> _sortedMap(
    Map<String, double> source, {
    int limit = 6,
  }) {
    final entries = source.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(entries.take(limit));
  }
}
