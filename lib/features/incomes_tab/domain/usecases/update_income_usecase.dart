import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/incomes_tab/domain/repositories/income_repository.dart';

class UpdateIncomeUsecase {
  final IncomeRepository incomeRepository;

  UpdateIncomeUsecase({required this.incomeRepository});

  Future<Either<Failure, void>> call(
    String incomeId,
    String title,
    double amount,
    DateTime date,
    String category,
  ) async {
    return await incomeRepository.updateIncome(
      incomeId,
      title,
      amount,
      date,
      category,
    );
  }
}
