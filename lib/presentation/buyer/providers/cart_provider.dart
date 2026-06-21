import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agrolinkbd/presentation/buyer/models/cart_model.dart';

final cartCollectionRef = FirebaseFirestore.instance.collection('carts');

// Cart items state provider
final cartItemsProvider = StateProvider<List<CartItemModel>>((ref) => []);

// Current buyer ID provider (should be connected to auth)
final currentBuyerIdProvider = StateProvider<String>((ref) => '');

// Fetch cart from Firestore
final cartProvider = FutureProvider<CartModel>((ref) async {
  try {
    final buyerId = ref.watch(currentBuyerIdProvider);
    if (buyerId.isEmpty) {
      return CartModel(
        id: '',
        buyerId: '',
        items: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    final snapshot =
        await cartCollectionRef.where('buyerId', isEqualTo: buyerId).get();
    if (snapshot.docs.isEmpty) {
      return CartModel(
        id: '',
        buyerId: buyerId,
        items: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    return CartModel.fromMap(snapshot.docs.first.data());
  } catch (e) {
    throw Exception('Failed to fetch cart: $e');
  }
});

// Add item to cart
final addToCartProvider =
    FutureProvider.family<void, CartItemModel>((ref, item) async {
  try {
    final buyerId = ref.watch(currentBuyerIdProvider);
    if (buyerId.isEmpty) throw Exception('User not authenticated');

    final cartSnapshot =
        await cartCollectionRef.where('buyerId', isEqualTo: buyerId).get();

    if (cartSnapshot.docs.isEmpty) {
      // Create new cart
      final newCart = CartModel(
        id: cartCollectionRef.doc().id,
        buyerId: buyerId,
        items: [item],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await cartCollectionRef.doc(newCart.id).set(newCart.toMap());
    } else {
      // Update existing cart
      final existingCart = CartModel.fromMap(cartSnapshot.docs.first.data());
      final existingItemIndex =
          existingCart.items.indexWhere((p) => p.productId == item.productId);

      List<CartItemModel> updatedItems;
      if (existingItemIndex >= 0) {
        // Update quantity
        updatedItems = List.from(existingCart.items);
        updatedItems[existingItemIndex] =
            updatedItems[existingItemIndex].copyWith(
          quantity: updatedItems[existingItemIndex].quantity + item.quantity,
        );
      } else {
        // Add new item
        updatedItems = [...existingCart.items, item];
      }

      final updatedCart = existingCart.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );

      await cartCollectionRef
          .doc(cartSnapshot.docs.first.id)
          .update(updatedCart.toMap());
    }

    ref.invalidate(cartProvider);
  } catch (e) {
    throw Exception('Failed to add to cart: $e');
  }
});

// Remove item from cart
final removeFromCartProvider =
    FutureProvider.family<void, String>((ref, itemId) async {
  try {
    final buyerId = ref.watch(currentBuyerIdProvider);
    if (buyerId.isEmpty) throw Exception('User not authenticated');

    final cartSnapshot =
        await cartCollectionRef.where('buyerId', isEqualTo: buyerId).get();
    if (cartSnapshot.docs.isNotEmpty) {
      final existingCart = CartModel.fromMap(cartSnapshot.docs.first.data());
      final updatedItems =
          existingCart.items.where((item) => item.id != itemId).toList();

      final updatedCart = existingCart.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
      );

      await cartCollectionRef
          .doc(cartSnapshot.docs.first.id)
          .update(updatedCart.toMap());
      ref.invalidate(cartProvider);
    }
  } catch (e) {
    throw Exception('Failed to remove from cart: $e');
  }
});

// Update cart item quantity
final updateCartItemQuantityProvider =
    FutureProvider.family<void, ({String itemId, int quantity})>(
        (ref, params) async {
  try {
    final buyerId = ref.watch(currentBuyerIdProvider);
    if (buyerId.isEmpty) throw Exception('User not authenticated');

    final cartSnapshot =
        await cartCollectionRef.where('buyerId', isEqualTo: buyerId).get();
    if (cartSnapshot.docs.isNotEmpty) {
      final existingCart = CartModel.fromMap(cartSnapshot.docs.first.data());
      final itemIndex =
          existingCart.items.indexWhere((item) => item.id == params.itemId);

      if (itemIndex >= 0) {
        final updatedItems = List.from(existingCart.items);
        if (params.quantity <= 0) {
          updatedItems.removeAt(itemIndex);
        } else {
          updatedItems[itemIndex] =
              updatedItems[itemIndex].copyWith(quantity: params.quantity);
        }

        final updatedCart = existingCart.copyWith(
          items: updatedItems as List<CartItemModel>?,
          updatedAt: DateTime.now(),
        );

        await cartCollectionRef
            .doc(cartSnapshot.docs.first.id)
            .update(updatedCart.toMap());
        ref.invalidate(cartProvider);
      }
    }
  } catch (e) {
    throw Exception('Failed to update cart item: $e');
  }
});

// Apply coupon
final applyCouponProvider = StateProvider<String>((ref) => '');

final cartSummaryProvider = Provider<CartSummary>((ref) {
  final cart = ref.watch(cartProvider);

  return cart
          .whenData((cart) {
            return CartSummary(
              subtotal: cart.getSubtotal(),
              deliveryFee: cart.getDeliveryFee(),
              taxAmount: cart.getTaxAmount(),
              discountAmount: cart.discountAmount,
              total: cart.getTotal(),
              itemCount: cart.getItemCount(),
            );
          })
          .asData
          ?.value ??
      CartSummary();
});

class CartSummary {
  final double subtotal;
  final double deliveryFee;
  final double taxAmount;
  final double discountAmount;
  final double total;
  final int itemCount;

  CartSummary({
    this.subtotal = 0,
    this.deliveryFee = 0,
    this.taxAmount = 0,
    this.discountAmount = 0,
    this.total = 0,
    this.itemCount = 0,
  });
}

// Clear cart
final clearCartProvider = FutureProvider<void>((ref) async {
  try {
    final buyerId = ref.watch(currentBuyerIdProvider);
    if (buyerId.isEmpty) throw Exception('User not authenticated');

    final cartSnapshot =
        await cartCollectionRef.where('buyerId', isEqualTo: buyerId).get();
    if (cartSnapshot.docs.isNotEmpty) {
      await cartCollectionRef.doc(cartSnapshot.docs.first.id).delete();
      ref.invalidate(cartProvider);
    }
  } catch (e) {
    throw Exception('Failed to clear cart: $e');
  }
});
