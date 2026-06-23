import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/withdraw_request_model.dart';
import 'transaction_service.dart';

class WithdrawService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TransactionService _transactionService = TransactionService();

  static const String _withdrawCollection = 'withdraw_requests';

  // Create a new withdraw request
  Future<WithdrawRequestModel> createWithdrawRequest({
    required String userId,
    required double amount,
    required String method,
    required String accountDetails,
  }) async {
    try {
      // 1. Deduct balance immediately to prevent double spending
      bool deducted = await _transactionService.deductBalance(
        userId: userId,
        amount: amount,
        reason: 'Withdrawal request to $method',
      );

      if (!deducted) {
        throw Exception('Insufficient balance or error deducting funds');
      }

      // 2. Create withdraw request
      final id = const Uuid().v4();
      final withdrawRequest = WithdrawRequestModel(
        id: id,
        userId: userId,
        amount: amount,
        method: method,
        accountDetails: accountDetails,
        status: WithdrawStatus.pending,
        createdAt: DateTime.now(),
      );

      try {
        await _firestore
            .collection(_withdrawCollection)
            .doc(id)
            .set(withdrawRequest.toJson());
      } catch (e) {
        // Critical: If writing the request fails (e.g., permission denied), refund the money!
        debugPrint('Failed to save withdraw request, refunding user: $e');
        await _transactionService.addCredit(
          userId: userId,
          amount: amount,
          reason: 'Refund for failed system withdrawal request',
        );
        rethrow;
      }

      debugPrint('Withdraw request created: $id');
      return withdrawRequest;
    } catch (e) {
      debugPrint('Error creating withdraw request: $e');
      rethrow;
    }
  }

  // Get user's withdraw requests
  Stream<List<WithdrawRequestModel>> getUserWithdrawRequests(String userId) {
    return _firestore
        .collection(_withdrawCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => WithdrawRequestModel.fromJson(doc.data()))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // descending
          return list;
        });
  }

  // Get all pending withdraw requests for Admin
  Stream<List<WithdrawRequestModel>> getPendingWithdrawRequests() {
    return _firestore
        .collection(_withdrawCollection)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => WithdrawRequestModel.fromJson(doc.data()))
              .toList();
          list.sort((a, b) => a.createdAt.compareTo(b.createdAt)); // ascending
          return list;
        });
  }

  // Admin approves a withdraw request
  Future<bool> approveWithdraw(String requestId) async {
    try {
      await _firestore.collection(_withdrawCollection).doc(requestId).update({
        'status': WithdrawStatus.approved.toString().split('.').last,
        'processedAt': Timestamp.now(),
      });

      debugPrint('Withdraw approved: $requestId');
      return true;
    } catch (e) {
      debugPrint('Error approving withdraw: $e');
      throw Exception(e.toString());
    }
  }

  // Admin rejects a withdraw request
  Future<bool> rejectWithdraw(WithdrawRequestModel request) async {
    try {
      // 1. Refund the amount back to user's wallet
      bool refunded = await _transactionService.addCredit(
        userId: request.userId,
        amount: request.amount,
        reason: 'Refund for rejected withdrawal to ${request.method}',
        metadata: {'withdrawRequestId': request.id},
      );

      if (!refunded) {
        throw Exception('Failed to refund wallet');
      }

      // 2. Update request status
      await _firestore.collection(_withdrawCollection).doc(request.id).update({
        'status': WithdrawStatus.rejected.toString().split('.').last,
        'processedAt': Timestamp.now(),
      });

      debugPrint('Withdraw rejected: ${request.id}');
      return true;
    } catch (e) {
      debugPrint('Error rejecting withdraw: $e');
      return false;
    }
  }
}
