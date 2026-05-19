import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/auth/domain/repositories/auth_repository.dart';

class ForgetPasswordUsecase {
  final AuthRepository authRepository;

  ForgetPasswordUsecase({required this.authRepository});

  Future<Either<Failure, void>> call(String email) async {
    return await authRepository.forgetPassword(email);
  }
}
