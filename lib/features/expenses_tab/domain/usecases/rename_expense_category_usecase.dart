import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/expenses_tab/domain/repositories/expense_repository.dart';

class RenameExpenseCategoryUsecase {
  final ExpenseRepository expenseRepository;

  RenameExpenseCategoryUsecase({required this.expenseRepository});

  Future<Either<Failure, int>> call({
    required String fromCategory,
    required String toCategory,
  }) {
    return expenseRepository.renameCategory(fromCategory, toCategory);
  }
}
