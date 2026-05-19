import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/auth/domain/repositories/auth_repository.dart';

class SignupUsecase {
  final AuthRepository authRepository;

  SignupUsecase({required this.authRepository});

  Future<Either<Failure, void>> call(
    String username,
    String email,
    String password,
  ) async {
    return await authRepository.signup(username, email, password);
  }
}
