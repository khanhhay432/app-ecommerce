import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('vi');

  Locale get locale => _locale;
  bool get isVietnamese => _locale.languageCode == 'vi';

  LocaleProvider() {
    _loadLocalePreference();
  }

  Future<void> _loadLocalePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('languageCode') ?? 'vi';
      _locale = Locale(languageCode);
      notifyListeners();
    } catch (e) {
      print('Error loading locale preference: $e');
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    
    _locale = locale;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('languageCode', locale.languageCode);
    } catch (e) {
      print('Error saving locale preference: $e');
    }
  }
}
