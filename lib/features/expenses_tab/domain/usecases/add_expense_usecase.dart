import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/expenses_tab/domain/repositories/expense_repository.dart';

class AddExpenseUsecase {
  final ExpenseRepository expenseRepository;

  AddExpenseUsecase({required this.expenseRepository});
  Future<Either<Failure, void>> call(
    String title,
    String category,
    double amount,
    DateTime date, {
    String? incomeSource,
  }) async {
    return await expenseRepository.addExpense(
      title,
      category,
      amount,
      date,
      incomeSource: incomeSource,
    );
  }
}
