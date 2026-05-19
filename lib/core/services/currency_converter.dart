import 'package:imrpo/core/models/currency.dart';

/// Converts amounts using static rates (1 unit → USD).
class CurrencyConverter {
  CurrencyConverter._();

  static const String baseCode = 'USD';

  static const List<Currency> currencies = [
    Currency(code: 'USD', name: 'US Dollar', symbol: '\$', rateToUsd: 1.0),
    Currency(code: 'EUR', name: 'Euro', symbol: '€', rateToUsd: 1.08),
    Currency(code: 'GBP', name: 'British Pound', symbol: '£', rateToUsd: 1.27),
    Currency(code: 'JPY', name: 'Japanese Yen', symbol: '¥', rateToUsd: 0.0067),
    Currency(code: 'CAD', name: 'Canadian Dollar', symbol: 'C\$', rateToUsd: 0.74),
    Currency(code: 'AUD', name: 'Australian Dollar', symbol: 'A\$', rateToUsd: 0.65),
    Currency(code: 'CHF', name: 'Swiss Franc', symbol: 'CHF', rateToUsd: 1.12),
    Currency(code: 'CNY', name: 'Chinese Yuan', symbol: '¥', rateToUsd: 0.14),
    Currency(code: 'INR', name: 'Indian Rupee', symbol: '₹', rateToUsd: 0.012),
    Currency(code: 'SAR', name: 'Saudi Riyal', symbol: '﷼', rateToUsd: 0.27),
    Currency(code: 'AED', name: 'UAE Dirham', symbol: 'د.إ', rateToUsd: 0.27),
    Currency(code: 'EGP', name: 'Egyptian Pound', symbol: 'E£', rateToUsd: 0.021),
    Currency(code: 'TRY', name: 'Turkish Lira', symbol: '₺', rateToUsd: 0.031),
    Currency(code: 'MXN', name: 'Mexican Peso', symbol: '\$', rateToUsd: 0.058),
    Currency(code: 'BRL', name: 'Brazilian Real', symbol: 'R\$', rateToUsd: 0.20),
  ];

  static Currency get base => currencies.first;

  static Currency byCode(String code) {
    return currencies.firstWhere(
      (c) => c.code == code,
      orElse: () => base,
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
