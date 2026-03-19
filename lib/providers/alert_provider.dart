import 'package:flutter/material.dart';
import '../models/alert_model.dart';
import '../models/price_model.dart';
import '../services/api_service.dart';

class AlertProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool isLoading = false;
  String? error;
  List<AlertModel> alerts = [];
  List<PriceModel> prices = [];

  Future<void> fetchAlerts(String token, int searchId) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final response = await _apiService.getAlertsForSearch(token, searchId);
      final data = response['data'] as List<dynamic>? ?? [];
      alerts = data.map((e) => AlertModel.fromJson(e)).toList();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPriceHistory(String token, int searchId) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final response = await _apiService.getPriceHistory(token, searchId);
      final data = response['data'] as List<dynamic>? ?? [];
      prices = data.map((e) => PriceModel.fromJson(e)).toList();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAlert(
    String token,
    int searchId,
    String ruleType,
    double thresholdValue,
  ) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await _apiService.createAlert(token, searchId, ruleType, thresholdValue);
      await fetchAlerts(token, searchId);
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteAlert(String token, int alertId, int searchId) async {
    try {
      isLoading = true;
      notifyListeners();

      await _apiService.deleteAlert(token, alertId);
      await fetchAlerts(token, searchId);
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}