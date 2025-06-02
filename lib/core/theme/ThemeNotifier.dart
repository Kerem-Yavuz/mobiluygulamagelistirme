import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkTheme;
  bool get isDarkTheme => _isDarkTheme;

  ThemeNotifier(this._isDarkTheme);

  void toggleTheme(bool isDark) async {
    _isDarkTheme = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', isDark);
    notifyListeners();
  }

  ThemeMode get currentThemeMode =>
      _isDarkTheme ? ThemeMode.dark : ThemeMode.light;
}
