import 'package:imrpo/core/l10n/l10n_entity_strings.dart';
import 'package:imrpo/core/models/transaction_entry_meta.dart';
import 'package:imrpo/core/services/currency_preferences.dart';
import 'package:imrpo/core/services/service_locator.dart';
import 'package:imrpo/l10n/app_localizations.dart';

/// Formats optional foreign entry for list subtitles.
String? formatForeignEntrySubtitle(
  AppLocalizations l10n,
  TransactionEntryMeta? meta,
) {
  if (meta == null || !meta.hasForeignEntry) return null;
  final code = meta.entryCurrency!;
  final symbol = localizeCurrencySymbol(l10n, code);
  final amt = meta.entryAmount!;
  final value = amt == amt.roundToDouble()
      ? amt.toInt().toString()
      : amt.toStringAsFixed(2);
  return '$symbol$value $code';
}

/// EGP equivalent helper for amount field (storedAsBase).
String formatStoredAsBaseHint(AppLocalizations l10n, double? amountInBase) {
  if (amountInBase == null) return '';
  final egp = getIt<CurrencyPreferences>().formatBase(amountInBase);
  return l10n.storedAsBase(egp);
}
