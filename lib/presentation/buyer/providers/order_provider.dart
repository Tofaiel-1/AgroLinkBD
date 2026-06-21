import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agrolinkbd/presentation/buyer/models/order_model.dart';

final ordersCollectionRef = FirebaseFirestore.instance.collection('orders');
final currentBuyerIdProvider = StateProvider<String>((ref) => '');

// Fetch all orders for current buyer
final buyerOrdersProvider = FutureProvider<List<BuyerOrderModel>>((ref) async {
  try {
    final buyerId = ref.watch(currentBuyerIdProvider);
    if (buyerId.isEmpty) return [];

    final snapshot = await ordersCollectionRef
        .where('buyerId', isEqualTo: buyerId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => BuyerOrderModel.fromMap(doc.data()))
        .toList();
  } catch (e) {
    throw Exception('Failed to fetch orders: $e');
  }
});

// Fetch active orders (pending, confirmed, packed, shipped)
final activeOrdersProvider = FutureProvider<List<BuyerOrderModel>>((ref) async {
  try {
    final buyerId = ref.watch(currentBuyerIdProvider);
    if (buyerId.isEmpty) return [];

    final snapshot = await ordersCollectionRef
        .where('buyerId', isEqualTo: buyerId)
        .where('orderStatus',
            whereIn: ['pending', 'confirmed', 'packed', 'shipped'])
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => BuyerOrderModel.fromMap(doc.data()))
        .toList();
  } catch (e) {
    throw Exception('Failed to fetch active orders: $e');
  }
});

// Fetch completed orders
final completedOrdersProvider =
    FutureProvider<List<BuyerOrderModel>>((ref) async {
  try {
    final buyerId = ref.watch(currentBuyerIdProvider);
    if (buyerId.isEmpty) return [];

    final snapshot = await ordersCollectionRef
        .where('buyerId', isEqualTo: buyerId)
        .where('orderStatus', isEqualTo: 'delivered')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => BuyerOrderModel.fromMap(doc.data()))
        .toList();
  } catch (e) {
    throw Exception('Failed to fetch completed orders: $e');
  }
});

// Fetch cancelled orders
final cancelledOrdersProvider =
    FutureProvider<List<BuyerOrderModel>>((ref) async {
  try {
    final buyerId = ref.watch(currentBuyerIdProvider);
    if (buyerId.isEmpty) return [];

    final snapshot = await ordersCollectionRef
        .where('buyerId', isEqualTo: buyerId)
        .where('orderStatus', isEqualTo: 'cancelled')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => BuyerOrderModel.fromMap(doc.data()))
        .toList();
  } catch (e) {
    throw Exception('Failed to fetch cancelled orders: $e');
  }
});

// Fetch single order details
final orderDetailsProvider =
    FutureProvider.family<BuyerOrderModel, String>((ref, orderId) async {
  try {
    final doc = await ordersCollectionRef.doc(orderId).get();
    if (doc.exists) {
      return BuyerOrderModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    throw Exception('Order not found');
  } catch (e) {
    throw Exception('Failed to fetch order: $e');
  }
});

// Create new order
final createOrderProvider =
    FutureProvider.family<BuyerOrderModel, BuyerOrderModel>((ref, order) async {
  try {
    final newOrderRef = ordersCollectionRef.doc();

    // Create order map with new ID
    final orderMap = order.toMap();
    orderMap['id'] = newOrderRef.id;

    await newOrderRef.set(orderMap);
    ref.invalidate(buyerOrdersProvider);

    // Return the created order with new ID
    return BuyerOrderModel.fromMap(orderMap);
  } catch (e) {
    throw Exception('Failed to create order: $e');
  }
});

// Cancel order
final cancelOrderProvider =
    FutureProvider.family<void, String>((ref, orderId) async {
  try {
    await ordersCollectionRef.doc(orderId).update({'orderStatus': 'cancelled'});
    ref.invalidate(buyerOrdersProvider);
  } catch (e) {
    throw Exception('Failed to cancel order: $e');
  }
});

// Update order status (admin/system only, but included for tracking)
final updateOrderStatusProvider =
    FutureProvider.family<void, ({String orderId, String status})>(
        (ref, params) async {
  try {
    await ordersCollectionRef
        .doc(params.orderId)
        .update({'orderStatus': params.status});
    ref.invalidate(buyerOrdersProvider);
  } catch (e) {
    throw Exception('Failed to update order: $e');
  }
});

// Track order location (for active deliveries)
final orderTrackingProvider =
    StreamProvider.family<BuyerOrderModel, String>((ref, orderId) {
  return ordersCollectionRef.doc(orderId).snapshots().map((doc) {
    if (doc.exists) {
      return BuyerOrderModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    throw Exception('Order not found');
  });
});

// Search orders
final searchOrdersProvider =
    FutureProvider.family<List<BuyerOrderModel>, String>((ref, query) async {
  try {
    final buyerId = ref.watch(currentBuyerIdProvider);
    if (buyerId.isEmpty) return [];

    final snapshot =
        await ordersCollectionRef.where('buyerId', isEqualTo: buyerId).get();

    final allOrders = snapshot.docs
        .map((doc) => BuyerOrderModel.fromMap(doc.data()))
        .toList();

    return allOrders
        .where((order) =>
            order.id.toLowerCase().contains(query.toLowerCase()) ||
            order.farmerName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  } catch (e) {
    throw Exception('Failed to search orders: $e');
  }
});
