import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  bool _isDarkMode = true; // Default to dark mode like web version

  ThemeProvider(this._prefs) {
    loadTheme();
  }

  bool get isDarkMode => _isDarkMode;

  Future<void> loadTheme() async {
    _isDarkMode = _prefs.getBool('dark_mode') ?? true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool('dark_mode', _isDarkMode);
    notifyListeners();
  }

  Future<void> setDarkMode(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      await _prefs.setBool('dark_mode', _isDarkMode);
      notifyListeners();
    }
  }
}