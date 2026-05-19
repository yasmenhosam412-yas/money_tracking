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
      "user_id": supabaseClient.auth.currentUser!.id,
    });
  }

  @override
  Future<void> deleteExpense(String expanseId) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Not authenticated');
    }

    final deleted = await supabaseClient
        .from('expenses')
        .delete()
        .eq('expense_id', expanseId)
        .eq('user_id', userId)
        .select('expense_id');

    ensureDeleteSucceeded(deleted);
  }

  @override
  Future<List<ExpenseModel>> getExpenses() async {
    final response = await supabaseClient
        .from("expenses")
        .select()
        .eq("user_id", supabaseClient.auth.currentUser!.id);

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
