import 'package:imrpo/core/helpers/supabase_auth_helper.dart';
import 'package:imrpo/core/helpers/supabase_delete_helper.dart';
import 'package:imrpo/features/expenses_tab/data/datasources/expenses_datasource.dart';
import 'package:imrpo/features/expenses_tab/data/models/expense_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpensesDatasourceImpl extends ExpensesDatasource {
  final SupabaseClient supabaseClient;

  ExpensesDatasourceImpl({required this.supabaseClient});
  @override
  Future<void> addExpense(
    String title,
    double amount,
    String category,
    DateTime date,
  ) async {
    await supabaseClient.from("expenses").insert({
      "title": title,
      "amount": amount,
      "category": category,
      "date": date.toIso8601String(),
      "user_id": SupabaseAuthHelper.requireUserId(),
    });
  }

  @override
  Future<void> deleteExpense(String expanseId) async {
    final userId = SupabaseAuthHelper.requireUserId();

    final deleted = await supabaseClient
        .from('expenses')
        .delete()
        .eq('expense_id', expanseId)
        .eq('user_id', userId)
        .select('expense_id');

    ensureDeleteSucceeded(deleted);
  }

  @override
  Future<void> deleteAllExpenses() async {
    final userId = SupabaseAuthHelper.requireUserId();

    await supabaseClient.from('expenses').delete().eq('user_id', userId);
  }

  @override
  Future<List<ExpenseModel>> getExpenses() async {
    final userId = SupabaseAuthHelper.requireUserId();
    final response = await supabaseClient
        .from('expenses')
        .select()
        .eq('user_id', userId);

    return response.map((e) => ExpenseModel.fromMap(e)).toList();
  }

  @override
  Future<void> updateExpense(
    String expenseId,
    String title,
    double amount,
    String category,
    DateTime date,
  ) async {
    await supabaseClient
        .from("expenses")
        .update({
          'title': title,
          'amount': amount,
          'date': date.toIso8601String(),
          'category': category,
        })
        .eq("expense_id", expenseId);
  }
}
