import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/payment_model.dart';
import 'transaction_service.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TransactionService _transactionService = TransactionService();

  static const String _paymentCollection = 'payments';
  static const String _usersCollection = 'users';
  static const String _ordersCollection = 'orders';

  // Initialize payment
  Future<Payment> initializePayment({
    required String userId,
    required double amount,
    required PaymentMethod method,
    required String purpose,
    String? orderId,
    String? receipientId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Generate unique payment ID
      const uuid = Uuid();
      String paymentId = uuid.v4();

      // Create payment object
      Payment payment = Payment(
        id: paymentId,
        userId: userId,
        amount: amount,
        method: method,
        status: PaymentStatus.pending,
        purpose: purpose,
        orderId: orderId,
        receipientId: receipientId,
        metadata: metadata ?? {},
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await _firestore
          .collection(_paymentCollection)
          .doc(paymentId)
          .set(payment.toJson());

      debugPrint('Payment initialized: $paymentId for amount: $amount');
      return payment;
    } catch (e) {
      debugPrint('Error initializing payment: $e');
      rethrow;
    }
  }

  // Process payment with Flutterwave
  Future<bool> processPaymentWithFlutterwave({
    required String paymentId,
    required String phoneNumber,
    required String email,
    required String fullName,
  }) async {
    try {
      // Update payment status to processing
      await updatePaymentStatus(
        paymentId,
        PaymentStatus.processing,
      );

      // TODO: Integrate with Flutterwave API
      // 1. Initialize Flutterwave transaction
      // 2. Send payment request
      // 3. Handle callback

      // For now, simulate successful payment after verification
      await Future.delayed(const Duration(seconds: 2));

      return true;
    } catch (e) {
      debugPrint('Error processing payment with Flutterwave: $e');
      await updatePaymentStatus(paymentId, PaymentStatus.failed,
          failureReason: 'Flutterwave processing error: $e');
      rethrow;
    }
  }

  // Verify and complete payment
  Future<bool> verifyAndCompletePayment({
    required String paymentId,
    String? transactionId,
    Map<String, dynamic>? verificationData,
  }) async {
    try {
      // Get payment
      Payment payment = await getPayment(paymentId);

      if (payment.isCompleted) {
        debugPrint('Payment already completed: $paymentId');
        return true;
      }

      // Update payment status to completed
      Payment completedPayment = await updatePaymentStatus(
        paymentId,
        PaymentStatus.completed,
        transactionId: transactionId,
        verificationData: verificationData,
      );

      // Create transaction record
      String txnId = const Uuid().v4();
      await _transactionService.addTransaction(
        id: txnId,
        userId: payment.userId,
        type: TransactionType.debit,
        amount: payment.amount,
        title: 'Payment: ${payment.purpose}',
        description: 'Payment via ${payment.methodText}',
        paymentId: paymentId,
        relatedId: payment.orderId,
        relatedType: payment.purpose,
        metadata: {
          'paymentMethod': payment.methodText,
          'paymentStatus': payment.statusText,
          'transactionId': transactionId,
        },
      );

      // Execute post-payment actions
      await _executePostPaymentActions(completedPayment);

      debugPrint('Payment completed and verified: $paymentId');
      return true;
    } catch (e) {
      debugPrint('Error verifying payment: $e');
      await updatePaymentStatus(paymentId, PaymentStatus.failed,
          failureReason: 'Payment verification failed: $e');
      rethrow;
    }
  }

  // Refund payment
  Future<bool> refundPayment({
    required String paymentId,
    String? reason,
  }) async {
    try {
      Payment payment = await getPayment(paymentId);

      if (!payment.canRefund) {
        throw Exception('Payment cannot be refunded');
      }

      // Update payment status to refunded
      await updatePaymentStatus(
        paymentId,
        PaymentStatus.refunded,
      );

      // Create refund transaction
      await _transactionService.addTransaction(
        id: const Uuid().v4(),
        userId: payment.userId,
        type: TransactionType.refund,
        amount: payment.amount,
        title: 'Refund: ${payment.purpose}',
        description: reason ?? 'Payment refunded',
        paymentId: paymentId,
        metadata: {
          'originalPaymentId': paymentId,
          'refundReason': reason,
        },
      );

      debugPrint('Payment refunded: $paymentId');
      return true;
    } catch (e) {
      debugPrint('Error refunding payment: $e');
      rethrow;
    }
  }

  // Get payment
  Future<Payment> getPayment(String paymentId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(_paymentCollection).doc(paymentId).get();

      if (!doc.exists) {
        throw Exception('Payment not found: $paymentId');
      }

      return Payment.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error getting payment: $e');
      rethrow;
    }
  }

  // Update payment status
  Future<Payment> updatePaymentStatus(
    String paymentId,
    PaymentStatus status, {
    String? transactionId,
    String? failureReason,
    Map<String, dynamic>? verificationData,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'status': status.toString(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (transactionId != null) {
        updateData['transactionId'] = transactionId;
      }

      if (failureReason != null) {
        updateData['failureReason'] = failureReason;
      }

      if (status == PaymentStatus.completed) {
        updateData['completedAt'] = DateTime.now().toIso8601String();
      }

      if (status == PaymentStatus.refunded) {
        updateData['refundedAt'] = DateTime.now().toIso8601String();
      }

      if (verificationData != null) {
        updateData['verificationData'] = verificationData;
      }

      await _firestore
          .collection(_paymentCollection)
          .doc(paymentId)
          .update(updateData);

      return getPayment(paymentId);
    } catch (e) {
      debugPrint('Error updating payment status: $e');
      rethrow;
    }
  }

  // Get user payments
  Stream<List<Payment>> getUserPayments(String userId) {
    return _firestore
        .collection(_paymentCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Payment.fromJson(doc.data())).toList();
    });
  }

  // Get payment statistics
  Future<Map<String, dynamic>> getPaymentStats(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_paymentCollection)
          .where('userId', isEqualTo: userId)
          .get();

      double totalAmount = 0;
      int completedCount = 0;
      int pendingCount = 0;
      int failedCount = 0;

      for (var doc in snapshot.docs) {
        Payment payment = Payment.fromJson(doc.data() as Map<String, dynamic>);
        totalAmount += payment.amount;

        if (payment.isCompleted) completedCount++;
        if (payment.isPending) pendingCount++;
        if (payment.isFailed) failedCount++;
      }

      return {
        'totalAmount': totalAmount,
        'completedCount': completedCount,
        'pendingCount': pendingCount,
        'failedCount': failedCount,
        'totalTransactions': snapshot.docs.length,
      };
    } catch (e) {
      debugPrint('Error getting payment stats: $e');
      rethrow;
    }
  }

  // Execute post-payment actions based on purpose
  Future<void> _executePostPaymentActions(Payment payment) async {
    try {
      switch (payment.purpose) {
        case 'subscription':
          await _activateSubscription(payment.userId);
          break;
        case 'featured_post':
          if (payment.metadata.containsKey('productId')) {
            await _featureProduct(payment.metadata['productId']);
          }
          break;
        case 'investment':
          if (payment.metadata.containsKey('investmentId')) {
            await _processInvestment(
              payment.metadata['investmentId'],
              payment.userId,
              payment.amount,
            );
          }
          break;
        case 'order':
          if (payment.orderId != null) {
            await _updateOrderStatus(payment.orderId!, 'paid');
          }
          break;
      }
    } catch (e) {
      debugPrint('Error executing post-payment actions: $e');
    }
  }

  // Activate premium subscription
  Future<void> _activateSubscription(String userId) async {
    try {
      DateTime expiryDate = DateTime.now().add(const Duration(days: 30));
      await _firestore.collection(_usersCollection).doc(userId).update({
        'isPremium': true,
        'premiumExpiryDate': expiryDate.toIso8601String(),
        'subscriptionStatus': 'active',
      });
      debugPrint('Subscription activated for user: $userId');
    } catch (e) {
      debugPrint('Error activating subscription: $e');
    }
  }

  // Feature product
  Future<void> _featureProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'isFeatured': true,
        'featuredUntil':
            DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        'featuredDate': DateTime.now().toIso8601String(),
      });
      debugPrint('Product featured: $productId');
    } catch (e) {
      debugPrint('Error featuring product: $e');
    }
  }

  // Process investment
  Future<void> _processInvestment(
    String investmentId,
    String investorId,
    double amount,
  ) async {
    try {
      await _firestore
          .collection('investments')
          .doc(investmentId)
          .collection('investors')
          .add({
        'investorId': investorId,
        'amount': amount,
        'investmentDate': DateTime.now().toIso8601String(),
        'status': 'active',
      });

      await _firestore.collection('investments').doc(investmentId).update({
        'raisedAmount': FieldValue.increment(amount),
        'investorCount': FieldValue.increment(1),
      });

      debugPrint(
          'Investment processed: $investmentId for investor: $investorId');
    } catch (e) {
      debugPrint('Error processing investment: $e');
    }
  }

  // Update order status
  Future<void> _updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection(_ordersCollection).doc(orderId).update({
        'paymentStatus': status,
        'status': status == 'paid' ? 'confirmed' : 'pending',
        'paidAt': DateTime.now().toIso8601String(),
      });
      debugPrint('Order status updated: $orderId -> $status');
    } catch (e) {
      debugPrint('Error updating order status: $e');
    }
  }
}
