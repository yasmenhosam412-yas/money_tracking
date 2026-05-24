import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/core/models/pending_transaction.dart';
import 'package:imrpo/core/models/transaction_entry_meta.dart';
import 'package:imrpo/core/services/association_context.dart';
import 'package:imrpo/core/services/offline_transaction_store.dart';
import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/core/utils/pending_transaction_mappers.dart';
import 'package:imrpo/features/budgets/data/datasources/budget_datasource.dart';
import 'package:imrpo/features/expenses_tab/data/datasources/expenses_datasource.dart';
import 'package:imrpo/features/expenses_tab/data/models/expense_model.dart';
import 'package:imrpo/features/expenses_tab/domain/repositories/expense_repository.dart';

class ExpenseRepositroyImpl extends ExpenseRepository {
  final ExpensesDatasource expensesDatasource;
  final BudgetDatasource budgetDatasource;

  ExpenseRepositroyImpl({
    required this.expensesDatasource,
    required this.budgetDatasource,
  });

  OfflineTransactionStore get _offlineStore => getIt<OfflineTransactionStore>();

  bool get _isOfflineMode => getIt<AssociationContext>().isOffline;

  Future<List<ExpenseModel>> _pendingForActiveLedger() async {
    await _offlineStore.load();
    final pending = await _offlineStore.forActiveLedger(
      PendingTransactionKind.expense,
    );
    return pendingToExpenseModels(pending);
  }

  Future<Either<Failure, void>> _queueExpenseOffline({
    required String title,
    required String category,
    required double amount,
    required DateTime date,
    String? incomeSource,
    TransactionEntryMeta? entryMeta,
  }) async {
    await _offlineStore.enqueueExpense(
      title: title,
      category: category,
      amount: amount,
      date: date,
      incomeSource: incomeSource,
      entryCurrency: entryMeta?.entryCurrency,
      entryAmount: entryMeta?.entryAmount,
    );
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> addExpense(
    String title,
    String category,
    double amount,
    DateTime date, {
    String? incomeSource,
    String? receiptUrl,
    TransactionEntryMeta? entryMeta,
  }) async {
    if (_isOfflineMode) {
      if (receiptUrl != null && receiptUrl.trim().isNotEmpty) {
        return Left(
          UnknownError(
            error: 'Receipts can only be attached when you are online.',
          ),
        );
      }
      return _queueExpenseOffline(
        title: title,
        category: category,
        amount: amount,
        date: date,
        incomeSource: incomeSource,
        entryMeta: entryMeta,
      );
    }

    try {
      await expensesDatasource.addExpense(
        title,
        amount,
        category,
        date,
        incomeSource: incomeSource,
        receiptUrl: receiptUrl,
        entryMeta: entryMeta,
      );
      return const Right(null);
    } catch (e) {
      final failure = ErrorHelper.handle(e);
      if (failure is NetworkError) {
        if (receiptUrl != null && receiptUrl.trim().isNotEmpty) {
          return Left(
            UnknownError(
              error: 'Receipts can only be attached when you are online.',
            ),
          );
        }
        return _queueExpenseOffline(
          title: title,
          category: category,
          amount: amount,
          date: date,
          incomeSource: incomeSource,
          entryMeta: entryMeta,
        );
      }
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> deleteExpense(String expenseId) async {
    if (PendingTransaction.isOfflinePublicId(expenseId)) {
      await _offlineStore.removeByLocalId(
        PendingTransaction.localIdFromPublic(expenseId),
      );
      return const Right(null);
    }

    try {
      await expensesDatasource.deleteExpense(expenseId);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHelper.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAllExpenses() async {
    try {
      await expensesDatasource.deleteAllExpenses();
      return const Right(null);
    } catch (e) {
      return Left(ErrorHelper.handle(e));
    }
  }

  @override
  Future<Either<Failure, List<ExpenseModel>>> getExpenses() async {
    try {
      final expenses = await expensesDatasource.getExpenses();
      final pending = await _pendingForActiveLedger();
      return Right(mergeExpenses(expenses, pending));
    } catch (e) {
      final failure = ErrorHelper.handle(e);
      if (failure is NetworkError) {
        return Right(await _pendingForActiveLedger());
      }
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> updateExpense(
    String title,
    String category,
    double amount,
    DateTime date,
    String expenseId, {
    String? incomeSource,
    String? receiptUrl,
    bool clearReceipt = false,
    TransactionEntryMeta? entryMeta,
  }) async {
    if (PendingTransaction.isOfflinePublicId(expenseId)) {
      return Left(
        UnknownError(error: 'Edit this entry after you are back online.'),
      );
    }

    try {
      await expensesDatasource.updateExpense(
        expenseId,
        title,
        amount,
        category,
        date,
        incomeSource: incomeSource,
        receiptUrl: receiptUrl,
        clearReceipt: clearReceipt,
        entryMeta: entryMeta,
      );
      return const Right(null);
    } catch (e) {
      return Left(ErrorHelper.handle(e));
    }
  }

  @override
  Future<Either<Failure, int>> renameCategory(
    String fromCategory,
    String toCategory,
  ) async {
    try {
      final count = await expensesDatasource.renameCategory(
        fromCategory,
        toCategory,
      );
      try {
        await budgetDatasource.renameCategory(fromCategory, toCategory);
      } catch (_) {}
      return Right(count);
    } catch (e) {
      return Left(ErrorHelper.handle(e));
    }
  }

  @override
  Future<Either<Failure, int>> deleteByCategory(String category) async {
    try {
      final count = await expensesDatasource.deleteByCategory(category);
      return Right(count);
    } catch (e) {
      return Left(ErrorHelper.handle(e));
    }
  }
}
