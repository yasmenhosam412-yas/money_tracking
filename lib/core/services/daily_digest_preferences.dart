import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyDigestPreferences extends ChangeNotifier {
  static const _enabledKey = 'daily_digest_enabled';
  static const _hourKey = 'daily_digest_hour';
  static const _minuteKey = 'daily_digest_minute';

  static const defaultHour = 20;
  static const defaultMinute = 0;

  bool _enabled = true;
  int _hour = defaultHour;
  int _minute = defaultMinute;
  bool _loaded = false;

  bool get isLoaded => _loaded;
  bool get enabled => _enabled;
  int get hour => _hour;
  int get minute => _minute;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_enabledKey) ?? true;
    _hour = prefs.getInt(_hourKey) ?? defaultHour;
    _minute = prefs.getInt(_minuteKey) ?? defaultMinute;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setEnabled(bool value) async {
    if (_enabled == value) return;
    _enabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);
  }

  Future<void> setTime({required int hour, required int minute}) async {
    final h = hour.clamp(0, 23);
    final m = minute.clamp(0, 59);
    if (_hour == h && _minute == m) return;
    _hour = h;
    _minute = m;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_hourKey, h);
    await prefs.setInt(_minuteKey, m);
  }
}
