import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/incomes_tab/domain/repositories/income_repository.dart';

class AddIncomeUsecase {
  final IncomeRepository incomeRepository;

  AddIncomeUsecase({required this.incomeRepository});

  Future<Either<Failure,void>> call(
    String title,
    double amount,
    DateTime date,
    String category,
  ) async {
    return await incomeRepository.addIncome(
      title,
      amount,
      date,
      category,
    );
  }
}
