import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:agrolinkbd/core/models/buyer_inventory_model.dart';

class BuyerInventoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'buyer_inventory';

  // Add an item to buyer inventory (usually called after a successful purchase)
  Future<String?> addToInventory(BuyerInventoryModel item) async {
    try {
      final docRef = await _firestore.collection(_collectionName).add(item.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding to buyer inventory: $e');
      return null;
    }
  }

  // Stream a buyer's inventory
  Stream<List<BuyerInventoryModel>> getInventoryByBuyerId(String buyerId) {
    return _firestore
        .collection(_collectionName)
        .where('buyerId', isEqualTo: buyerId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return BuyerInventoryModel.fromMap(doc.data(), doc.id);
      }).toList();
      // Sort by purchase date descending
      list.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
      return list;
    });
  }

  // Update market price for a specific inventory item
  Future<bool> updateMarketPrice(String inventoryId, double newMarketPrice) async {
    try {
      await _firestore.collection(_collectionName).doc(inventoryId).update({
        'currentMarketPrice': newMarketPrice,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('Error updating inventory market price: $e');
      return false;
    }
  }

  // Update inventory quantity (e.g. if buyer consumes/sells it)
  Future<bool> updateQuantity(String inventoryId, double newQuantity) async {
    if (newQuantity < 0) return false;
    
    try {
      await _firestore.collection(_collectionName).doc(inventoryId).update({
        'quantity': newQuantity,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('Error updating inventory quantity: $e');
      return false;
    }
  }

  // Get a single inventory item by ID
  Stream<BuyerInventoryModel?> getInventoryItemByIdStream(String inventoryId) {
    return _firestore
        .collection(_collectionName)
        .doc(inventoryId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return BuyerInventoryModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }
}
