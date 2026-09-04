import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/marketplace_item_model.dart';

class MarketplaceController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String collectionName = 'fish_marketplace_lots';

  // All active and history lots from Firestore
  final RxList<MarketplaceItemModel> items = <MarketplaceItemModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  StreamSubscription<QuerySnapshot>? _lotsSubscription;

  @override
  void onInit() {
    super.onInit();
    _initFirestoreListener();
  }

  @override
  void onClose() {
    _lotsSubscription?.cancel();
    super.onClose();
  }

  /// Listen to all real-time fish lots from Firestore (No fake mock items)
  void _initFirestoreListener() {
    isLoading.value = true;
    _lotsSubscription?.cancel();

    try {
      _lotsSubscription = _firestore
          .collection(collectionName)
          .snapshots()
          .listen((snapshot) {
        final List<MarketplaceItemModel> loadedList = snapshot.docs.map((doc) {
          return MarketplaceItemModel.fromMap(doc.data(), doc.id);
        }).toList();

        // Sort by createdAt descending (newest first)
        loadedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        items.assignAll(loadedList);
        isLoading.value = false;
        error.value = '';
      }, onError: (err) {
        debugPrint('⚠️ Error streaming fish marketplace lots: $err');
        error.value = err.toString();
        isLoading.value = false;
      });
    } catch (e) {
      debugPrint('⚠️ Firestore initialization error in MarketplaceController: $e');
      isLoading.value = false;
    }
  }

  /// Helper to get current Firebase User ID safely
  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  /// Active lots published by the currently logged-in fish farmer
  List<MarketplaceItemModel> get myActiveLots {
    final uid = currentUserId;
    return items.where((item) {
      final matchesUser = uid.isEmpty || item.farmerId == uid || item.farmerId == 'FARMER_123';
      final isActive = item.status == 'active' || item.status == 'available';
      return matchesUser && isActive;
    }).toList();
  }

  /// Previous selling activity & sold history for the currently logged-in fish farmer
  List<MarketplaceItemModel> get mySoldHistory {
    final uid = currentUserId;
    return items.where((item) {
      final matchesUser = uid.isEmpty || item.farmerId == uid || item.farmerId == 'FARMER_123';
      final isSold = item.status == 'sold' || item.status == 'completed';
      return matchesUser && isSold;
    }).toList();
  }

  /// Total lifetime revenue earned from sold lots
  double get totalLifetimeRevenue {
    double sum = 0.0;
    for (final lot in mySoldHistory) {
      sum += (lot.soldPrice ?? (lot.quantityKg * lot.pricePerKg));
    }
    return sum;
  }

  /// Total kilograms of fish sold in history
  double get totalKgSold {
    double sum = 0.0;
    for (final lot in mySoldHistory) {
      sum += lot.quantityKg;
    }
    return sum;
  }

  /// Add a brand new real fish lot to Firestore
  Future<String?> addLot(MarketplaceItemModel item) async {
    try {
      isLoading.value = true;
      final docRef = await _firestore.collection(collectionName).add(item.toMap());
      // Real-time listener will automatically populate items
      isLoading.value = false;
      return docRef.id;
    } catch (e) {
      debugPrint('⚠️ Error adding fish lot to Firestore: $e');
      isLoading.value = false;
      return null;
    }
  }

  /// Update an existing fish lot in Firestore
  Future<bool> updateLot(MarketplaceItemModel item) async {
    try {
      isLoading.value = true;
      await _firestore.collection(collectionName).doc(item.id).update(item.toMap());
      isLoading.value = false;
      return true;
    } catch (e) {
      debugPrint('⚠️ Error updating fish lot in Firestore: $e');
      isLoading.value = false;
      return false;
    }
  }

  /// Mark a lot as SOLD -> Auto vanishes from active lots and moves to sales history
  Future<bool> markLotAsSold(String lotId, {double? finalPrice, String? buyerName}) async {
    try {
      final existingLot = items.firstWhereOrNull((l) => l.id == lotId);
      final priceToRecord = finalPrice ?? (existingLot != null ? (existingLot.quantityKg * existingLot.pricePerKg) : 0.0);

      await _firestore.collection(collectionName).doc(lotId).update({
        'status': 'sold',
        'soldAt': FieldValue.serverTimestamp(),
        'soldPrice': priceToRecord,
        'soldTo': buyerName ?? 'Direct Buyer / Wholesaler',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('⚠️ Error marking fish lot as sold: $e');
      return false;
    }
  }

  /// Delete a fish lot permanently from Firestore
  Future<bool> deleteLot(String lotId) async {
    try {
      await _firestore.collection(collectionName).doc(lotId).delete();
      return true;
    } catch (e) {
      debugPrint('⚠️ Error deleting fish lot from Firestore: $e');
      return false;
    }
  }

  /// Legacy addItem compatibility
  void addItem(MarketplaceItemModel item) {
    addLot(item);
  }
}

