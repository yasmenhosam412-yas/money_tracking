import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/budgets/domain/repositories/budget_repository.dart';

class DeleteBudgetUsecase {
  final BudgetRepository budgetRepository;

  DeleteBudgetUsecase({required this.budgetRepository});

  Future<Either<Failure, void>> call(String budgetId) {
    return budgetRepository.deleteBudget(budgetId);
  }
}
