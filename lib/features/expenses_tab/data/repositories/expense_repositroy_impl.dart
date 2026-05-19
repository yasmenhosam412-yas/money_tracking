import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/expenses_tab/data/datasources/expenses_datasource.dart';
import 'package:imrpo/features/expenses_tab/data/models/expense_model.dart';
import 'package:imrpo/features/expenses_tab/domain/repositories/expense_repository.dart';

class ExpenseRepositroyImpl extends ExpenseRepository {
  final ExpensesDatasource expensesDatasource;

  ExpenseRepositroyImpl({required this.expensesDatasource});
  @override
  Future<Either<Failure, void>> addExpense(
    String title,
    String category,
    double amount,
    DateTime date,
  ) async {
    try {
      await expensesDatasource.addExpense(title, amount, category, date);
      return Right(null);
    } catch (e) {
      return Left(ErrorHelper.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExpense(String expenseId) async {
    try {
      await expensesDatasource.deleteExpense(expenseId);
      return Right(null);
    } catch (e) {
      return Left(ErrorHelper.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAllExpenses() async {
    try {
      await expensesDatasource.deleteAllExpenses();
      return const Right(null);
    } catch (e) {
      return Left(ErrorHelper.handle(e));
    }
  }

  @override
  Future<Either<Failure, List<ExpenseModel>>> getExpenses() async {
    try {
      final expenses = await expensesDatasource.getExpenses();
      return Right(expenses);
    } catch (e) {
      return Left(ErrorHelper.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateExpense(
    String title,
    String category,
    double amount,
    DateTime date,
    String expenseId,
  ) async {
    try {
      await expensesDatasource.updateExpense(
        expenseId,
        title,
        amount,
        category,
        date,
      );
      return Right(null);
    } catch (e) {
      return Left(ErrorHelper.handle(e));
    }
  }
}
