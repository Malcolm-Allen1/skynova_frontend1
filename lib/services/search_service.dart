import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/search_model.dart';

class SearchService {
  final String baseUrl;

  SearchService({required this.baseUrl});

  Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Exception _buildError(http.Response response, dynamic body, String fallback) {
    if (response.statusCode == 401) {
      return Exception('SESSION_EXPIRED');
    }

    if (body is Map<String, dynamic>) {
      return Exception(body['message'] ?? fallback);
    }

    return Exception(fallback);
  }

  Future<List<SearchModel>> getSearches(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/searches'),
      headers: _headers(token),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final List data = body['data'] ?? [];
      return data.map((e) => SearchModel.fromJson(e)).toList();
    } else {
      throw _buildError(response, body, 'Failed to fetch searches');
    }
  }

  Future<void> createSearch({
    required String token,
    required String origin,
    required String destination,
    String? departDate,
    String? returnDate,
    String currency = 'USD',
    double? maxPrice,
  }) async {
    final payload = {
      'origin': origin.trim(),
      'destination': destination.trim(),
      'currency': currency,
      if (departDate != null && departDate.trim().isNotEmpty)
        'depart_date': departDate.trim(),
      if (returnDate != null && returnDate.trim().isNotEmpty)
        'return_date': returnDate.trim(),
      if (maxPrice != null) 'max_price': maxPrice,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/searches'),
      headers: _headers(token),
      body: jsonEncode(payload),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw _buildError(response, body, 'Failed to create search');
    }
  }

  Future<void> updateSearch({
    required String token,
    required int id,
    required String origin,
    required String destination,
    String? departDate,
    String? returnDate,
    String currency = 'USD',
    double? maxPrice,
  }) async {
    final payload = {
      'origin': origin.trim(),
      'destination': destination.trim(),
      'currency': currency,
      if (departDate != null && departDate.trim().isNotEmpty)
        'depart_date': departDate.trim(),
      if (returnDate != null && returnDate.trim().isNotEmpty)
        'return_date': returnDate.trim(),
      if (maxPrice != null) 'max_price': maxPrice,
    };

    final response = await http.put(
      Uri.parse('$baseUrl/searches/$id'),
      headers: _headers(token),
      body: jsonEncode(payload),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw _buildError(response, body, 'Failed to update search');
    }
  }

  Future<void> deleteSearch({
    required String token,
    required int id,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/searches/$id'),
      headers: _headers(token),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw _buildError(response, body, 'Failed to delete search');
    }
  }
}