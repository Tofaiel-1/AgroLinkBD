import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/payment_model.dart';

class TransactionService {
  final firestore.FirebaseFirestore _firestore =
      firestore.FirebaseFirestore.instance;

  static const String _transactionsCollection = 'transactions';
  static const String _usersCollection = 'users';
  static const String _walletField = 'walletBalance';
  static const String _pendingWalletField = 'pendingBalance';

  // Add transaction with detailed tracking
  Future<Transaction> addTransaction({
    required String id,
    required String userId,
    required TransactionType type,
    required double amount,
    required String title,
    String? description,
    String? paymentId,
    String? relatedId,
    String? relatedType,
    double? balanceBefore,
    double? balanceAfter,
    Map<String, dynamic>? metadata,
    String? status,
  }) async {
    try {
      // Generate ID if not provided
      final transactionId = id.isEmpty ? const Uuid().v4() : id;

      // Get current wallet balance if not provided
      if (balanceBefore == null) {
        balanceBefore = await getWalletBalance(userId);
      }

      // Calculate new balance
      double newBalance = balanceBefore;
      if (type == TransactionType.credit) {
        newBalance += amount;
      } else if (type == TransactionType.debit) {
        newBalance -= amount;
      } else if (type == TransactionType.refund) {
        newBalance += amount;
      }

      balanceAfter ??= newBalance;

      // Create transaction object
      Transaction transaction = Transaction(
        id: transactionId,
        userId: userId,
        type: type,
        amount: amount,
        title: title,
        description: description,
        paymentId: paymentId,
        relatedId: relatedId,
        relatedType: relatedType,
        balanceBefore: balanceBefore,
        balanceAfter: balanceAfter,
        metadata: metadata ?? {},
        createdAt: DateTime.now(),
        status: status ?? 'completed',
      );

      // Save transaction to Firestore
      await _firestore
          .collection(_transactionsCollection)
          .doc(transactionId)
          .set(transaction.toJson());

      // Update user wallet balance
      await _firestore.collection(_usersCollection).doc(userId).update({
        _walletField: balanceAfter,
      });

      debugPrint(
        'Transaction added: $transactionId | Type: ${type.toString()} | Amount: $amount | New Balance: $balanceAfter',
      );

      return transaction;
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      rethrow;
    }
  }

  // Get user transactions with filters
  Stream<List<Transaction>> getUserTransactions(
    String userId, {
    TransactionType? type,
    int limit = 50,
  }) {
    firestore.Query query = _firestore
        .collection(_transactionsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (type != null) {
      query = query.where('type', isEqualTo: type.toString());
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map(
              (doc) => Transaction.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Get transaction by ID
  Future<Transaction?> getTransaction(String transactionId) async {
    try {
      firestore.DocumentSnapshot doc = await _firestore
          .collection(_transactionsCollection)
          .doc(transactionId)
          .get();

      if (!doc.exists) return null;

      return Transaction.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error getting transaction: $e');
      return null;
    }
  }

  // Get wallet balance
  Future<double> getWalletBalance(String userId) async {
    try {
      firestore.DocumentSnapshot doc =
          await _firestore.collection(_usersCollection).doc(userId).get();

      if (!doc.exists) {
        // Initialize wallet for new user
        await _firestore.collection(_usersCollection).doc(userId).set({
          _walletField: 0.0,
          _pendingWalletField: 0.0,
        }, firestore.SetOptions(merge: true));
        return 0.0;
      }

      final balance = (doc.data() as Map<String, dynamic>)[_walletField] ?? 0.0;
      return (balance as num).toDouble();
    } catch (e) {
      debugPrint('Error getting wallet balance: $e');
      return 0.0;
    }
  }

  // Get pending wallet balance (Escrow)
  Future<double> getPendingBalance(String userId) async {
    try {
      firestore.DocumentSnapshot doc =
          await _firestore.collection(_usersCollection).doc(userId).get();

      if (!doc.exists) {
        return 0.0;
      }

      final pending = (doc.data() as Map<String, dynamic>)[_pendingWalletField] ?? 0.0;
      return (pending as num).toDouble();
    } catch (e) {
      debugPrint('Error getting pending balance: $e');
      return 0.0;
    }
  }

  // Get transaction history for date range
  Future<List<Transaction>> getTransactionsByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      firestore.QuerySnapshot snapshot = await _firestore
          .collection(_transactionsCollection)
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThanOrEqualTo: startDate)
          .where('createdAt', isLessThanOrEqualTo: endDate)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map(
              (doc) => Transaction.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting transactions by date range: $e');
      return [];
    }
  }

  // Get transaction statistics
  Future<Map<String, dynamic>> getTransactionStats(String userId) async {
    try {
      firestore.QuerySnapshot snapshot = await _firestore
          .collection(_transactionsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      double totalCredit = 0;
      double totalDebit = 0;
      double totalRefund = 0;
      int creditCount = 0;
      int debitCount = 0;
      int refundCount = 0;

      for (var doc in snapshot.docs) {
        Transaction transaction =
            Transaction.fromJson(doc.data() as Map<String, dynamic>);

        switch (transaction.type) {
          case TransactionType.credit:
            totalCredit += transaction.amount;
            creditCount++;
            break;
          case TransactionType.debit:
            totalDebit += transaction.amount;
            debitCount++;
            break;
          case TransactionType.refund:
            totalRefund += transaction.amount;
            refundCount++;
            break;
        }
      }

      double walletBalance = await getWalletBalance(userId);
      double netAmount = totalCredit - totalDebit + totalRefund;

      return {
        'walletBalance': walletBalance,
        'totalCredit': totalCredit,
        'totalDebit': totalDebit,
        'totalRefund': totalRefund,
        'netAmount': netAmount,
        'creditCount': creditCount,
        'debitCount': debitCount,
        'refundCount': refundCount,
        'totalTransactions': snapshot.docs.length,
      };
    } catch (e) {
      debugPrint('Error getting transaction stats: $e');
      return {
        'walletBalance': 0.0,
        'totalCredit': 0.0,
        'totalDebit': 0.0,
        'totalRefund': 0.0,
        'netAmount': 0.0,
        'creditCount': 0,
        'debitCount': 0,
        'refundCount': 0,
        'totalTransactions': 0,
      };
    }
  }

  // Create wallet for user
  Future<void> initializeUserWallet(String userId,
      {double initialBalance = 0.0}) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update({
        _walletField: initialBalance,
        _pendingWalletField: 0.0,
      }).catchError(
        (e) async {
          // If user doesn't exist, create it
          if (e.code == 'not-found') {
            await _firestore.collection(_usersCollection).doc(userId).set({
              _walletField: initialBalance,
              _pendingWalletField: 0.0,
            });
          }
        },
      );

      debugPrint(
          'Wallet initialized for user: $userId with balance: $initialBalance');
    } catch (e) {
      debugPrint('Error initializing wallet: $e');
    }
  }

  // Add credit to wallet
  Future<bool> addCredit({
    required String userId,
    required double amount,
    required String reason,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await addTransaction(
        id: const Uuid().v4(),
        userId: userId,
        type: TransactionType.credit,
        amount: amount,
        title: 'Credit: $reason',
        metadata: metadata,
      );
      return true;
    } catch (e) {
      debugPrint('Error adding credit: $e');
      return false;
    }
  }

  // Deduct from wallet
  Future<bool> deductBalance({
    required String userId,
    required double amount,
    required String reason,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      double currentBalance = await getWalletBalance(userId);

      if (currentBalance < amount) {
        throw Exception('Insufficient wallet balance');
      }

      await addTransaction(
        id: const Uuid().v4(),
        userId: userId,
        type: TransactionType.debit,
        amount: amount,
        title: 'Debit: $reason',
        metadata: metadata,
      );
      return true;
    } catch (e) {
      debugPrint('Error deducting balance: $e');
      return false;
    }
  }

  // Escrow / Pending Balance Management
  
  // Add to Pending Balance (Escrow)
  Future<bool> addEscrow({
    required String userId,
    required double amount,
    required String reason,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      double currentPending = await getPendingBalance(userId);
      double newPending = currentPending + amount;

      await _firestore.collection(_usersCollection).doc(userId).update({
        _pendingWalletField: newPending,
      });

      // Optionally record an escrow transaction (could be tracked differently)
      debugPrint('Escrow added: $amount to user $userId');
      return true;
    } catch (e) {
      debugPrint('Error adding to escrow: $e');
      return false;
    }
  }

  // Release Escrow to Main Balance (Subtract from pending, add to wallet)
  Future<bool> releaseEscrow({
    required String userId,
    required double amount,
    required String reason,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      double currentPending = await getPendingBalance(userId);
      
      if (currentPending < amount) {
        debugPrint('Warning: Trying to release more escrow than available. Clamping amount.');
        amount = currentPending;
      }
      
      if (amount <= 0) return false;

      double newPending = currentPending - amount;

      // Update pending
      await _firestore.collection(_usersCollection).doc(userId).update({
        _pendingWalletField: newPending,
      });

      // Add to main wallet and record transaction
      await addCredit(
        userId: userId, 
        amount: amount, 
        reason: 'Escrow Released: $reason',
        metadata: metadata,
      );

      return true;
    } catch (e) {
      debugPrint('Error releasing escrow: $e');
      return false;
    }
  }
}
