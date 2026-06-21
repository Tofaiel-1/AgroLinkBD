import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ProductModel> _products = [];
  List<ProductModel> _myProducts = [];
  bool _isLoading = false;
  String? _error;

  List<ProductModel> get products => _products;
  List<ProductModel> get myProducts => _myProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all products
  Future<void> loadProducts({
    ProductCategory? category,
    String? searchQuery,
    String? district,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Query query = _firestore
          .collection('products')
          .where('status', isEqualTo: ProductStatus.available.toString());

      if (category != null) {
        query = query.where('category', isEqualTo: category.toString());
      }

      if (district != null) {
        query = query.where('district', isEqualTo: district);
      }

      QuerySnapshot snapshot = await query
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      _products = snapshot.docs
          .map(
            (doc) => ProductModel.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();

      // Filter by search query if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        _products = _products
            .where(
              (p) =>
                  p.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  p.description.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ),
            )
            .toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load my products
  Future<void> loadMyProducts(String sellerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();

      _myProducts = snapshot.docs
          .map(
            (doc) => ProductModel.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Add product
  Future<void> addProduct(ProductModel product) async {
    try {
      await _firestore
          .collection('products')
          .doc(product.id)
          .set(product.toJson());
      _myProducts.insert(0, product);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Update product
  Future<void> updateProduct(ProductModel product) async {
    try {
      await _firestore
          .collection('products')
          .doc(product.id)
          .update(product.toJson());

      int index = _myProducts.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _myProducts[index] = product;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      _myProducts.removeWhere((p) => p.id == productId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Toggle favorite
  Future<void> toggleFavorite(String productId, String userId) async {
    try {
      DocumentReference userDoc = _firestore.collection('users').doc(userId);
      DocumentSnapshot userSnapshot = await userDoc.get();

      List<String> favorites = [];
      if (userSnapshot.exists) {
        Map<String, dynamic> data = userSnapshot.data() as Map<String, dynamic>;
        favorites = List<String>.from(data['favorites'] ?? []);
      }

      if (favorites.contains(productId)) {
        favorites.remove(productId);
        await _firestore.collection('products').doc(productId).update({
          'favorites': FieldValue.increment(-1),
        });
      } else {
        favorites.add(productId);
        await _firestore.collection('products').doc(productId).update({
          'favorites': FieldValue.increment(1),
        });
      }

      await userDoc.set({'favorites': favorites}, SetOptions(merge: true));
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Increment views
  Future<void> incrementViews(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'views': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing views: $e');
    }
  }

  // Get featured products
  List<ProductModel> get featuredProducts {
    return _products.where((p) => p.isFeatured).toList();
  }

  // Get organic products
  List<ProductModel> get organicProducts {
    return _products.where((p) => p.isOrganic).toList();
  }
}
