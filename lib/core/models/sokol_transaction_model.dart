import 'package:cloud_firestore/cloud_firestore.dart';

class SokolTransactionModel {
  final String id;
  final String senderUid;
  final String receiverUid;
  final double amount;
  final String paymentMethod;
  final String status; // pending, success, failed
  final DateTime timestamp;
  final String? description;

  SokolTransactionModel({
    required this.id,
    required this.senderUid,
    required this.receiverUid,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.timestamp,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderUid': senderUid,
      'receiverUid': receiverUid,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
      'description': description,
    };
  }

  factory SokolTransactionModel.fromJson(Map<String, dynamic> json, String id) {
    DateTime parsedTimestamp = DateTime.now();
    if (json['timestamp'] != null) {
      if (json['timestamp'] is Timestamp) {
        parsedTimestamp = (json['timestamp'] as Timestamp).toDate();
      } else if (json['timestamp'] is String) {
        parsedTimestamp = DateTime.tryParse(json['timestamp']) ?? DateTime.now();
      }
    }

    return SokolTransactionModel(
      id: id,
      senderUid: json['senderUid'] ?? '',
      receiverUid: json['receiverUid'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? '',
      status: json['status'] ?? 'pending',
      timestamp: parsedTimestamp,
      description: json['description'],
    );
  }
}
