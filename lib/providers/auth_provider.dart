import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isCheckingSession = true;
  String? _token;
  String? _refreshToken;
  String? _error;
  Map<String, dynamic>? _user;

  bool get isLoading => _isLoading;
  bool get isCheckingSession => _isCheckingSession;
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;
  String? get token => _token;
  String? get refreshToken => _refreshToken;
  String? get error => _error;
  Map<String, dynamic>? get user => _user;
  String? get name =>
      _user?['name']?.toString() ?? _user?['full_name']?.toString();

  Future<void> loadSession() async {
    _isCheckingSession = true;
    _error = null;
    notifyListeners();

    try {
      _token = await _authService.getToken();
      _refreshToken = await _authService.getRefreshToken();

      if (_token == null || _token!.isEmpty) {
        _isCheckingSession = false;
        notifyListeners();
        return;
      }

      try {
        final meResponse = await _apiService.getMe(_token!);
        final userData = meResponse['data'];

        if (userData is Map<String, dynamic>) {
          _user = userData;
        }
      } catch (e) {
        final refreshed = await tryRefreshToken();

        if (refreshed) {
          final meResponse = await _apiService.getMe(_token!);
          final userData = meResponse['data'];

          if (userData is Map<String, dynamic>) {
            _user = userData;
          }
        } else {
          await logout();
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isCheckingSession = false;
      notifyListeners();
    }
  }

  Future<void> loadUserProfile() async {
    if (_token == null || _token!.isEmpty) return;

    try {
      final meResponse = await _apiService.getMe(_token!);
      final userData = meResponse['data'];

      if (userData is Map<String, dynamic>) {
        _user = userData;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.login(email, password);

      final accessToken =
          response['data']?['accessToken'] ?? response['data']?['token'];
      final refreshToken = response['data']?['refreshToken'];

      if (accessToken == null || accessToken.toString().isEmpty) {
        _error = 'No access token returned';
        return false;
      }

      _token = accessToken.toString();
      _refreshToken = refreshToken?.toString();

      final userData = response['data']?['user'];
      if (userData is Map<String, dynamic>) {
        _user = userData;
      } else {
        _user = null;
      }

      await _authService.saveToken(_token!);

      if (_refreshToken != null && _refreshToken!.isNotEmpty) {
        await _authService.saveRefreshToken(_refreshToken!);
      }

      if (_user == null) {
        await loadUserProfile();
      }

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> tryRefreshToken() async {
    try {
      final storedRefreshToken =
          _refreshToken ?? await _authService.getRefreshToken();

      if (storedRefreshToken == null || storedRefreshToken.isEmpty) {
        return false;
      }

      final response = await _apiService.refreshToken(storedRefreshToken);

      final newAccessToken =
          response['data']?['accessToken'] ?? response['data']?['token'];
      final newRefreshToken = response['data']?['refreshToken'];

      if (newAccessToken == null || newAccessToken.toString().isEmpty) {
        return false;
      }

      _token = newAccessToken.toString();
      await _authService.saveToken(_token!);

      if (newRefreshToken != null && newRefreshToken.toString().isNotEmpty) {
        _refreshToken = newRefreshToken.toString();
        await _authService.saveRefreshToken(_refreshToken!);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _refreshToken = null;
    _user = null;
    _error = null;

    await _authService.clearToken();
    await _authService.clearRefreshToken();

    notifyListeners();
  }
}