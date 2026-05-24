import 'package:imrpo/core/models/transaction_entry_meta.dart';
import 'package:imrpo/features/expenses_tab/data/models/expense_model.dart';

abstract class ExpensesDatasource {
  Future<void> addExpense(
    String title,
    double amount,
    String category,
    DateTime date, {
    String? incomeSource,
    String? receiptUrl,
    TransactionEntryMeta? entryMeta,
    String? associationIdOverride,
  });
  Future<void> updateExpense(
    String expenseId,
    String title,
    double amount,
    String category,
    DateTime date, {
    String? incomeSource,
    String? receiptUrl,
    bool clearReceipt = false,
    TransactionEntryMeta? entryMeta,
  });
  Future<void> deleteExpense(String expanseId);
  Future<void> deleteAllExpenses();
  Future<List<ExpenseModel>> getExpenses();
  Future<int> renameCategory(String fromCategory, String toCategory);
  Future<int> deleteByCategory(String category);
}
