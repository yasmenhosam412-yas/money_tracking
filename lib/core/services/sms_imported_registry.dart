import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks SMS message IDs already saved to the app (prevents duplicate imports).
class SmsImportedRegistry extends ChangeNotifier {
  static const _storageKey = 'imported_sms_ids';

  final Set<String> _ids = {};

  int get importedCount => _ids.length;

  bool isImported(String smsId) => _ids.contains(smsId);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_storageKey);
    if (saved == null) return;
    _ids
      ..clear()
      ..addAll(saved);
    notifyListeners();
  }

  Future<void> markImported(String smsId) async {
    if (smsId.isEmpty || !_ids.add(smsId)) return;
    notifyListeners();
    await _persist();
  }

  Future<void> markImportedMany(Iterable<String> smsIds) async {
    var changed = false;
    for (final id in smsIds) {
      if (id.isNotEmpty && _ids.add(id)) {
        changed = true;
      }
    }
    if (!changed) return;
    notifyListeners();
    await _persist();
  }

  Future<void> clearAll() async {
    if (_ids.isEmpty) return;
    _ids.clear();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, _ids.toList());
  }
}
