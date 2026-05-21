import 'package:imrpo/core/helpers/association_datasource_mixin.dart';
import 'package:imrpo/core/helpers/supabase_auth_helper.dart';
import 'package:imrpo/core/helpers/supabase_delete_helper.dart';
import 'package:imrpo/features/expenses_tab/data/datasources/expenses_datasource.dart';
import 'package:imrpo/features/expenses_tab/data/models/expense_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpensesDatasourceImpl extends ExpensesDatasource
    with AssociationDatasourceMixin {
  final SupabaseClient supabaseClient;

  ExpensesDatasourceImpl({required this.supabaseClient});
  @override
  Future<void> addExpense(
    String title,
    double amount,
    String category,
    DateTime date, {
    String? incomeSource,
  }) async {
    final trimmed = incomeSource?.trim();
    final row = scopedFinancialRow({
      "title": title,
      "amount": amount,
      "category": category,
      "date": date.toIso8601String(),
      "user_id": SupabaseAuthHelper.requireUserId(),
    });
    if (trimmed != null && trimmed.isNotEmpty) {
      row["income_source"] = trimmed;
    }
    await supabaseClient.from("expenses").insert(row);
  }

  @override
  Future<void> deleteExpense(String expanseId) async {
    final userId = SupabaseAuthHelper.requireUserId();

    var deleteQuery = supabaseClient
        .from('expenses')
        .delete()
        .eq('expense_id', expanseId)
        .eq('user_id', userId);
    deleteQuery = scopeFinancialQuery(deleteQuery);
    final deleted = await deleteQuery.select('expense_id');

    ensureDeleteSucceeded(deleted);
  }

  @override
  Future<void> deleteAllExpenses() async {
    final userId = SupabaseAuthHelper.requireUserId();

    var deleteQuery =
        supabaseClient.from('expenses').delete().eq('user_id', userId);
    deleteQuery = scopeFinancialQuery(deleteQuery);
    await deleteQuery;
  }

  @override
  Future<List<ExpenseModel>> getExpenses() async {
    final userId = SupabaseAuthHelper.requireUserId();
    var selectQuery =
        supabaseClient.from('expenses').select().eq('user_id', userId);
    selectQuery = scopeFinancialQuery(selectQuery);
    final response = await selectQuery;

    return response.map((e) => ExpenseModel.fromMap(e)).toList();
  }

  @override
  Future<void> updateExpense(
    String expenseId,
    String title,
    double amount,
    String category,
    DateTime date, {
    String? incomeSource,
  }) async {
    final trimmed = incomeSource?.trim();
    final update = <String, dynamic>{
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
    };
    if (trimmed == null || trimmed.isEmpty) {
      update['income_source'] = null;
    } else {
      update['income_source'] = trimmed;
    }
    var updateQuery = supabaseClient
        .from("expenses")
        .update(update)
        .eq("expense_id", expenseId)
        .eq('user_id', SupabaseAuthHelper.requireUserId());
    updateQuery = scopeFinancialQuery(updateQuery);
    await updateQuery;
  }

  @override
  Future<int> renameCategory(String fromCategory, String toCategory) async {
    final userId = SupabaseAuthHelper.requireUserId();
    var updateQuery = supabaseClient
        .from('expenses')
        .update({'category': toCategory})
        .eq('user_id', userId)
        .eq('category', fromCategory);
    updateQuery = scopeFinancialQuery(updateQuery);
    final updated = await updateQuery.select('expense_id');

    return (updated as List).length;
  }

  @override
  Future<int> deleteByCategory(String category) async {
    final userId = SupabaseAuthHelper.requireUserId();
    var deleteQuery = supabaseClient
        .from('expenses')
        .delete()
        .eq('user_id', userId)
        .eq('category', category);
    deleteQuery = scopeFinancialQuery(deleteQuery);
    final deleted = await deleteQuery.select('expense_id');

    return (deleted as List).length;
  }
}
