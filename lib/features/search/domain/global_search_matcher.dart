import 'package:imrpo/core/l10n/l10n_entity_strings.dart';
import 'package:imrpo/core/services/currency_converter.dart';
import 'package:imrpo/features/search/domain/search_result_item.dart';
import 'package:imrpo/l10n/app_localizations.dart';

class GlobalSearchMatcher {
  GlobalSearchMatcher._();

  static const _amountEpsilon = 0.01;

  static List<SearchResultItem> filter(
    List<SearchResultItem> items,
    AppLocalizations l10n,
    String query, {
    SearchResultType? typeFilter,
    required String displayCode,
  }) {
    final filtered = typeFilter == null
        ? items
        : items.where((item) => item.type == typeFilter).toList();

    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) {
      return _sortByDate(filtered);
    }

    return _sortByDate(
      filtered
          .where(
            (item) => _matches(
              l10n,
              item,
              needle,
              displayCode: displayCode,
            ),
          )
          .toList(),
    );
  }

  static List<SearchResultItem> _sortByDate(List<SearchResultItem> items) {
    final sorted = List<SearchResultItem>.from(items)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  static bool _matches(
    AppLocalizations l10n,
    SearchResultItem item,
    String needle, {
    required String displayCode,
  }) {
    if (_matchesAmount(item, needle, displayCode)) return true;

    final isIncome = item.type == SearchResultType.income;
    final localizedCategory = isIncome
        ? localizeIncomeCategory(l10n, item.category)
        : localizeExpenseCategory(l10n, item.category);
    final localizedTitle = localizeDemoTitle(l10n, item.title);

    final haystacks = <String>{
      item.title,
      item.category,
      localizedTitle,
      localizedCategory,
    };

    return haystacks.any((value) => value.toLowerCase().contains(needle));
  }

  static bool _matchesAmount(
    SearchResultItem item,
    String needle,
    String displayCode,
  ) {
    final displayAmount =
        CurrencyConverter.fromBase(item.amount, displayCode);
    final formatted =
        CurrencyConverter.format(displayAmount, displayCode).toLowerCase();
    final formattedPlain = _stripCurrencyDecorations(formatted);

    final textHaystacks = <String>{
      item.amount.toString(),
      _formatAmountCompact(item.amount),
      displayAmount.toString(),
      _formatAmountCompact(displayAmount),
      formatted,
      formattedPlain,
    };

    if (textHaystacks.any((value) => value.contains(needle))) {
      return true;
    }

    final parsed = parseAmountQuery(needle);
    if (parsed == null) return false;

    if (_nearEqual(displayAmount, parsed)) return true;
    if (_nearEqual(item.amount, parsed)) return true;

    return false;
  }

  /// Parses a user-entered amount (display currency), tolerating symbols and separators.
  static double? parseAmountQuery(String raw) {
    var s = _normalizeDigits(raw.trim().toLowerCase());
    if (s.isEmpty) return null;

    s = s.replaceAll(RegExp(r'[\s\u00A0]'), '');
    for (final currency in CurrencyConverter.currencies) {
      s = s.replaceAll(currency.symbol.toLowerCase(), '');
      s = s.replaceAll(currency.code.toLowerCase(), '');
    }
    s = s.replaceAll(RegExp(r'[^0-9.,\-]'), '');
    if (s.isEmpty || s == '-' || s == '.' || s == ',') return null;

    s = _normalizeDecimalSeparators(s);
    return double.tryParse(s);
  }

  static String _normalizeDigits(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      final ch = String.fromCharCode(rune);
      const arabicIndic = '٠١٢٣٤٥٦٧٨٩';
      const easternArabic = '۰۱۲۳۴۵۶۷۸۹';
      final arIndex = arabicIndic.indexOf(ch);
      if (arIndex >= 0) {
        buffer.write(arIndex);
        continue;
      }
      final faIndex = easternArabic.indexOf(ch);
      if (faIndex >= 0) {
        buffer.write(faIndex);
        continue;
      }
      buffer.write(ch);
    }
    return buffer.toString();
  }

  static String _normalizeDecimalSeparators(String s) {
    final hasComma = s.contains(',');
    final hasDot = s.contains('.');
    if (hasComma && hasDot) {
      final lastComma = s.lastIndexOf(',');
      final lastDot = s.lastIndexOf('.');
      if (lastComma > lastDot) {
        return s.replaceAll('.', '').replaceAll(',', '.');
      }
      return s.replaceAll(',', '');
    }
    if (hasComma) {
      final parts = s.split(',');
      if (parts.length == 2 && parts[1].length <= 2) {
        return '${parts[0]}.${parts[1]}';
      }
      return s.replaceAll(',', '');
    }
    return s;
  }

  static String _stripCurrencyDecorations(String formatted) {
    var s = formatted;
    for (final currency in CurrencyConverter.currencies) {
      s = s.replaceAll(currency.symbol.toLowerCase(), '');
      s = s.replaceAll(currency.code.toLowerCase(), '');
    }
    return s.trim();
  }

  static bool _nearEqual(double a, double b) => (a - b).abs() < _amountEpsilon;

  static String _formatAmountCompact(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(2);
  }
}
