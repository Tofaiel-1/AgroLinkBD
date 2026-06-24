import 'package:agrolinkbd/core/models/phase2_models/farm_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service for managing farm operations with Firestore
class FarmService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  /// Get a real-time stream of all farms for current farmer
  Stream<List<Farm>> getFarmsStream() {
    if (currentUserId == null) return const Stream.empty();

    return _firestore
        .collection('farms')
        .where('userId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Farm.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Get all farms for current farmer (one-time fetch)
  Future<List<Farm>> getFarms() async {
    if (currentUserId == null) return [];

    try {
      final snapshot = await _firestore
          .collection('farms')
          .where('userId', isEqualTo: currentUserId)
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
    if (currentUserId == null) return null;

    try {
      // Ensure the farm is created with the correct userId
      final farmData = farm.toMap();
      farmData['userId'] = currentUserId;

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
    if (currentUserId == null) return const Stream.empty();

    return _firestore
        .collection('crop_plantings')
        .where('userId', isEqualTo: currentUserId)
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
    if (currentUserId == null) return;
    try {
      final data = planting.toMap();
      data['userId'] = currentUserId;
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
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FarmActivity.fromMap(doc.data(), doc.id))
          .toList();
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
    if (currentUserId == null) return const Stream.empty();

    return _firestore
        .collection('farm_expenses')
        .where('userId', isEqualTo: currentUserId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FarmExpense.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Add a new expense
  Future<void> addExpense(FarmExpense expense) async {
    if (currentUserId == null) return;
    try {
      final data = expense.toMap();
      data['userId'] = currentUserId;
      await _firestore.collection('farm_expenses').add(data);
    } catch (e) {
      print('Error adding farm expense: $e');
    }
  }

  /// Get a real-time stream of all farm revenues for current farmer
  Stream<List<FarmRevenue>> getRevenuesStream() {
    if (currentUserId == null) return const Stream.empty();

    return _firestore
        .collection('farm_revenues')
        .where('userId', isEqualTo: currentUserId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FarmRevenue.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Add a new revenue
  Future<void> addRevenue(FarmRevenue revenue) async {
    if (currentUserId == null) return;
    try {
      final data = revenue.toMap();
      data['userId'] = currentUserId;
      await _firestore.collection('farm_revenues').add(data);
    } catch (e) {
      print('Error adding farm revenue: $e');
    }
  }

  /// Get a real-time stream of all farm inventory for current farmer
  Stream<List<FarmInventoryItem>> getInventoryStream() {
    if (currentUserId == null) return const Stream.empty();

    return _firestore
        .collection('farm_inventory')
        .where('userId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FarmInventoryItem.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Add a new inventory item
  Future<void> addInventoryItem(FarmInventoryItem item) async {
    if (currentUserId == null) return;
    try {
      final data = item.toMap();
      data['userId'] = currentUserId;
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
