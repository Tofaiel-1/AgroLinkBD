import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/masked_identity_helper.dart';

class OrderModel {
  final String id;
  final String buyerId;
  final String farmerId;
  final String farmerName;
  final String productName;
  final String productImageUrl;
  final double quantity;
  final String unit;
  final double totalAmount;
  final double platformFee; // 3% Platform Commission + service margin
  final double farmerPayout; // 97% Net Payout to Farmer
  final double driverFare; // Logistics Trip Fare
  final String deliveryOtp; // 4-digit secret release code
  final String batchCode; // QR Batch tracking code
  final String status;
  final int statusStep; // 1: Pending/Held, 2: Picked Up, 3: Shipped/In Transit, 4: Delivered/Released
  final String transportStatus;
  final String paymentStatus;
  final String escrowStatus; // 'held', 'released', 'refunded', 'disputed'
  final String? driverId;
  final String? driverName;
  final String? qualityGrade;
  final DateTime createdAt;
  final DateTime? estimatedDeliveryDate;
  final DateTime? completedAt;
  final double? rating;
  final String? reviewText;
  final String? specialInstructions;

  OrderModel({
    required this.id,
    required this.buyerId,
    required this.farmerId,
    required this.farmerName,
    required this.productName,
    required this.productImageUrl,
    required this.quantity,
    this.unit = 'কেজি',
    required this.totalAmount,
    double? platformFee,
    double? farmerPayout,
    double? driverFare,
    String? deliveryOtp,
    String? batchCode,
    required this.status,
    required this.statusStep,
    this.transportStatus = 'পেন্ডিং',
    this.paymentStatus = 'paid',
    this.escrowStatus = 'held',
    this.driverId,
    this.driverName,
    this.qualityGrade = 'Grade A (প্রিমিয়াম)',
    required this.createdAt,
    this.estimatedDeliveryDate,
    this.completedAt,
    this.rating,
    this.reviewText,
    this.specialInstructions,
  })  : platformFee = platformFee ?? (totalAmount * 0.03),
        farmerPayout = farmerPayout ?? (totalAmount * 0.97),
        driverFare = driverFare ?? 0.0,
        deliveryOtp = deliveryOtp ?? MaskedIdentityHelper.generateDeliveryOtp(),
        batchCode = batchCode ?? MaskedIdentityHelper.generateBatchCode();

  factory OrderModel.fromMap(Map<String, dynamic> data, String documentId) {
    return OrderModel(
      id: documentId,
      buyerId: data['buyerId'] ?? '',
      farmerId: data['farmerId'] ?? '',
      farmerName: data['farmerName'] ?? 'AgroLink Farmer',
      productName: data['productName'] ?? '',
      productImageUrl: data['productImageUrl'] ?? '',
      quantity: (data['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: data['unit'] ?? 'কেজি',
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      platformFee: (data['platformFee'] as num?)?.toDouble(),
      farmerPayout: (data['farmerPayout'] as num?)?.toDouble(),
      driverFare: (data['driverFare'] as num?)?.toDouble() ?? 0.0,
      deliveryOtp: data['deliveryOtp'] ?? '1234',
      batchCode: data['batchCode'] ?? 'BATCH-BD-0000',
      status: data['status'] ?? 'pending',
      statusStep: (data['statusStep'] as num?)?.toInt() ?? 1,
      transportStatus: data['transportStatus'] ?? 'অর্ডার গৃহীত হয়েছে • এস্ক্রো লকড',
      paymentStatus: data['paymentStatus'] ?? 'paid',
      escrowStatus: data['escrowStatus'] ?? 'held',
      driverId: data['driverId'],
      driverName: data['driverName'],
      qualityGrade: data['qualityGrade'] ?? 'Grade A',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      estimatedDeliveryDate: (data['estimatedDeliveryDate'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      rating: (data['rating'] as num?)?.toDouble(),
      reviewText: data['reviewText'],
      specialInstructions: data['specialInstructions'],
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
      'unit': unit,
      'totalAmount': totalAmount,
      'platformFee': platformFee,
      'farmerPayout': farmerPayout,
      'driverFare': driverFare,
      'deliveryOtp': deliveryOtp,
      'batchCode': batchCode,
      'status': status,
      'statusStep': statusStep,
      'transportStatus': transportStatus,
      'paymentStatus': paymentStatus,
      'escrowStatus': escrowStatus,
      'driverId': driverId,
      'driverName': driverName,
      'qualityGrade': qualityGrade,
      'createdAt': Timestamp.fromDate(createdAt),
      if (estimatedDeliveryDate != null) 'estimatedDeliveryDate': Timestamp.fromDate(estimatedDeliveryDate!),
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
      if (rating != null) 'rating': rating,
      if (reviewText != null) 'reviewText': reviewText,
      if (specialInstructions != null) 'specialInstructions': specialInstructions,
    };
  }
}
