import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/incomes_tab/data/datasources/income_datasource.dart';
import 'package:imrpo/features/incomes_tab/data/models/income_model.dart';
import 'package:imrpo/features/incomes_tab/domain/repositories/income_repository.dart';

class IncomeRepositoryImpl extends IncomeRepository {
  final IncomeDatasource incomeDatasource;

  IncomeRepositoryImpl({required this.incomeDatasource});
  @override
  Future<Either<Failure, void>> addIncome(
    String title,
    double amount,
    DateTime date,
    String category,
  ) async {
    try {
      await incomeDatasource.addIncome(title, amount, date, category);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHelper.handle(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteIncome(String incomeId) async {
    try {
      await incomeDatasource.deleteIncome(incomeId);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHelper.handle(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<IncomeModel>>> getIncomes() async {
    try {
      final incomes = await incomeDatasource.getIncomes();
      return Right(incomes);
    } catch (e) {
      return Left(ErrorHelper.handle(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateIncome(
    String incomeId,
    String title,
    double amount,
    DateTime date,
    String category,
  ) async {
    try {
      await incomeDatasource.updateIncome(
        incomeId,
        title,
        amount,
        date,
        category,
      );
      return const Right(null);
    } catch (e) {
      return Left(ErrorHelper.handle(e.toString()));
    }
  }
}
