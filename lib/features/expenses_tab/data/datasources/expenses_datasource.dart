import 'package:imrpo/features/expenses_tab/data/models/expense_model.dart';

abstract class ExpensesDatasource {
  Future<void> addExpense(String title ,double amount,String  category,DateTime date);
  Future<void> updateExpense(String expenseId  ,String title ,double amount,String  category,DateTime date);
  Future<void> deleteExpense(String expanseId);
  Future<void> deleteAllExpenses();
  Future<List<ExpenseModel>> getExpenses();
}
