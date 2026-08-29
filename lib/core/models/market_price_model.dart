enum PriceTrend { up, down, stable }

class MarketPriceModel {
  final String id;
  final String productName;
  final String category;
  final double currentPrice;
  final double previousPrice;
  final String unit;
  final PriceTrend trend;
  final DateTime updatedAt;
  final String? location;
  final String? imageUrl;

  MarketPriceModel({
    required this.id,
    required this.productName,
    required this.category,
    required this.currentPrice,
    required this.previousPrice,
    required this.unit,
    required this.trend,
    required this.updatedAt,
    this.location,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productName': productName,
      'category': category,
      'currentPrice': currentPrice,
      'previousPrice': previousPrice,
      'unit': unit,
      'trend': trend.toString(),
      'updatedAt': updatedAt.toIso8601String(),
      'location': location,
      'imageUrl': imageUrl,
    };
  }

  factory MarketPriceModel.fromJson(Map<String, dynamic> json) {
    return MarketPriceModel(
      id: json['id'],
      productName: json['productName'],
      category: json['category'],
      currentPrice: (json['currentPrice'] as num).toDouble(),
      previousPrice: (json['previousPrice'] as num).toDouble(),
      unit: json['unit'],
      trend: PriceTrend.values.firstWhere(
        (e) => e.toString() == json['trend'],
        orElse: () => PriceTrend.stable,
      ),
      updatedAt: DateTime.parse(json['updatedAt']),
      location: json['location'],
      imageUrl: json['imageUrl'],
    );
  }
}
