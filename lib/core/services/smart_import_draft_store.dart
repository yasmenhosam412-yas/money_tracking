import 'package:imrpo/core/models/parsed_financial_entry.dart';

/// Holds the last parsed message from Smart import (paste tab) so the
/// Expenses tab can open a prefilled sheet without returning to Smart import.
class SmartImportDraftStore {
  ParsedFinancialEntry? _last;

  void save(ParsedFinancialEntry entry) {
    if (!entry.hasUsableData) return;
    _last = entry;
  }

  ParsedFinancialEntry? get lastScan => _last;

  /// Draft suitable for the add-expense flow (expense type only).
  ParsedFinancialEntry? get lastExpenseDraft {
    final e = _last;
    if (e == null || !e.hasUsableData) return null;
    if (e.type != FinancialEntryType.expense) return null;
    return e;
  }
}
