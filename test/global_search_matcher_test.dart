import 'package:flutter_test/flutter_test.dart';
import 'package:imrpo/core/services/currency_converter.dart';
import 'package:imrpo/features/search/domain/global_search_matcher.dart';
import 'package:imrpo/features/search/domain/search_result_item.dart';
import 'package:imrpo/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('parseAmountQuery', () {
    test('parses plain and grouped numbers', () {
      expect(GlobalSearchMatcher.parseAmountQuery('500'), 500);
      expect(GlobalSearchMatcher.parseAmountQuery('1,250.50'), 1250.5);
      expect(GlobalSearchMatcher.parseAmountQuery('1.250,50'), 1250.5);
    });

    test('parses amount with currency symbol', () {
      expect(GlobalSearchMatcher.parseAmountQuery('E£500'), 500);
      expect(GlobalSearchMatcher.parseAmountQuery('\$12.5'), 12.5);
    });

    test('parses Arabic-Indic digits', () {
      expect(GlobalSearchMatcher.parseAmountQuery('٥٠٠'), 500);
    });
  });

  group('filter by amount', () {
    late AppLocalizations l10n;

    setUpAll(() async {
      l10n = await AppLocalizations.delegate.load(const Locale('en'));
    });

    test('matches display amount in EGP not base USD', () {
      const baseUsd = 10.5; // 10.5 USD ≈ 500 EGP at 0.021 rate
      final display = CurrencyConverter.fromBase(baseUsd, 'EGP');
      expect(display.round(), 500);

      final item = SearchResultItem(
        type: SearchResultType.expense,
        id: '1',
        title: 'Coffee',
        category: 'Food',
        amount: baseUsd,
        date: DateTime(2025, 1, 1),
      );

      final results = GlobalSearchMatcher.filter(
        [item],
        l10n,
        '500',
        displayCode: 'EGP',
      );
      expect(results, hasLength(1));
    });

    test('does not false-match unrelated amount', () {
      final item = SearchResultItem(
        type: SearchResultType.income,
        id: '2',
        title: 'Salary',
        category: 'Salary',
        amount: CurrencyConverter.toBase(3000, 'EGP'),
        date: DateTime(2025, 2, 1),
      );

      final results = GlobalSearchMatcher.filter(
        [item],
        l10n,
        '9999',
        displayCode: 'EGP',
      );
      expect(results, isEmpty);
    });
  });
}
