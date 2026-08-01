import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  static const String keyLanguage = 'language';

  // Default to বাংলা for Farmer app
  String _currentLanguage = 'বাংলা';

  String get currentLanguage => _currentLanguage;

  bool get isBangla =>
      _currentLanguage == 'বাংলা' ||
      _currentLanguage == 'bn' ||
      _currentLanguage == 'Bangla';

  /// Reactive helper for BuildContext
  static bool isBn(BuildContext context) {
    try {
      return Provider.of<LanguageProvider>(context, listen: true).isBangla;
    } catch (_) {
      return true; // Default fallback to Bangla
    }
  }

  /// Non-reactive helper for BuildContext (e.g. inside callbacks)
  static bool isBnStatic(BuildContext context) {
    try {
      return Provider.of<LanguageProvider>(context, listen: false).isBangla;
    } catch (_) {
      return true;
    }
  }

  /// Load saved language from SharedPreferences
  Future<void> loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(keyLanguage);
      if (saved != null && saved.isNotEmpty) {
        _currentLanguage = saved;
      } else {
        _currentLanguage = 'বাংলা';
      }
      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ Error loading language preference: $e');
    }
  }

  /// Save and update language preference
  Future<void> setLanguage(String lang) async {
    if (_currentLanguage == lang) return;
    _currentLanguage = lang;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyLanguage, lang);
    } catch (e) {
      debugPrint('⚠️ Error saving language preference: $e');
    }
  }

  /// Toggle between বাংলা and English
  Future<void> toggleLanguage() async {
    if (isBangla) {
      await setLanguage('English');
    } else {
      await setLanguage('বাংলা');
    }
  }
}
