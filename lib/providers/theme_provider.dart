import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  ThemeData _themeData = AppTheme.lightTheme;

  bool get isDarkMode => _isDarkMode;
  ThemeData get themeData => _themeData;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _themeData = _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
      notifyListeners();
    } catch (e) {
      print('Error loading theme preference: $e');
    }
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    _themeData = _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _isDarkMode);
    } catch (e) {
      print('Error saving theme preference: $e');
    }
  }

  Future<void> resetToLightMode() async {
    _isDarkMode = false;
    _themeData = AppTheme.lightTheme;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', false);
    } catch (e) {
      print('Error resetting theme: $e');
    }
  }
}
