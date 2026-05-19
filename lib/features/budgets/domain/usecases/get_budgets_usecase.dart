import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/budgets/domain/entities/budget.dart';
import 'package:imrpo/features/budgets/domain/repositories/budget_repository.dart';

class GetBudgetsUsecase {
  final BudgetRepository budgetRepository;

  GetBudgetsUsecase({required this.budgetRepository});

  Future<Either<Failure, List<Budget>>> call({
    required int year,
    required int month,
  }) {
    return budgetRepository.getBudgets(year: year, month: month);
  }
}
