class PriceModel {
  final int id;
  final int searchId;
  final double price;
  final DateTime capturedAt;
  final String? source;

  PriceModel({
    required this.id,
    required this.searchId,
    required this.price,
    required this.capturedAt,
    this.source,
  });

  factory PriceModel.fromJson(Map<String, dynamic> json) {
    return PriceModel(
      id: json['id'] ?? 0,
      searchId: json['search_id'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      capturedAt: json['captured_at'] != null
          ? DateTime.tryParse(json['captured_at']) ?? DateTime.now()
          : DateTime.now(),
      source: json['source']?.toString(),
    );
  }
}