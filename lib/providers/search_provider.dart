import 'package:flutter/material.dart';
import '../models/search_model.dart';
import '../services/search_service.dart';

class SearchProvider extends ChangeNotifier {
  final SearchService _searchService = SearchService(
    baseUrl: 'http://10.0.2.2:4000/api',
  );

  List<SearchModel> _searches = [];
  bool _isLoading = false;
  String? _error;

  List<SearchModel> get searches => _searches;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSearches(String token) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _searches = await _searchService.getSearches(token);
    } catch (e) {
      if (e.toString().contains('SESSION_EXPIRED')) {
        _error = 'Session expired. Please log in again.';
      } else {
        _error = e.toString().replaceFirst('Exception: ', '');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createSearch({
    required String token,
    required String origin,
    required String destination,
    String? departDate,
    String? returnDate,
    String currency = 'USD',
    double? maxPrice,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _searchService.createSearch(
        token: token,
        origin: origin,
        destination: destination,
        departDate: departDate,
        returnDate: returnDate,
        currency: currency,
        maxPrice: maxPrice,
      );

      await fetchSearches(token);
      return true;
    } catch (e) {
      if (e.toString().contains('SESSION_EXPIRED')) {
        _error = 'Session expired. Please log in again.';
      } else {
        _error = e.toString().replaceFirst('Exception: ', '');
      }
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateSearch({
    required String token,
    required int id,
    required String origin,
    required String destination,
    String? departDate,
    String? returnDate,
    String currency = 'USD',
    double? maxPrice,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _searchService.updateSearch(
        token: token,
        id: id,
        origin: origin,
        destination: destination,
        departDate: departDate,
        returnDate: returnDate,
        currency: currency,
        maxPrice: maxPrice,
      );

      await fetchSearches(token);
      return true;
    } catch (e) {
      if (e.toString().contains('SESSION_EXPIRED')) {
        _error = 'Session expired. Please log in again.';
      } else {
        _error = e.toString().replaceFirst('Exception: ', '');
      }
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteSearch({
    required String token,
    required int id,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _searchService.deleteSearch(
        token: token,
        id: id,
      );

      await fetchSearches(token);
      return true;
    } catch (e) {
      if (e.toString().contains('SESSION_EXPIRED')) {
        _error = 'Session expired. Please log in again.';
      } else {
        _error = e.toString().replaceFirst('Exception: ', '');
      }
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}