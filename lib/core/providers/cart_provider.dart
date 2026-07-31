import 'package:flutter/material.dart';
import 'package:agrolinkbd/core/models/cart_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _cartItems = [];

  List<CartItem> get items => _cartItems;

  int get itemCount => _cartItems.length;

  double get totalPrice =>
      _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  void addToCart(CartItem item) {
    // Check if item already exists in cart
    final existingIndex =
        _cartItems.indexWhere((i) => i.id == item.id);

    final String nowIso = DateTime.now().toIso8601String();

    if (existingIndex >= 0) {
      // Increase quantity and record timestamp in history ("kobe kobe add koresi")
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
      // Add new item with initial history timestamp
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

    debugPrint('✅ Added to cart: ${item.title} (Quantity: ${item.quantity})');
    notifyListeners();
  }

  void removeFromCart(String id) {
    _cartItems.removeWhere((item) => item.id == id);
    debugPrint('❌ Removed from cart: $id');
    notifyListeners();
  }

  void updateQuantity(String id, double quantity) {
    final index = _cartItems.indexWhere((i) => i.id == id);
    if (index >= 0) {
      if (quantity <= 0.0) {
        removeFromCart(id);
      } else {
        _cartItems[index] = _cartItems[index].copyWith(quantity: quantity);
        notifyListeners();
      }
    }
  }

  void clearCart() {
    _cartItems.clear();
    debugPrint('🗑️ Cart cleared');
    notifyListeners();
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

  // Group items by seller for checkout
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
}
