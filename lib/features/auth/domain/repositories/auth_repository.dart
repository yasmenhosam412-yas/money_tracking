import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> signup(
    String username,
    String email,
    String password,
  );
  Future<Either<Failure, void>> login(String email, String password);
  Future<Either<Failure, void>> forgetPassword(String email);
  Future<Either<Failure, void>> verifyOTP(String newPassword, String otp, String email);

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, void>> deleteAccount();
}
