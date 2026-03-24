class AlertModel {
  final int id;
  final String origin;
  final String destination;
  final String ruleType;
  final dynamic thresholdValue;
  final bool isActive;
  final String? lastTriggeredAt; // 🔥 ADD THIS

  AlertModel({
    required this.id,
    required this.origin,
    required this.destination,
    required this.ruleType,
    required this.thresholdValue,
    required this.isActive,
    this.lastTriggeredAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] ?? 0,
      origin: json['origin'] ?? '',
      destination: json['destination'] ?? '',
      ruleType: json['rule_type'] ?? '',
      thresholdValue: json['threshold_value'] ?? '',
      isActive: json['is_active'] == true || json['is_active'] == 1,
      lastTriggeredAt: json['last_triggered_at'], // 🔥 ADD THIS
    );
  }
}