import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/expenses_tab/domain/repositories/expense_repository.dart';

class DeleteExpensesByCategoryUsecase {
  final ExpenseRepository expenseRepository;

  DeleteExpensesByCategoryUsecase({required this.expenseRepository});

  Future<Either<Failure, int>> call(String category) {
    return expenseRepository.deleteByCategory(category);
  }
}
