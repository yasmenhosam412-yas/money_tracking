import 'package:imrpo/core/services/currency_preferences.dart';
import 'package:imrpo/core/services/service_locator.dart';

class Money {
  Money._();

  static String format(double baseAmount) =>
      getIt<CurrencyPreferences>().formatBase(baseAmount);

  /// Association / gom3eya amounts stored as EGP (not USD base).
  static String formatEgp(double amountInEgp) =>
      getIt<CurrencyPreferences>().formatDisplayAmount(amountInEgp);
}
