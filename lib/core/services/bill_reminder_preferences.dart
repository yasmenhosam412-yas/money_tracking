import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BillReminderPreferences extends ChangeNotifier {
  static const _enabledKey = 'bill_reminders_enabled';
  static const _defaultLeadDaysKey = 'bill_reminders_default_lead_days';

  bool _enabled = true;
  int _defaultLeadDays = 1;
  bool _loaded = false;

  bool get isLoaded => _loaded;
  bool get enabled => _enabled;
  int get defaultLeadDays => _defaultLeadDays;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_enabledKey) ?? true;
    _defaultLeadDays = prefs.getInt(_defaultLeadDaysKey) ?? 1;
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

  Future<void> setDefaultLeadDays(int days) async {
    final clamped = days.clamp(0, 14);
    if (_defaultLeadDays == clamped) return;
    _defaultLeadDays = clamped;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_defaultLeadDaysKey, clamped);
  }
}
