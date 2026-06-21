import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CropService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add crop
  Future<String?> addCrop({
    required String userId,
    required String name,
    required String status,
    required String area,
    required DateTime plantedDate,
    required DateTime expectedHarvest,
  }) async {
    try {
      DocumentReference ref = await _firestore.collection('crops').add({
        'userId': userId,
        'name': name,
        'status': status,
        'area': area,
        'plantedDate': Timestamp.fromDate(plantedDate),
        'expectedHarvest': Timestamp.fromDate(expectedHarvest),
        'health': 100,
        'createdAt': FieldValue.serverTimestamp(),
        'tasks': [],
      });

      return ref.id;
    } catch (e) {
      debugPrint('Add crop error: $e');
      return null;
    }
  }

  // Get user crops
  Stream<QuerySnapshot> getUserCrops(String userId) {
    return _firestore
        .collection('crops')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Update crop
  Future<void> updateCrop(String cropId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('crops').doc(cropId).update(data);
    } catch (e) {
      debugPrint('Update crop error: $e');
    }
  }

  // Add task to crop
  Future<void> addTask(String cropId, Map<String, dynamic> task) async {
    try {
      await _firestore.collection('crops').doc(cropId).update({
        'tasks': FieldValue.arrayUnion([task]),
      });
    } catch (e) {
      debugPrint('Add task error: $e');
    }
  }
}
