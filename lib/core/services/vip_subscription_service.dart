import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agrolinkbd/core/services/sslcommerz_service.dart';

class VipSubscriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream to listen to real-time VIP subscription and admin approval status for a user
  Stream<DocumentSnapshot<Map<String, dynamic>>> getSubscriptionStatusStream(String userId) {
    if (userId.isEmpty) {
      return const Stream.empty();
    }
    return _firestore.collection('vip_subscriptions').doc(userId).snapshots();
  }

  /// Check if user has active and approved VIP subscription
  Future<bool> isVipActive(String userId) async {
    if (userId.isEmpty) return false;
    try {
      final doc = await _firestore.collection('vip_subscriptions').doc(userId).get();
      if (!doc.exists) return false;
      final data = doc.data()!;
      final status = data['status'] as String?;
      final expiresAt = (data['expiresAt'] as Timestamp?)?.toDate();

      if (status == 'approved' || status == 'active') {
        if (expiresAt == null || expiresAt.isAfter(DateTime.now())) {
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error checking VIP status: $e');
      return false;
    }
  }

  /// Submit manual TrxID (bKash / Nagad / Rocket) for Admin Verification
  Future<bool> submitManualTransaction({
    required String userId,
    required String userName,
    required String userPhone,
    required String paymentMethod,
    required String senderPhone,
    required String transactionId,
    required double amount,
    required String planName,
  }) async {
    try {
      final now = FieldValue.serverTimestamp();
      final docRef = _firestore.collection('vip_subscriptions').doc(userId);

      final payload = {
        'userId': userId,
        'userName': userName,
        'userPhone': userPhone,
        'senderPhone': senderPhone,
        'paymentMethod': paymentMethod,
        'transactionId': transactionId.trim().toUpperCase(),
        'amount': amount,
        'planName': planName,
        'status': 'pending_approval',
        'submittedAt': now,
        'updatedAt': now,
        'adminNotes': 'Pending verification of TrxID: ${transactionId.trim().toUpperCase()}',
      };

      await docRef.set(payload, SetOptions(merge: true));

      // Also create an entry in admin_approvals for central admin dashboard
      await _firestore.collection('admin_approvals').add({
        ...payload,
        'type': 'vip_wholesale_pass',
        'isResolved': false,
      });

      return true;
    } catch (e) {
      debugPrint('Error submitting manual VIP transaction: $e');
      return false;
    }
  }

  /// Initiate SSLCommerz Payment Gateway & record transaction for Admin Approval / Auto-Activation
  Future<bool> initiateSslCommerzPayment(
    BuildContext context, {
    required String userId,
    required String userName,
    required String userPhone,
    required String userEmail,
    required double amount,
    required String planName,
  }) async {
    try {
      final bool isPaid = await SSLCommerzService.initiatePayment(
        context: context,
        amount: amount,
        productName: 'AgroLink VIP Wholesale Pass - $planName',
        customerName: userName.isNotEmpty ? userName : 'Valued Trader',
        customerEmail: userEmail.isNotEmpty ? userEmail : 'trader@agrolinkbd.com',
        customerPhone: userPhone.isNotEmpty ? userPhone : '01700000000',
        customerAddress: 'Bangladesh',
      );

      if (isPaid) {
        final now = FieldValue.serverTimestamp();
        final txnId = 'SSL-${DateTime.now().millisecondsSinceEpoch}';
        final expiryDate = DateTime.now().add(const Duration(days: 30));

        final payload = {
          'userId': userId,
          'userName': userName,
          'userPhone': userPhone,
          'paymentMethod': 'SSLCommerz',
          'transactionId': txnId,
          'amount': amount,
          'planName': planName,
          'status': 'approved', // Auto-approved via official SSLCommerz payment gateway
          'paidAt': now,
          'activatedAt': now,
          'expiresAt': Timestamp.fromDate(expiryDate),
          'adminNotes': 'Automatically verified via SSLCommerz Gateway. Txn: $txnId',
        };

        // Update user's VIP document
        await _firestore.collection('vip_subscriptions').doc(userId).set(payload, SetOptions(merge: true));

        // Update User profile isPremium flag in Firestore
        await _firestore.collection('users').doc(userId).set({
          'isPremium': true,
          'premiumExpiresAt': Timestamp.fromDate(expiryDate),
          'role': 'vip_trader',
        }, SetOptions(merge: true));

        // Record in admin transactions
        await _firestore.collection('admin_approvals').add({
          ...payload,
          'type': 'vip_wholesale_pass',
          'isResolved': true,
        });

        return true;
      }
      return false;
    } catch (e) {
      debugPrint('SSLCommerz VIP Initiation Error: $e');
      return false;
    }
  }

  /// Admin approval helper (can be invoked by Admin Panel)
  Future<void> adminApproveSubscription({
    required String userId,
    required int daysValid,
    required String adminId,
  }) async {
    final now = DateTime.now();
    final expiresAt = now.add(Duration(days: daysValid));

    await _firestore.collection('vip_subscriptions').doc(userId).update({
      'status': 'approved',
      'approvedBy': adminId,
      'approvedAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(expiresAt),
    });

    await _firestore.collection('users').doc(userId).set({
      'isPremium': true,
      'premiumExpiresAt': Timestamp.fromDate(expiresAt),
    }, SetOptions(merge: true));
  }
}
