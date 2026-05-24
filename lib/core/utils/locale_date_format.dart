import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

/// Ensures [DateFormat] locale data is loaded before formatting (required on startup).
class LocaleDateFormat {
  LocaleDateFormat._();

  static final Set<String> _initialized = {};

  static String _normalize(String locale) => locale.split('_').first;

  static Future<void> ensureInitialized(String locale) async {
    final key = _normalize(locale);
    if (_initialized.contains(key)) return;
    await initializeDateFormatting(key);
    _initialized.add(key);
  }

  static Future<void> ensureAppLocales() async {
    await ensureInitialized('en');
    await ensureInitialized('ar');
  }

  static String yMMMdAddJm(DateTime dateTime, String locale) {
    final key = _normalize(locale);
    return DateFormat.yMMMd(key).add_jm().format(dateTime);
  }
}
