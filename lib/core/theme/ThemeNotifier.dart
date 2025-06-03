import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkTheme;
  bool get isDarkTheme => _isDarkTheme;

  ThemeNotifier(this._isDarkTheme);

  void toggleTheme(bool isDark) async { // Toggles the theme and saves the user's preference to local storage
    _isDarkTheme = isDark;
    final prefs = await SharedPreferences.getInstance(); // Save the updated theme preference to SharedPreferences
    await prefs.setBool('isDarkTheme', isDark);
    notifyListeners();  // Notify all listeners the theme has been updated
  }

  ThemeMode get currentThemeMode =>
      _isDarkTheme ? ThemeMode.dark : ThemeMode.light;
}
