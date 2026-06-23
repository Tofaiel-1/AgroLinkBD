import 'package:cloud_firestore/cloud_firestore.dart';

enum WithdrawStatus { pending, approved, rejected }

class WithdrawRequestModel {
  final String id;
  final String userId;
  final double amount;
  final String method; // e.g., 'bkash', 'nagad', 'bank'
  final String accountDetails; // e.g., phone number or bank details
  final WithdrawStatus status;
  final DateTime createdAt;
  final DateTime? processedAt;

  WithdrawRequestModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.method,
    required this.accountDetails,
    required this.status,
    required this.createdAt,
    this.processedAt,
  });

  factory WithdrawRequestModel.fromJson(Map<String, dynamic> json) {
    return WithdrawRequestModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      method: json['method'] ?? '',
      accountDetails: json['accountDetails'] ?? '',
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
      'method': method,
      'accountDetails': accountDetails,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'processedAt':
          processedAt != null ? Timestamp.fromDate(processedAt!) : null,
    };
  }

  static WithdrawStatus _statusFromString(String? statusStr) {
    switch (statusStr) {
      case 'approved':
        return WithdrawStatus.approved;
      case 'rejected':
        return WithdrawStatus.rejected;
      case 'pending':
      default:
        return WithdrawStatus.pending;
    }
  }

  String get statusText {
    switch (status) {
      case WithdrawStatus.pending:
        return 'Pending';
      case WithdrawStatus.approved:
        return 'Approved';
      case WithdrawStatus.rejected:
        return 'Rejected';
    }
  }
}
