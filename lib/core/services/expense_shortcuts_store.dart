import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:imrpo/features/expenses_tab/domain/entities/expense_shortcut.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists user-defined one-tap expense shortcuts on device.
class ExpenseShortcutsStore extends ChangeNotifier {
  static const _prefsKey = 'expense_shortcuts_v1';

  List<ExpenseShortcut> _items = [];

  List<ExpenseShortcut> get items => List.unmodifiable(_items);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) {
      _items = [];
      notifyListeners();
      return;
    }
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _items = decoded
          .map(
            (e) => ExpenseShortcut.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
    } catch (_) {
      _items = [];
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_items.map((e) => e.toJson()).toList());
    await prefs.setString(_prefsKey, encoded);
    notifyListeners();
  }

  Future<void> upsert(ExpenseShortcut shortcut) async {
    final idx = _items.indexWhere((e) => e.id == shortcut.id);
    if (idx >= 0) {
      _items = [..._items]..[idx] = shortcut;
    } else {
      _items = [..._items, shortcut];
    }
    await _persist();
  }

  Future<void> remove(String id) async {
    _items = _items.where((e) => e.id != id).toList();
    await _persist();
  }
}
