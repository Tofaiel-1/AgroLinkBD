import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../models/payment_model.dart';
import 'transaction_service.dart';

/// Escrow Financial Engine
/// Manages fund locking, revenue splitting (Platform Commission + Transport Margin),
/// and automated payout upon delivery OTP / QR verification.
class EscrowService {
  static final EscrowService _instance = EscrowService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TransactionService _transactionService = TransactionService();

  static const String _ordersCollection = 'orders';
  static const String _usersCollection = 'users';
  static const String _platformRevenueCollection = 'platform_revenue';
  static const String _adminUserId = 'super_admin_agrolink';

  // Commission Rates
  static const double defaultPlatformCommissionRate = 0.03; // 3% of product subtotal
  static const double defaultTransportPlatformCutRate = 0.05; // 5% of transport fare

  EscrowService._internal();

  factory EscrowService() {
    return _instance;
  }

  /// Calculate transparent breakdown of costs and payouts
  Map<String, double> calculateBreakdown({
    required double productSubtotal,
    double transportFare = 0.0,
    double platformCommissionRate = defaultPlatformCommissionRate,
    double transportPlatformCutRate = defaultTransportPlatformCutRate,
  }) {
    final productCommission = productSubtotal * platformCommissionRate;
    final transportPlatformCut = transportFare * transportPlatformCutRate;
    final totalPlatformFee = productCommission + transportPlatformCut;

    final farmerPayout = productSubtotal - productCommission;
    final driverNetFare = transportFare - transportPlatformCut;
    final totalChargedToBuyer = productSubtotal + transportFare;

    return {
      'productSubtotal': productSubtotal,
      'transportFare': transportFare,
      'platformCommission': productCommission,
      'transportPlatformCut': transportPlatformCut,
      'totalPlatformFee': totalPlatformFee,
      'farmerPayout': farmerPayout,
      'driverNetFare': driverNetFare,
      'totalChargedToBuyer': totalChargedToBuyer,
    };
  }

  /// Lock escrow funds when buyer places an order
  Future<String?> lockEscrowOrder(OrderModel order) async {
    try {
      final docRef = await _firestore.collection(_ordersCollection).add(order.toMap());
      final orderId = docRef.id;

      // Update farmer's pending balance in Firestore
      if (order.farmerId.isNotEmpty) {
        await _firestore.collection(_usersCollection).doc(order.farmerId).set({
          'pendingBalance': FieldValue.increment(order.farmerPayout),
        }, SetOptions(merge: true));
      }

      // Log Escrow Hold Transaction
      await _transactionService.addTransaction(
        id: '',
        userId: order.buyerId,
        type: TransactionType.debit,
        amount: order.totalAmount,
        title: 'অর্ডার এস্ক্রো লকড 🔒',
        description: '${order.productName} (${order.quantity} ${order.unit}) ক্রয়ের জন্য এস্ক্রোতে টাকা আটকে রাখা হয়েছে।',
        relatedId: orderId,
        relatedType: 'order_escrow_hold',
        status: 'held',
        metadata: {
          'orderId': orderId,
          'batchCode': order.batchCode,
          'platformFee': order.platformFee,
          'farmerPayout': order.farmerPayout,
          'driverFare': order.driverFare,
        },
      );

      debugPrint('Escrow locked for order: $orderId, Total: ৳${order.totalAmount}');
      return orderId;
    } catch (e) {
      debugPrint('Error locking escrow order: $e');
      return null;
    }
  }

  /// Release Escrow funds upon successful Delivery OTP verification
  Future<Map<String, dynamic>> releaseEscrowFunds({
    required String orderId,
    required String enteredOtp,
    String? verifiedByDriverId,
  }) async {
    try {
      final orderDoc = await _firestore.collection(_ordersCollection).doc(orderId).get();

      if (!orderDoc.exists) {
        return {'success': false, 'message': 'অর্ডারটি পাওয়া যায়নি।'};
      }

      final data = orderDoc.data()!;
      final correctOtp = data['deliveryOtp']?.toString().trim();
      final escrowStatus = data['escrowStatus']?.toString();

      if (escrowStatus == 'released') {
        return {'success': false, 'message': 'এই অর্ডারের পেমেন্ট ইতিমধ্যে রিলিজ করা হয়েছে।'};
      }

      if (correctOtp != enteredOtp.trim()) {
        return {
          'success': false,
          'message': 'ভুল ওটিপি কোড! ক্রেতার কাছ থেকে সঠিক ৪-সংখ্যার ডেলিভারি ওটিপি নিন।'
        };
      }

      final double totalAmount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
      final double farmerPayout = (data['farmerPayout'] as num?)?.toDouble() ?? (totalAmount * 0.97);
      final double platformFee = (data['platformFee'] as num?)?.toDouble() ?? (totalAmount * 0.03);
      final double driverFare = (data['driverFare'] as num?)?.toDouble() ?? 0.0;
      final String farmerId = data['farmerId'] ?? '';
      final String driverId = verifiedByDriverId ?? data['driverId'] ?? '';
      final String productName = data['productName'] ?? 'Product';
      final String batchCode = data['batchCode'] ?? 'BATCH-BD-0000';

      // 1. Update Order Document Status
      await _firestore.collection(_ordersCollection).doc(orderId).update({
        'status': 'delivered',
        'statusStep': 4,
        'escrowStatus': 'released',
        'transportStatus': 'সফলভাবে ডেলিভারি ও পেমেন্ট রিলিজ সম্পন্ন হয়েছে ✅',
        'completedAt': FieldValue.serverTimestamp(),
      });

      // 2. Credit Farmer Wallet & Remove Pending Balance
      if (farmerId.isNotEmpty) {
        await _firestore.collection(_usersCollection).doc(farmerId).set({
          'walletBalance': FieldValue.increment(farmerPayout),
          'pendingBalance': FieldValue.increment(-farmerPayout),
          'totalOrders': FieldValue.increment(1),
          'totalRevenue': FieldValue.increment(farmerPayout),
        }, SetOptions(merge: true));

        await _transactionService.addTransaction(
          id: '',
          userId: farmerId,
          type: TransactionType.credit,
          amount: farmerPayout,
          title: 'বিক্রয়মূল্য প্রাপ্তি 🌾',
          description: '$productName ($batchCode) সফল ডেলিভারির পর ৯৭% নেট মূল্য ওয়ালেটে যোগ হয়েছে।',
          relatedId: orderId,
          relatedType: 'farmer_payout',
          status: 'completed',
        );
      }

      // 3. Credit Driver Wallet (if transport exists)
      if (driverId.isNotEmpty && driverFare > 0) {
        await _firestore.collection(_usersCollection).doc(driverId).set({
          'walletBalance': FieldValue.increment(driverFare),
          'pendingBalance': FieldValue.increment(-driverFare),
          'totalTrips': FieldValue.increment(1),
        }, SetOptions(merge: true));

        await _transactionService.addTransaction(
          id: '',
          userId: driverId,
          type: TransactionType.credit,
          amount: driverFare,
          title: 'ট্রিপ ভাড়া প্রাপ্তি 🚚',
          description: 'অর্ডার #$batchCode সফল ডেলিভারির ভাড়া ওয়ালেটে জমা হয়েছে।',
          relatedId: orderId,
          relatedType: 'driver_trip_fare',
          status: 'completed',
        );
      }

      // 4. Log Platform Revenue (Profit for you/admin)
      await _firestore.collection(_platformRevenueCollection).add({
        'orderId': orderId,
        'batchCode': batchCode,
        'platformFee': platformFee,
        'totalOrderAmount': totalAmount,
        'farmerPayout': farmerPayout,
        'driverFare': driverFare,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'marketplace_commission',
      });

      // Credit Admin Master Account
      await _firestore.collection(_usersCollection).doc(_adminUserId).set({
        'walletBalance': FieldValue.increment(platformFee),
        'totalPlatformCommission': FieldValue.increment(platformFee),
      }, SetOptions(merge: true));

      return {
        'success': true,
        'message': 'অভিনন্দন! ডেলিভারি ওটিপি যাচাই সফল হয়েছে এবং সবার টাকা স্বয়ংক্রিয়ভাবে ওয়ালেটে পৌঁছে গেছে।',
        'farmerPayout': farmerPayout,
        'platformFee': platformFee,
        'driverFare': driverFare,
      };
    } catch (e) {
      debugPrint('Error releasing escrow funds: $e');
      return {'success': false, 'message': 'পেমেন্ট রিলিজ করতে সমস্যা হয়েছে: $e'};
    }
  }

  /// Refund Escrow Funds to Buyer in case of dispute/damage
  Future<bool> refundEscrowOrder({
    required String orderId,
    required String reason,
  }) async {
    try {
      final orderDoc = await _firestore.collection(_ordersCollection).doc(orderId).get();
      if (!orderDoc.exists) return false;

      final data = orderDoc.data()!;
      final double totalAmount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
      final double farmerPayout = (data['farmerPayout'] as num?)?.toDouble() ?? 0.0;
      final String buyerId = data['buyerId'] ?? '';
      final String farmerId = data['farmerId'] ?? '';

      // Update Order
      await _firestore.collection(_ordersCollection).doc(orderId).update({
        'status': 'cancelled',
        'escrowStatus': 'refunded',
        'transportStatus': 'অর্ডার বাতিল ও রিফান্ড প্রদান করা হয়েছে ↩️',
        'cancelReason': reason,
      });

      // Refund Buyer
      if (buyerId.isNotEmpty && totalAmount > 0) {
        await _firestore.collection(_usersCollection).doc(buyerId).set({
          'walletBalance': FieldValue.increment(totalAmount),
        }, SetOptions(merge: true));

        await _transactionService.addTransaction(
          id: '',
          userId: buyerId,
          type: TransactionType.refund,
          amount: totalAmount,
          title: 'এস্ক্রো রিফান্ড ↩️',
          description: 'বাতিলকৃত অর্ডার #$orderId-এর রিফান্ড ওয়ালেটে ফেরত দেওয়া হয়েছে। কারণ: $reason',
          relatedId: orderId,
          relatedType: 'escrow_refund',
          status: 'completed',
        );
      }

      // Decrement Farmer Pending
      if (farmerId.isNotEmpty && farmerPayout > 0) {
        await _firestore.collection(_usersCollection).doc(farmerId).set({
          'pendingBalance': FieldValue.increment(-farmerPayout),
        }, SetOptions(merge: true));
      }

      return true;
    } catch (e) {
      debugPrint('Error refunding escrow order: $e');
      return false;
    }
  }
}
