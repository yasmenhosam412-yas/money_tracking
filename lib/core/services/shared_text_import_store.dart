import 'package:flutter/foundation.dart';

/// Holds SMS/bank text shared into the app from another app (Android share sheet).
class SharedTextImportStore extends ChangeNotifier {
  String? _pending;
  bool smartImportScreenOpen = false;

  bool get hasPending => _pending != null && _pending!.isNotEmpty;

  String? get pending => _pending;

  void setPending(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _pending = trimmed;
    notifyListeners();
  }

  /// Returns pending text and clears it (one-shot consume).
  String? consumePending() {
    final value = _pending;
    _pending = null;
    return value;
  }
}
