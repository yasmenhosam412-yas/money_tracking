import 'package:imrpo/core/services/currency_converter.dart';

/// Optional foreign-currency fields stored alongside USD-base [amount].
class TransactionEntryMeta {
  final String? entryCurrency;
  final double? entryAmount;

  const TransactionEntryMeta({this.entryCurrency, this.entryAmount});

  bool get hasForeignEntry {
    final code = entryCurrency?.trim();
    final amt = entryAmount;
    if (code == null || code.isEmpty || amt == null) return false;
    return !CurrencyConverter.isDefaultEntryCurrency(code);
  }

  Map<String, dynamic> toRowFields() {
    final code = entryCurrency?.trim();
    if (code == null || code.isEmpty || entryAmount == null) {
      return {
        'entry_currency': null,
        'entry_amount': null,
      };
    }
    if (CurrencyConverter.isDefaultEntryCurrency(code)) {
      return {
        'entry_currency': null,
        'entry_amount': null,
      };
    }
    return {
      'entry_currency': code,
      'entry_amount': entryAmount,
    };
  }

  static TransactionEntryMeta? fromRow(Map<String, dynamic> map) {
    final code = map['entry_currency'] as String?;
    final raw = map['entry_amount'];
    if (code == null || code.trim().isEmpty || raw == null) return null;
    return TransactionEntryMeta(
      entryCurrency: code.trim(),
      entryAmount: (raw as num).toDouble(),
    );
  }
}
