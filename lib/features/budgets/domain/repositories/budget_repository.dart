import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/budgets/domain/entities/budget.dart';

abstract class BudgetRepository {
  Future<Either<Failure, List<Budget>>> getBudgets({
    required int year,
    required int month,
  });

  Future<Either<Failure, Budget>> upsertBudget({
    required String category,
    required double amount,
    required int year,
    required int month,
    String? budgetId,
  });

  Future<Either<Failure, void>> deleteBudget(String budgetId);
}
