import 'package:imrpo/core/services/currency_converter.dart';
import 'package:imrpo/features/csv_import/domain/csv_column_field.dart';

class CsvParsedRow {
  final bool isExpense;
  final String title;
  final double amountBase;
  final DateTime date;
  final String category;
  final String? paidFrom;

  const CsvParsedRow({
    required this.isExpense,
    required this.title,
    required this.amountBase,
    required this.date,
    required this.category,
    this.paidFrom,
  });
}

class CsvImportParser {
  static List<List<String>> parseRaw(String content) {
    final rows = <List<String>>[];
    for (final line in content.split(RegExp(r'\r?\n'))) {
      if (line.trim().isEmpty) continue;
      rows.add(_splitLine(line));
    }
    return rows.where((row) => row.any((c) => c.isNotEmpty)).toList();
  }

  static List<String> _splitLine(String line) {
    final cells = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;
    for (var i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        inQuotes = !inQuotes;
        continue;
      }
      if (ch == ',' && !inQuotes) {
        cells.add(buffer.toString().trim());
        buffer.clear();
        continue;
      }
      buffer.write(ch);
    }
    cells.add(buffer.toString().trim());
    return cells;
  }

  static List<CsvColumnField> guessMappings(List<String> header) {
    return header.map((cell) {
      final h = cell.toLowerCase();
      if (_matches(h, ['title', 'name', 'description', 'memo', 'note'])) {
        return CsvColumnField.title;
      }
      if (_matches(h, ['amount', 'value', 'sum', 'total', 'price'])) {
        return CsvColumnField.amount;
      }
      if (_matches(h, ['date', 'when', 'day', 'time'])) {
        return CsvColumnField.date;
      }
      if (_matches(h, ['category', 'cat', 'type', 'tag'])) {
        return CsvColumnField.category;
      }
      if (_matches(h, ['income', 'expense', 'transaction', 'kind', 'flow'])) {
        return CsvColumnField.type;
      }
      if (_matches(h, ['paid', 'source', 'wallet', 'account', 'from'])) {
        return CsvColumnField.paidFrom;
      }
      return CsvColumnField.skip;
    }).toList();
  }

  static bool _matches(String h, List<String> keys) =>
      keys.any((k) => h.contains(k));

  static List<CsvParsedRow> buildRows({
    required List<List<String>> rows,
    required List<CsvColumnField> mappings,
    required bool firstRowIsHeader,
    required String defaultCurrencyCode,
  }) {
    final dataRows = firstRowIsHeader && rows.isNotEmpty
        ? rows.sublist(1)
        : rows;
    final parsed = <CsvParsedRow>[];

    for (final row in dataRows) {
      String? title;
      double? amount;
      DateTime? date;
      String? category;
      String? typeRaw;
      String? paidFrom;

      for (var i = 0; i < row.length && i < mappings.length; i++) {
        final value = row[i].trim();
        if (value.isEmpty) continue;
        switch (mappings[i]) {
          case CsvColumnField.title:
            title = value;
          case CsvColumnField.amount:
            amount = _parseAmount(value);
          case CsvColumnField.date:
            date = _parseDate(value);
          case CsvColumnField.category:
            category = value;
          case CsvColumnField.type:
            typeRaw = value;
          case CsvColumnField.paidFrom:
            paidFrom = value;
          case CsvColumnField.skip:
            break;
        }
      }

      if (title == null || amount == null) continue;
      final isExpense = _isExpense(typeRaw);
      parsed.add(
        CsvParsedRow(
          isExpense: isExpense,
          title: title,
          amountBase: CurrencyConverter.toBase(amount, defaultCurrencyCode),
          date: date ?? DateTime.now(),
          category: category ?? (isExpense ? 'Other' : 'Cash'),
          paidFrom: isExpense ? paidFrom : null,
        ),
      );
    }
    return parsed;
  }

  static double? _parseAmount(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[^\d.,\-]'), '');
    if (cleaned.isEmpty) return null;
    final normalized = cleaned.contains(',') && !cleaned.contains('.')
        ? cleaned.replaceAll(',', '.')
        : cleaned.replaceAll(',', '');
    return double.tryParse(normalized);
  }

  static DateTime? _parseDate(String raw) {
    final iso = DateTime.tryParse(raw);
    if (iso != null) return iso;
    final parts = raw.split(RegExp(r'[./\-]'));
    if (parts.length == 3) {
      final a = int.tryParse(parts[0]);
      final b = int.tryParse(parts[1]);
      final c = int.tryParse(parts[2]);
      if (a != null && b != null && c != null) {
        if (a > 31) return DateTime(a, b, c);
        if (c > 31) return DateTime(c, b, a);
        return DateTime(c, b, a);
      }
    }
    return null;
  }

  static bool _isExpense(String? typeRaw) {
    if (typeRaw == null || typeRaw.trim().isEmpty) return true;
    final t = typeRaw.toLowerCase();
    if (t.contains('income') ||
        t.contains('salary') ||
        t.contains('deposit') ||
        t == 'in' ||
        t == '+') {
      return false;
    }
    return true;
  }
}
