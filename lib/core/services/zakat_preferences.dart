import 'package:shared_preferences/shared_preferences.dart';

class ZakatPreferences {
  static const _goldPriceKey = 'zakat_gold_price_per_gram_egp';
  static const _silverPriceKey = 'zakat_silver_price_per_gram_egp';

  /// Approximate 24k gold per gram in EGP (user can adjust).
  static const defaultGoldPricePerGramEgp = 4500.0;

  /// Approximate silver per gram in EGP (user can adjust).
  static const defaultSilverPricePerGramEgp = 55.0;

  static Future<double> loadGoldPricePerGram() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_goldPriceKey) ?? defaultGoldPricePerGramEgp;
  }

  static Future<double> loadSilverPricePerGram() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_silverPriceKey) ?? defaultSilverPricePerGramEgp;
  }

  static Future<void> saveGoldPricePerGram(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_goldPriceKey, value.clamp(0, double.infinity));
  }

  static Future<void> saveSilverPricePerGram(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_silverPriceKey, value.clamp(0, double.infinity));
  }
}
