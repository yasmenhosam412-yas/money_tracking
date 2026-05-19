import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/budgets/domain/entities/budget.dart';
import 'package:imrpo/features/budgets/domain/repositories/budget_repository.dart';

class UpsertBudgetUsecase {
  final BudgetRepository budgetRepository;

  UpsertBudgetUsecase({required this.budgetRepository});

  Future<Either<Failure, Budget>> call({
    required String category,
    required double amount,
    required int year,
    required int month,
  }) {
    return budgetRepository.upsertBudget(
      category: category,
      amount: amount,
      year: year,
      month: month,
    );
  }
}
