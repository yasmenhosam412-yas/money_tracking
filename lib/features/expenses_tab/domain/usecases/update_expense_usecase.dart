import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/expenses_tab/domain/repositories/expense_repository.dart';

class UpdateExpenseUsecase {
  final ExpenseRepository expenseRepository;

  UpdateExpenseUsecase({required this.expenseRepository});
  Future<Either<Failure, void>> call(
    String expenseId,
    String title,
    String category,
    double amount,
    DateTime date,
  ) async {
    return await expenseRepository.updateExpense(
      title,
      category,
      amount,
      date,
      expenseId,
    );
  }
}
