import 'package:imrpo/core/helpers/supabase_auth_helper.dart';
import 'package:imrpo/core/helpers/supabase_delete_helper.dart';
import 'package:imrpo/features/plans_tab/data/datasources/plans_datasource.dart';
import 'package:imrpo/features/plans_tab/data/models/plan_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlansDatasourceImpl implements PlansDatasource {
  final SupabaseClient supabaseClient;

  PlansDatasourceImpl({required this.supabaseClient});

  @override
  Future<void> addPlan(
    String title,
    String category,
    double targetAmount,
    double savedAmount,
    DateTime? deadline,
  ) async {
    await supabaseClient.from('plans').insert({
      'title': title,
      'category': category,
      'target_amount': targetAmount,
      'saved_amount': savedAmount,
      'deadline': deadline?.toIso8601String(),
      'user_id': SupabaseAuthHelper.requireUserId(),
    });
  }

  @override
  Future<void> deletePlan(String planId) async {
    final userId = SupabaseAuthHelper.requireUserId();

    final deleted = await supabaseClient
        .from('plans')
        .delete()
        .eq('plan_id', planId)
        .eq('user_id', userId)
        .select('plan_id');

    ensureDeleteSucceeded(deleted);
  }

  @override
  Future<List<PlanModel>> getPlans() async {
    final userId = SupabaseAuthHelper.requireUserId();
    final response = await supabaseClient
        .from('plans')
        .select()
        .eq('user_id', userId);

    return response.map((item) => PlanModel.fromMap(item)).toList();
  }

  @override
  Future<void> updatePlan(
    String planId,
    String title,
    String category,
    double targetAmount,
    double savedAmount,
    DateTime? deadline,
  ) async {
    await supabaseClient.from('plans').update({
      'title': title,
      'category': category,
      'target_amount': targetAmount,
      'saved_amount': savedAmount,
      'deadline': deadline?.toIso8601String(),
    }).eq('plan_id', planId);
  }

  @override
  Future<void> updatePlanSaved(String planId, double savedAmount) async {
    await supabaseClient.from('plans').update({
      'saved_amount': savedAmount,
    }).eq('plan_id', planId);
  }
}
