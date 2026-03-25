import 'package:flutter/material.dart';

import '../models/alert_model.dart';
import '../models/price_model.dart';
import '../services/api_service.dart';

class AlertProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _error;

  List<AlertModel> _alerts = [];
  List<AlertModel> _searchAlerts = [];
  List<PriceModel> _prices = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<AlertModel> get alerts => _alerts;
  List<AlertModel> get searchAlerts => _searchAlerts;
  List<PriceModel> get prices => _prices;

  Future<void> fetchAlerts(String token) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.getAlerts(token);
      final List data = response['data'] ?? [];

      _alerts = data.map((e) => AlertModel.fromJson(e)).toList();
    } catch (e) {
      if (e.toString().contains('SESSION_EXPIRED')) {
        _error = 'Session expired. Please log in again.';
      } else {
        _error = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSearchAlerts(String token, int searchId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.getAlertsBySearch(token, searchId);
      final List data = response['data'] ?? [];

      _searchAlerts = data.map((e) => AlertModel.fromJson(e)).toList();
    } catch (e) {
      if (e.toString().contains('SESSION_EXPIRED')) {
        _error = 'Session expired. Please log in again.';
      } else {
        _error = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPriceHistory(String token, int searchId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.getPriceHistory(token, searchId);
      final List data = response['data'] ?? [];

      _prices = data.map((e) => PriceModel.fromJson(e)).toList();
    } catch (e) {
      if (e.toString().contains('SESSION_EXPIRED')) {
        _error = 'Session expired. Please log in again.';
      } else {
        _error = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAlert(
    String token,
    int searchId,
    String ruleType,
    double value,
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _apiService.createAlert(token, searchId, ruleType, value);
      await fetchSearchAlerts(token, searchId);
      await fetchAlerts(token);

      return true;
    } catch (e) {
      if (e.toString().contains('SESSION_EXPIRED')) {
        _error = 'Session expired. Please log in again.';
      } else {
        _error = e.toString();
      }
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAlert({
    required String token,
    required int alertId,
    int? searchId,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _apiService.deleteAlert(token, alertId);

      _alerts.removeWhere((a) => a.id == alertId);
      _searchAlerts.removeWhere((a) => a.id == alertId);

      return true;
    } catch (e) {
      if (e.toString().contains('SESSION_EXPIRED')) {
        _error = 'Session expired. Please log in again.';
      } else {
        _error = e.toString();
      }
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool hasPriceDropped() {
    if (_prices.length < 2) return false;

    final latest = _prices.last.price;
    final previous = _prices[_prices.length - 2].price;

    return latest < previous;
  }

  double? latestPrice() {
    if (_prices.isEmpty) return null;
    return _prices.last.price;
  }

  double? previousPrice() {
    if (_prices.length < 2) return null;
    return _prices[_prices.length - 2].price;
  }

  void clearSearchData() {
    _searchAlerts = [];
    _prices = [];
    _error = null;
    notifyListeners();
  }
}