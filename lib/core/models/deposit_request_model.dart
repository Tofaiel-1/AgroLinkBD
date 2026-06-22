import 'package:cloud_firestore/cloud_firestore.dart';

enum DepositStatus { pending, approved, rejected }

class DepositRequestModel {
  final String id;
  final String userId;
  final double amount;
  final String paymentMethod; // e.g., 'bkash', 'nagad', 'bank'
  final String? transactionId; // Optional transaction ID provided by user
  final DepositStatus status;
  final DateTime createdAt;
  final DateTime? processedAt;

  DepositRequestModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.paymentMethod,
    this.transactionId,
    required this.status,
    required this.createdAt,
    this.processedAt,
  });

  factory DepositRequestModel.fromJson(Map<String, dynamic> json) {
    return DepositRequestModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? '',
      transactionId: json['transactionId'],
      status: _statusFromString(json['status']),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      processedAt: json['processedAt'] != null
          ? (json['processedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'processedAt':
          processedAt != null ? Timestamp.fromDate(processedAt!) : null,
    };
  }

  static DepositStatus _statusFromString(String? statusStr) {
    switch (statusStr) {
      case 'approved':
        return DepositStatus.approved;
      case 'rejected':
        return DepositStatus.rejected;
      case 'pending':
      default:
        return DepositStatus.pending;
    }
  }

  String get statusText {
    switch (status) {
      case DepositStatus.pending:
        return 'Pending';
      case DepositStatus.approved:
        return 'Approved';
      case DepositStatus.rejected:
        return 'Rejected';
    }
  }
}
