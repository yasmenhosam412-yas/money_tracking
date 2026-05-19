import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/home/domain/repositories/home_repository.dart';

class UpdateUsernameUsecase {
  final HomeRepository homeRepository;

  UpdateUsernameUsecase({required this.homeRepository});

  Future<Either<Failure, void>> call(String username) {
    return homeRepository.updateUsername(username);
  }
}
