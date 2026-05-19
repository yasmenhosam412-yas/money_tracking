import 'package:imrpo/core/helpers/supabase_delete_helper.dart';
import 'package:imrpo/features/incomes_tab/data/datasources/income_datasource.dart';
import 'package:imrpo/features/incomes_tab/data/models/income_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IncomeDatasourceImpl extends IncomeDatasource {
  final SupabaseClient supabaseClient;

  IncomeDatasourceImpl({required this.supabaseClient});

  @override
  Future<void> addIncome(
    String title,
    double amount,
    DateTime date,
    String category,
  ) async {
    await supabaseClient.from('incomes').insert({
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'user_id': supabaseClient.auth.currentUser!.id,
    });
  }

  @override
  Future<void> deleteIncome(String incomeId) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Not authenticated');
    }

    final deleted = await supabaseClient
        .from('incomes')
        .delete()
        .eq('income_id', incomeId)
        .eq('user_id', userId)
        .select('income_id');

    ensureDeleteSucceeded(deleted);
  }

  @override
  Future<List<IncomeModel>> getIncomes() {
    return supabaseClient.from('incomes').select().eq("user_id", supabaseClient.auth.currentUser?.id ?? "").then((response) {
      final data = response;
      return data.map((item) => IncomeModel.fromMap(item)).toList();
    });
  }

  @override
  Future<void> updateIncome(
    String incomeId,
    String title,
    double amount,
    DateTime date,
    String category,
  ) async {
    await supabaseClient
        .from('incomes')
        .update({
          'title': title,
          'amount': amount,
          'date': date.toIso8601String(),
          'category': category,
        })
        .eq('income_id', incomeId);
  }
}
