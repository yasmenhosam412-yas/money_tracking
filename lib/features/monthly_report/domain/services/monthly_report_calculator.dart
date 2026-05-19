import 'package:imrpo/features/budgets/domain/entities/budget.dart';
import 'package:imrpo/features/budgets/domain/entities/budget_period.dart';
import 'package:imrpo/features/budgets/domain/services/budget_calculator.dart';
import 'package:imrpo/features/expenses_tab/domain/entities/expense.dart';
import 'package:imrpo/features/incomes_tab/domain/entities/income.dart';
import 'package:imrpo/features/monthly_report/domain/entities/monthly_report_snapshot.dart';

class MonthlyReportCalculator {
  static MonthlyReportSnapshot build({
    required BudgetPeriod period,
    required List<Income> incomes,
    required List<Expense> expenses,
    required List<Budget> budgets,
  }) {
    final previous = period.previous;

    final income = _sumIncomes(incomes, period);
    final expenseTotal = _sumExpenses(expenses, period);
    final net = income - expenseTotal;
    final savingsRate = income <= 0
        ? 0.0
        : ((income - expenseTotal) / income).clamp(0.0, 1.0);

    final spent = BudgetCalculator.spentByCategoryForMonth(
      expenses,
      year: period.year,
      month: period.month,
    );
    final monthBudgets = budgets
        .where((b) => b.year == period.year && b.month == period.month)
        .toList();

    return MonthlyReportSnapshot(
      period: period,
      income: income,
      expenses: expenseTotal,
      net: net,
      savingsRate: savingsRate,
      incomeBySource: _incomeBySource(incomes, period),
      expenseByCategory: spent,
      budgetRows: BudgetCalculator.merge(
        budgets: monthBudgets,
        spentByCategory: spent,
      ),
      previousIncome: _sumIncomes(incomes, previous),
      previousExpenses: _sumExpenses(expenses, previous),
      previousNet: _sumIncomes(incomes, previous) -
          _sumExpenses(expenses, previous),
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
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(entries);
  }

  static String formatPercentChange(double current, double previous) {
    if (previous == 0) {
      if (current == 0) return '—';
      return '+100%';
    }
    final pct = ((current - previous) / previous) * 100;
    final sign = pct >= 0 ? '+' : '';
    return '$sign${pct.toStringAsFixed(0)}%';
  }
}
