import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Add product
  Future<String?> addProduct({
    required String name,
    required String category,
    required double price,
    required String unit,
    required String description,
    required String location,
    required String sellerId,
    File? image,
  }) async {
    try {
      String? imageUrl;

      if (image != null) {
        // Upload image
        String fileName =
            'products/${DateTime.now().millisecondsSinceEpoch}.jpg';
        TaskSnapshot snapshot = await _storage.ref(fileName).putFile(image);
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      DocumentReference ref = await _firestore.collection('products').add({
        'name': name,
        'category': category,
        'price': price,
        'unit': unit,
        'description': description,
        'location': location,
        'sellerId': sellerId,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'active',
        'views': 0,
        'likes': 0,
      });

      return ref.id;
    } catch (e) {
      debugPrint('Add product error: $e');
      return null;
    }
  }

  // Get products
  Stream<QuerySnapshot> getProducts({String? category}) {
    Query query = _firestore
        .collection('products')
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true);

    if (category != null && category != 'সকল') {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots();
  }

  // Get user products
  Stream<QuerySnapshot> getUserProducts(String userId) {
    return _firestore
        .collection('products')
        .where('sellerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'status': 'deleted',
      });
    } catch (e) {
      debugPrint('Delete product error: $e');
    }
  }
}
