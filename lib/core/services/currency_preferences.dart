import 'package:flutter/foundation.dart';
import 'package:imrpo/core/services/currency_converter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyPreferences extends ChangeNotifier {
  static const _storageKey = 'display_currency_code';

  String _displayCode = CurrencyConverter.defaultDisplayCode;

  String get displayCode => _displayCode;

  /// Loads the last selected currency from device storage.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_storageKey);
    if (saved != null && _isSupported(saved)) {
      _displayCode = saved;
      notifyListeners();
    }
  }

  set displayCode(String code) {
    if (!_isSupported(code) || _displayCode == code) return;
    _displayCode = code;
    notifyListeners();
    _persist(code);
  }

  Future<void> _persist(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, code);
  }

  bool _isSupported(String code) =>
      CurrencyConverter.currencies.any((c) => c.code == code);

  double displayAmount(double baseAmount) =>
      CurrencyConverter.fromBase(baseAmount, _displayCode);

  String formatBase(double baseAmount) => CurrencyConverter.format(
        displayAmount(baseAmount),
        _displayCode,
      );
}
