import 'package:flutter/foundation.dart';
import 'package:imrpo/core/helpers/supabase_auth_helper.dart';
import 'package:imrpo/core/models/pending_transaction.dart';
import 'package:imrpo/core/models/transaction_entry_meta.dart';
import 'package:imrpo/core/services/association_context.dart';
import 'package:imrpo/core/services/offline_transaction_store.dart';
import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/core/utils/network_errors.dart';
import 'package:imrpo/features/expenses_tab/data/datasources/expenses_datasource.dart';
import 'package:imrpo/features/incomes_tab/data/datasources/income_datasource.dart';

class OfflineTransactionSyncService {
  Future<int> flushIfOnline() async {
    if (!SupabaseAuthHelper.isSignedIn) return 0;
    if (getIt<AssociationContext>().isOffline) return 0;

    final store = getIt<OfflineTransactionStore>();
    await store.load();
    final pending = List<PendingTransaction>.from(store.allPending());
    if (pending.isEmpty) return 0;

    final associations = getIt<AssociationContext>();
    final previousActive = associations.activeAssociationId;
    var synced = 0;
    final expenses = getIt<ExpensesDatasource>();
    final incomes = getIt<IncomeDatasource>();

    for (final item in pending) {
      try {
        await _ensureActiveAssociation(item.associationId, associations);
        await _pushOne(item, expenses: expenses, incomes: incomes);
        await store.removeByLocalId(item.localId);
        synced++;
      } catch (e, st) {
        if (isNetworkError(e)) {
          debugPrint('OfflineTransactionSync: still offline');
          break;
        }
        debugPrint('OfflineTransactionSync: failed ${item.localId}: $e\n$st');
      }
    }

    final restore = previousActive;
    if (restore != null &&
        restore.isNotEmpty &&
        restore != associations.activeAssociationId) {
      await associations.selectAssociation(restore);
    }
    return synced;
  }

  Future<void> _ensureActiveAssociation(
    String? associationId,
    AssociationContext associations,
  ) async {
    if (associationId == null || associationId.isEmpty) return;
    if (associations.activeAssociationId == associationId) return;
    if (associations.items.any((i) => i.id == associationId)) {
      await associations.selectAssociation(associationId);
    }
  }

  Future<void> _pushOne(
    PendingTransaction item, {
    required ExpensesDatasource expenses,
    required IncomeDatasource incomes,
  }) async {
    final entryMeta = _entryMeta(item);
    final associationOverride = item.associationId;

    if (item.kind == PendingTransactionKind.expense) {
      await expenses.addExpense(
        item.title,
        item.amount,
        item.category,
        item.date,
        incomeSource: item.incomeSource,
        entryMeta: entryMeta,
        associationIdOverride: associationOverride,
      );
      return;
    }

    await incomes.addIncome(
      item.title,
      item.amount,
      item.date,
      item.category,
      entryMeta: entryMeta,
      associationIdOverride: associationOverride,
    );
  }

  TransactionEntryMeta? _entryMeta(PendingTransaction item) {
    if (item.entryCurrency == null || item.entryAmount == null) return null;
    return TransactionEntryMeta(
      entryCurrency: item.entryCurrency!,
      entryAmount: item.entryAmount!,
    );
  }
}
