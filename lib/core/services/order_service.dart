import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agrolinkbd/core/models/order_model.dart';
import 'package:flutter/foundation.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'orders';

  // Create a new order
  Future<String?> createOrder(OrderModel order) async {
    try {
      final docRef = await _firestore.collection(_collectionName).add(order.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating order: $e');
      return null;
    }
  }

  // Stream orders for a specific buyer
  Stream<List<OrderModel>> getOrdersByBuyerId(String buyerId) {
    return _firestore
        .collection(_collectionName)
        .where('buyerId', isEqualTo: buyerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return OrderModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Stream orders for a specific farmer
  Stream<List<OrderModel>> getOrdersByFarmerId(String farmerId) {
    return _firestore
        .collection(_collectionName)
        .where('farmerId', isEqualTo: farmerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return OrderModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Update order status
  Future<bool> updateOrderStatus(String orderId, String newStatus, int step) async {
    try {
      await _firestore.collection(_collectionName).doc(orderId).update({
        'status': newStatus,
        'statusStep': step,
      });
      return true;
    } catch (e) {
      debugPrint('Error updating order status: $e');
      return false;
    }
  }

  Future<void> updateOrderRating(String orderId, double rating, String reviewText) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'rating': rating,
        'reviewText': reviewText,
      });
    } catch (e) {
      debugPrint('Error updating order rating: $e');
    }
  }
}
