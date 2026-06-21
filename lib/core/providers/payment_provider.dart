import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';
import '../services/transaction_service.dart';

// Payment Service Provider
final paymentServiceProvider = Provider((ref) => PaymentService());

// Transaction Service Provider
final transactionServiceProvider = Provider((ref) => TransactionService());

// User Payments Stream Provider
final userPaymentsProvider =
    StreamProvider.family<List<Payment>, String>((ref, userId) {
  final paymentService = ref.watch(paymentServiceProvider);
  return paymentService.getUserPayments(userId);
});

// User Transactions Stream Provider
final userTransactionsProvider =
    StreamProvider.family<List<Transaction>, String>(
  (ref, userId) {
    final transactionService = ref.watch(transactionServiceProvider);
    return transactionService.getUserTransactions(userId);
  },
);

// Wallet Balance Provider
final walletBalanceProvider =
    FutureProvider.family<double, String>((ref, userId) async {
  final transactionService = ref.watch(transactionServiceProvider);
  return transactionService.getWalletBalance(userId);
});

// Pending Balance Provider
final pendingBalanceProvider =
    FutureProvider.family<double, String>((ref, userId) async {
  final transactionService = ref.watch(transactionServiceProvider);
  return transactionService.getPendingBalance(userId);
});

// Payment Stats Provider
final paymentStatsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
  final paymentService = ref.watch(paymentServiceProvider);
  return paymentService.getPaymentStats(userId);
});

// Transaction Stats Provider
final transactionStatsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
  final transactionService = ref.watch(transactionServiceProvider);
  return transactionService.getTransactionStats(userId);
});

// Payment State Notifier
class PaymentNotifier extends StateNotifier<Payment?> {
  PaymentNotifier(this.paymentService) : super(null);

  final PaymentService paymentService;

  Future<Payment> initializePayment({
    required String userId,
    required double amount,
    required PaymentMethod method,
    required String purpose,
    String? orderId,
    String? receipientId,
    Map<String, dynamic>? metadata,
  }) async {
    final payment = await paymentService.initializePayment(
      userId: userId,
      amount: amount,
      method: method,
      purpose: purpose,
      orderId: orderId,
      receipientId: receipientId,
      metadata: metadata,
    );
    state = payment;
    return payment;
  }

  Future<bool> completePayment({
    required String paymentId,
    String? transactionId,
    Map<String, dynamic>? verificationData,
  }) async {
    try {
      final result = await paymentService.verifyAndCompletePayment(
        paymentId: paymentId,
        transactionId: transactionId,
        verificationData: verificationData,
      );
      if (result) {
        state = await paymentService.getPayment(paymentId);
      }
      return result;
    } catch (e) {
      return false;
    }
  }

  Future<bool> refundPayment({
    required String paymentId,
    String? reason,
  }) async {
    try {
      final result = await paymentService.refundPayment(
        paymentId: paymentId,
        reason: reason,
      );
      if (result) {
        state = await paymentService.getPayment(paymentId);
      }
      return result;
    } catch (e) {
      return false;
    }
  }

  Future<Payment> getPayment(String paymentId) async {
    final payment = await paymentService.getPayment(paymentId);
    state = payment;
    return payment;
  }
}

// Payment State Notifier Provider
final paymentNotifierProvider =
    StateNotifierProvider<PaymentNotifier, Payment?>((ref) {
  final paymentService = ref.watch(paymentServiceProvider);
  return PaymentNotifier(paymentService);
});

// Transaction State Notifier
class TransactionNotifier extends StateNotifier<Transaction?> {
  TransactionNotifier(this.transactionService) : super(null);

  final TransactionService transactionService;

  Future<Transaction> addTransaction({
    required String userId,
    required TransactionType type,
    required double amount,
    required String title,
    String? description,
    String? paymentId,
    String? relatedId,
    String? relatedType,
    Map<String, dynamic>? metadata,
  }) async {
    final transaction = await transactionService.addTransaction(
      id: '',
      userId: userId,
      type: type,
      amount: amount,
      title: title,
      description: description,
      paymentId: paymentId,
      relatedId: relatedId,
      relatedType: relatedType,
      metadata: metadata,
    );
    state = transaction;
    return transaction;
  }

  Future<Transaction?> getTransaction(String transactionId) async {
    final transaction = await transactionService.getTransaction(transactionId);
    state = transaction;
    return transaction;
  }

  Future<bool> addEscrow({
    required String userId,
    required double amount,
    required String reason,
    Map<String, dynamic>? metadata,
  }) async {
    return await transactionService.addEscrow(
      userId: userId,
      amount: amount,
      reason: reason,
      metadata: metadata,
    );
  }

  Future<bool> releaseEscrow({
    required String userId,
    required double amount,
    required String reason,
    Map<String, dynamic>? metadata,
  }) async {
    return await transactionService.releaseEscrow(
      userId: userId,
      amount: amount,
      reason: reason,
      metadata: metadata,
    );
  }
}

// Transaction State Notifier Provider
final transactionNotifierProvider =
    StateNotifierProvider<TransactionNotifier, Transaction?>((ref) {
  final transactionService = ref.watch(transactionServiceProvider);
  return TransactionNotifier(transactionService);
});

// Payment by ID Provider
final paymentByIdProvider =
    FutureProvider.family<Payment, String>((ref, paymentId) async {
  final paymentService = ref.watch(paymentServiceProvider);
  return paymentService.getPayment(paymentId);
});

// Transaction by ID Provider
final transactionByIdProvider =
    FutureProvider.family<Transaction?, String>((ref, transactionId) async {
  final transactionService = ref.watch(transactionServiceProvider);
  return transactionService.getTransaction(transactionId);
});

// Recent Transactions by Date Provider
final recentTransactionsProvider = FutureProvider.family<
    List<Transaction>,
    (
      String userId,
      DateTime startDate,
      DateTime endDate,
    )>((ref, params) async {
  final transactionService = ref.watch(transactionServiceProvider);
  return transactionService.getTransactionsByDateRange(
    userId: params.$1,
    startDate: params.$2,
    endDate: params.$3,
  );
});
