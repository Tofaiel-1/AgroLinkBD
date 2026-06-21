import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enhanced_transaction_model.dart';
import '../models/payment_flow_model.dart';
import '../models/settlement_model.dart';
import '../services/payment_service_core.dart';

// ============================================================================
// FIRESTORE INSTANCE PROVIDER
// ============================================================================

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// ============================================================================
// WALLET PROVIDERS
// ============================================================================

/// Get user's wallet
final userWalletProvider =
    FutureProvider.family<Wallet?, String>((ref, userId) async {
  final firestore = ref.watch(firestoreProvider);
  try {
    final doc = await firestore.collection('wallets').doc(userId).get();
    if (!doc.exists) return null;
    return Wallet.fromJson(doc.data()!);
  } catch (e) {
    print('Error fetching wallet: $e');
    return null;
  }
});

/// Get wallet balance
final walletBalanceProvider =
    FutureProvider.family<double, String>((ref, userId) async {
  final wallet = await ref.watch(userWalletProvider(userId).future);
  return wallet?.balance ?? 0;
});

/// Get pending balance
final walletPendingBalanceProvider = FutureProvider.family<double, String>(
  (ref, userId) async {
    final wallet = await ref.watch(userWalletProvider(userId).future);
    return wallet?.pendingBalance ?? 0;
  },
);

/// Watch wallet changes in real-time
final walletStreamProvider =
    StreamProvider.family<Wallet?, String>((ref, userId) {
  final firestore = ref.watch(firestoreProvider);
  return firestore.collection('wallets').doc(userId).snapshots().map((doc) {
    if (!doc.exists) return null;
    return Wallet.fromJson(doc.data()!);
  });
});

// ============================================================================
// TRANSACTION PROVIDERS
// ============================================================================

/// Get user's recent transactions
final userTransactionsProvider =
    FutureProvider.family<List<Transaction>, String>((ref, userId) async {
  final firestore = ref.watch(firestoreProvider);
  try {
    final snapshot = await firestore
        .collection('transactions')
        .where('payerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    return snapshot.docs
        .map((doc) => Transaction.fromJson(doc.data()))
        .toList();
  } catch (e) {
    print('Error fetching transactions: $e');
    return [];
  }
});

/// Get user's income transactions
final userIncomeTransactionsProvider =
    FutureProvider.family<List<Transaction>, String>((ref, userId) async {
  final firestore = ref.watch(firestoreProvider);
  try {
    final snapshot = await firestore
        .collection('transactions')
        .where('payeeId', isEqualTo: userId)
        .where('type', isEqualTo: 'credit')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    return snapshot.docs
        .map((doc) => Transaction.fromJson(doc.data()))
        .toList();
  } catch (e) {
    print('Error fetching income transactions: $e');
    return [];
  }
});

/// Get transaction by ID
final transactionProvider =
    FutureProvider.family<Transaction?, String>((ref, transactionId) async {
  final firestore = ref.watch(firestoreProvider);
  try {
    final doc =
        await firestore.collection('transactions').doc(transactionId).get();
    if (!doc.exists) return null;
    return Transaction.fromJson(doc.data()!);
  } catch (e) {
    print('Error fetching transaction: $e');
    return null;
  }
});

/// Watch transaction changes in real-time
final transactionStreamProvider =
    StreamProvider.family<Transaction?, String>((ref, transactionId) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('transactions')
      .doc(transactionId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    return Transaction.fromJson(doc.data()!);
  });
});

/// Get payment statistics for user
final paymentStatsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
  final transactions = await ref.watch(userTransactionsProvider(userId).future);

  double totalTransacted = 0;
  double totalCommission = 0;
  int successfulPayments = 0;
  int failedPayments = 0;

  for (final txn in transactions) {
    if (txn.isCompleted) {
      totalTransacted += txn.amount;
      totalCommission += txn.commissionAmount;
      successfulPayments++;
    } else if (txn.isFailed) {
      failedPayments++;
    }
  }

  return {
    'totalTransacted': totalTransacted,
    'totalCommission': totalCommission,
    'successfulPayments': successfulPayments,
    'failedPayments': failedPayments,
    'totalTransactions': transactions.length,
  };
});

// ============================================================================
// PAYMENT FLOW PROVIDERS
// ============================================================================

/// Get payment flow by ID
final paymentFlowProvider =
    FutureProvider.family<PaymentFlow?, String>((ref, flowId) async {
  final firestore = ref.watch(firestoreProvider);
  try {
    final doc = await firestore.collection('payment_flows').doc(flowId).get();
    if (!doc.exists) return null;
    return PaymentFlow.fromJson(doc.data()!);
  } catch (e) {
    print('Error fetching payment flow: $e');
    return null;
  }
});

/// Watch payment flow changes in real-time
final paymentFlowStreamProvider =
    StreamProvider.family<PaymentFlow?, String>((ref, flowId) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('payment_flows')
      .doc(flowId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    return PaymentFlow.fromJson(doc.data()!);
  });
});

/// Get user's payment flows
final userPaymentFlowsProvider =
    FutureProvider.family<List<PaymentFlow>, String>((ref, userId) async {
  final firestore = ref.watch(firestoreProvider);
  try {
    final snapshot = await firestore
        .collection('payment_flows')
        .where('initiatorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .get();

    return snapshot.docs
        .map((doc) => PaymentFlow.fromJson(doc.data()))
        .toList();
  } catch (e) {
    print('Error fetching payment flows: $e');
    return [];
  }
});

/// Get active payment flows
final activePaymentFlowsProvider =
    FutureProvider.family<List<PaymentFlow>, String>((ref, userId) async {
  final flows = await ref.watch(userPaymentFlowsProvider(userId).future);
  return flows
      .where(
        (f) =>
            f.status != PaymentFlowStatus.completed &&
            f.status != PaymentFlowStatus.failed &&
            f.status != PaymentFlowStatus.cancelled,
      )
      .toList();
});

// ============================================================================
// SETTLEMENT PROVIDERS
// ============================================================================

/// Get user's settlements
final userSettlementsProvider =
    FutureProvider.family<List<Settlement>, String>((ref, userId) async {
  final firestore = ref.watch(firestoreProvider);
  try {
    final snapshot = await firestore
        .collection('settlements')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(12)
        .get();

    return snapshot.docs.map((doc) => Settlement.fromJson(doc.data())).toList();
  } catch (e) {
    print('Error fetching settlements: $e');
    return [];
  }
});

/// Get pending settlements
final pendingSettlementsProvider =
    FutureProvider.family<List<Settlement>, String>((ref, userId) async {
  final settlements = await ref.watch(userSettlementsProvider(userId).future);
  return settlements
      .where((s) => s.status == SettlementStatus.pending)
      .toList();
});

/// Get settlement by ID
final settlementProvider =
    FutureProvider.family<Settlement?, String>((ref, settlementId) async {
  final firestore = ref.watch(firestoreProvider);
  try {
    final doc =
        await firestore.collection('settlements').doc(settlementId).get();
    if (!doc.exists) return null;
    return Settlement.fromJson(doc.data()!);
  } catch (e) {
    print('Error fetching settlement: $e');
    return null;
  }
});

/// Watch settlement changes
final settlementStreamProvider =
    StreamProvider.family<Settlement?, String>((ref, settlementId) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('settlements')
      .doc(settlementId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    return Settlement.fromJson(doc.data()!);
  });
});

// ============================================================================
// WITHDRAWAL REQUEST PROVIDERS
// ============================================================================

/// Get user's withdrawal requests
final userWithdrawalRequestsProvider =
    FutureProvider.family<List<WithdrawalRequest>, String>((ref, userId) async {
  final firestore = ref.watch(firestoreProvider);
  try {
    final snapshot = await firestore
        .collection('withdrawal_requests')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .get();

    return snapshot.docs
        .map((doc) => WithdrawalRequest.fromJson(doc.data()))
        .toList();
  } catch (e) {
    print('Error fetching withdrawal requests: $e');
    return [];
  }
});

/// Get pending withdrawal requests
final pendingWithdrawalsProvider =
    FutureProvider.family<List<WithdrawalRequest>, String>(
  (ref, userId) async {
    final requests =
        await ref.watch(userWithdrawalRequestsProvider(userId).future);
    return requests
        .where((r) =>
            r.status == WithdrawalStatus.pending ||
            r.status == WithdrawalStatus.processing)
        .toList();
  },
);

// ============================================================================
// COMMISSION AND ANALYTICS PROVIDERS
// ============================================================================

/// Get commission breakdown for user
final commissionBreakdownProvider =
    FutureProvider.family<Map<String, double>, String>((ref, userId) async {
  final transactions =
      await ref.watch(userIncomeTransactionsProvider(userId).future);

  final breakdown = WalletServiceCore.calculateCategoryBreakdown(transactions);
  return breakdown;
});

/// Get monthly earnings
final monthlyEarningsProvider =
    FutureProvider.family<Map<String, double>, String>((ref, userId) async {
  final transactions =
      await ref.watch(userIncomeTransactionsProvider(userId).future);

  final monthly = WalletServiceCore.calculateMonthlyEarnings(transactions);
  return monthly;
});

/// Get earnings analytics
final earningsAnalyticsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
  final transactions =
      await ref.watch(userIncomeTransactionsProvider(userId).future);

  final completed = transactions.where((t) => t.isCompleted).toList();

  double totalEarned = 0;
  double totalCommission = 0;
  double highestTransaction = 0;
  double averageTransaction = 0;

  for (final t in completed) {
    totalEarned += t.netAmount;
    totalCommission += t.commissionAmount;
    if (t.amount > highestTransaction) {
      highestTransaction = t.amount;
    }
  }

  if (completed.isNotEmpty) {
    averageTransaction = totalEarned / completed.length;
  }

  return {
    'totalEarned': totalEarned,
    'totalCommission': totalCommission,
    'highestTransaction': highestTransaction,
    'averageTransaction': averageTransaction,
    'totalTransactions': completed.length,
  };
});

// ============================================================================
// STATE NOTIFIER PROVIDERS (for mutations)
// ============================================================================

/// State notifier for creating transactions
final transactionCreationProvider =
    StateNotifierProvider<TransactionNotifier, AsyncValue<Transaction?>>((ref) {
  return TransactionNotifier(ref);
});

class TransactionNotifier extends StateNotifier<AsyncValue<Transaction?>> {
  final Ref ref;

  TransactionNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> createTransaction({
    required String payerId,
    required String payeeId,
    required double amount,
    required TransactionCategory category,
    required PaymentMethod method,
    required String description,
    String? orderId,
    String? transportId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final transaction = PaymentServiceCore.createTransaction(
        payerId: payerId,
        payerName: null,
        payeeId: payeeId,
        payeeName: null,
        amount: amount,
        category: category,
        method: method,
        description: description,
        orderId: orderId,
        transportId: transportId,
      );

      final firestore = ref.read(firestoreProvider);
      await firestore
          .collection('transactions')
          .doc(transaction.id)
          .set(transaction.toJson());

      state = AsyncValue.data(transaction);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// State notifier for payment flows
final paymentFlowCreationProvider =
    StateNotifierProvider<PaymentFlowNotifier, AsyncValue<PaymentFlow?>>((ref) {
  return PaymentFlowNotifier(ref);
});

class PaymentFlowNotifier extends StateNotifier<AsyncValue<PaymentFlow?>> {
  final Ref ref;

  PaymentFlowNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> createPaymentFlow({
    required PaymentFlowType flowType,
    required String initiatorId,
    required String primaryRecipientId,
    required double totalAmount,
    required List<PaymentParty> parties,
    required List<PaymentSplit> splits,
    String? relatedOrderId,
    String? relatedTransportId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final flow = PaymentServiceCore.createPaymentFlow(
        flowType: flowType,
        initiatorId: initiatorId,
        initiatorName: null,
        primaryRecipientId: primaryRecipientId,
        primaryRecipientName: null,
        totalAmount: totalAmount,
        parties: parties,
        splits: splits,
        relatedOrderId: relatedOrderId,
        relatedTransportId: relatedTransportId,
      );

      final firestore = ref.read(firestoreProvider);
      await firestore
          .collection('payment_flows')
          .doc(flow.id)
          .set(flow.toJson());

      state = AsyncValue.data(flow);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// ============================================================================
// VALIDATION PROVIDERS
// ============================================================================

/// Validate payment amount
final validatePaymentProvider =
    FutureProvider.family<PaymentValidationResult, double>(
  (ref, amount) async {
    return PaymentServiceCore.validatePaymentAmount(amount);
  },
);

/// Check withdrawal eligibility
final checkWithdrawalEligibilityProvider = FutureProvider.family<
    PaymentValidationResult,
    ({
      double availableBalance,
      double amount,
      double dailyWithdrawn,
      double monthlyWithdrawn,
      bool isKycVerified,
    })>((ref, params) async {
  return WalletServiceCore.canWithdraw(
    availableBalance: params.availableBalance,
    amount: params.amount,
    dailyWithdrawn: params.dailyWithdrawn,
    monthlyWithdrawn: params.monthlyWithdrawn,
    isKycVerified: params.isKycVerified,
  );
});
