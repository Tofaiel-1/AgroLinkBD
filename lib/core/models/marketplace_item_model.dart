import 'package:cloud_firestore/cloud_firestore.dart';

class MarketplaceItemModel {
  final String id;
  final String farmerId;
  final String farmerName;
  final String fishType;
  final double quantityKg;
  final double avgWeightGram;
  final double pricePerKg;
  final String status;
  final DateTime createdAt;

  MarketplaceItemModel({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.fishType,
    required this.quantityKg,
    required this.avgWeightGram,
    required this.pricePerKg,
    this.status = 'available',
    required this.createdAt,
  });

  factory MarketplaceItemModel.fromMap(Map<String, dynamic> data, String documentId) {
    return MarketplaceItemModel(
      id: documentId,
      farmerId: data['farmerId'] ?? '',
      farmerName: data['farmerName'] ?? 'Unknown Farmer',
      fishType: data['fishType'] ?? '',
      quantityKg: (data['quantityKg'] ?? 0).toDouble(),
      avgWeightGram: (data['avgWeightGram'] ?? 0).toDouble(),
      pricePerKg: (data['pricePerKg'] ?? 0).toDouble(),
      status: data['status'] ?? 'available',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'farmerId': farmerId,
      'farmerName': farmerName,
      'fishType': fishType,
      'quantityKg': quantityKg,
      'avgWeightGram': avgWeightGram,
      'pricePerKg': pricePerKg,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
