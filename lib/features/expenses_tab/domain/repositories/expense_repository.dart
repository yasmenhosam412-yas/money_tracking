import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/expenses_tab/data/models/expense_model.dart';

abstract class ExpenseRepository {
  Future<Either<Failure, void>> addExpense(String title,String category,double amount,DateTime date);
  Future<Either<Failure, void>> updateExpense(String title,String category,double amount,DateTime date,String expenseId);
  Future<Either<Failure, void>> deleteExpense(String expenseId);
  Future<Either<Failure, void>> deleteAllExpenses();
  Future<Either<Failure, List<ExpenseModel>>> getExpenses();

}
