import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/home/data/datasources/home_datasource.dart';
import 'package:imrpo/features/home/data/models/user_profile_model.dart';
import 'package:imrpo/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeDatasource homeDatasource;

  HomeRepositoryImpl({required this.homeDatasource});

  @override
  Future<Either<Failure, UserProfileModel>> getCurrentUserProfile() async {
    try {
      final profile = await homeDatasource.getCurrentUserProfile();
      return Right(profile);
    } catch (e) {
      return Left(ErrorHelper.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateUsername(String username) async {
    try {
      await homeDatasource.updateUsername(username);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHelper.handle(e));
    }
  }
}
