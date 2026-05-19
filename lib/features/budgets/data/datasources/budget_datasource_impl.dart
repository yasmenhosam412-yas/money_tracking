import 'package:imrpo/core/helpers/supabase_auth_helper.dart';
import 'package:imrpo/core/helpers/supabase_delete_helper.dart';
import 'package:imrpo/features/budgets/data/datasources/budget_datasource.dart';
import 'package:imrpo/features/budgets/data/models/budget_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BudgetDatasourceImpl implements BudgetDatasource {
  final SupabaseClient supabaseClient;

  BudgetDatasourceImpl({required this.supabaseClient});

  @override
  Future<List<BudgetModel>> getBudgets({
    required int year,
    required int month,
  }) async {
    final userId = SupabaseAuthHelper.requireUserId();
    final response = await supabaseClient
        .from('budgets')
        .select()
        .eq('user_id', userId)
        .eq('year', year)
        .eq('month', month);

    return response.map((row) => BudgetModel.fromMap(row)).toList();
  }

  @override
  Future<BudgetModel> upsertBudget({
    required String category,
    required double amount,
    required int year,
    required int month,
  }) async {
    final userId = SupabaseAuthHelper.requireUserId();
    final existing = await supabaseClient
        .from('budgets')
        .select()
        .eq('user_id', userId)
        .eq('category', category)
        .eq('year', year)
        .eq('month', month)
        .maybeSingle();

    if (existing != null) {
      final updated = await supabaseClient
          .from('budgets')
          .update({'amount': amount})
          .eq('budget_id', existing['budget_id'] as String)
          .select()
          .single();
      return BudgetModel.fromMap(updated);
    }

    final inserted = await supabaseClient
        .from('budgets')
        .insert({
          'user_id': userId,
          'category': category,
          'amount': amount,
          'year': year,
          'month': month,
        })
        .select()
        .single();
    return BudgetModel.fromMap(inserted);
  }

  @override
  Future<void> deleteBudget(String budgetId) async {
    final userId = SupabaseAuthHelper.requireUserId();
    final deleted = await supabaseClient
        .from('budgets')
        .delete()
        .eq('budget_id', budgetId)
        .eq('user_id', userId)
        .select('budget_id');

    ensureDeleteSucceeded(deleted);
  }

  @override
  Future<void> renameCategory(String fromCategory, String toCategory) async {
    if (fromCategory == toCategory) return;
    final userId = SupabaseAuthHelper.requireUserId();
    await supabaseClient
        .from('budgets')
        .update({'category': toCategory})
        .eq('user_id', userId)
        .eq('category', fromCategory);
  }
}
