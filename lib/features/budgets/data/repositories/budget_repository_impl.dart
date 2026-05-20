import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/budgets/data/datasources/budget_datasource.dart';
import 'package:imrpo/features/budgets/domain/entities/budget.dart';
import 'package:imrpo/features/budgets/domain/repositories/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetDatasource budgetDatasource;

  BudgetRepositoryImpl({required this.budgetDatasource});

  @override
  Future<Either<Failure, List<Budget>>> getBudgets({
    required int year,
    required int month,
  }) async {
    try {
      final budgets = await budgetDatasource.getBudgets(
        year: year,
        month: month,
      );
      return Right(budgets);
    } catch (e) {
      return Left(ErrorHelper.handle(e));
    }
  }

  @override
  Future<Either<Failure, Budget>> upsertBudget({
    required String category,
    required double amount,
    required int year,
    required int month,
    String? budgetId,
  }) async {
    try {
      final budget = await budgetDatasource.upsertBudget(
        category: category,
        amount: amount,
        year: year,
        month: month,
        budgetId: budgetId,
      );
      return Right(budget);
    } catch (e) {
      return Left(ErrorHelper.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBudget(String budgetId) async {
    try {
      await budgetDatasource.deleteBudget(budgetId);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHelper.handle(e));
    }
  }
}
