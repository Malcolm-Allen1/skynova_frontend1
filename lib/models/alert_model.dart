class AlertModel {
  final int id;
  final int searchId;
  final String ruleType;
  final double thresholdValue;
  final int isActive;
  final String? lastTriggeredAt;

  AlertModel({
    required this.id,
    required this.searchId,
    required this.ruleType,
    required this.thresholdValue,
    required this.isActive,
    this.lastTriggeredAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'],
      searchId: json['search_id'],
      ruleType: json['rule_type'],
      thresholdValue: double.tryParse(json['threshold_value'].toString()) ?? 0,
      isActive: json['is_active'] ?? 1,
      lastTriggeredAt: json['last_triggered_at'],
    );
  }
}