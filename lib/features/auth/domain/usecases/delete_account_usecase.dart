import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/auth/domain/repositories/auth_repository.dart';

class DeleteAccountUsecase {
  final AuthRepository authRepository;

  DeleteAccountUsecase({required this.authRepository});

  Future<Either<Failure, void>> call() => authRepository.deleteAccount();
}
