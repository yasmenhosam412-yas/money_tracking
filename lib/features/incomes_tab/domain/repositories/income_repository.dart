import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/incomes_tab/data/models/income_model.dart';

abstract class IncomeRepository {
  Future<Either<Failure,void>> addIncome(String title, double amount, DateTime date, String category);
  Future<Either<Failure,void>> deleteIncome(String incomeId);
  Future<Either<Failure,void>> updateIncome(String incomeId, String title, double amount, DateTime date, String category);
  Future<Either<Failure,List<IncomeModel>>> getIncomes();
}