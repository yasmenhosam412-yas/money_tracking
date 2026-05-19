import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/home/data/models/user_profile_model.dart';
import 'package:imrpo/features/home/domain/repositories/home_repository.dart';

class GetUserProfileUsecase {
  final HomeRepository homeRepository;

  GetUserProfileUsecase({required this.homeRepository});

  Future<Either<Failure, UserProfileModel>> call() {
    return homeRepository.getCurrentUserProfile();
  }
}
