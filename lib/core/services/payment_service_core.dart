import 'package:uuid/uuid.dart';
import '../models/enhanced_transaction_model.dart';
import '../models/payment_flow_model.dart';
import '../models/settlement_model.dart';
import '../models/user_model.dart';

// ============================================================================
// PAYMENT CONFIGURATION
// ============================================================================

class CommissionConfig {
  // Commission rates by category
  static const double productSaleCommission = 0.05; // 5%
  static const double supplySaleCommission = 0.03; // 3%
  static const double transportCommission = 0.05; // 5%
  static const double minimumCommission = 10.0; // Tk 10 min

  // Maximum amounts
  static const double minPaymentAmount = 100.0;
  static const double maxPaymentAmount = 10000000.0;

  // Withdrawal limits
  static const double dailyWithdrawLimit = 50000.0;
  static const double monthlyWithdrawLimit = 500000.0;

  // Fees
  static const double processingFee = 0.0; // No fee currently
  static const double taxRate = 0.0; // No tax currently

  /// Get commission rate for category
  static double getCommissionRate(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.productSale:
        return productSaleCommission;
      case TransactionCategory.supplySale:
        return supplySaleCommission;
      case TransactionCategory.transportService:
        return transportCommission;
      case TransactionCategory.walletTopup:
      case TransactionCategory.walletWithdraw:
        return 0.0;
      default:
        return 0.0;
    }
  }

  /// Calculate commission amount
  static double calculateCommission(double amount, double rate) {
    final commission = amount * rate;
    return commission < minimumCommission ? minimumCommission : commission;
  }
}

// ============================================================================
// PAYMENT SERVICE (Core Payment Logic)
// ============================================================================

class PaymentServiceCore {
  static const _uuid = Uuid();

  /// Validate payment amount
  static PaymentValidationResult validatePaymentAmount(double amount) {
    if (amount <= 0) {
      return PaymentValidationResult(
        isValid: false,
        error: 'Amount must be greater than 0',
        errorCode: 'INVALID_AMOUNT',
      );
    }

    if (amount < CommissionConfig.minPaymentAmount) {
      return PaymentValidationResult(
        isValid: false,
        error:
            'Minimum payment amount is Tk ${CommissionConfig.minPaymentAmount}',
        errorCode: 'AMOUNT_TOO_LOW',
      );
    }

    if (amount > CommissionConfig.maxPaymentAmount) {
      return PaymentValidationResult(
        isValid: false,
        error:
            'Maximum payment amount is Tk ${CommissionConfig.maxPaymentAmount}',
        errorCode: 'AMOUNT_TOO_HIGH',
      );
    }

    // Check decimal places
    if ((amount * 100).toInt() != amount * 100) {
      return PaymentValidationResult(
        isValid: false,
        error: 'Payment amount must have maximum 2 decimal places',
        errorCode: 'INVALID_PRECISION',
      );
    }

    return PaymentValidationResult(isValid: true);
  }

  /// Validate user eligibility
  static PaymentValidationResult validateUserEligibility(UserModel user) {
    if (user.status == UserStatus.suspended) {
      return PaymentValidationResult(
        isValid: false,
        error: 'Your account is suspended',
        errorCode: 'ACCOUNT_SUSPENDED',
      );
    }

    if (user.status == UserStatus.inactive) {
      return PaymentValidationResult(
        isValid: false,
        error: 'Your account is inactive',
        errorCode: 'ACCOUNT_INACTIVE',
      );
    }

    return PaymentValidationResult(isValid: true);
  }

  /// Create a simple transaction
  static Transaction createTransaction({
    required String payerId,
    required String? payerName,
    required String payeeId,
    required String? payeeName,
    required double amount,
    required TransactionCategory category,
    required PaymentMethod method,
    required String description,
    String? orderId,
    String? transportId,
    String? productId,
    Map<String, dynamic> metadata = const {},
  }) {
    // Calculate commission
    final commissionRate = CommissionConfig.getCommissionRate(category);
    final commission =
        CommissionConfig.calculateCommission(amount, commissionRate);
    final netAmount = amount - commission;

    final transaction = Transaction(
      id: 'TXN-${_uuid.v4().substring(0, 8).toUpperCase()}',
      payerId: payerId,
      payerName: payerName,
      payeeId: payeeId,
      payeeName: payeeName,
      amount: amount,
      commissionAmount: commission,
      commissionRate: commissionRate,
      netAmount: netAmount,
      type: TransactionType.debit,
      category: category,
      paymentMethod: method,
      status: TransactionStatus.pending,
      orderId: orderId,
      transportId: transportId,
      productId: productId,
      description: description,
      metadata: metadata,
      createdAt: DateTime.now(),
      logs: [
        TransactionLog(
          id: '${_uuid.v4()}',
          transactionId: 'temp',
          action: 'created',
          timestamp: DateTime.now(),
        )
      ],
    );

    return transaction;
  }

  /// Create credit transaction for payee
  static Transaction createCreditTransaction(
    Transaction debitTransaction,
    String? transactionId,
  ) {
    return Transaction(
      id: 'TXN-${_uuid.v4().substring(0, 8).toUpperCase()}',
      payerId: debitTransaction.payerId,
      payerName: debitTransaction.payerName,
      payeeId: debitTransaction.payeeId,
      payeeName: debitTransaction.payeeName,
      amount: debitTransaction.netAmount,
      commissionAmount: debitTransaction.commissionAmount,
      commissionRate: debitTransaction.commissionRate,
      netAmount: debitTransaction.netAmount,
      type: TransactionType.credit,
      category: debitTransaction.category,
      paymentMethod: debitTransaction.paymentMethod,
      status: TransactionStatus.pending,
      orderId: debitTransaction.orderId,
      transportId: debitTransaction.transportId,
      productId: debitTransaction.productId,
      description: 'Credit: ${debitTransaction.description}',
      metadata: debitTransaction.metadata,
      linkedTransactionIds: [transactionId ?? ''],
      createdAt: DateTime.now(),
    );
  }

  /// Create multi-party payment flow
  static PaymentFlow createPaymentFlow({
    required PaymentFlowType flowType,
    required String initiatorId,
    required String? initiatorName,
    required String primaryRecipientId,
    required String? primaryRecipientName,
    required double totalAmount,
    required List<PaymentParty> parties,
    required List<PaymentSplit> splits,
    String? relatedOrderId,
    String? relatedTransportId,
    Map<String, dynamic> metadata = const {},
  }) {
    // Calculate total commission
    final totalCommission = splits
        .where((s) => s.reason == 'commission')
        .fold(0.0, (prev, s) => prev + s.amount);

    return PaymentFlow(
      id: 'FLOW-${_uuid.v4().substring(0, 8).toUpperCase()}',
      flowType: flowType,
      initiatorId: initiatorId,
      initiatorName: initiatorName,
      primaryRecipientId: primaryRecipientId,
      primaryRecipientName: primaryRecipientName,
      parties: parties,
      relatedOrderId: relatedOrderId,
      relatedTransportId: relatedTransportId,
      totalAmount: totalAmount,
      splits: splits,
      totalCommission: totalCommission,
      status: PaymentFlowStatus.initiated,
      metadata: metadata,
      createdAt: DateTime.now(),
    );
  }

  /// Create payment split
  static PaymentSplit createPaymentSplit({
    required String recipientId,
    required String? recipientName,
    required double amount,
    required String reason,
  }) {
    final percentage = 0.0; // Will be calculated later

    return PaymentSplit(
      id: '${_uuid.v4()}',
      recipientId: recipientId,
      recipientName: recipientName,
      amount: amount,
      percentage: percentage,
      reason: reason,
      status: TransactionStatus.pending,
    );
  }

  /// Calculate payment splits for buyer to farmer
  static List<PaymentSplit> calculateBuyerToFarmerSplit({
    required double totalAmount,
    required String farmerId,
    required String? farmerName,
    String? platformCommissionId = 'PLATFORM_ADMIN',
  }) {
    final commissionRate = CommissionConfig.productSaleCommission;
    final commission =
        CommissionConfig.calculateCommission(totalAmount, commissionRate);
    final farmerAmount = totalAmount - commission;

    return [
      PaymentSplit(
        id: '${_uuid.v4()}',
        recipientId: farmerId,
        recipientName: farmerName,
        amount: farmerAmount,
        percentage: (farmerAmount / totalAmount * 100),
        reason: 'principal',
        status: TransactionStatus.pending,
      ),
      PaymentSplit(
        id: '${_uuid.v4()}',
        recipientId: platformCommissionId ?? 'PLATFORM_ADMIN',
        recipientName: 'Platform',
        amount: commission,
        percentage: (commission / totalAmount * 100),
        reason: 'commission',
        status: TransactionStatus.pending,
      ),
    ];
  }

  /// Calculate payment splits for transport (shared)
  static List<PaymentSplit> calculateSharedTransportSplit({
    required double totalAmount,
    required String driverId,
    required String? driverName,
    required double buyerShare,
    required double farmerShare,
    String? platformCommissionId = 'PLATFORM_ADMIN',
  }) {
    final commissionRate = CommissionConfig.transportCommission;
    final commission =
        CommissionConfig.calculateCommission(totalAmount, commissionRate);
    final driverAmount = totalAmount - commission;

    return [
      PaymentSplit(
        id: '${_uuid.v4()}',
        recipientId: driverId,
        recipientName: driverName,
        amount: driverAmount,
        percentage: (driverAmount / totalAmount * 100),
        reason: 'principal',
        status: TransactionStatus.pending,
      ),
      PaymentSplit(
        id: '${_uuid.v4()}',
        recipientId: platformCommissionId ?? 'PLATFORM_ADMIN',
        recipientName: 'Platform',
        amount: commission,
        percentage: (commission / totalAmount * 100),
        reason: 'commission',
        status: TransactionStatus.pending,
      ),
    ];
  }

  /// Create refund transaction flow
  static PaymentFlow createRefundFlow({
    required String originalTransactionId,
    required String initiatorId,
    required String farmerId,
    required String? farmerName,
    required double refundAmount,
    required String reason,
    String? driverId,
  }) {
    final parties = <PaymentParty>[
      PaymentParty(
        userId: farmerId,
        userName: farmerName,
        userType: 'farmer',
        amount: refundAmount,
        status: TransactionStatus.pending,
      ),
    ];

    if (driverId != null) {
      parties.add(
        PaymentParty(
          userId: driverId,
          userName: 'Driver',
          userType: 'driver',
          amount: 0, // Negotiated separately
          status: TransactionStatus.pending,
        ),
      );
    }

    return PaymentFlow(
      id: 'REFUND-${_uuid.v4().substring(0, 8).toUpperCase()}',
      flowType: PaymentFlowType.refund,
      initiatorId: initiatorId,
      primaryRecipientId: farmerId,
      primaryRecipientName: farmerName,
      parties: parties,
      totalAmount: refundAmount,
      splits: [
        PaymentSplit(
          id: '${_uuid.v4()}',
          recipientId: initiatorId,
          amount: refundAmount,
          percentage: 100,
          reason: 'refund',
          status: TransactionStatus.pending,
        ),
      ],
      totalCommission: 0,
      status: PaymentFlowStatus.initiated,
      metadata: {
        'reason': reason,
        'originalTransactionId': originalTransactionId
      },
      createdAt: DateTime.now(),
    );
  }

  /// Log transaction action
  static TransactionLog logTransaction({
    required String transactionId,
    required String action,
    String? details,
    Map<String, dynamic> metadata = const {},
  }) {
    return TransactionLog(
      id: '${_uuid.v4()}',
      transactionId: transactionId,
      action: action,
      details: details,
      metadata: metadata,
      timestamp: DateTime.now(),
    );
  }
}

// ============================================================================
// WALLET SERVICE
// ============================================================================

class WalletServiceCore {
  /// Calculate wallet balance
  static double calculateBalance({
    required double totalEarned,
    required double totalSpent,
    required double commissionDeducted,
  }) {
    return totalEarned - totalSpent - commissionDeducted;
  }

  /// Check withdrawal eligibility
  static PaymentValidationResult canWithdraw({
    required double availableBalance,
    required double amount,
    required double dailyWithdrawn,
    required double monthlyWithdrawn,
    required bool isKycVerified,
  }) {
    if (!isKycVerified) {
      return PaymentValidationResult(
        isValid: false,
        error: 'KYC verification required to withdraw',
        errorCode: 'KYC_NOT_VERIFIED',
      );
    }

    if (availableBalance < amount) {
      return PaymentValidationResult(
        isValid: false,
        error: 'Insufficient balance',
        errorCode: 'INSUFFICIENT_BALANCE',
      );
    }

    final dailyRemaining = CommissionConfig.dailyWithdrawLimit - dailyWithdrawn;
    if (amount > dailyRemaining) {
      return PaymentValidationResult(
        isValid: false,
        error: 'Daily withdrawal limit exceeded. Remaining: Tk $dailyRemaining',
        errorCode: 'DAILY_LIMIT_EXCEEDED',
      );
    }

    final monthlyRemaining =
        CommissionConfig.monthlyWithdrawLimit - monthlyWithdrawn;
    if (amount > monthlyRemaining) {
      return PaymentValidationResult(
        isValid: false,
        error:
            'Monthly withdrawal limit exceeded. Remaining: Tk $monthlyRemaining',
        errorCode: 'MONTHLY_LIMIT_EXCEEDED',
      );
    }

    return PaymentValidationResult(isValid: true);
  }

  /// Calculate earnings by category
  static Map<String, double> calculateCategoryBreakdown(
    List<Transaction> transactions,
  ) {
    final breakdown = <String, double>{};

    for (final txn in transactions.where((t) => t.isCompleted && t.isIncome)) {
      final category = txn.categoryText;
      breakdown[category] = (breakdown[category] ?? 0) + txn.netAmount;
    }

    return breakdown;
  }

  /// Calculate monthly earnings
  static Map<String, double> calculateMonthlyEarnings(
    List<Transaction> transactions,
  ) {
    final monthly = <String, double>{};

    for (final txn in transactions.where((t) => t.isCompleted && t.isIncome)) {
      final monthKey =
          '${txn.createdAt.year}-${txn.createdAt.month.toString().padLeft(2, '0')}';
      monthly[monthKey] = (monthly[monthKey] ?? 0) + txn.netAmount;
    }

    return monthly;
  }
}

// ============================================================================
// SETTLEMENT SERVICE
// ============================================================================

class SettlementServiceCore {
  static const _uuid = Uuid();

  /// Create settlement from transactions
  static Settlement createSettlement({
    required String userId,
    required String? userName,
    required List<Transaction> transactions,
    required SettlementPeriod period,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final now = DateTime.now();
    final actualStartDate = startDate ?? DateTime(now.year, now.month, now.day);
    final actualEndDate = endDate ?? now;

    // Filter completed transactions
    final completedTxns =
        transactions.where((t) => t.isCompleted && t.isIncome).toList();

    double totalAmount = 0;
    double totalCommission = 0;
    final categoryBreakdown = <String, dynamic>{};
    final paymentMethodBreakdown = <String, int>{};

    for (final txn in completedTxns) {
      totalAmount += txn.amount;
      totalCommission += txn.commissionAmount;

      // Category breakdown
      final category = txn.categoryText;
      categoryBreakdown[category] =
          (categoryBreakdown[category] as double? ?? 0) + txn.netAmount;

      // Payment method breakdown
      final method = txn.paymentMethod.text;
      paymentMethodBreakdown[method] =
          (paymentMethodBreakdown[method] ?? 0) + 1;
    }

    final netAmount = totalAmount - totalCommission;

    return Settlement(
      id: 'SETTLE-${_uuid.v4().substring(0, 8).toUpperCase()}',
      userId: userId,
      userName: userName,
      totalTransactionAmount: totalAmount,
      totalCommissionDeducted: totalCommission,
      totalRefundsProcessed: 0,
      netAmount: netAmount,
      period: period,
      startDate: actualStartDate,
      endDate: actualEndDate,
      generatedAt: now,
      transactionIds: completedTxns.map((t) => t.id).toList(),
      transactionCount: completedTxns.length,
      categoryBreakdown: categoryBreakdown,
      paymentMethodBreakdown: paymentMethodBreakdown,
      status: SettlementStatus.pending,
    );
  }

  /// Calculate settlement statistics
  static Map<String, dynamic> getSettlementStats(Settlement settlement) {
    return {
      'totalTransactions': settlement.transactionCount,
      'totalAmount': settlement.totalTransactionAmount,
      'totalCommission': settlement.totalCommissionDeducted,
      'netAmount': settlement.netAmount,
      'averageTransaction': settlement.transactionCount > 0
          ? settlement.totalTransactionAmount / settlement.transactionCount
          : 0,
      'categoryBreakdown': settlement.categoryBreakdown,
      'paymentMethods': settlement.paymentMethodBreakdown,
      'status': settlement.statusText,
      'periodRange': settlement.periodRange,
    };
  }
}

// ============================================================================
// PAYMENT VALIDATION RESULT
// ============================================================================

class PaymentValidationResult {
  final bool isValid;
  final String? error;
  final String? errorCode;

  PaymentValidationResult({
    required this.isValid,
    this.error,
    this.errorCode,
  });

  @override
  String toString() => isValid ? 'Valid' : 'Invalid: $error';
}
