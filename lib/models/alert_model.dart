class AlertModel {
  final int id;
  final int searchId;
  final String ruleType;
  final double thresholdValue;
  final bool isActive;
  final String origin;
  final String destination;

  AlertModel({
    required this.id,
    required this.searchId,
    required this.ruleType,
    required this.thresholdValue,
    required this.isActive,
    required this.origin,
    required this.destination,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: _toInt(json['id']),
      searchId: _toInt(json['search_id']),
      ruleType: json['rule_type']?.toString() ?? '',
      thresholdValue: _toDouble(json['threshold_value']),
      isActive: json['is_active'] == true ||
          json['is_active'] == 1 ||
          json['is_active']?.toString().toLowerCase() == 'true' ||
          json['is_active']?.toString() == '1',
      origin: json['origin']?.toString() ?? '',
      destination: json['destination']?.toString() ?? '',
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}