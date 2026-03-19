import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:skynova_frontend1/core/app_config.dart';

class ApiService {
  static const String baseUrl =  AppConfig.baseUrl;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getSearches(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/searches'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getAlertsForSearch(String token, int searchId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/alerts/searches/$searchId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> createAlert(
    String token,
    int searchId,
    String ruleType,
    double thresholdValue,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/alerts'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'search_id': searchId,
        'rule_type': ruleType,
        'threshold_value': thresholdValue,
      }),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> deleteAlert(String token, int alertId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/alerts/$alertId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getPriceHistory(String token, int searchId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/prices/searches/$searchId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
  final body = jsonDecode(response.body);

  if (response.statusCode == 401) {
    throw Exception('UNAUTHORIZED');
  }

  if (response.statusCode >= 200 && response.statusCode < 300) {
    return body;
  }

  throw Exception(body['message'] ?? 'Something went wrong');
}
}