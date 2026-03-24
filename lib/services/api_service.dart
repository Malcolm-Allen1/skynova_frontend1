import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://10.0.2.2:4000/api';

  Map<String, String> _headers({String? token}) {
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers(),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: _headers(),
      body: jsonEncode({
        'refreshToken': refreshToken,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to refresh token');
    }
  }

  Future<Map<String, dynamic>> getMe(String accessToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: _headers(token: accessToken),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch user');
    }
  }

  Future<Map<String, dynamic>> getAlerts(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/alerts'),
      headers: _headers(token: token),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch alerts');
    }
  }

  Future<Map<String, dynamic>> getAlertsBySearch(String token, int searchId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/alerts/searches/$searchId'),
      headers: _headers(token: token),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch search alerts');
    }
  }

  Future<Map<String, dynamic>> getPriceHistory(String token, int searchId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/prices/searches/$searchId'),
      headers: _headers(token: token),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch price history');
    }
  }

  Future<Map<String, dynamic>> createAlert(
    String token,
    int searchId,
    String ruleType,
    double value,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/alerts'),
      headers: _headers(token: token),
      body: jsonEncode({
        'search_id': searchId,
        'rule_type': ruleType,
        'threshold_value': value,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to create alert');
    }
  }

  Future<Map<String, dynamic>> deleteAlert(String token, int alertId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/alerts/$alertId'),
      headers: _headers(token: token),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to delete alert');
    }
  }
}