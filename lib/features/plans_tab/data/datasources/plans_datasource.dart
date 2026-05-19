import 'package:imrpo/features/plans_tab/data/models/plan_model.dart';

abstract class PlansDatasource {
  Future<void> addPlan(
    String title,
    String category,
    double targetAmount,
    double savedAmount,
    DateTime? deadline,
  );

  Future<void> updatePlan(
    String planId,
    String title,
    String category,
    double targetAmount,
    double savedAmount,
    DateTime? deadline,
  );

  Future<void> updatePlanSaved(String planId, double savedAmount);

  Future<void> deletePlan(String planId);

  Future<List<PlanModel>> getPlans();
}
