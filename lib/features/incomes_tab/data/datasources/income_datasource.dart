import 'package:imrpo/features/incomes_tab/data/models/income_model.dart';

abstract class IncomeDatasource {
  Future<void> addIncome(String title, double amount, DateTime date, String category);
  Future<void> deleteIncome(String incomeId);
  Future<void> deleteAllIncomes();
  Future<void> updateIncome(String incomeId, String title, double amount, DateTime date, String category);
  Future<List<IncomeModel>> getIncomes();
}
