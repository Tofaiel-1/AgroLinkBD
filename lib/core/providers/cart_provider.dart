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

    if (existingIndex >= 0) {
      // Increase quantity if item exists
      _cartItems[existingIndex] = _cartItems[existingIndex].copyWith(
          quantity: _cartItems[existingIndex].quantity + item.quantity);
    } else {
      // Add new item
      _cartItems.add(item);
    }

    debugPrint('✅ Added to cart: ${item.title} (Quantity: ${item.quantity})');
    notifyListeners();
  }

  void removeFromCart(String id) {
    _cartItems.removeWhere((item) => item.id == id);
    debugPrint('❌ Removed from cart: $id');
    notifyListeners();
  }

  void updateQuantity(String id, int quantity) {
    final index = _cartItems.indexWhere((i) => i.id == id);
    if (index >= 0) {
      if (quantity <= 0) {
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

  int getQuantity(String id) {
    try {
      return _cartItems.firstWhere((i) => i.id == id).quantity;
    } catch (e) {
      return 0;
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
