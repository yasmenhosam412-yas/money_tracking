part of 'plans_tab_bloc.dart';

enum PlansTabStatus {
  initial,
  loading,
  loaded,
  error,
  loadingAdd,
  errorAdd,
  loadingUpdate,
  errorUpdate,
  loadingDelete,
  errorDelete,
  loadingUpdateSaved,
  errorUpdateSaved,
}

abstract class PlansTabState extends Equatable {
  const PlansTabState();

  @override
  List<Object?> get props => [];
}

class PlansTabInitial extends PlansTabState {
  const PlansTabInitial();
}

class PlansTabLoaded extends PlansTabState {
  final List<Plan> plans;
  final PlansTabStatus status;
  final String error;
  final String? deletingPlanId;

  const PlansTabLoaded({
    required this.plans,
    this.status = PlansTabStatus.loaded,
    this.error = '',
    this.deletingPlanId,
  });

  bool get hasData => plans.isNotEmpty;

  double get totalTarget =>
      plans.fold(0, (sum, plan) => sum + plan.targetAmount);

  double get totalSaved =>
      plans.fold(0, (sum, plan) => sum + plan.savedAmount);

  double get overallProgress {
    if (totalTarget <= 0) return 0;
    return (totalSaved / totalTarget).clamp(0.0, 1.0);
  }

  int get completedCount => plans.where((p) => p.isCompleted).length;

  PlansTabLoaded copyWith({
    List<Plan>? plans,
    PlansTabStatus? status,
    String? error,
    String? deletingPlanId,
  }) {
    return PlansTabLoaded(
      plans: plans ?? this.plans,
      status: status ?? this.status,
      error: error ?? this.error,
      deletingPlanId: deletingPlanId,
    );
  }

  @override
  List<Object?> get props => [plans, status, error, deletingPlanId];
}
