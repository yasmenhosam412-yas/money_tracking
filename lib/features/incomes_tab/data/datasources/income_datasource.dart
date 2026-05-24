import 'package:imrpo/core/models/transaction_entry_meta.dart';
import 'package:imrpo/features/incomes_tab/data/models/income_model.dart';

abstract class IncomeDatasource {
  Future<void> addIncome(
    String title,
    double amount,
    DateTime date,
    String category, {
    TransactionEntryMeta? entryMeta,
    String? associationIdOverride,
  });
  Future<void> deleteIncome(String incomeId);
  Future<void> deleteAllIncomes();
  Future<void> updateIncome(
    String incomeId,
    String title,
    double amount,
    DateTime date,
    String category, {
    TransactionEntryMeta? entryMeta,
  });
  Future<List<IncomeModel>> getIncomes();
  Future<int> renameCategory(String fromCategory, String toCategory);
  Future<int> deleteByCategory(String category);
}
