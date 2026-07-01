import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentRequestStatus { pending, accepted, rejected }

class PaymentRequestModel {
  final String requestId;
  final String requesterUid;
  final String payerUid;
  final double amount;
  final String? note;
  final PaymentRequestStatus status;
  final DateTime timestamp;

  PaymentRequestModel({
    required this.requestId,
    required this.requesterUid,
    required this.payerUid,
    required this.amount,
    this.note,
    this.status = PaymentRequestStatus.pending,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'requesterUid': requesterUid,
      'payerUid': payerUid,
      'amount': amount,
      'note': note,
      'status': status.name,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory PaymentRequestModel.fromJson(Map<String, dynamic> json, String id) {
    return PaymentRequestModel(
      requestId: id,
      requesterUid: json['requesterUid'] ?? '',
      payerUid: json['payerUid'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      note: json['note'],
      status: PaymentRequestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentRequestStatus.pending,
      ),
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }
}
