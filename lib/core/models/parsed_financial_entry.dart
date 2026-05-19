import 'package:imrpo/core/services/currency_converter.dart';

enum FinancialEntryType { expense, income }

/// Data extracted from invoice OCR or bank SMS text.
class ParsedFinancialEntry {
  final String? title;
  /// Amount in [currencyCode] as read from the message (not app base currency).
  final double? amount;
  final String? currencyCode;
  final DateTime? date;
  final FinancialEntryType type;
  final String rawText;

  const ParsedFinancialEntry({
    this.title,
    this.amount,
    this.currencyCode,
    this.date,
    required this.type,
    required this.rawText,
  });

  String get sourceCurrencyCode =>
      currencyCode ?? CurrencyConverter.baseCode;

  double? get amountInBase {
    if (amount == null) return null;
    return CurrencyConverter.toBase(amount!, sourceCurrencyCode);
  }

  bool get hasUsableData =>
      (amount != null && amount! > 0) ||
      (title != null && title!.trim().isNotEmpty);

  ParsedFinancialEntry copyWith({
    String? title,
    double? amount,
    String? currencyCode,
    DateTime? date,
    FinancialEntryType? type,
  }) {
    return ParsedFinancialEntry(
      title: title ?? this.title,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
      date: date ?? this.date,
      type: type ?? this.type,
      rawText: rawText,
    );
  }
}
