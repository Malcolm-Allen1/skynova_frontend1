class PriceModel {
  final int id;
  final double price;
  final String capturedAt;
  final String? source;

  PriceModel({
    required this.id,
    required this.price,
    required this.capturedAt,
    this.source,
  });

  factory PriceModel.fromJson(Map<String, dynamic> json) {
    return PriceModel(
      id: json['id'],
      price: double.tryParse(json['price'].toString()) ?? 0,
      capturedAt: json['captured_at'] ?? '',
      source: json['source'],
    );
  }
}