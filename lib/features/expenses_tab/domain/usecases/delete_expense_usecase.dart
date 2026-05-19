import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/expenses_tab/domain/repositories/expense_repository.dart';

class DeleteExpenseUsecase {
  final ExpenseRepository expenseRepository;

  DeleteExpenseUsecase({required this.expenseRepository});
  Future<Either<Failure, void>> call(
    String expenseId,
  ) async {
    return await expenseRepository.deleteExpense(
      expenseId,
    );
  }
}
