import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://10.0.2.2:4000/api';

  Map<String, String> _headers({String? token}) {
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    final data = jsonDecode(response.body);

    if (response.statusCode == 401) {
      throw Exception('SESSION_EXPIRED');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Request failed');
    }
  }

  // ================= AUTH =================

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers(),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: _headers(),
      body: jsonEncode({
        'refreshToken': refreshToken,
      }),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getMe(String accessToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: _headers(token: accessToken),
    );

    return _handleResponse(response);
  }

  // ================= SEARCHES =================

  Future<Map<String, dynamic>> getSearches(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/searches'),
      headers: _headers(token: token),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> createSearch(
    String token,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/searches'),
      headers: _headers(token: token),
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateSearch(
    String token,
    int searchId,
    Map<String, dynamic> body,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/searches/$searchId'),
      headers: _headers(token: token),
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> deleteSearch(String token, int searchId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/searches/$searchId'),
      headers: _headers(token: token),
    );

    return _handleResponse(response);
  }

  // ================= ALERTS =================

  Future<Map<String, dynamic>> getAlerts(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/alerts'),
      headers: _headers(token: token),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getAlertsBySearch(
    String token,
    int searchId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/alerts/searches/$searchId'),
      headers: _headers(token: token),
    );

    return _handleResponse(response);
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

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> deleteAlert(String token, int alertId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/alerts/$alertId'),
      headers: _headers(token: token),
    );

    return _handleResponse(response);
  }

  // ================= PRICES =================

  Future<Map<String, dynamic>> getPriceHistory(
    String token,
    int searchId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/prices/searches/$searchId'),
      headers: _headers(token: token),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> addPriceHistory(
    String token,
    int searchId,
    double price, {
    String? source,
    String? capturedAt,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/prices/searches/$searchId'),
      headers: _headers(token: token),
      body: jsonEncode({
        'price': price,
        if (source != null && source.isNotEmpty) 'source': source,
        if (capturedAt != null && capturedAt.isNotEmpty)
          'captured_at': capturedAt,
      }),
    );

    return _handleResponse(response);
  }
}