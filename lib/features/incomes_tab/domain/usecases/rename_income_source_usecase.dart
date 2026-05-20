import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/incomes_tab/domain/repositories/income_repository.dart';

class RenameIncomeSourceUsecase {
  final IncomeRepository incomeRepository;

  RenameIncomeSourceUsecase({required this.incomeRepository});

  Future<Either<Failure, int>> call({
    required String fromSource,
    required String toSource,
  }) {
    return incomeRepository.renameCategory(fromSource, toSource);
  }
}
