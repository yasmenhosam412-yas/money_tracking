import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/balance_tab/domain/entities/balance_activity.dart';
import 'package:imrpo/features/balance_tab/domain/entities/balance_summary.dart';
import 'package:imrpo/features/balance_tab/domain/repositories/balance_repository.dart';
import 'package:imrpo/features/expenses_tab/data/models/expense_model.dart';
import 'package:imrpo/features/expenses_tab/domain/repositories/expense_repository.dart';
import 'package:imrpo/features/incomes_tab/data/models/income_model.dart';
import 'package:imrpo/features/incomes_tab/domain/repositories/income_repository.dart';

class BalanceRepositoryImpl implements BalanceRepository {
  final IncomeRepository incomeRepository;
  final ExpenseRepository expenseRepository;

  BalanceRepositoryImpl({
    required this.incomeRepository,
    required this.expenseRepository,
  });

  @override
  Future<Either<Failure, BalanceSummary>> getBalance({
    required DateTime reference,
    bool filterByDay = false,
    bool includeAllDates = false,
  }) async {
    final incomesResult = await incomeRepository.getIncomes();
    final expensesResult = await expenseRepository.getExpenses();

    return incomesResult.fold(
      Left.new,
      (incomes) => expensesResult.fold(
        Left.new,
        (expenses) => Right(
          _buildSummary(
            incomes,
            expenses,
            reference,
            filterByDay: filterByDay,
            includeAllDates: includeAllDates,
          ),
        ),
      ),
    );
  }

  BalanceSummary _buildSummary(
    List<IncomeModel> incomes,
    List<ExpenseModel> expenses,
    DateTime reference, {
    bool filterByDay = false,
    bool includeAllDates = false,
  }) {
    final monthlyIncomes = includeAllDates
        ? incomes
        : incomes
            .where((i) => _matches(i.date, reference, filterByDay))
            .toList();
    final monthlyExpenses = includeAllDates
        ? expenses
        : expenses
            .where((e) => _matches(e.date, reference, filterByDay))
            .toList();

    final monthlyIncome =
        monthlyIncomes.fold<double>(0, (sum, i) => sum + i.amount);
    final monthlyExpenseTotal =
        monthlyExpenses.fold<double>(0, (sum, e) => sum + e.amount);

    final activities = <BalanceActivity>[
      ...monthlyIncomes.map(
        (income) => BalanceActivity(
          id: 'income_${income.id}',
          title: income.title,
          category: income.category,
          amount: income.amount,
          date: income.date,
          type: BalanceActivityType.income,
        ),
      ),
      ...monthlyExpenses.map(
        (expense) => BalanceActivity(
          id: 'expense_${expense.id}',
          title: expense.title,
          category: expense.category,
          amount: expense.amount,
          date: expense.date,
          type: BalanceActivityType.expense,
        ),
      ),
    ]..sort((a, b) => b.date.compareTo(a.date));

    return BalanceSummary(
      monthlyIncome: monthlyIncome,
      monthlyExpenses: monthlyExpenseTotal,
      activities: activities,
    );
  }

  bool _matches(DateTime date, DateTime reference, bool filterByDay) {
    if (filterByDay) {
      return date.year == reference.year &&
          date.month == reference.month &&
          date.day == reference.day;
    }
    return date.year == reference.year && date.month == reference.month;
  }
}
