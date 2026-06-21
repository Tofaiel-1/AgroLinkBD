import 'package:intl/intl.dart';

// ============================================================================
// ENHANCED TRANSACTION MODEL
// ============================================================================

enum TransactionCategory {
  productSale, // Buying/selling crops
  supplySale, // Buying/selling fertilizers, seeds, pesticides
  transportService, // Delivery/transport
  commission, // Platform commission
  refund, // Refund/return
  walletTopup, // Adding money to wallet
  walletWithdraw, // Withdrawing from wallet
  incentive, // Bonus/incentive
  dispute, // Dispute resolution
  other
}

enum TransactionStatus {
  pending, // Awaiting processing
  confirmed, // Confirmed but not completed
  processing, // Being processed
  completed, // Successfully completed
  failed, // Transaction failed
  refunded, // Refund processed
  disputed, // Under dispute
  cancelled, // Cancelled by user
}

enum TransactionType {
  credit, // Money received
  debit, // Money sent
  refund, // Refund transaction
  transfer, // P2P transfer
  commission, // Commission deducted
  fee, // Service fee
}

class Transaction {
  final String id;

  // Core Payment Parties
  final String payerId; // User sending payment
  final String? payerName;
  final String payeeId; // User receiving payment
  final String? payeeName;

  // Amount Details
  final double amount; // Base transaction amount
  final double commissionAmount; // Commission deducted
  final double commissionRate; // Commission percentage
  final double netAmount; // Amount after commission
  final double? refundAmount; // If this is a refund

  // Classification
  final TransactionType type;
  final TransactionCategory category;
  final PaymentMethod paymentMethod;
  final TransactionStatus status;

  // Reference Information
  final String? orderId; // Related order ID
  final String? transportId; // Related transport request
  final String? productId; // Related product
  final String? supplySaleId; // Related supply sale

  // Multi-party Payment Tracking
  final List<String> linkedTransactionIds; // Related transactions in same flow
  final String? paymentFlowId; // Parent payment flow

  // Commission Tracking
  final String? commissionPayeeId; // Who receives commission (platform)
  final bool isPlatformCommission; // Is this a commission transaction

  // Settlement Information
  final bool isSettled; // Whether amount is settled
  final DateTime? settledAt; // When settlement happened
  final String? settlementBatchId; // Which settlement batch

  // Description & Metadata
  final String description;
  final Map<String, dynamic> metadata;

  // Status Information
  final String? failureReason;
  final String? failureCode;
  final int? retryCount;

  // Timestamps
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? refundedAt;
  final DateTime? updatedAt;

  // Audit Trail
  final List<TransactionLog> logs;

  Transaction({
    required this.id,
    required this.payerId,
    this.payerName,
    required this.payeeId,
    this.payeeName,
    required this.amount,
    required this.commissionAmount,
    required this.commissionRate,
    required this.netAmount,
    this.refundAmount,
    required this.type,
    required this.category,
    required this.paymentMethod,
    required this.status,
    this.orderId,
    this.transportId,
    this.productId,
    this.supplySaleId,
    this.linkedTransactionIds = const [],
    this.paymentFlowId,
    this.commissionPayeeId,
    this.isPlatformCommission = false,
    this.isSettled = false,
    this.settledAt,
    this.settlementBatchId,
    required this.description,
    this.metadata = const {},
    this.failureReason,
    this.failureCode,
    this.retryCount = 0,
    required this.createdAt,
    this.completedAt,
    this.refundedAt,
    this.updatedAt,
    this.logs = const [],
  });

  // Computed properties
  bool get isCompleted => status == TransactionStatus.completed;
  bool get isFailed => status == TransactionStatus.failed;
  bool get isPending => status == TransactionStatus.pending;
  bool get isProcessing => status == TransactionStatus.processing;
  bool get canRefund => isCompleted && refundAmount == null;
  bool get isIncome => type == TransactionType.credit;
  bool get isExpense => type == TransactionType.debit;

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

  String get typeText {
    switch (type) {
      case TransactionType.credit:
        return 'Received';
      case TransactionType.debit:
        return 'Sent';
      case TransactionType.refund:
        return 'Refund';
      case TransactionType.transfer:
        return 'Transfer';
      case TransactionType.commission:
        return 'Commission';
      case TransactionType.fee:
        return 'Fee';
    }
  }

  String get categoryText {
    switch (category) {
      case TransactionCategory.productSale:
        return 'Product Sale';
      case TransactionCategory.supplySale:
        return 'Supply Purchase';
      case TransactionCategory.transportService:
        return 'Transport Service';
      case TransactionCategory.commission:
        return 'Commission';
      case TransactionCategory.refund:
        return 'Refund';
      case TransactionCategory.walletTopup:
        return 'Wallet Top-up';
      case TransactionCategory.walletWithdraw:
        return 'Wallet Withdrawal';
      case TransactionCategory.incentive:
        return 'Incentive';
      case TransactionCategory.dispute:
        return 'Dispute';
      case TransactionCategory.other:
        return 'Other';
    }
  }

  String get formattedAmount {
    return 'Tk ${amount.toStringAsFixed(2)}';
  }

  String get formattedNetAmount {
    return 'Tk ${netAmount.toStringAsFixed(2)}';
  }

  String get formattedDate {
    return DateFormat('dd MMM yyyy, hh:mm a').format(createdAt);
  }

  String get formattedDateOnly {
    return DateFormat('dd MMM yyyy').format(createdAt);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payerId': payerId,
      'payerName': payerName,
      'payeeId': payeeId,
      'payeeName': payeeName,
      'amount': amount,
      'commissionAmount': commissionAmount,
      'commissionRate': commissionRate,
      'netAmount': netAmount,
      'refundAmount': refundAmount,
      'type': type.toString(),
      'category': category.toString(),
      'paymentMethod': paymentMethod.toString(),
      'status': status.toString(),
      'orderId': orderId,
      'transportId': transportId,
      'productId': productId,
      'supplySaleId': supplySaleId,
      'linkedTransactionIds': linkedTransactionIds,
      'paymentFlowId': paymentFlowId,
      'commissionPayeeId': commissionPayeeId,
      'isPlatformCommission': isPlatformCommission,
      'isSettled': isSettled,
      'settledAt': settledAt?.toIso8601String(),
      'settlementBatchId': settlementBatchId,
      'description': description,
      'metadata': metadata,
      'failureReason': failureReason,
      'failureCode': failureCode,
      'retryCount': retryCount,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'refundedAt': refundedAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'logs': logs.map((log) => log.toJson()).toList(),
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      payerId: json['payerId'],
      payerName: json['payerName'],
      payeeId: json['payeeId'],
      payeeName: json['payeeName'],
      amount: (json['amount'] as num).toDouble(),
      commissionAmount: (json['commissionAmount'] as num).toDouble(),
      commissionRate: (json['commissionRate'] as num).toDouble(),
      netAmount: (json['netAmount'] as num).toDouble(),
      refundAmount: json['refundAmount'] != null
          ? (json['refundAmount'] as num).toDouble()
          : null,
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      category: TransactionCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString() == json['paymentMethod'],
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      orderId: json['orderId'],
      transportId: json['transportId'],
      productId: json['productId'],
      supplySaleId: json['supplySaleId'],
      linkedTransactionIds:
          List<String>.from(json['linkedTransactionIds'] ?? []),
      paymentFlowId: json['paymentFlowId'],
      commissionPayeeId: json['commissionPayeeId'],
      isPlatformCommission: json['isPlatformCommission'] ?? false,
      isSettled: json['isSettled'] ?? false,
      settledAt:
          json['settledAt'] != null ? DateTime.parse(json['settledAt']) : null,
      settlementBatchId: json['settlementBatchId'],
      description: json['description'],
      metadata: json['metadata'] ?? {},
      failureReason: json['failureReason'],
      failureCode: json['failureCode'],
      retryCount: json['retryCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      refundedAt: json['refundedAt'] != null
          ? DateTime.parse(json['refundedAt'])
          : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      logs: (json['logs'] as List<dynamic>?)
              ?.map((log) => TransactionLog.fromJson(log))
              .toList() ??
          [],
    );
  }

  Transaction copyWith({
    String? id,
    String? payerId,
    String? payerName,
    String? payeeId,
    String? payeeName,
    double? amount,
    double? commissionAmount,
    double? commissionRate,
    double? netAmount,
    double? refundAmount,
    TransactionType? type,
    TransactionCategory? category,
    PaymentMethod? paymentMethod,
    TransactionStatus? status,
    String? orderId,
    String? transportId,
    String? productId,
    String? supplySaleId,
    List<String>? linkedTransactionIds,
    String? paymentFlowId,
    String? commissionPayeeId,
    bool? isPlatformCommission,
    bool? isSettled,
    DateTime? settledAt,
    String? settlementBatchId,
    String? description,
    Map<String, dynamic>? metadata,
    String? failureReason,
    String? failureCode,
    int? retryCount,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? refundedAt,
    DateTime? updatedAt,
    List<TransactionLog>? logs,
  }) {
    return Transaction(
      id: id ?? this.id,
      payerId: payerId ?? this.payerId,
      payerName: payerName ?? this.payerName,
      payeeId: payeeId ?? this.payeeId,
      payeeName: payeeName ?? this.payeeName,
      amount: amount ?? this.amount,
      commissionAmount: commissionAmount ?? this.commissionAmount,
      commissionRate: commissionRate ?? this.commissionRate,
      netAmount: netAmount ?? this.netAmount,
      refundAmount: refundAmount ?? this.refundAmount,
      type: type ?? this.type,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      orderId: orderId ?? this.orderId,
      transportId: transportId ?? this.transportId,
      productId: productId ?? this.productId,
      supplySaleId: supplySaleId ?? this.supplySaleId,
      linkedTransactionIds: linkedTransactionIds ?? this.linkedTransactionIds,
      paymentFlowId: paymentFlowId ?? this.paymentFlowId,
      commissionPayeeId: commissionPayeeId ?? this.commissionPayeeId,
      isPlatformCommission: isPlatformCommission ?? this.isPlatformCommission,
      isSettled: isSettled ?? this.isSettled,
      settledAt: settledAt ?? this.settledAt,
      settlementBatchId: settlementBatchId ?? this.settlementBatchId,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
      failureReason: failureReason ?? this.failureReason,
      failureCode: failureCode ?? this.failureCode,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      refundedAt: refundedAt ?? this.refundedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      logs: logs ?? this.logs,
    );
  }
}

// ============================================================================
// TRANSACTION LOG MODEL (for audit trail)
// ============================================================================

class TransactionLog {
  final String id;
  final String transactionId;
  final String
      action; // created, confirmed, processing, completed, failed, refunded
  final String? details;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;

  TransactionLog({
    required this.id,
    required this.transactionId,
    required this.action,
    this.details,
    this.metadata = const {},
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transactionId': transactionId,
      'action': action,
      'details': details,
      'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TransactionLog.fromJson(Map<String, dynamic> json) {
    return TransactionLog(
      id: json['id'],
      transactionId: json['transactionId'],
      action: json['action'],
      details: json['details'],
      metadata: json['metadata'] ?? {},
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

// ============================================================================
// ENHANCED WALLET MODEL
// ============================================================================

enum WalletStatus {
  active,
  inactive,
  suspended,
  locked,
  limitedAccess,
}

class Wallet {
  final String id;
  final String userId;
  final String? userName;

  // Balance Information
  final double balance; // Available balance
  final double totalEarned; // Lifetime earnings
  final double totalSpent; // Lifetime spending
  final double pendingBalance; // Awaiting settlement
  final double onHoldBalance; // Disputed/frozen

  // Account Status
  final WalletStatus status;
  final bool canWithdraw; // KYC verified
  final bool canReceivePayments;
  final bool canSendPayments;

  // Withdrawal Information
  final List<BankAccount> bankAccounts;
  final String? preferredBankAccountId;

  // Settlement Information
  final DateTime lastSettlementDate;
  final DateTime? nextSettlementDate;
  final List<String> settlementBatchIds;

  // Category Breakdown
  final Map<String, double> categoryBreakdown; // Earnings by category
  final Map<String, double> monthlyEarnings; // Monthly earnings history

  // Limits & Restrictions
  final double dailyWithdrawLimit;
  final double monthlyWithdrawLimit;
  final double? totalWithdrawToday;
  final double? totalWithdrawThisMonth;

  // Timestamps
  final DateTime createdAt;
  final DateTime? kycVerifiedAt;
  final DateTime? lastUpdatedAt;

  Wallet({
    required this.id,
    required this.userId,
    this.userName,
    required this.balance,
    required this.totalEarned,
    required this.totalSpent,
    required this.pendingBalance,
    required this.onHoldBalance,
    required this.status,
    required this.canWithdraw,
    required this.canReceivePayments,
    required this.canSendPayments,
    this.bankAccounts = const [],
    this.preferredBankAccountId,
    required this.lastSettlementDate,
    this.nextSettlementDate,
    this.settlementBatchIds = const [],
    this.categoryBreakdown = const {},
    this.monthlyEarnings = const {},
    this.dailyWithdrawLimit = 50000,
    this.monthlyWithdrawLimit = 500000,
    this.totalWithdrawToday,
    this.totalWithdrawThisMonth,
    required this.createdAt,
    this.kycVerifiedAt,
    this.lastUpdatedAt,
  });

  // Computed properties
  double get availableBalance => balance - onHoldBalance;
  double get totalBalance => balance + pendingBalance;
  bool get isKycVerified => kycVerifiedAt != null;
  bool get isActive => status == WalletStatus.active;
  bool get isSuspended => status == WalletStatus.suspended;

  double get remainingDailyLimit {
    final today = totalWithdrawToday ?? 0;
    return dailyWithdrawLimit - today;
  }

  double get remainingMonthlyLimit {
    final month = totalWithdrawThisMonth ?? 0;
    return monthlyWithdrawLimit - month;
  }

  bool canWithdrawAmount(double amount) {
    if (!canWithdraw || !isActive) return false;
    if (availableBalance < amount) return false;
    if (amount > remainingDailyLimit) return false;
    if (amount > remainingMonthlyLimit) return false;
    return true;
  }

  String get statusText {
    switch (status) {
      case WalletStatus.active:
        return 'Active';
      case WalletStatus.inactive:
        return 'Inactive';
      case WalletStatus.suspended:
        return 'Suspended';
      case WalletStatus.locked:
        return 'Locked';
      case WalletStatus.limitedAccess:
        return 'Limited Access';
    }
  }

  String get formattedBalance {
    return 'Tk ${balance.toStringAsFixed(2)}';
  }

  String get formattedTotalEarned {
    return 'Tk ${totalEarned.toStringAsFixed(2)}';
  }

  String get formattedTotalSpent {
    return 'Tk ${totalSpent.toStringAsFixed(2)}';
  }

  String get formattedPendingBalance {
    return 'Tk ${pendingBalance.toStringAsFixed(2)}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'balance': balance,
      'totalEarned': totalEarned,
      'totalSpent': totalSpent,
      'pendingBalance': pendingBalance,
      'onHoldBalance': onHoldBalance,
      'status': status.toString(),
      'canWithdraw': canWithdraw,
      'canReceivePayments': canReceivePayments,
      'canSendPayments': canSendPayments,
      'bankAccounts': bankAccounts.map((ba) => ba.toJson()).toList(),
      'preferredBankAccountId': preferredBankAccountId,
      'lastSettlementDate': lastSettlementDate.toIso8601String(),
      'nextSettlementDate': nextSettlementDate?.toIso8601String(),
      'settlementBatchIds': settlementBatchIds,
      'categoryBreakdown': categoryBreakdown,
      'monthlyEarnings': monthlyEarnings,
      'dailyWithdrawLimit': dailyWithdrawLimit,
      'monthlyWithdrawLimit': monthlyWithdrawLimit,
      'totalWithdrawToday': totalWithdrawToday,
      'totalWithdrawThisMonth': totalWithdrawThisMonth,
      'createdAt': createdAt.toIso8601String(),
      'kycVerifiedAt': kycVerifiedAt?.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt?.toIso8601String(),
    };
  }

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      balance: (json['balance'] as num).toDouble(),
      totalEarned: (json['totalEarned'] as num).toDouble(),
      totalSpent: (json['totalSpent'] as num).toDouble(),
      pendingBalance: (json['pendingBalance'] as num).toDouble(),
      onHoldBalance: (json['onHoldBalance'] as num).toDouble(),
      status: WalletStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      canWithdraw: json['canWithdraw'] ?? false,
      canReceivePayments: json['canReceivePayments'] ?? true,
      canSendPayments: json['canSendPayments'] ?? true,
      bankAccounts: (json['bankAccounts'] as List<dynamic>?)
              ?.map((ba) => BankAccount.fromJson(ba))
              .toList() ??
          [],
      preferredBankAccountId: json['preferredBankAccountId'],
      lastSettlementDate: DateTime.parse(json['lastSettlementDate']),
      nextSettlementDate: json['nextSettlementDate'] != null
          ? DateTime.parse(json['nextSettlementDate'])
          : null,
      settlementBatchIds: List<String>.from(json['settlementBatchIds'] ?? []),
      categoryBreakdown:
          Map<String, double>.from(json['categoryBreakdown'] ?? {}),
      monthlyEarnings: Map<String, double>.from(json['monthlyEarnings'] ?? {}),
      dailyWithdrawLimit: (json['dailyWithdrawLimit'] as num).toDouble(),
      monthlyWithdrawLimit: (json['monthlyWithdrawLimit'] as num).toDouble(),
      totalWithdrawToday: json['totalWithdrawToday'] != null
          ? (json['totalWithdrawToday'] as num).toDouble()
          : null,
      totalWithdrawThisMonth: json['totalWithdrawThisMonth'] != null
          ? (json['totalWithdrawThisMonth'] as num).toDouble()
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      kycVerifiedAt: json['kycVerifiedAt'] != null
          ? DateTime.parse(json['kycVerifiedAt'])
          : null,
      lastUpdatedAt: json['lastUpdatedAt'] != null
          ? DateTime.parse(json['lastUpdatedAt'])
          : null,
    );
  }

  Wallet copyWith({
    String? id,
    String? userId,
    String? userName,
    double? balance,
    double? totalEarned,
    double? totalSpent,
    double? pendingBalance,
    double? onHoldBalance,
    WalletStatus? status,
    bool? canWithdraw,
    bool? canReceivePayments,
    bool? canSendPayments,
    List<BankAccount>? bankAccounts,
    String? preferredBankAccountId,
    DateTime? lastSettlementDate,
    DateTime? nextSettlementDate,
    List<String>? settlementBatchIds,
    Map<String, double>? categoryBreakdown,
    Map<String, double>? monthlyEarnings,
    double? dailyWithdrawLimit,
    double? monthlyWithdrawLimit,
    double? totalWithdrawToday,
    double? totalWithdrawThisMonth,
    DateTime? createdAt,
    DateTime? kycVerifiedAt,
    DateTime? lastUpdatedAt,
  }) {
    return Wallet(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      balance: balance ?? this.balance,
      totalEarned: totalEarned ?? this.totalEarned,
      totalSpent: totalSpent ?? this.totalSpent,
      pendingBalance: pendingBalance ?? this.pendingBalance,
      onHoldBalance: onHoldBalance ?? this.onHoldBalance,
      status: status ?? this.status,
      canWithdraw: canWithdraw ?? this.canWithdraw,
      canReceivePayments: canReceivePayments ?? this.canReceivePayments,
      canSendPayments: canSendPayments ?? this.canSendPayments,
      bankAccounts: bankAccounts ?? this.bankAccounts,
      preferredBankAccountId:
          preferredBankAccountId ?? this.preferredBankAccountId,
      lastSettlementDate: lastSettlementDate ?? this.lastSettlementDate,
      nextSettlementDate: nextSettlementDate ?? this.nextSettlementDate,
      settlementBatchIds: settlementBatchIds ?? this.settlementBatchIds,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      monthlyEarnings: monthlyEarnings ?? this.monthlyEarnings,
      dailyWithdrawLimit: dailyWithdrawLimit ?? this.dailyWithdrawLimit,
      monthlyWithdrawLimit: monthlyWithdrawLimit ?? this.monthlyWithdrawLimit,
      totalWithdrawToday: totalWithdrawToday ?? this.totalWithdrawToday,
      totalWithdrawThisMonth:
          totalWithdrawThisMonth ?? this.totalWithdrawThisMonth,
      createdAt: createdAt ?? this.createdAt,
      kycVerifiedAt: kycVerifiedAt ?? this.kycVerifiedAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }
}

// ============================================================================
// BANK ACCOUNT MODEL
// ============================================================================

enum BankAccountType {
  checking,
  savings,
  mobileWallet,
  other,
}

enum BankAccountStatus {
  active,
  inactive,
  verified,
  unverified,
  blocked,
}

class BankAccount {
  final String id;
  final String userId;
  final String bankName;
  final String accountNumber;
  final String accountHolderName;
  final BankAccountType accountType;
  final BankAccountStatus status;
  final bool isVerified;
  final bool isPrimary;
  final DateTime? verifiedAt;
  final DateTime createdAt;

  BankAccount({
    required this.id,
    required this.userId,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolderName,
    required this.accountType,
    required this.status,
    required this.isVerified,
    required this.isPrimary,
    this.verifiedAt,
    required this.createdAt,
  });

  String get maskedAccountNumber {
    if (accountNumber.length >= 4) {
      return '**** **** **** ${accountNumber.substring(accountNumber.length - 4)}';
    }
    return accountNumber;
  }

  String get accountTypeText {
    switch (accountType) {
      case BankAccountType.checking:
        return 'Checking';
      case BankAccountType.savings:
        return 'Savings';
      case BankAccountType.mobileWallet:
        return 'Mobile Wallet';
      case BankAccountType.other:
        return 'Other';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountHolderName': accountHolderName,
      'accountType': accountType.toString(),
      'status': status.toString(),
      'isVerified': isVerified,
      'isPrimary': isPrimary,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'],
      userId: json['userId'],
      bankName: json['bankName'],
      accountNumber: json['accountNumber'],
      accountHolderName: json['accountHolderName'],
      accountType: BankAccountType.values.firstWhere(
        (e) => e.toString() == json['accountType'],
      ),
      status: BankAccountStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      isVerified: json['isVerified'] ?? false,
      isPrimary: json['isPrimary'] ?? false,
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

// ============================================================================
// PAYMENT METHOD MODEL (from existing, kept for compatibility)
// ============================================================================

enum PaymentMethod { bkash, nagad, rocket, card, flutterwave }

extension PaymentMethodExtension on PaymentMethod {
  String get text {
    switch (this) {
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

  String get code {
    switch (this) {
      case PaymentMethod.bkash:
        return 'bkash';
      case PaymentMethod.nagad:
        return 'nagad';
      case PaymentMethod.rocket:
        return 'rocket';
      case PaymentMethod.card:
        return 'card';
      case PaymentMethod.flutterwave:
        return 'flutterwave';
    }
  }
}
