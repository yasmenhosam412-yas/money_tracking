import 'package:imrpo/core/helpers/association_datasource_mixin.dart';
import 'package:imrpo/core/helpers/supabase_auth_helper.dart';
import 'package:imrpo/core/helpers/supabase_delete_helper.dart';
import 'package:imrpo/features/budgets/data/datasources/budget_datasource.dart';
import 'package:imrpo/features/budgets/data/models/budget_model.dart';
import 'package:imrpo/features/budgets/domain/services/budget_calculator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BudgetDatasourceImpl extends BudgetDatasource
    with AssociationDatasourceMixin {
  final SupabaseClient supabaseClient;

  BudgetDatasourceImpl({required this.supabaseClient});

  @override
  Future<List<BudgetModel>> getBudgets({
    required int year,
    required int month,
  }) async {
    final userId = SupabaseAuthHelper.requireUserId();
    var selectQuery = supabaseClient
        .from('budgets')
        .select()
        .eq('user_id', userId)
        .eq('year', year)
        .eq('month', month);
    selectQuery = scopeFinancialQuery(selectQuery);
    final response = await selectQuery;

    return response.map((row) => BudgetModel.fromMap(row)).toList();
  }

  @override
  Future<BudgetModel> upsertBudget({
    required String category,
    required double amount,
    required int year,
    required int month,
    String? budgetId,
  }) async {
    final userId = SupabaseAuthHelper.requireUserId();
    final normalizedCategory = BudgetCalculator.categoryKey(category);

    if (budgetId != null && budgetId.isNotEmpty) {
      var updateQuery = supabaseClient
          .from('budgets')
          .update({
            'category': normalizedCategory,
            'amount': amount,
          })
          .eq('budget_id', budgetId)
          .eq('user_id', userId);
      updateQuery = scopeFinancialQuery(updateQuery);
      final updated = await updateQuery.select().single();

      var deleteDupQuery = supabaseClient
          .from('budgets')
          .delete()
          .eq('user_id', userId)
          .eq('year', year)
          .eq('month', month)
          .eq('category', normalizedCategory)
          .neq('budget_id', budgetId);
      deleteDupQuery = scopeFinancialQuery(deleteDupQuery);
      await deleteDupQuery;

      return BudgetModel.fromMap(updated);
    }

    var existingQuery = supabaseClient
        .from('budgets')
        .select()
        .eq('user_id', userId)
        .eq('category', normalizedCategory)
        .eq('year', year)
        .eq('month', month);
    existingQuery = scopeFinancialQuery(existingQuery);
    final existing = await existingQuery.maybeSingle();

    if (existing != null) {
      var updateQuery = supabaseClient
          .from('budgets')
          .update({'amount': amount})
          .eq('budget_id', existing['budget_id'] as String);
      updateQuery = scopeFinancialQuery(updateQuery);
      final updated = await updateQuery.select().single();
      return BudgetModel.fromMap(updated);
    }

    final inserted = await supabaseClient
        .from('budgets')
        .insert(
          scopedFinancialRow({
            'user_id': userId,
            'category': normalizedCategory,
            'amount': amount,
            'year': year,
            'month': month,
          }),
        )
        .select()
        .single();
    return BudgetModel.fromMap(inserted);
  }

  @override
  Future<void> deleteBudget(String budgetId) async {
    final userId = SupabaseAuthHelper.requireUserId();
    var deleteQuery = supabaseClient
        .from('budgets')
        .delete()
        .eq('budget_id', budgetId)
        .eq('user_id', userId);
    deleteQuery = scopeFinancialQuery(deleteQuery);
    final deleted = await deleteQuery.select('budget_id');

    ensureDeleteSucceeded(deleted);
  }

  @override
  Future<void> renameCategory(String fromCategory, String toCategory) async {
    if (fromCategory == toCategory) return;
    final userId = SupabaseAuthHelper.requireUserId();
    var updateQuery = supabaseClient
        .from('budgets')
        .update({'category': toCategory})
        .eq('user_id', userId)
        .eq('category', fromCategory);
    updateQuery = scopeFinancialQuery(updateQuery);
    await updateQuery;
  }
}
