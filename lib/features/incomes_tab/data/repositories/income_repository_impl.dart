import 'package:dartz/dartz.dart';
import 'package:imrpo/core/helpers/error_helper.dart';
import 'package:imrpo/core/models/pending_transaction.dart';
import 'package:imrpo/core/models/transaction_entry_meta.dart';
import 'package:imrpo/core/services/association_context.dart';
import 'package:imrpo/core/services/offline_transaction_store.dart';
import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/core/utils/pending_transaction_mappers.dart';
import 'package:imrpo/features/incomes_tab/data/datasources/income_datasource.dart';
import 'package:imrpo/features/incomes_tab/data/models/income_model.dart';
import 'package:imrpo/features/incomes_tab/domain/repositories/income_repository.dart';

class IncomeRepositoryImpl extends IncomeRepository {
  final IncomeDatasource incomeDatasource;

  IncomeRepositoryImpl({required this.incomeDatasource});

  OfflineTransactionStore get _offlineStore => getIt<OfflineTransactionStore>();

  bool get _isOfflineMode => getIt<AssociationContext>().isOffline;

  Future<List<IncomeModel>> _pendingForActiveLedger() async {
    await _offlineStore.load();
    final pending = await _offlineStore.forActiveLedger(
      PendingTransactionKind.income,
    );
    return pendingToIncomeModels(pending);
  }

  Future<Either<Failure, void>> _queueIncomeOffline({
    required String title,
    required double amount,
    required DateTime date,
    required String category,
    TransactionEntryMeta? entryMeta,
  }) async {
    await _offlineStore.enqueueIncome(
      title: title,
      category: category,
      amount: amount,
      date: date,
      entryCurrency: entryMeta?.entryCurrency,
      entryAmount: entryMeta?.entryAmount,
    );
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> addIncome(
    String title,
    double amount,
    DateTime date,
    String category, {
    TransactionEntryMeta? entryMeta,
  }) async {
    if (_isOfflineMode) {
      return _queueIncomeOffline(
        title: title,
        amount: amount,
        date: date,
        category: category,
        entryMeta: entryMeta,
      );
    }

    try {
      await incomeDatasource.addIncome(
        title,
        amount,
        date,
        category,
        entryMeta: entryMeta,
      );
      return const Right(null);
    } catch (e) {
      final failure = ErrorHelper.handle(e);
      if (failure is NetworkError) {
        return _queueIncomeOffline(
          title: title,
          amount: amount,
          date: date,
          category: category,
          entryMeta: entryMeta,
        );
      }
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> deleteIncome(String incomeId) async {
    if (PendingTransaction.isOfflinePublicId(incomeId)) {
      await _offlineStore.removeByLocalId(
        PendingTransaction.localIdFromPublic(incomeId),
      );
      return const Right(null);
    }

    try {
      await incomeDatasource.deleteIncome(incomeId);
      return const Right(null);
    } catch (e) {
      return Left(ErrorHelper.handle(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAllIncomes() async {
    try {
      await incomeDatasource.deleteAllIncomes();
      return const Right(null);
    } catch (e) {
      return Left(ErrorHelper.handle(e));
    }
  }

  @override
  Future<Either<Failure, List<IncomeModel>>> getIncomes() async {
    try {
      final incomes = await incomeDatasource.getIncomes();
      final pending = await _pendingForActiveLedger();
      return Right(mergeIncomes(incomes, pending));
    } catch (e) {
      final failure = ErrorHelper.handle(e);
      if (failure is NetworkError) {
        return Right(await _pendingForActiveLedger());
      }
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> updateIncome(
    String incomeId,
    String title,
    double amount,
    DateTime date,
    String category, {
    TransactionEntryMeta? entryMeta,
  }) async {
    if (PendingTransaction.isOfflinePublicId(incomeId)) {
      return Left(
        UnknownError(error: 'Edit this entry after you are back online.'),
      );
    }

    try {
      await incomeDatasource.updateIncome(
        incomeId,
        title,
        amount,
        date,
        category,
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
      final count = await incomeDatasource.renameCategory(
        fromCategory,
        toCategory,
      );
      return Right(count);
    } catch (e) {
      return Left(ErrorHelper.handle(e));
    }
  }

  @override
  Future<Either<Failure, int>> deleteByCategory(String category) async {
    try {
      final count = await incomeDatasource.deleteByCategory(category);
      return Right(count);
    } catch (e) {
      return Left(ErrorHelper.handle(e));
    }
  }
}
