import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/plans_tab/domain/repositories/plan_repository.dart';

class UpdatePlanSavedUsecase {
  final PlanRepository planRepository;

  UpdatePlanSavedUsecase({required this.planRepository});

  Future<Either<Failure, void>> call(String planId, double savedAmount) {
    return planRepository.updatePlanSaved(planId, savedAmount);
  }
}
