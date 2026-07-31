import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agrolinkbd/core/models/cart_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _cartItems = [];
  String? _currentUserId;
  bool _isLoading = false;

  List<CartItem> get items => _cartItems;
  int get itemCount => _cartItems.length;
  bool get isLoading => _isLoading;

  double get totalPrice =>
      _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  CartProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && user.uid != _currentUserId) {
        _currentUserId = user.uid;
        loadUserCart(user.uid);
      } else if (user == null) {
        _currentUserId = null;
        _cartItems.clear();
        notifyListeners();
      }
    });

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _currentUserId = currentUser.uid;
      loadUserCart(currentUser.uid);
    }
  }

  Future<void> loadUserCart(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Try loading from SharedPreferences first for instant UI response
      final prefs = await SharedPreferences.getInstance();
      final localJson = prefs.getString('cart_$userId');
      if (localJson != null && localJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(localJson);
        _cartItems.clear();
        for (var itemMap in decoded) {
          _cartItems.add(CartItem.fromJson(Map<String, dynamic>.from(itemMap)));
        }
        notifyListeners();
      }

      // 2. Fetch authoritative cart from Firebase Firestore
      final doc = await FirebaseFirestore.instance
          .collection('user_carts')
          .doc(userId)
          .get();

      if (doc.exists && doc.data()?['items'] != null) {
        final List<dynamic> firestoreItems = doc.data()!['items'];
        _cartItems.clear();
        for (var itemMap in firestoreItems) {
          _cartItems.add(CartItem.fromJson(Map<String, dynamic>.from(itemMap)));
        }
        debugPrint('✅ User cart loaded from Firebase user_carts: ${_cartItems.length} items');
      } else {
        // Fallback: check inside the users/{userId} doc
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        if (userDoc.exists && userDoc.data()?['cart'] != null) {
          final List<dynamic> userCartItems = userDoc.data()!['cart'];
          _cartItems.clear();
          for (var itemMap in userCartItems) {
            _cartItems.add(CartItem.fromJson(Map<String, dynamic>.from(itemMap)));
          }
          debugPrint('✅ User cart loaded from Firebase users doc: ${_cartItems.length} items');
        }
      }

      // 3. If there was a guest cart saved before login, merge it now
      final guestJson = prefs.getString('guest_cart');
      if (guestJson != null && guestJson.isNotEmpty) {
        final List<dynamic> guestItems = jsonDecode(guestJson);
        for (var itemMap in guestItems) {
          final item = CartItem.fromJson(Map<String, dynamic>.from(itemMap));
          _addOrMergeItemWithoutSave(item);
        }
        await prefs.remove('guest_cart');
        _saveCartToFirebaseAndLocal();
      } else {
        // Keep local cache synced with Firebase authoritative list
        _saveLocalCacheOnly();
      }
    } catch (e) {
      debugPrint('⚠️ Error loading cart from Firebase: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _addOrMergeItemWithoutSave(CartItem item) {
    final existingIndex = _cartItems.indexWhere((i) => i.id == item.id);
    final String nowIso = DateTime.now().toIso8601String();

    if (existingIndex >= 0) {
      final existingItem = _cartItems[existingIndex];
      final Map<String, dynamic> updatedMetadata =
          Map<String, dynamic>.from(existingItem.metadata);

      List<String> history = [];
      if (updatedMetadata['history'] is List) {
        history = List<String>.from(updatedMetadata['history'] as List);
      } else if (updatedMetadata['addedAt'] != null) {
        history.add(updatedMetadata['addedAt'].toString());
      }
      history.add(nowIso);

      updatedMetadata['history'] = history;
      updatedMetadata['lastAddedAt'] = nowIso;

      _cartItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + item.quantity,
        metadata: updatedMetadata,
      );
    } else {
      final Map<String, dynamic> updatedMetadata =
          Map<String, dynamic>.from(item.metadata);
      if (updatedMetadata['addedAt'] == null) {
        updatedMetadata['addedAt'] = nowIso;
      }
      if (updatedMetadata['history'] == null) {
        updatedMetadata['history'] = [updatedMetadata['addedAt'] ?? nowIso];
      }
      updatedMetadata['lastAddedAt'] = nowIso;

      _cartItems.add(item.copyWith(metadata: updatedMetadata));
    }
  }

  void addToCart(CartItem item) {
    _addOrMergeItemWithoutSave(item);
    debugPrint('✅ Added to cart: ${item.title} (Quantity: ${item.quantity})');
    notifyListeners();
    _saveCartToFirebaseAndLocal();
  }

  void removeFromCart(String id) {
    _cartItems.removeWhere((item) => item.id == id);
    debugPrint('❌ Removed from cart: $id');
    notifyListeners();
    _saveCartToFirebaseAndLocal();
  }

  void updateQuantity(String id, double quantity) {
    final index = _cartItems.indexWhere((i) => i.id == id);
    if (index >= 0) {
      if (quantity <= 0.0) {
        removeFromCart(id);
      } else {
        _cartItems[index] = _cartItems[index].copyWith(quantity: quantity);
        notifyListeners();
        _saveCartToFirebaseAndLocal();
      }
    }
  }

  void clearCart() {
    _cartItems.clear();
    debugPrint('🗑️ Cart cleared');
    notifyListeners();
    _saveCartToFirebaseAndLocal();
  }

  double getQuantity(String id) {
    try {
      return _cartItems.firstWhere((i) => i.id == id).quantity;
    } catch (e) {
      return 0.0;
    }
  }

  bool isInCart(String id) {
    return _cartItems.any((item) => item.id == id);
  }

  Map<String, List<CartItem>> groupBySource() {
    final Map<String, List<CartItem>> grouped = {};
    for (var item in _cartItems) {
      if (grouped[item.sellerId] == null) {
        grouped[item.sellerId] = [];
      }
      grouped[item.sellerId]!.add(item);
    }
    return grouped;
  }

  Future<void> _saveCartToFirebaseAndLocal() async {
    final jsonList = _cartItems.map((e) => e.toJson()).toList();
    final prefs = await SharedPreferences.getInstance();

    final userId = _currentUserId ?? FirebaseAuth.instance.currentUser?.uid;
    if (userId != null && userId.isNotEmpty) {
      // 1. Save to SharedPreferences
      await prefs.setString('cart_$userId', jsonEncode(jsonList));

      // 2. Save to user_carts collection in Firestore
      try {
        await FirebaseFirestore.instance
            .collection('user_carts')
            .doc(userId)
            .set({
          'items': jsonList,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // 3. Also update users collection doc so all user data stays together
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'cart': jsonList,
          'cartUpdatedAt': FieldValue.serverTimestamp(),
        }).catchError((_) {});
      } catch (e) {
        debugPrint('⚠️ Could not sync cart to Firebase: $e');
      }
    } else {
      // Save as guest cart in SharedPreferences
      await prefs.setString('guest_cart', jsonEncode(jsonList));
    }
  }

  Future<void> _saveLocalCacheOnly() async {
    final userId = _currentUserId ?? FirebaseAuth.instance.currentUser?.uid;
    if (userId != null && userId.isNotEmpty) {
      final jsonList = _cartItems.map((e) => e.toJson()).toList();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cart_$userId', jsonEncode(jsonList));
    }
  }
}
