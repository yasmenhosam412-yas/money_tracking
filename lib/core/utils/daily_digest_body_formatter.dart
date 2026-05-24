import 'package:imrpo/core/services/currency_preferences.dart';
import 'package:imrpo/core/services/daily_digest_summary_service.dart';
import 'package:imrpo/l10n/app_localizations.dart';

/// Text shown in the daily digest push notification body.
String formatDailyDigestNotificationBody(
  AppLocalizations l10n,
  CurrencyPreferences money,
  DailyDigestSummary? summary,
) {
  if (summary == null || !summary.hasYesterdayActivity) {
    return l10n.dailyDigestNotificationEmpty;
  }

  final parts = <String>[];

  if (summary.expenseCount > 0) {
    parts.add(
      l10n.dailyDigestYesterdayExpenses(
        summary.expenseCount,
        money.formatBase(summary.expenseTotal),
      ),
    );
  } else {
    parts.add(l10n.dailyDigestYesterdayNoExpenses);
  }

  if (summary.incomeCount > 0) {
    parts.add(
      l10n.dailyDigestYesterdayIncomes(
        summary.incomeCount,
        money.formatBase(summary.incomeTotal),
      ),
    );
  } else {
    parts.add(l10n.dailyDigestYesterdayNoIncomes);
  }

  final netLabel = summary.monthNet >= 0
      ? '+${money.formatBase(summary.monthNet)}'
      : '−${money.formatBase(summary.monthNet.abs())}';

  parts.add(l10n.dailyDigestMonthNet(netLabel));
  return parts.join(' ');
}
