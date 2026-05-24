import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/core/models/transaction_entry_meta.dart';
import 'package:imrpo/features/expenses_tab/data/models/expense_model.dart';

abstract class ExpenseRepository {
  Future<Either<Failure, void>> addExpense(
    String title,
    String category,
    double amount,
    DateTime date, {
    String? incomeSource,
    String? receiptUrl,
    TransactionEntryMeta? entryMeta,
  });
  Future<Either<Failure, void>> updateExpense(
    String title,
    String category,
    double amount,
    DateTime date,
    String expenseId, {
    String? incomeSource,
    String? receiptUrl,
    bool clearReceipt = false,
    TransactionEntryMeta? entryMeta,
  });
  Future<Either<Failure, void>> deleteExpense(String expenseId);
  Future<Either<Failure, void>> deleteAllExpenses();
  Future<Either<Failure, List<ExpenseModel>>> getExpenses();
  Future<Either<Failure, int>> renameCategory(
    String fromCategory,
    String toCategory,
  );
  Future<Either<Failure, int>> deleteByCategory(String category);
}
