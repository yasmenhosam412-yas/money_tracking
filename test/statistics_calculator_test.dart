import 'package:flutter_test/flutter_test.dart';
import 'package:imrpo/features/expenses_tab/domain/entities/expense.dart';
import 'package:imrpo/features/incomes_tab/domain/entities/income.dart';
import 'package:imrpo/features/statistics_tab/domain/services/statistics_calculator.dart';

void main() {
  test('build aggregates last 3 calendar months', () {
    final ref = DateTime(2026, 5, 15);
    final incomes = [
      Income(
        id: '1',
        title: 'Salary',
        category: 'Salary',
        amount: 5000,
        date: DateTime(2026, 5, 10),
      ),
      Income(
        id: '2',
        title: 'Salary',
        category: 'Salary',
        amount: 4000,
        date: DateTime(2026, 4, 5),
      ),
    ];
    final expenses = [
      Expense(
        id: '1',
        title: 'Rent',
        category: 'Rent',
        amount: 2000,
        date: DateTime(2026, 5, 1),
      ),
      Expense(
        id: '2',
        title: 'Food',
        category: 'Food',
        amount: 300,
        date: DateTime(2026, 3, 20),
      ),
    ];

    final snapshot = StatisticsCalculator.build(
      incomes: incomes,
      expenses: expenses,
      reference: ref,
    );

    expect(snapshot.months.length, 3);
    expect(snapshot.months.last.income, 5000);
    expect(snapshot.months.last.expenses, 2000);
    expect(snapshot.months.first.expenses, 300);
    expect(snapshot.totalIncome, 9000);
    expect(snapshot.totalExpenses, 2300);
    expect(snapshot.expenseByCategory.containsKey('Rent'), isTrue);
  });
}
