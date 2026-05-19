import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/expenses_tab/data/models/expense_model.dart';
import 'package:imrpo/features/expenses_tab/domain/repositories/expense_repository.dart';

class GetAllExpensesUsecase {
  final ExpenseRepository expenseRepository;

  GetAllExpensesUsecase({required this.expenseRepository});
  Future<Either<Failure, List<ExpenseModel>>> call() async {
    return await expenseRepository.getExpenses();
  }
}
