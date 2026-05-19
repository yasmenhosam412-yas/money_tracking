import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/plans_tab/data/models/plan_model.dart';
import 'package:imrpo/features/plans_tab/domain/repositories/plan_repository.dart';

class GetAllPlansUsecase {
  final PlanRepository planRepository;

  GetAllPlansUsecase({required this.planRepository});

  Future<Either<Failure, List<PlanModel>>> call() {
    return planRepository.getPlans();
  }
}
