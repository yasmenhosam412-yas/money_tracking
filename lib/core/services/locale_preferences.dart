import 'package:flutter/material.dart';
import 'package:imrpo/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalePreferences extends ChangeNotifier {
  static const _storageKey = 'app_locale_code';

  Locale _locale = const Locale('ar');
  bool _isSaving = false;

  Locale get locale => _locale;
  bool get isSaving => _isSaving;

  /// Loads the saved locale, or keeps English as default.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_storageKey);
    if (saved != null && _isSupported(saved)) {
      _locale = Locale(saved);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!_isSupported(locale.languageCode) || _locale == locale || _isSaving) {
      return;
    }

    _isSaving = true;
    notifyListeners();

    try {
      _locale = locale;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, locale.languageCode);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  bool _isSupported(String code) =>
      AppLocalizations.supportedLocales
          .any((locale) => locale.languageCode == code);

  static String languageLabel(AppLocalizations l10n, String languageCode) {
    switch (languageCode) {
      case 'ar':
        return l10n.languageArabic;
      case 'en':
      default:
        return l10n.languageEnglish;
    }
  }
}
