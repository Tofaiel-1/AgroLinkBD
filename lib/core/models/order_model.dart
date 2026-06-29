import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String buyerId;
  final String farmerId;
  final String farmerName;
  final String productName;
  final String productImageUrl;
  final int quantity;
  final double totalAmount;
  final String status;
  final int statusStep; // 1: Pending, 2: Processing, 3: Shipped, 4: Delivered
  final String transportStatus;
  final String paymentStatus;
  final DateTime createdAt;
  final DateTime? estimatedDeliveryDate;
  final double? rating;
  final String? reviewText;

  OrderModel({
    required this.id,
    required this.buyerId,
    required this.farmerId,
    required this.farmerName,
    required this.productName,
    required this.productImageUrl,
    required this.quantity,
    required this.totalAmount,
    required this.status,
    required this.statusStep,
    required this.transportStatus,
    required this.paymentStatus,
    required this.createdAt,
    this.estimatedDeliveryDate,
    this.rating,
    this.reviewText,
  });

  factory OrderModel.fromMap(Map<String, dynamic> data, String documentId) {
    return OrderModel(
      id: documentId,
      buyerId: data['buyerId'] ?? '',
      farmerId: data['farmerId'] ?? '',
      farmerName: data['farmerName'] ?? 'AgroLink Farmer',
      productName: data['productName'] ?? '',
      productImageUrl: data['productImageUrl'] ?? '',
      quantity: data['quantity'] ?? 1,
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] ?? 'pending',
      statusStep: data['statusStep'] ?? 1,
      transportStatus: data['transportStatus'] ?? 'অর্ডার গৃহীত হয়েছে',
      paymentStatus: data['paymentStatus'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      estimatedDeliveryDate: (data['estimatedDeliveryDate'] as Timestamp?)?.toDate(),
      rating: (data['rating'] as num?)?.toDouble(),
      reviewText: data['reviewText'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'buyerId': buyerId,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'productName': productName,
      'productImageUrl': productImageUrl,
      'quantity': quantity,
      'totalAmount': totalAmount,
      'status': status,
      'statusStep': statusStep,
      'transportStatus': transportStatus,
      'paymentStatus': paymentStatus,
      'createdAt': Timestamp.fromDate(createdAt),
      if (estimatedDeliveryDate != null) 'estimatedDeliveryDate': Timestamp.fromDate(estimatedDeliveryDate!),
      if (rating != null) 'rating': rating,
      if (reviewText != null) 'reviewText': reviewText,
    };
  }
}
