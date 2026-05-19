import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/features/expenses_tab/domain/repositories/expense_repository.dart';

class DeleteAllExpensesUsecase {
  final ExpenseRepository expenseRepository;

  DeleteAllExpensesUsecase({required this.expenseRepository});

  Future<Either<Failure, void>> call() => expenseRepository.deleteAllExpenses();
}
