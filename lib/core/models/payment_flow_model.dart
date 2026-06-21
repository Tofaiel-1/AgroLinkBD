import 'package:intl/intl.dart';
import 'enhanced_transaction_model.dart';

// ============================================================================
// PAYMENT FLOW MODEL (for tracking multi-party cyclic payments)
// ============================================================================

enum PaymentFlowType {
  buyerToFarmer, // Buyer purchases crops from Farmer
  farmerToShopOwner, // Farmer buys inputs from Shop
  buyerToDriver, // Buyer pays Driver for transport
  farmerToDriver, // Farmer pays Driver for transport
  multiPartyTransport, // Both Buyer & Farmer pay Driver
  refund, // Refund payment
  commission, // Commission settlement
  platformTransfer, // Money transfer via wallet
  incentive, // Bonus or incentive
}

enum PaymentFlowStatus {
  initiated, // Flow just started
  pending, // Awaiting confirmation
  partiallyPaid, // Some payments completed
  completed, // All payments completed
  failed, // One or more failed
  disputed, // Under dispute
  cancelled, // Cancelled by user
  refunded, // Refunded
}

class PaymentFlow {
  final String id;
  final PaymentFlowType flowType;
  final String initiatorId; // Who started the flow
  final String? initiatorName;

  // Primary recipient
  final String primaryRecipientId;
  final String? primaryRecipientName;

  // Multi-party tracking
  final List<PaymentParty> parties; // All parties involved

  // Reference Information
  final String? relatedOrderId; // Related product order
  final String? relatedTransportId; // Related transport request
  final String? relatedProductId;
  final String? relatedSupplyId;

  // Amount Details
  final double totalAmount;
  final List<PaymentSplit> splits; // How amount is split
  final double totalCommission;

  // Transaction Tracking
  final List<String> transactionIds; // Related transactions
  final List<String> completedTransactionIds;
  final List<String> pendingTransactionIds;

  // Status Tracking
  final PaymentFlowStatus status;
  final String? failureReason;
  final int retryCount;

  // Metadata
  final Map<String, dynamic> metadata;
  final String? notes;

  // Timestamps
  final DateTime createdAt;
  final DateTime? initiatedAt;
  final DateTime? completedAt;
  final DateTime? expiresAt;

  PaymentFlow({
    required this.id,
    required this.flowType,
    required this.initiatorId,
    this.initiatorName,
    required this.primaryRecipientId,
    this.primaryRecipientName,
    required this.parties,
    this.relatedOrderId,
    this.relatedTransportId,
    this.relatedProductId,
    this.relatedSupplyId,
    required this.totalAmount,
    required this.splits,
    required this.totalCommission,
    this.transactionIds = const [],
    this.completedTransactionIds = const [],
    this.pendingTransactionIds = const [],
    required this.status,
    this.failureReason,
    this.retryCount = 0,
    this.metadata = const {},
    this.notes,
    required this.createdAt,
    this.initiatedAt,
    this.completedAt,
    this.expiresAt,
  });

  // Computed properties
  bool get isCompleted => status == PaymentFlowStatus.completed;
  bool get isFailed => status == PaymentFlowStatus.failed;
  bool get isPending => status == PaymentFlowStatus.pending;
  bool get isPartiallyPaid => status == PaymentFlowStatus.partiallyPaid;
  bool get isDisputed => status == PaymentFlowStatus.disputed;
  bool get isCancelled => status == PaymentFlowStatus.cancelled;
  bool get isRefunded => status == PaymentFlowStatus.refunded;

  double get totalPaid {
    return splits
        .where((s) => s.status == TransactionStatus.completed)
        .fold(0, (prev, s) => prev + s.amount);
  }

  double get remainingAmount => totalAmount - totalPaid;
  int get totalParties => parties.length;
  int get completedParties =>
      parties.where((p) => p.status == TransactionStatus.completed).length;

  bool get allPartiesPaid => completedParties == totalParties;

  String get progressText {
    final percent = (totalPaid / totalAmount * 100).toStringAsFixed(0);
    return '$percent% complete';
  }

  String get statusText {
    switch (status) {
      case PaymentFlowStatus.initiated:
        return 'Initiated';
      case PaymentFlowStatus.pending:
        return 'Pending';
      case PaymentFlowStatus.partiallyPaid:
        return 'Partially Paid';
      case PaymentFlowStatus.completed:
        return 'Completed';
      case PaymentFlowStatus.failed:
        return 'Failed';
      case PaymentFlowStatus.disputed:
        return 'Disputed';
      case PaymentFlowStatus.cancelled:
        return 'Cancelled';
      case PaymentFlowStatus.refunded:
        return 'Refunded';
    }
  }

  String get typeText {
    switch (flowType) {
      case PaymentFlowType.buyerToFarmer:
        return 'Product Purchase';
      case PaymentFlowType.farmerToShopOwner:
        return 'Supply Purchase';
      case PaymentFlowType.buyerToDriver:
        return 'Transport - Buyer';
      case PaymentFlowType.farmerToDriver:
        return 'Transport - Farmer';
      case PaymentFlowType.multiPartyTransport:
        return 'Transport - Shared';
      case PaymentFlowType.refund:
        return 'Refund';
      case PaymentFlowType.commission:
        return 'Commission';
      case PaymentFlowType.platformTransfer:
        return 'Wallet Transfer';
      case PaymentFlowType.incentive:
        return 'Incentive';
    }
  }

  String get formattedAmount {
    return 'Tk ${totalAmount.toStringAsFixed(2)}';
  }

  String get formattedTotalPaid {
    return 'Tk ${totalPaid.toStringAsFixed(2)}';
  }

  String get formattedRemainingAmount {
    return 'Tk ${remainingAmount.toStringAsFixed(2)}';
  }

  String get formattedDate {
    return DateFormat('dd MMM yyyy, hh:mm a').format(createdAt);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'flowType': flowType.toString(),
      'initiatorId': initiatorId,
      'initiatorName': initiatorName,
      'primaryRecipientId': primaryRecipientId,
      'primaryRecipientName': primaryRecipientName,
      'parties': parties.map((p) => p.toJson()).toList(),
      'relatedOrderId': relatedOrderId,
      'relatedTransportId': relatedTransportId,
      'relatedProductId': relatedProductId,
      'relatedSupplyId': relatedSupplyId,
      'totalAmount': totalAmount,
      'splits': splits.map((s) => s.toJson()).toList(),
      'totalCommission': totalCommission,
      'transactionIds': transactionIds,
      'completedTransactionIds': completedTransactionIds,
      'pendingTransactionIds': pendingTransactionIds,
      'status': status.toString(),
      'failureReason': failureReason,
      'retryCount': retryCount,
      'metadata': metadata,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'initiatedAt': initiatedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  factory PaymentFlow.fromJson(Map<String, dynamic> json) {
    return PaymentFlow(
      id: json['id'],
      flowType: PaymentFlowType.values.firstWhere(
        (e) => e.toString() == json['flowType'],
      ),
      initiatorId: json['initiatorId'],
      initiatorName: json['initiatorName'],
      primaryRecipientId: json['primaryRecipientId'],
      primaryRecipientName: json['primaryRecipientName'],
      parties: (json['parties'] as List<dynamic>)
          .map((p) => PaymentParty.fromJson(p))
          .toList(),
      relatedOrderId: json['relatedOrderId'],
      relatedTransportId: json['relatedTransportId'],
      relatedProductId: json['relatedProductId'],
      relatedSupplyId: json['relatedSupplyId'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      splits: (json['splits'] as List<dynamic>)
          .map((s) => PaymentSplit.fromJson(s))
          .toList(),
      totalCommission: (json['totalCommission'] as num).toDouble(),
      transactionIds: List<String>.from(json['transactionIds'] ?? []),
      completedTransactionIds:
          List<String>.from(json['completedTransactionIds'] ?? []),
      pendingTransactionIds:
          List<String>.from(json['pendingTransactionIds'] ?? []),
      status: PaymentFlowStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      failureReason: json['failureReason'],
      retryCount: json['retryCount'] ?? 0,
      metadata: json['metadata'] ?? {},
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      initiatedAt: json['initiatedAt'] != null
          ? DateTime.parse(json['initiatedAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      expiresAt:
          json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    );
  }

  PaymentFlow copyWith({
    String? id,
    PaymentFlowType? flowType,
    String? initiatorId,
    String? initiatorName,
    String? primaryRecipientId,
    String? primaryRecipientName,
    List<PaymentParty>? parties,
    String? relatedOrderId,
    String? relatedTransportId,
    String? relatedProductId,
    String? relatedSupplyId,
    double? totalAmount,
    List<PaymentSplit>? splits,
    double? totalCommission,
    List<String>? transactionIds,
    List<String>? completedTransactionIds,
    List<String>? pendingTransactionIds,
    PaymentFlowStatus? status,
    String? failureReason,
    int? retryCount,
    Map<String, dynamic>? metadata,
    String? notes,
    DateTime? createdAt,
    DateTime? initiatedAt,
    DateTime? completedAt,
    DateTime? expiresAt,
  }) {
    return PaymentFlow(
      id: id ?? this.id,
      flowType: flowType ?? this.flowType,
      initiatorId: initiatorId ?? this.initiatorId,
      initiatorName: initiatorName ?? this.initiatorName,
      primaryRecipientId: primaryRecipientId ?? this.primaryRecipientId,
      primaryRecipientName: primaryRecipientName ?? this.primaryRecipientName,
      parties: parties ?? this.parties,
      relatedOrderId: relatedOrderId ?? this.relatedOrderId,
      relatedTransportId: relatedTransportId ?? this.relatedTransportId,
      relatedProductId: relatedProductId ?? this.relatedProductId,
      relatedSupplyId: relatedSupplyId ?? this.relatedSupplyId,
      totalAmount: totalAmount ?? this.totalAmount,
      splits: splits ?? this.splits,
      totalCommission: totalCommission ?? this.totalCommission,
      transactionIds: transactionIds ?? this.transactionIds,
      completedTransactionIds:
          completedTransactionIds ?? this.completedTransactionIds,
      pendingTransactionIds:
          pendingTransactionIds ?? this.pendingTransactionIds,
      status: status ?? this.status,
      failureReason: failureReason ?? this.failureReason,
      retryCount: retryCount ?? this.retryCount,
      metadata: metadata ?? this.metadata,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      initiatedAt: initiatedAt ?? this.initiatedAt,
      completedAt: completedAt ?? this.completedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

// ============================================================================
// PAYMENT PARTY MODEL
// ============================================================================

class PaymentParty {
  final String userId;
  final String? userName;
  final String userType; // farmer, buyer, driver, shop
  final double amount;
  final TransactionStatus status;
  final DateTime? paidAt;
  final String? transactionId;
  final String? notes;

  PaymentParty({
    required this.userId,
    this.userName,
    required this.userType,
    required this.amount,
    required this.status,
    this.paidAt,
    this.transactionId,
    this.notes,
  });

  bool get isPaid => status == TransactionStatus.completed;

  String get statusText {
    switch (status) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.confirmed:
        return 'Confirmed';
      case TransactionStatus.processing:
        return 'Processing';
      case TransactionStatus.completed:
        return 'Paid';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.refunded:
        return 'Refunded';
      case TransactionStatus.disputed:
        return 'Disputed';
      case TransactionStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get formattedAmount {
    return 'Tk ${amount.toStringAsFixed(2)}';
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userType': userType,
      'amount': amount,
      'status': status.toString(),
      'paidAt': paidAt?.toIso8601String(),
      'transactionId': transactionId,
      'notes': notes,
    };
  }

  factory PaymentParty.fromJson(Map<String, dynamic> json) {
    return PaymentParty(
      userId: json['userId'],
      userName: json['userName'],
      userType: json['userType'],
      amount: (json['amount'] as num).toDouble(),
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      transactionId: json['transactionId'],
      notes: json['notes'],
    );
  }
}

// ============================================================================
// PAYMENT SPLIT MODEL
// ============================================================================

class PaymentSplit {
  final String id;
  final String recipientId;
  final String? recipientName;
  final double amount;
  final double percentage;
  final String reason; // 'principal', 'commission', 'refund', 'fee'
  final TransactionStatus status;
  final DateTime? completedAt;
  final String? transactionId;
  final String? notes;

  PaymentSplit({
    required this.id,
    required this.recipientId,
    this.recipientName,
    required this.amount,
    required this.percentage,
    required this.reason,
    required this.status,
    this.completedAt,
    this.transactionId,
    this.notes,
  });

  bool get isCompleted => status == TransactionStatus.completed;

  String get statusText {
    switch (status) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.confirmed:
        return 'Confirmed';
      case TransactionStatus.processing:
        return 'Processing';
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.refunded:
        return 'Refunded';
      case TransactionStatus.disputed:
        return 'Disputed';
      case TransactionStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get reasonText {
    switch (reason) {
      case 'principal':
        return 'Principal Amount';
      case 'commission':
        return 'Platform Commission';
      case 'refund':
        return 'Refund';
      case 'fee':
        return 'Service Fee';
      default:
        return reason;
    }
  }

  String get formattedAmount {
    return 'Tk ${amount.toStringAsFixed(2)}';
  }

  String get formattedPercentage {
    return '${percentage.toStringAsFixed(2)}%';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipientId': recipientId,
      'recipientName': recipientName,
      'amount': amount,
      'percentage': percentage,
      'reason': reason,
      'status': status.toString(),
      'completedAt': completedAt?.toIso8601String(),
      'transactionId': transactionId,
      'notes': notes,
    };
  }

  factory PaymentSplit.fromJson(Map<String, dynamic> json) {
    return PaymentSplit(
      id: json['id'],
      recipientId: json['recipientId'],
      recipientName: json['recipientName'],
      amount: (json['amount'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
      reason: json['reason'],
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      transactionId: json['transactionId'],
      notes: json['notes'],
    );
  }

  PaymentSplit copyWith({
    String? id,
    String? recipientId,
    String? recipientName,
    double? amount,
    double? percentage,
    String? reason,
    TransactionStatus? status,
    DateTime? completedAt,
    String? transactionId,
    String? notes,
  }) {
    return PaymentSplit(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      recipientName: recipientName ?? this.recipientName,
      amount: amount ?? this.amount,
      percentage: percentage ?? this.percentage,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      transactionId: transactionId ?? this.transactionId,
      notes: notes ?? this.notes,
    );
  }
}
