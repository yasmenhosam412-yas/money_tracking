import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/home/data/models/user_profile_model.dart';

abstract class HomeRepository {
  Future<Either<Failure, UserProfileModel>> getCurrentUserProfile();

  Future<Either<Failure, void>> updateUsername(String username);
}
