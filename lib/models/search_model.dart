class SearchModel {
  final int id;
  final String origin;
  final String destination;
  final String? departDate;
  final String? returnDate;
  final String currency;
  final double? maxPrice;
  final String? createdAt;
  final String? imageUrl;

  SearchModel({
    required this.id,
    required this.origin,
    required this.destination,
    this.departDate,
    this.returnDate,
    required this.currency,
    this.maxPrice,
    this.createdAt,
    this.imageUrl,
  });

  factory SearchModel.fromJson(Map<String, dynamic> json) {
    return SearchModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      origin: json['origin']?.toString() ?? '',
      destination: json['destination']?.toString() ?? '',
      departDate: json['depart_date']?.toString(),
      returnDate: json['return_date']?.toString(),
      currency: json['currency']?.toString() ?? 'USD',
      maxPrice: json['max_price'] == null
          ? null
          : double.tryParse(json['max_price'].toString()),
      createdAt: json['created_at']?.toString(),
      imageUrl: json['image_url']?.toString(),
    );
  }
}