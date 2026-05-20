import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/incomes_tab/domain/repositories/income_repository.dart';

class DeleteIncomesBySourceUsecase {
  final IncomeRepository incomeRepository;

  DeleteIncomesBySourceUsecase({required this.incomeRepository});

  Future<Either<Failure, int>> call(String source) {
    return incomeRepository.deleteByCategory(source);
  }
}
