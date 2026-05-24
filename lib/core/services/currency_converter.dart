import 'package:imrpo/core/models/currency.dart';

/// Converts amounts using static rates (1 unit → USD).
class CurrencyConverter {
  CurrencyConverter._();

  /// Internal storage currency (amounts saved in DB).
  static const String baseCode = 'USD';

  /// Only currency shown and entered in the app UI.
  static const String defaultDisplayCode = 'EGP';

  static const Currency _storageCurrency = Currency(
    code: 'USD',
    name: 'US Dollar',
    symbol: r'$',
    rateToUsd: 1.0,
  );

  static const List<Currency> currencies = [
    Currency(
      code: 'EGP',
      name: 'Egyptian Pound',
      symbol: 'E£',
      rateToUsd: 0.021,
    ),
    Currency(
      code: 'USD',
      name: 'US Dollar',
      symbol: r'$',
      rateToUsd: 1.0,
    ),
    Currency(
      code: 'EUR',
      name: 'Euro',
      symbol: '€',
      rateToUsd: 1.08,
    ),
  ];

  /// Currencies selectable when logging a transaction (travel mode).
  static List<Currency> get entryCurrencies => currencies;

  static bool isDefaultEntryCurrency(String code) =>
      code == defaultDisplayCode;

  static Currency get base => _storageCurrency;

  static Currency byCode(String code) {
    if (code == baseCode) return _storageCurrency;
    return currencies.firstWhere(
      (c) => c.code == code,
      orElse: () => currencies.first,
    );
  }

  /// Convert [amount] from [fromCode] to [toCode].
  static double convert({
    required double amount,
    required String fromCode,
    required String toCode,
  }) {
    if (fromCode == toCode) return amount;
    final from = byCode(fromCode);
    final to = byCode(toCode);
    final inUsd = amount * from.rateToUsd;
    return inUsd / to.rateToUsd;
  }

  /// Store everything in base (USD).
  static double toBase(double amount, String fromCode) =>
      convert(amount: amount, fromCode: fromCode, toCode: baseCode);

  static double fromBase(double baseAmount, String toCode) =>
      convert(amount: baseAmount, fromCode: baseCode, toCode: toCode);

  static String format(double amount, String currencyCode) {
    final currency = byCode(currencyCode);
    final value = amount == amount.roundToDouble()
        ? amount.toInt().toString()
        : amount.toStringAsFixed(2);
    return '${currency.symbol}$value';
  }

  static String formatConverted({
    required double amount,
    required String fromCode,
    required String toCode,
  }) {
    final converted = convert(
      amount: amount,
      fromCode: fromCode,
      toCode: toCode,
    );
    return format(converted, toCode);
  }
}
