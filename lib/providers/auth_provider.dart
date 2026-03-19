import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isCheckingSession = true;
  String? _token;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isCheckingSession => _isCheckingSession;
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;
  String? get token => _token;
  String? get error => _error;

  Future<void> loadSession() async {
    _isCheckingSession = true;
    notifyListeners();

    try {
      _token = await _authService.getToken();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _token = null;
    }

    _isCheckingSession = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.login(email, password);

      final token = response['data']?['accessToken'] ??
          response['data']?['token'] ??
          response['accessToken'] ??
          response['token'];

      if (token == null || token.toString().isEmpty) {
        throw Exception('No token returned from backend');
      }

      _token = token.toString();
      await _authService.saveToken(_token!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    await _authService.clearToken();
    notifyListeners();
  }
}