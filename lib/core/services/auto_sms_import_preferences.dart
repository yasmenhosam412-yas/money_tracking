import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User settings for background SMS auto-import (Android only).
class AutoSmsImportPreferences extends ChangeNotifier {
  static const _enabledKey = 'auto_sms_import_enabled';
  static const _defaultsConfiguredKey = 'auto_sms_import_defaults_configured';
  static const _expenseCategoryKey = 'auto_sms_import_expense_category';
  static const _incomeSourceKey = 'auto_sms_import_income_source';
  static const _expensePaidFromKey = 'auto_sms_import_expense_paid_from';
  static const _lastScanMsKey = 'auto_sms_import_last_scan_ms';

  static const defaultExpenseCategory = 'Bills';
  static const defaultIncomeSource = 'Other';
  static const defaultExpensePaidFrom = 'Cash';

  bool _enabled = false;
  bool _defaultsConfigured = false;
  String _expenseCategory = defaultExpenseCategory;
  String _incomeSource = defaultIncomeSource;
  String _expensePaidFrom = defaultExpensePaidFrom;
  DateTime? _lastScanAt;

  bool get enabled => _enabled;
  bool get defaultsConfigured => _defaultsConfigured;
  String get expenseCategory => _expenseCategory;
  String get incomeSource => _incomeSource;
  String get expensePaidFrom => _expensePaidFrom;
  DateTime? get lastScanAt => _lastScanAt;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_enabledKey) ?? false;
    _defaultsConfigured = prefs.getBool(_defaultsConfiguredKey) ?? false;
    _expenseCategory =
        prefs.getString(_expenseCategoryKey) ?? defaultExpenseCategory;
    _incomeSource = prefs.getString(_incomeSourceKey) ?? defaultIncomeSource;
    _expensePaidFrom =
        prefs.getString(_expensePaidFromKey) ?? defaultExpensePaidFrom;
    final lastMs = prefs.getInt(_lastScanMsKey);
    _lastScanAt = lastMs != null
        ? DateTime.fromMillisecondsSinceEpoch(lastMs)
        : null;
    notifyListeners();
  }

  Future<void> setDefaults({
    required String expenseCategory,
    required String incomeSource,
    required String expensePaidFrom,
  }) async {
    _expenseCategory = expenseCategory;
    _incomeSource = incomeSource;
    _expensePaidFrom = expensePaidFrom;
    _defaultsConfigured = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_expenseCategoryKey, expenseCategory);
    await prefs.setString(_incomeSourceKey, incomeSource);
    await prefs.setString(_expensePaidFromKey, expensePaidFrom);
    await prefs.setBool(_defaultsConfiguredKey, true);
  }

  Future<void> setEnabled(
    bool value, {
    bool markScanFromNow = false,
  }) async {
    _enabled = value;
    if (markScanFromNow) {
      _lastScanAt = DateTime.now();
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);
    if (markScanFromNow && _lastScanAt != null) {
      await prefs.setInt(_lastScanMsKey, _lastScanAt!.millisecondsSinceEpoch);
    }
  }

  Future<void> markScanComplete([DateTime? at]) async {
    _lastScanAt = at ?? DateTime.now();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastScanMsKey, _lastScanAt!.millisecondsSinceEpoch);
  }
}
