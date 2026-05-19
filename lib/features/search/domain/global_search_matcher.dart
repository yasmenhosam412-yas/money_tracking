import 'package:imrpo/core/l10n/l10n_entity_strings.dart';
import 'package:imrpo/features/search/domain/search_result_item.dart';
import 'package:imrpo/l10n/app_localizations.dart';

class GlobalSearchMatcher {
  GlobalSearchMatcher._();

  static List<SearchResultItem> filter(
    List<SearchResultItem> items,
    AppLocalizations l10n,
    String query, {
    SearchResultType? typeFilter,
  }) {
    final filtered = typeFilter == null
        ? items
        : items.where((item) => item.type == typeFilter).toList();

    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) {
      return _sortByDate(filtered);
    }

    return _sortByDate(
      filtered.where((item) => _matches(l10n, item, needle)).toList(),
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
    String needle,
  ) {
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
      item.amount.toString(),
      _formatAmountCompact(item.amount),
    };

    if (haystacks.any((value) => value.toLowerCase().contains(needle))) {
      return true;
    }

    final numericQuery = double.tryParse(needle.replaceAll(',', ''));
    if (numericQuery != null && item.amount == numericQuery) {
      return true;
    }

    return false;
  }

  static String _formatAmountCompact(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(2);
  }
}
