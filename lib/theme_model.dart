import 'package:flutter/material.dart';
import 'package:picgur/theme_preferences.dart';

class ThemeModel extends ChangeNotifier {
  late bool _isDark;
  late ThemePreferences _preferences;
  bool get isDark => _isDark;

  ThemeModel() {
    _isDark = true;
    _preferences = ThemePreferences();
    getPreferences();
  }

  set isDark(bool value) {
    _isDark = value;
    _preferences.setDarkMode(value);
    notifyListeners();
  }

  getPreferences() async {
    _isDark = await _preferences.getDarkMode();
    notifyListeners();
  }
}