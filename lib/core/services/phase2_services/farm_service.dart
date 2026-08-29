import 'package:agrolinkbd/core/models/phase2_models/farm_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/controllers/user_controller.dart';

/// Service for managing farm operations with Firestore
class FarmService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId {
    if (_auth.currentUser?.uid != null && _auth.currentUser!.uid.isNotEmpty) {
      return _auth.currentUser!.uid;
    }
    try {
      if (Get.isRegistered<UserController>()) {
        final uc = Get.find<UserController>();
        if (uc.userId.isNotEmpty) return uc.userId;
      }
    } catch (_) {}
    return 'farmer_demo';
  }

  /// Get a real-time stream of all farms for current farmer
  Stream<List<Farm>> getFarmsStream() {
    final uid = currentUserId;
    if (uid == null || uid.isEmpty) return Stream.value([]);

    return _firestore
        .collection('farms')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Farm.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get all farms for current farmer (one-time fetch)
  Future<List<Farm>> getFarms() async {
    final uid = currentUserId;
    if (uid == null || uid.isEmpty) return [];

    try {
      final snapshot = await _firestore
          .collection('farms')
          .where('userId', isEqualTo: uid)
          .get();

      return snapshot.docs
          .map((doc) => Farm.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting farms: $e');
      return [];
    }
  }

  /// Create a new farm
  Future<Farm?> createFarm(Farm farm) async {
    final uid = currentUserId;
    if (uid == null || uid.isEmpty) return null;

    try {
      // Ensure the farm is created with the correct userId
      final farmData = farm.toMap();
      farmData['userId'] = uid;

      final docRef = await _firestore.collection('farms').add(farmData);
      
      return Farm.fromMap(farmData, docRef.id);
    } catch (e) {
      print('Error creating farm: $e');
      return null;
    }
  }

  /// Update an existing farm
  Future<void> updateFarm(Farm farm) async {
    try {
      await _firestore.collection('farms').doc(farm.id).update(farm.toMap());
    } catch (e) {
      print('Error updating farm: $e');
    }
  }

  /// Delete an existing farm
  Future<void> deleteFarm(String farmId) async {
    try {
      await _firestore.collection('farms').doc(farmId).delete();
    } catch (e) {
      print('Error deleting farm: $e');
    }
  }

  /// Get a real-time stream of all crop plantings for current farmer
  Stream<List<CropPlanting>> getCropPlantingsStream() {
    final uid = currentUserId;
    if (uid == null || uid.isEmpty) return Stream.value([]);

    return _firestore
        .collection('crop_plantings')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CropPlanting.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get crop plantings for a farm
  Future<List<CropPlanting>> getCropPlannings(String farmId) async {
    try {
      final snapshot = await _firestore
          .collection('crop_plantings')
          .where('farmId', isEqualTo: farmId)
          .get();

      return snapshot.docs
          .map((doc) => CropPlanting.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting crop plantings: $e');
      return [];
    }
  }

  /// Add a new crop planting
  Future<void> addCropPlanting(CropPlanting planting) async {
    final uid = currentUserId;
    if (uid == null || uid.isEmpty) return;
    try {
      final data = planting.toMap();
      data['userId'] = uid;
      await _firestore.collection('crop_plantings').add(data);
    } catch (e) {
      print('Error adding crop planting: $e');
    }
  }

  /// Delete a crop planting
  Future<void> deleteCropPlanting(String plantingId) async {
    try {
      await _firestore.collection('crop_plantings').doc(plantingId).delete();
    } catch (e) {
      print('Error deleting crop planting: $e');
    }
  }

  /// Get farm activities log
  Future<List<FarmActivity>> getFarmActivities(String farmId) async {
    try {
      final snapshot = await _firestore
          .collection('farm_activities')
          .where('farmId', isEqualTo: farmId)
          .get();

      final list = snapshot.docs
          .map((doc) => FarmActivity.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    } catch (e) {
      print('Error getting farm activities: $e');
      return [];
    }
  }

  /// Log a farm activity
  Future<void> logFarmActivity(FarmActivity activity) async {
    try {
      await _firestore.collection('farm_activities').add(activity.toMap());
    } catch (e) {
      print('Error logging farm activity: $e');
    }
  }

  /// Get a real-time stream of all farm expenses for current farmer
  Stream<List<FarmExpense>> getExpensesStream() {
    final uid = currentUserId;
    if (uid == null || uid.isEmpty) return Stream.value([]);

    return _firestore
        .collection('farm_expenses')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => FarmExpense.fromMap(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => b.date.compareTo(a.date));
          return list;
        });
  }

  /// Add a new expense
  Future<void> addExpense(FarmExpense expense) async {
    final uid = currentUserId;
    if (uid == null || uid.isEmpty) return;
    try {
      final data = expense.toMap();
      data['userId'] = uid;
      await _firestore.collection('farm_expenses').add(data);
    } catch (e) {
      print('Error adding farm expense: $e');
    }
  }

  /// Delete an expense
  Future<void> deleteExpense(String expenseId) async {
    try {
      await _firestore.collection('farm_expenses').doc(expenseId).delete();
    } catch (e) {
      print('Error deleting farm expense: $e');
    }
  }

  /// Get a real-time stream of all farm revenues for current farmer
  Stream<List<FarmRevenue>> getRevenuesStream() {
    final uid = currentUserId;
    if (uid == null || uid.isEmpty) return Stream.value([]);

    return _firestore
        .collection('farm_revenues')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => FarmRevenue.fromMap(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => b.date.compareTo(a.date));
          return list;
        });
  }

  /// Add a new revenue
  Future<void> addRevenue(FarmRevenue revenue) async {
    final uid = currentUserId;
    if (uid == null || uid.isEmpty) return;
    try {
      final data = revenue.toMap();
      data['userId'] = uid;
      await _firestore.collection('farm_revenues').add(data);
    } catch (e) {
      print('Error adding farm revenue: $e');
    }
  }

  /// Delete a revenue
  Future<void> deleteRevenue(String revenueId) async {
    try {
      await _firestore.collection('farm_revenues').doc(revenueId).delete();
    } catch (e) {
      print('Error deleting farm revenue: $e');
    }
  }

  /// Get a real-time stream of all farm inventory for current farmer
  Stream<List<FarmInventoryItem>> getInventoryStream() {
    final uid = currentUserId;
    if (uid == null || uid.isEmpty) return Stream.value([]);

    return _firestore
        .collection('farm_inventory')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FarmInventoryItem.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Add a new inventory item
  Future<void> addInventoryItem(FarmInventoryItem item) async {
    final uid = currentUserId;
    if (uid == null || uid.isEmpty) return;
    try {
      final data = item.toMap();
      data['userId'] = uid;
      await _firestore.collection('farm_inventory').add(data);
    } catch (e) {
      print('Error adding farm inventory item: $e');
    }
  }

  /// Update an existing inventory item
  Future<void> updateInventoryItem(FarmInventoryItem item) async {
    try {
      await _firestore.collection('farm_inventory').doc(item.id).update(item.toMap());
    } catch (e) {
      print('Error updating inventory item: $e');
    }
  }

  /// Delete an existing inventory item
  Future<void> deleteInventoryItem(String itemId) async {
    try {
      await _firestore.collection('farm_inventory').doc(itemId).delete();
    } catch (e) {
      print('Error deleting inventory item: $e');
    }
  }
}
