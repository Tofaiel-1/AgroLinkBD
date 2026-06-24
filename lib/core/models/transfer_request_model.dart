import 'package:cloud_firestore/cloud_firestore.dart';

class TransferRequestModel {
  final String id;
  final String senderId;
  final String receiverId;
  final double amount;
  final String paymentMethod;
  final String accountNumber;
  final String reason;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;

  TransferRequestModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.amount,
    required this.paymentMethod,
    required this.accountNumber,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory TransferRequestModel.fromJson(Map<String, dynamic> json, String documentId) {
    DateTime parsedCreatedAt;
    try {
      final rawCreatedAt = json['createdAt'];
      if (rawCreatedAt is Timestamp) {
        parsedCreatedAt = rawCreatedAt.toDate();
      } else if (rawCreatedAt is String) {
        parsedCreatedAt = DateTime.parse(rawCreatedAt);
      } else {
        parsedCreatedAt = DateTime.now();
      }
    } catch (_) {
      parsedCreatedAt = DateTime.now();
    }

    return TransferRequestModel(
      id: documentId,
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'accountNumber': accountNumber,
      'reason': reason,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
