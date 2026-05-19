import 'package:imrpo/core/services/currency_preferences.dart';
import 'package:imrpo/core/services/service_locator.dart';

class Money {
  Money._();

  static String format(double baseAmount) =>
      getIt<CurrencyPreferences>().formatBase(baseAmount);
}
