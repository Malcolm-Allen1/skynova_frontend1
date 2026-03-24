import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _themeKey = 'mint';
  String? _profileImagePath;

  ThemeMode get themeMode => _themeMode;
  String get themeKey => _themeKey;
  String? get profileImagePath => _profileImagePath;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final savedThemeMode = prefs.getString('theme_mode') ?? 'system';
    final savedThemeKey = prefs.getString('theme_key') ?? 'mint';
    final savedProfileImage = prefs.getString('profile_image_path');

    _themeMode = _mapThemeMode(savedThemeMode);
    _themeKey = savedThemeKey;
    _profileImagePath = savedProfileImage;

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();

    String value = 'system';
    if (mode == ThemeMode.light) value = 'light';
    if (mode == ThemeMode.dark) value = 'dark';

    await prefs.setString('theme_mode', value);
    notifyListeners();
  }

  Future<void> setThemeKey(String key) async {
    _themeKey = key;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_key', key);
    notifyListeners();
  }

  Future<void> setProfileImagePath(String path) async {
    _profileImagePath = path;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', path);
    notifyListeners();
  }

  ThemeMode _mapThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}