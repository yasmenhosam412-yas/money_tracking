import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/incomes_tab/data/models/income_model.dart';
import 'package:imrpo/features/incomes_tab/domain/repositories/income_repository.dart';

class GetAllIncomesUsecase {
  final IncomeRepository incomeRepository;

  GetAllIncomesUsecase({required this.incomeRepository});

  Future<Either<Failure,List<IncomeModel>>> call() async {
    return await incomeRepository.getIncomes();
  }
}
