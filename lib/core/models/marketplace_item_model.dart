import 'package:cloud_firestore/cloud_firestore.dart';

class MarketplaceItemModel {
  final String id;
  final String farmerId;
  final String farmerName;
  final String farmerPhone;
  final String fishType;
  final double quantityKg;
  final double avgWeightGram;
  final double pricePerKg;
  final String location;
  final String? imageUrl;
  final String status; // 'active', 'sold', 'cancelled'
  final double? soldPrice;
  final String? soldTo;
  final DateTime? soldAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? description;

  MarketplaceItemModel({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    this.farmerPhone = '',
    required this.fishType,
    required this.quantityKg,
    required this.avgWeightGram,
    required this.pricePerKg,
    this.location = '',
    this.imageUrl,
    this.status = 'active',
    this.soldPrice,
    this.soldTo,
    this.soldAt,
    required this.createdAt,
    this.updatedAt,
    this.description,
  });

  double get totalEstimatedValue => quantityKg * pricePerKg;

  factory MarketplaceItemModel.fromMap(Map<String, dynamic> data, String documentId) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) {
        final parsed = DateTime.tryParse(val);
        if (parsed != null) return parsed;
      }
      return DateTime.now();
    }

    DateTime? parseNullableDate(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return MarketplaceItemModel(
      id: documentId,
      farmerId: data['farmerId']?.toString() ?? '',
      farmerName: data['farmerName']?.toString() ?? 'Fish Farmer',
      farmerPhone: data['farmerPhone']?.toString() ?? '',
      fishType: data['fishType']?.toString() ?? 'দেশি মাছ',
      quantityKg: (data['quantityKg'] is num) ? (data['quantityKg'] as num).toDouble() : (double.tryParse(data['quantityKg']?.toString() ?? '0') ?? 0.0),
      avgWeightGram: (data['avgWeightGram'] is num) ? (data['avgWeightGram'] as num).toDouble() : (double.tryParse(data['avgWeightGram']?.toString() ?? '0') ?? 0.0),
      pricePerKg: (data['pricePerKg'] is num) ? (data['pricePerKg'] as num).toDouble() : (double.tryParse(data['pricePerKg']?.toString() ?? '0') ?? 0.0),
      location: data['location']?.toString() ?? '',
      imageUrl: data['imageUrl']?.toString(),
      status: data['status']?.toString() ?? 'active',
      soldPrice: data['soldPrice'] != null ? (data['soldPrice'] as num).toDouble() : null,
      soldTo: data['soldTo']?.toString(),
      soldAt: parseNullableDate(data['soldAt']),
      createdAt: parseDate(data['createdAt']),
      updatedAt: parseNullableDate(data['updatedAt']),
      description: data['description']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'farmerId': farmerId,
      'farmerName': farmerName,
      'farmerPhone': farmerPhone,
      'fishType': fishType,
      'quantityKg': quantityKg,
      'avgWeightGram': avgWeightGram,
      'pricePerKg': pricePerKg,
      'location': location,
      'imageUrl': imageUrl,
      'status': status,
      'soldPrice': soldPrice,
      'soldTo': soldTo,
      'soldAt': soldAt != null ? Timestamp.fromDate(soldAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'description': description,
    };
  }

  MarketplaceItemModel copyWith({
    String? id,
    String? farmerId,
    String? farmerName,
    String? farmerPhone,
    String? fishType,
    double? quantityKg,
    double? avgWeightGram,
    double? pricePerKg,
    String? location,
    String? imageUrl,
    String? status,
    double? soldPrice,
    String? soldTo,
    DateTime? soldAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? description,
  }) {
    return MarketplaceItemModel(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      farmerPhone: farmerPhone ?? this.farmerPhone,
      fishType: fishType ?? this.fishType,
      quantityKg: quantityKg ?? this.quantityKg,
      avgWeightGram: avgWeightGram ?? this.avgWeightGram,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      soldPrice: soldPrice ?? this.soldPrice,
      soldTo: soldTo ?? this.soldTo,
      soldAt: soldAt ?? this.soldAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      description: description ?? this.description,
    );
  }
}

