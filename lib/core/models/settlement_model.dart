import 'package:intl/intl.dart';

// ============================================================================
// SETTLEMENT MODEL
// ============================================================================

enum SettlementStatus {
  pending, // Awaiting approval
  approved, // Approved by platform
  processing, // Being processed for payout
  completed, // Successfully settled
  failed, // Settlement failed
  cancelled, // Cancelled by user or admin
  disputed, // Under dispute
}

enum SettlementPeriod {
  daily, // Every day
  weekly, // Every 7 days
  biWeekly, // Every 14 days
  monthly, // Every 30 days
}

class Settlement {
  final String id;
  final String userId;
  final String? userName;

  // Amount Details
  final double totalTransactionAmount; // Sum of all transactions
  final double totalCommissionDeducted; // Commission paid to platform
  final double totalRefundsProcessed; // Total refunds issued
  final double netAmount; // Final amount to be paid out

  // Period Information
  final SettlementPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime generatedAt;

  // Transaction Details
  final List<String> transactionIds;
  final int transactionCount;
  final Map<String, dynamic> categoryBreakdown; // By category
  final Map<String, int> paymentMethodBreakdown; // By method

  // Status & Approval
  final SettlementStatus status;
  final String? approverAdminId;
  final DateTime? approvedAt;
  final String? approvalNotes;

  // Payout Information
  final String? paymentMethod; // bkash, nagad, bank transfer, etc
  final String? bankAccountId;
  final String? bankAccountNumber;
  final String? bankName;
  final String? transactionReference; // Payout transaction ID
  final DateTime? settledAt; // When payout completed

  // Deductions & Fees
  final double processingFee;
  final double taxDeducted;
  final double otherDeductions;

  // Settlement Proof
  final String? settlementProofId; // File/document ID
  final String? settlementProofUrl;
  final DateTime? proofGeneratedAt;

  // Dispute Information
  final bool isDisputed;
  final String? disputeReason;
  final DateTime? disputeRaisedAt;
  final String? disputeResolution;

  // Metadata & Notes
  final Map<String, dynamic> metadata;
  final String? notes;
  final String? adminNotes;

  // Retry Information
  final int retryCount;
  final DateTime? lastRetryAt;
  final String? lastErrorMessage;

  Settlement({
    required this.id,
    required this.userId,
    this.userName,
    required this.totalTransactionAmount,
    required this.totalCommissionDeducted,
    required this.totalRefundsProcessed,
    required this.netAmount,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.generatedAt,
    required this.transactionIds,
    required this.transactionCount,
    required this.categoryBreakdown,
    required this.paymentMethodBreakdown,
    required this.status,
    this.approverAdminId,
    this.approvedAt,
    this.approvalNotes,
    this.paymentMethod,
    this.bankAccountId,
    this.bankAccountNumber,
    this.bankName,
    this.transactionReference,
    this.settledAt,
    this.processingFee = 0.0,
    this.taxDeducted = 0.0,
    this.otherDeductions = 0.0,
    this.settlementProofId,
    this.settlementProofUrl,
    this.proofGeneratedAt,
    this.isDisputed = false,
    this.disputeReason,
    this.disputeRaisedAt,
    this.disputeResolution,
    this.metadata = const {},
    this.notes,
    this.adminNotes,
    this.retryCount = 0,
    this.lastRetryAt,
    this.lastErrorMessage,
  });

  // Computed properties
  bool get isPending => status == SettlementStatus.pending;
  bool get isApproved => status == SettlementStatus.approved;
  bool get isProcessing => status == SettlementStatus.processing;
  bool get isCompleted => status == SettlementStatus.completed;
  bool get isFailed => status == SettlementStatus.failed;
  bool get isCancelled => status == SettlementStatus.cancelled;

  Duration get settlementDuration => endDate.difference(startDate);
  bool get isPastDue {
    if (status != SettlementStatus.pending &&
        status != SettlementStatus.approved) {
      return false;
    }
    return DateTime.now().difference(generatedAt).inDays > 7;
  }

  double get totalDeductions =>
      totalCommissionDeducted + processingFee + taxDeducted + otherDeductions;

  double get actualPayoutAmount =>
      netAmount - processingFee - taxDeducted - otherDeductions;

  String get statusText {
    switch (status) {
      case SettlementStatus.pending:
        return 'Pending';
      case SettlementStatus.approved:
        return 'Approved';
      case SettlementStatus.processing:
        return 'Processing';
      case SettlementStatus.completed:
        return 'Completed';
      case SettlementStatus.failed:
        return 'Failed';
      case SettlementStatus.cancelled:
        return 'Cancelled';
      case SettlementStatus.disputed:
        return 'Disputed';
    }
  }

  String get periodText {
    switch (period) {
      case SettlementPeriod.daily:
        return 'Daily';
      case SettlementPeriod.weekly:
        return 'Weekly';
      case SettlementPeriod.biWeekly:
        return 'Bi-weekly';
      case SettlementPeriod.monthly:
        return 'Monthly';
    }
  }

  String get formattedTotalTransactionAmount {
    return 'Tk ${totalTransactionAmount.toStringAsFixed(2)}';
  }

  String get formattedTotalCommission {
    return 'Tk ${totalCommissionDeducted.toStringAsFixed(2)}';
  }

  String get formattedNetAmount {
    return 'Tk ${netAmount.toStringAsFixed(2)}';
  }

  String get formattedActualPayoutAmount {
    return 'Tk ${actualPayoutAmount.toStringAsFixed(2)}';
  }

  String get formattedTotalDeductions {
    return 'Tk ${totalDeductions.toStringAsFixed(2)}';
  }

  String get formattedStartDate {
    return DateFormat('dd MMM yyyy').format(startDate);
  }

  String get formattedEndDate {
    return DateFormat('dd MMM yyyy').format(endDate);
  }

  String get formattedGeneratedDate {
    return DateFormat('dd MMM yyyy, hh:mm a').format(generatedAt);
  }

  String get formattedApprovedDate {
    return approvedAt != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(approvedAt!)
        : 'Not approved';
  }

  String get formattedSettledDate {
    return settledAt != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(settledAt!)
        : 'Not settled';
  }

  String get periodRange {
    return '$formattedStartDate - $formattedEndDate';
  }

  String get settlementSummary {
    return '''
Transactions: $transactionCount
Total: $formattedTotalTransactionAmount
Commission: -$formattedTotalCommission
Deductions: -$formattedTotalDeductions
Net Payout: $formattedActualPayoutAmount
    ''';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'totalTransactionAmount': totalTransactionAmount,
      'totalCommissionDeducted': totalCommissionDeducted,
      'totalRefundsProcessed': totalRefundsProcessed,
      'netAmount': netAmount,
      'period': period.toString(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'generatedAt': generatedAt.toIso8601String(),
      'transactionIds': transactionIds,
      'transactionCount': transactionCount,
      'categoryBreakdown': categoryBreakdown,
      'paymentMethodBreakdown': paymentMethodBreakdown,
      'status': status.toString(),
      'approverAdminId': approverAdminId,
      'approvedAt': approvedAt?.toIso8601String(),
      'approvalNotes': approvalNotes,
      'paymentMethod': paymentMethod,
      'bankAccountId': bankAccountId,
      'bankAccountNumber': bankAccountNumber,
      'bankName': bankName,
      'transactionReference': transactionReference,
      'settledAt': settledAt?.toIso8601String(),
      'processingFee': processingFee,
      'taxDeducted': taxDeducted,
      'otherDeductions': otherDeductions,
      'settlementProofId': settlementProofId,
      'settlementProofUrl': settlementProofUrl,
      'proofGeneratedAt': proofGeneratedAt?.toIso8601String(),
      'isDisputed': isDisputed,
      'disputeReason': disputeReason,
      'disputeRaisedAt': disputeRaisedAt?.toIso8601String(),
      'disputeResolution': disputeResolution,
      'metadata': metadata,
      'notes': notes,
      'adminNotes': adminNotes,
      'retryCount': retryCount,
      'lastRetryAt': lastRetryAt?.toIso8601String(),
      'lastErrorMessage': lastErrorMessage,
    };
  }

  factory Settlement.fromJson(Map<String, dynamic> json) {
    return Settlement(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      totalTransactionAmount:
          (json['totalTransactionAmount'] as num).toDouble(),
      totalCommissionDeducted:
          (json['totalCommissionDeducted'] as num).toDouble(),
      totalRefundsProcessed: (json['totalRefundsProcessed'] as num).toDouble(),
      netAmount: (json['netAmount'] as num).toDouble(),
      period: SettlementPeriod.values.firstWhere(
        (e) => e.toString() == json['period'],
      ),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      generatedAt: DateTime.parse(json['generatedAt']),
      transactionIds: List<String>.from(json['transactionIds'] ?? []),
      transactionCount: json['transactionCount'],
      categoryBreakdown: json['categoryBreakdown'] ?? {},
      paymentMethodBreakdown: json['paymentMethodBreakdown'] ?? {},
      status: SettlementStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      approverAdminId: json['approverAdminId'],
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'])
          : null,
      approvalNotes: json['approvalNotes'],
      paymentMethod: json['paymentMethod'],
      bankAccountId: json['bankAccountId'],
      bankAccountNumber: json['bankAccountNumber'],
      bankName: json['bankName'],
      transactionReference: json['transactionReference'],
      settledAt:
          json['settledAt'] != null ? DateTime.parse(json['settledAt']) : null,
      processingFee: (json['processingFee'] as num).toDouble(),
      taxDeducted: (json['taxDeducted'] as num).toDouble(),
      otherDeductions: (json['otherDeductions'] as num).toDouble(),
      settlementProofId: json['settlementProofId'],
      settlementProofUrl: json['settlementProofUrl'],
      proofGeneratedAt: json['proofGeneratedAt'] != null
          ? DateTime.parse(json['proofGeneratedAt'])
          : null,
      isDisputed: json['isDisputed'] ?? false,
      disputeReason: json['disputeReason'],
      disputeRaisedAt: json['disputeRaisedAt'] != null
          ? DateTime.parse(json['disputeRaisedAt'])
          : null,
      disputeResolution: json['disputeResolution'],
      metadata: json['metadata'] ?? {},
      notes: json['notes'],
      adminNotes: json['adminNotes'],
      retryCount: json['retryCount'] ?? 0,
      lastRetryAt: json['lastRetryAt'] != null
          ? DateTime.parse(json['lastRetryAt'])
          : null,
      lastErrorMessage: json['lastErrorMessage'],
    );
  }

  Settlement copyWith({
    String? id,
    String? userId,
    String? userName,
    double? totalTransactionAmount,
    double? totalCommissionDeducted,
    double? totalRefundsProcessed,
    double? netAmount,
    SettlementPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? generatedAt,
    List<String>? transactionIds,
    int? transactionCount,
    Map<String, dynamic>? categoryBreakdown,
    Map<String, int>? paymentMethodBreakdown,
    SettlementStatus? status,
    String? approverAdminId,
    DateTime? approvedAt,
    String? approvalNotes,
    String? paymentMethod,
    String? bankAccountId,
    String? bankAccountNumber,
    String? bankName,
    String? transactionReference,
    DateTime? settledAt,
    double? processingFee,
    double? taxDeducted,
    double? otherDeductions,
    String? settlementProofId,
    String? settlementProofUrl,
    DateTime? proofGeneratedAt,
    bool? isDisputed,
    String? disputeReason,
    DateTime? disputeRaisedAt,
    String? disputeResolution,
    Map<String, dynamic>? metadata,
    String? notes,
    String? adminNotes,
    int? retryCount,
    DateTime? lastRetryAt,
    String? lastErrorMessage,
  }) {
    return Settlement(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      totalTransactionAmount:
          totalTransactionAmount ?? this.totalTransactionAmount,
      totalCommissionDeducted:
          totalCommissionDeducted ?? this.totalCommissionDeducted,
      totalRefundsProcessed:
          totalRefundsProcessed ?? this.totalRefundsProcessed,
      netAmount: netAmount ?? this.netAmount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      generatedAt: generatedAt ?? this.generatedAt,
      transactionIds: transactionIds ?? this.transactionIds,
      transactionCount: transactionCount ?? this.transactionCount,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      paymentMethodBreakdown:
          paymentMethodBreakdown ?? this.paymentMethodBreakdown,
      status: status ?? this.status,
      approverAdminId: approverAdminId ?? this.approverAdminId,
      approvedAt: approvedAt ?? this.approvedAt,
      approvalNotes: approvalNotes ?? this.approvalNotes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      bankAccountId: bankAccountId ?? this.bankAccountId,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankName: bankName ?? this.bankName,
      transactionReference: transactionReference ?? this.transactionReference,
      settledAt: settledAt ?? this.settledAt,
      processingFee: processingFee ?? this.processingFee,
      taxDeducted: taxDeducted ?? this.taxDeducted,
      otherDeductions: otherDeductions ?? this.otherDeductions,
      settlementProofId: settlementProofId ?? this.settlementProofId,
      settlementProofUrl: settlementProofUrl ?? this.settlementProofUrl,
      proofGeneratedAt: proofGeneratedAt ?? this.proofGeneratedAt,
      isDisputed: isDisputed ?? this.isDisputed,
      disputeReason: disputeReason ?? this.disputeReason,
      disputeRaisedAt: disputeRaisedAt ?? this.disputeRaisedAt,
      disputeResolution: disputeResolution ?? this.disputeResolution,
      metadata: metadata ?? this.metadata,
      notes: notes ?? this.notes,
      adminNotes: adminNotes ?? this.adminNotes,
      retryCount: retryCount ?? this.retryCount,
      lastRetryAt: lastRetryAt ?? this.lastRetryAt,
      lastErrorMessage: lastErrorMessage ?? this.lastErrorMessage,
    );
  }
}

// ============================================================================
// SETTLEMENT REQUEST MODEL (for user withdrawal requests)
// ============================================================================

enum WithdrawalStatus {
  pending, // Awaiting approval
  approved, // Approved by admin
  processing, // Being processed
  completed, // Successfully withdrawn
  failed, // Failed to withdraw
  cancelled, // Cancelled by user
}

class WithdrawalRequest {
  final String id;
  final String userId;
  final String? userName;
  final double amount;
  final String bankAccountId;
  final String? bankAccountNumber;
  final String? bankName;
  final WithdrawalStatus status;
  final String? transactionReference;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final DateTime? processedAt;
  final DateTime? completedAt;
  final String? rejectionReason;
  final String? adminNotes;
  final int retryCount;

  WithdrawalRequest({
    required this.id,
    required this.userId,
    this.userName,
    required this.amount,
    required this.bankAccountId,
    this.bankAccountNumber,
    this.bankName,
    required this.status,
    this.transactionReference,
    required this.createdAt,
    this.approvedAt,
    this.processedAt,
    this.completedAt,
    this.rejectionReason,
    this.adminNotes,
    this.retryCount = 0,
  });

  bool get isPending => status == WithdrawalStatus.pending;
  bool get isApproved => status == WithdrawalStatus.approved;
  bool get isProcessing => status == WithdrawalStatus.processing;
  bool get isCompleted => status == WithdrawalStatus.completed;
  bool get isFailed => status == WithdrawalStatus.failed;
  bool get isCancelled => status == WithdrawalStatus.cancelled;

  String get statusText {
    switch (status) {
      case WithdrawalStatus.pending:
        return 'Pending';
      case WithdrawalStatus.approved:
        return 'Approved';
      case WithdrawalStatus.processing:
        return 'Processing';
      case WithdrawalStatus.completed:
        return 'Completed';
      case WithdrawalStatus.failed:
        return 'Failed';
      case WithdrawalStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get formattedAmount {
    return 'Tk ${amount.toStringAsFixed(2)}';
  }

  String get formattedCreatedDate {
    return DateFormat('dd MMM yyyy, hh:mm a').format(createdAt);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'amount': amount,
      'bankAccountId': bankAccountId,
      'bankAccountNumber': bankAccountNumber,
      'bankName': bankName,
      'status': status.toString(),
      'transactionReference': transactionReference,
      'createdAt': createdAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'adminNotes': adminNotes,
      'retryCount': retryCount,
    };
  }

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) {
    return WithdrawalRequest(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      amount: (json['amount'] as num).toDouble(),
      bankAccountId: json['bankAccountId'],
      bankAccountNumber: json['bankAccountNumber'],
      bankName: json['bankName'],
      status: WithdrawalStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      transactionReference: json['transactionReference'],
      createdAt: DateTime.parse(json['createdAt']),
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'])
          : null,
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      rejectionReason: json['rejectionReason'],
      adminNotes: json['adminNotes'],
      retryCount: json['retryCount'] ?? 0,
    );
  }
}
