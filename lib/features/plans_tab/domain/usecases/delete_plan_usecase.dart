import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/plans_tab/domain/repositories/plan_repository.dart';

class DeletePlanUsecase {
  final PlanRepository planRepository;

  DeletePlanUsecase({required this.planRepository});

  Future<Either<Failure, void>> call(String planId) {
    return planRepository.deletePlan(planId);
  }
}
