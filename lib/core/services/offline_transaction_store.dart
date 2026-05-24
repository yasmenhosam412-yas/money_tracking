import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:imrpo/core/helpers/supabase_auth_helper.dart';
import 'package:imrpo/core/models/pending_transaction.dart';
import 'package:imrpo/core/services/association_context.dart';
import 'package:imrpo/core/services/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Queues incomes/expenses in SharedPreferences until Supabase is reachable.
class OfflineTransactionStore extends ChangeNotifier {
  static const _keyPrefix = 'offline_transactions_v1_';
  static int _idCounter = 0;

  static String _newLocalId() {
    _idCounter++;
    return '${DateTime.now().microsecondsSinceEpoch}_$_idCounter';
  }
  List<PendingTransaction> _items = [];
  bool _loaded = false;

  List<PendingTransaction> get items => List.unmodifiable(_items);

  int get pendingCount => _items.length;

  Future<void> load() async {
    final userId = SupabaseAuthHelper.userId;
    if (userId == null) {
      _items = [];
      _loaded = true;
      notifyListeners();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_keyPrefix$userId');
    if (raw == null || raw.isEmpty) {
      _items = [];
    } else {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _items = list
            .map(
              (e) => PendingTransaction.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList();
      } catch (_) {
        _items = [];
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final userId = SupabaseAuthHelper.userId;
    if (userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_items.map((e) => e.toJson()).toList());
    await prefs.setString('$_keyPrefix$userId', encoded);
  }

  Future<String?> _activeLedgerId() async {
    final ctx = getIt<AssociationContext>();
    final active = ctx.activeAssociationId;
    if (active != null && active.isNotEmpty) return active;
    return ctx.peekSavedActiveAssociationId();
  }

  Future<List<PendingTransaction>> forActiveLedger(
    PendingTransactionKind kind,
  ) async {
    final ledgerId = await _activeLedgerId();
    return _items.where((item) {
      if (item.kind != kind) return false;
      if (ledgerId == null || ledgerId.isEmpty) {
        return item.associationId == null || item.associationId!.isEmpty;
      }
      return item.associationId == ledgerId;
    }).toList();
  }

  Future<PendingTransaction> enqueueExpense({
    required String title,
    required String category,
    required double amount,
    required DateTime date,
    String? incomeSource,
    String? entryCurrency,
    double? entryAmount,
  }) async {
    if (!_loaded) await load();
    final ledgerId = await _activeLedgerId();
    final item = PendingTransaction(
      localId: _newLocalId(),
      kind: PendingTransactionKind.expense,
      title: title,
      category: category,
      amount: amount,
      date: date,
      incomeSource: incomeSource,
      entryCurrency: entryCurrency,
      entryAmount: entryAmount,
      associationId: ledgerId,
      createdAt: DateTime.now(),
    );
    _items.insert(0, item);
    await _persist();
    notifyListeners();
    return item;
  }

  Future<PendingTransaction> enqueueIncome({
    required String title,
    required String category,
    required double amount,
    required DateTime date,
    String? entryCurrency,
    double? entryAmount,
  }) async {
    if (!_loaded) await load();
    final ledgerId = await _activeLedgerId();
    final item = PendingTransaction(
      localId: _newLocalId(),
      kind: PendingTransactionKind.income,
      title: title,
      category: category,
      amount: amount,
      date: date,
      entryCurrency: entryCurrency,
      entryAmount: entryAmount,
      associationId: ledgerId,
      createdAt: DateTime.now(),
    );
    _items.insert(0, item);
    await _persist();
    notifyListeners();
    return item;
  }

  Future<void> removeByLocalId(String localId) async {
    if (!_loaded) await load();
    _items.removeWhere((item) => item.localId == localId);
    await _persist();
    notifyListeners();
  }

  Future<void> clearForUser() async {
    _items = [];
    await _persist();
    notifyListeners();
  }

  List<PendingTransaction> allPending() {
    if (!_loaded) return [];
    return List.unmodifiable(_items);
  }
}
