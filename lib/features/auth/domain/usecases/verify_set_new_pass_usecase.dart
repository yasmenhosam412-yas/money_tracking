import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/auth/domain/repositories/auth_repository.dart';

class VerifySetNewPassUsecase {
  final AuthRepository authRepository;

  VerifySetNewPassUsecase({required this.authRepository});

  Future<Either<Failure,void>> call(String newPassword, String otp, String email) async {
    return await authRepository.verifyOTP(newPassword, otp, email);
    
  }
}
