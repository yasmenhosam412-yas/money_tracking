import 'package:imrpo/features/plans_tab/domain/entities/plan.dart';

class PlanModel extends Plan {
  const PlanModel({
    required super.id,
    required super.title,
    required super.category,
    required super.targetAmount,
    required super.savedAmount,
    super.deadline,
  });

  factory PlanModel.fromMap(Map<String, dynamic> map) {
    final deadlineRaw = map['deadline'];
    return PlanModel(
      id: map['plan_id'] as String,
      title: map['title'] as String,
      category: map['category'] as String,
      targetAmount: (map['target_amount'] as num).toDouble(),
      savedAmount: (map['saved_amount'] as num).toDouble(),
      deadline: deadlineRaw != null
          ? DateTime.parse(deadlineRaw as String)
          : null,
    );
  }
}
