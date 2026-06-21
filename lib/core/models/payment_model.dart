import 'package:intl/intl.dart';

// Payment Models
enum PaymentMethod { bkash, nagad, rocket, card, flutterwave }

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
  cancelled
}

enum TransactionType { credit, debit, refund }

class Payment {
  final String id;
  final String userId;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final String
      purpose; // e.g., 'subscription', 'featured_post', 'investment', 'order'
  final String? transactionId;
  final String? orderId;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? refundedAt;
  final String? failureReason;
  final String? receipientId;

  Payment({
    required this.id,
    required this.userId,
    required this.amount,
    required this.method,
    required this.status,
    required this.purpose,
    this.transactionId,
    this.orderId,
    this.metadata = const {},
    required this.createdAt,
    this.completedAt,
    this.refundedAt,
    this.failureReason,
    this.receipientId,
  });

  bool get isCompleted => status == PaymentStatus.completed;
  bool get isFailed => status == PaymentStatus.failed;
  bool get isPending => status == PaymentStatus.pending;
  bool get isProcessing => status == PaymentStatus.processing;
  bool get canRefund => isCompleted && refundedAt == null;

  String get statusText {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.processing:
        return 'Processing';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
      case PaymentStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get methodText {
    switch (method) {
      case PaymentMethod.bkash:
        return 'bKash';
      case PaymentMethod.nagad:
        return 'Nagad';
      case PaymentMethod.rocket:
        return 'Rocket';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.flutterwave:
        return 'Flutterwave';
    }
  }

  String get formattedAmount {
    return 'Tk ${amount.toStringAsFixed(2)}';
  }

  String get formattedDate {
    return DateFormat('dd MMM yyyy, hh:mm a').format(createdAt);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'method': method.toString(),
      'status': status.toString(),
      'purpose': purpose,
      'transactionId': transactionId,
      'orderId': orderId,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'refundedAt': refundedAt?.toIso8601String(),
      'failureReason': failureReason,
      'receipientId': receipientId,
    };
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      userId: json['userId'],
      amount: (json['amount'] as num).toDouble(),
      method: PaymentMethod.values.firstWhere(
        (e) => e.toString() == json['method'],
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      purpose: json['purpose'],
      transactionId: json['transactionId'],
      orderId: json['orderId'],
      metadata: json['metadata'] ?? {},
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      refundedAt: json['refundedAt'] != null
          ? DateTime.parse(json['refundedAt'])
          : null,
      failureReason: json['failureReason'],
      receipientId: json['receipientId'],
    );
  }

  Payment copyWith({
    String? id,
    String? userId,
    double? amount,
    PaymentMethod? method,
    PaymentStatus? status,
    String? purpose,
    String? transactionId,
    String? orderId,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? refundedAt,
    String? failureReason,
    String? receipientId,
  }) {
    return Payment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      status: status ?? this.status,
      purpose: purpose ?? this.purpose,
      transactionId: transactionId ?? this.transactionId,
      orderId: orderId ?? this.orderId,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      refundedAt: refundedAt ?? this.refundedAt,
      failureReason: failureReason ?? this.failureReason,
      receipientId: receipientId ?? this.receipientId,
    );
  }
}

class Transaction {
  final String id;
  final String userId;
  final TransactionType type;
  final double amount;
  final String title;
  final String? description;
  final String? paymentId; // Link to payment
  final String? relatedId; // Link to product, order, etc.
  final String? relatedType; // 'order', 'subscription', 'refund', etc.
  final double? balanceBefore;
  final double? balanceAfter;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final String status; // 'completed', 'pending', 'failed'

  Transaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.title,
    this.description,
    this.paymentId,
    this.relatedId,
    this.relatedType,
    this.balanceBefore,
    this.balanceAfter,
    this.metadata = const {},
    required this.createdAt,
    this.status = 'completed',
  });

  String get typeText {
    switch (type) {
      case TransactionType.credit:
        return 'Credit';
      case TransactionType.debit:
        return 'Debit';
      case TransactionType.refund:
        return 'Refund';
    }
  }

  String get typeIcon {
    switch (type) {
      case TransactionType.credit:
        return '+';
      case TransactionType.debit:
        return '-';
      case TransactionType.refund:
        return '↩';
    }
  }

  String get formattedAmount {
    return '${type == TransactionType.debit ? '-' : '+'}Tk ${amount.toStringAsFixed(2)}';
  }

  String get formattedDate {
    return DateFormat('dd MMM yyyy, hh:mm a').format(createdAt);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString(),
      'amount': amount,
      'title': title,
      'description': description,
      'paymentId': paymentId,
      'relatedId': relatedId,
      'relatedType': relatedType,
      'balanceBefore': balanceBefore,
      'balanceAfter': balanceAfter,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      userId: json['userId'],
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      amount: (json['amount'] as num).toDouble(),
      title: json['title'],
      description: json['description'],
      paymentId: json['paymentId'],
      relatedId: json['relatedId'],
      relatedType: json['relatedType'],
      balanceBefore: json['balanceBefore'] != null
          ? (json['balanceBefore'] as num).toDouble()
          : null,
      balanceAfter: json['balanceAfter'] != null
          ? (json['balanceAfter'] as num).toDouble()
          : null,
      metadata: json['metadata'] ?? {},
      createdAt: DateTime.parse(json['createdAt']),
      status: json['status'] ?? 'completed',
    );
  }

  Transaction copyWith({
    String? id,
    String? userId,
    TransactionType? type,
    double? amount,
    String? title,
    String? description,
    String? paymentId,
    String? relatedId,
    String? relatedType,
    double? balanceBefore,
    double? balanceAfter,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    String? status,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      title: title ?? this.title,
      description: description ?? this.description,
      paymentId: paymentId ?? this.paymentId,
      relatedId: relatedId ?? this.relatedId,
      relatedType: relatedType ?? this.relatedType,
      balanceBefore: balanceBefore ?? this.balanceBefore,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}

class PaymentReceipt {
  final String receiptNumber;
  final Payment payment;
  final Transaction? transaction;
  final String? orderId;
  final String? orderDescription;
  final DateTime issuedAt;

  PaymentReceipt({
    required this.receiptNumber,
    required this.payment,
    this.transaction,
    this.orderId,
    this.orderDescription,
    required this.issuedAt,
  });

  String get formattedReceipt {
    return '''
========== PAYMENT RECEIPT ==========
Receipt No: $receiptNumber
Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(issuedAt)}
User ID: ${payment.userId}

Payment Details:
Amount: ${payment.formattedAmount}
Method: ${payment.methodText}
Status: ${payment.statusText}

${orderId != null ? 'Order ID: $orderId' : ''}
${orderDescription != null ? 'Description: $orderDescription' : ''}
${payment.transactionId != null ? 'Transaction ID: ${payment.transactionId}' : ''}

Purpose: ${payment.purpose}
=======================================
''';
  }
}
