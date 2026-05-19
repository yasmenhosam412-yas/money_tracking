import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/incomes_tab/domain/repositories/income_repository.dart';

class DeleteAllIncomesUsecase {
  final IncomeRepository incomeRepository;

  DeleteAllIncomesUsecase({required this.incomeRepository});

  Future<Either<Failure, void>> call() => incomeRepository.deleteAllIncomes();
}
