import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _themeKey = 'blue';
  String? _profileImagePath;

  String _fullName = '';
  String _phoneNumber = '';
  String _country = 'Jamaica';

  ThemeMode get themeMode => _themeMode;
  String get themeKey => _themeKey;
  String? get profileImagePath => _profileImagePath;

  String get fullName => _fullName;
  String get phoneNumber => _phoneNumber;
  String get country => _country;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final savedThemeMode = prefs.getString('theme_mode') ?? 'system';
    _themeKey = prefs.getString('theme_key') ?? 'blue';
    _profileImagePath = prefs.getString('profile_image_path');

    _fullName = prefs.getString('full_name') ?? '';
    _phoneNumber = prefs.getString('phone_number') ?? '';
    _country = prefs.getString('country') ?? 'Jamaica';

    switch (savedThemeMode) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.name);
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

  Future<void> savePersonalInfo({
    required String fullName,
    required String phoneNumber,
    required String country,
  }) async {
    _fullName = fullName;
    _phoneNumber = phoneNumber;
    _country = country;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('full_name', fullName);
    await prefs.setString('phone_number', phoneNumber);
    await prefs.setString('country', country);

    notifyListeners();
  }
}