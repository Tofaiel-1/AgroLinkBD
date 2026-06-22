import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/deposit_request_model.dart';
import 'transaction_service.dart';

class DepositService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TransactionService _transactionService = TransactionService();

  static const String _depositCollection = 'deposit_requests';

  // Create a new deposit request
  Future<DepositRequestModel> createDepositRequest({
    required String userId,
    required double amount,
    required String paymentMethod,
    String? transactionId,
  }) async {
    try {
      final id = const Uuid().v4();
      final depositRequest = DepositRequestModel(
        id: id,
        userId: userId,
        amount: amount,
        paymentMethod: paymentMethod,
        transactionId: transactionId,
        status: DepositStatus.pending,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(_depositCollection)
          .doc(id)
          .set(depositRequest.toJson());

      debugPrint('Deposit request created: $id');
      return depositRequest;
    } catch (e) {
      debugPrint('Error creating deposit request: $e');
      rethrow;
    }
  }

  // Get user's deposit requests
  Stream<List<DepositRequestModel>> getUserDepositRequests(String userId) {
    return _firestore
        .collection(_depositCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DepositRequestModel.fromJson(doc.data()))
            .toList());
  }

  // Get all pending deposit requests for Admin
  Stream<List<DepositRequestModel>> getPendingDepositRequests() {
    return _firestore
        .collection(_depositCollection)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DepositRequestModel.fromJson(doc.data()))
            .toList());
  }

  // Admin approves a deposit
  Future<bool> approveDeposit(DepositRequestModel request) async {
    try {
      // 1. Add credit to user's wallet
      bool credited = await _transactionService.addCredit(
        userId: request.userId,
        amount: request.amount,
        reason: 'Deposit via ${request.paymentMethod.toUpperCase()}',
        metadata: {'depositRequestId': request.id},
      );

      if (!credited) {
        throw Exception('Failed to add credit to wallet');
      }

      // 2. Update request status
      await _firestore.collection(_depositCollection).doc(request.id).update({
        'status': DepositStatus.approved.toString().split('.').last,
        'processedAt': Timestamp.now(),
      });

      debugPrint('Deposit approved: ${request.id}');
      return true;
    } catch (e) {
      debugPrint('Error approving deposit: $e');
      return false;
    }
  }

  // Admin rejects a deposit
  Future<bool> rejectDeposit(String requestId) async {
    try {
      await _firestore.collection(_depositCollection).doc(requestId).update({
        'status': DepositStatus.rejected.toString().split('.').last,
        'processedAt': Timestamp.now(),
      });
      debugPrint('Deposit rejected: $requestId');
      return true;
    } catch (e) {
      debugPrint('Error rejecting deposit: $e');
      return false;
    }
  }
}
