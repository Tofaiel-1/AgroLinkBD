import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agrolinkbd/presentation/buyer/models/wishlist_model.dart';

final wishlistCollectionRef =
    FirebaseFirestore.instance.collection('wishlists');
final currentBuyerIdProvider = StateProvider<String>((ref) => '');

// Fetch buyer's wishlist
final wishlistProvider = FutureProvider<List<WishlistItemModel>>((ref) async {
  try {
    final buyerId = ref.watch(currentBuyerIdProvider);
    if (buyerId.isEmpty) return [];

    final snapshot =
        await wishlistCollectionRef.where('buyerId', isEqualTo: buyerId).get();

    return snapshot.docs
        .map((doc) => WishlistItemModel.fromMap(doc.data()))
        .toList();
  } catch (e) {
    throw Exception('Failed to fetch wishlist: $e');
  }
});

// Add to wishlist
final addToWishlistProvider =
    FutureProvider.family<void, WishlistItemModel>((ref, item) async {
  try {
    final buyerId = ref.watch(currentBuyerIdProvider);
    if (buyerId.isEmpty) throw Exception('User not authenticated');

    await wishlistCollectionRef.add(item.toMap());
    ref.invalidate(wishlistProvider);
  } catch (e) {
    throw Exception('Failed to add to wishlist: $e');
  }
});

// Remove from wishlist
final removeFromWishlistProvider =
    FutureProvider.family<void, String>((ref, productId) async {
  try {
    final buyerId = ref.watch(currentBuyerIdProvider);
    if (buyerId.isEmpty) throw Exception('User not authenticated');

    final snapshot = await wishlistCollectionRef
        .where('buyerId', isEqualTo: buyerId)
        .where('productId', isEqualTo: productId)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }

    ref.invalidate(wishlistProvider);
  } catch (e) {
    throw Exception('Failed to remove from wishlist: $e');
  }
});

// Check if product is in wishlist
final isProductInWishlistProvider =
    FutureProvider.family<bool, String>((ref, productId) async {
  try {
    final buyerId = ref.watch(currentBuyerIdProvider);
    if (buyerId.isEmpty) return false;

    final snapshot = await wishlistCollectionRef
        .where('buyerId', isEqualTo: buyerId)
        .where('productId', isEqualTo: productId)
        .get();

    return snapshot.docs.isNotEmpty;
  } catch (e) {
    return false;
  }
});

// Get wishlist count
final wishlistCountProvider = FutureProvider<int>((ref) async {
  try {
    final buyerId = ref.watch(currentBuyerIdProvider);
    if (buyerId.isEmpty) return 0;

    final snapshot =
        await wishlistCollectionRef.where('buyerId', isEqualTo: buyerId).get();

    return snapshot.docs.length;
  } catch (e) {
    return 0;
  }
});

// Clear wishlist
final clearWishlistProvider = FutureProvider<void>((ref) async {
  try {
    final buyerId = ref.watch(currentBuyerIdProvider);
    if (buyerId.isEmpty) throw Exception('User not authenticated');

    final snapshot =
        await wishlistCollectionRef.where('buyerId', isEqualTo: buyerId).get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }

    ref.invalidate(wishlistProvider);
  } catch (e) {
    throw Exception('Failed to clear wishlist: $e');
  }
});
