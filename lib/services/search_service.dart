import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/search_model.dart';

class SearchService {
  final String baseUrl;

  SearchService({required this.baseUrl});

  Future<List<SearchModel>> getSearches(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/searches'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final List data = body['data'] ?? [];
      return data.map((e) => SearchModel.fromJson(e)).toList();
    } else {
      throw Exception(body['message'] ?? 'Failed to fetch searches');
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
    final response = await http.post(
      Uri.parse('$baseUrl/searches'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'origin': origin,
        'destination': destination,
        'depart_date': departDate,
        'return_date': returnDate,
        'currency': currency,
        'max_price': maxPrice,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(body['message'] ?? 'Failed to create search');
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
    final response = await http.put(
      Uri.parse('$baseUrl/searches/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'origin': origin,
        'destination': destination,
        'depart_date': departDate,
        'return_date': returnDate,
        'currency': currency,
        'max_price': maxPrice,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(body['message'] ?? 'Failed to update search');
    }
  }

  Future<void> deleteSearch({
    required String token,
    required int id,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/searches/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final body = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(body['message'] ?? 'Failed to delete search');
    }
  }
}