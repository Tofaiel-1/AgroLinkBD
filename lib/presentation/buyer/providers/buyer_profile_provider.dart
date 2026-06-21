import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agrolinkbd/presentation/buyer/models/buyer_model.dart';

final buyerCollectionRef =
    FirebaseFirestore.instance.collection('buyer_profiles');
final currentBuyerIdProvider = StateProvider<String>((ref) => '');

// Fetch current buyer profile
final buyerProfileProvider = FutureProvider<BuyerModel?>((ref) async {
  try {
    final buyerId = ref.watch(currentBuyerIdProvider);
    if (buyerId.isEmpty) return null;

    final doc = await buyerCollectionRef.doc(buyerId).get();
    if (doc.exists) {
      return BuyerModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  } catch (e) {
    throw Exception('Failed to fetch buyer profile: $e');
  }
});

// Update buyer profile
final updateBuyerProfileProvider =
    FutureProvider.family<void, BuyerModel>((ref, updatedBuyer) async {
  try {
    await buyerCollectionRef.doc(updatedBuyer.id).update(updatedBuyer.toMap());
    ref.invalidate(buyerProfileProvider);
  } catch (e) {
    throw Exception('Failed to update profile: $e');
  }
});

// Add wallet balance
final addWalletBalanceProvider =
    FutureProvider.family<void, double>((ref, amount) async {
  try {
    final buyerId = ref.watch(currentBuyerIdProvider);
    if (buyerId.isEmpty) throw Exception('User not authenticated');

    final doc = await buyerCollectionRef.doc(buyerId).get();
    if (doc.exists) {
      final buyer = BuyerModel.fromMap(doc.data() as Map<String, dynamic>);
      final updatedBuyer =
          buyer.copyWith(walletBalance: buyer.walletBalance + amount);
      await buyerCollectionRef.doc(buyerId).update(updatedBuyer.toMap());
      ref.invalidate(buyerProfileProvider);
    }
  } catch (e) {
    throw Exception('Failed to add wallet balance: $e');
  }
});

// Deduct wallet balance
final deductWalletBalanceProvider =
    FutureProvider.family<void, double>((ref, amount) async {
  try {
    final buyerId = ref.watch(currentBuyerIdProvider);
    if (buyerId.isEmpty) throw Exception('User not authenticated');

    final doc = await buyerCollectionRef.doc(buyerId).get();
    if (doc.exists) {
      final buyer = BuyerModel.fromMap(doc.data() as Map<String, dynamic>);
      if (buyer.walletBalance < amount) {
        throw Exception('Insufficient balance');
      }
      final updatedBuyer =
          buyer.copyWith(walletBalance: buyer.walletBalance - amount);
      await buyerCollectionRef.doc(buyerId).update(updatedBuyer.toMap());
      ref.invalidate(buyerProfileProvider);
    }
  } catch (e) {
    throw Exception('Failed to deduct wallet balance: $e');
  }
});

// Add saved farmer
final addSavedFarmerProvider =
    FutureProvider.family<void, String>((ref, farmerId) async {
  try {
    final buyerId = ref.watch(currentBuyerIdProvider);
    if (buyerId.isEmpty) throw Exception('User not authenticated');

    final doc = await buyerCollectionRef.doc(buyerId).get();
    if (doc.exists) {
      final buyer = BuyerModel.fromMap(doc.data() as Map<String, dynamic>);
      final updatedSavedFarmers = List<String>.from(buyer.savedFarmers);
      if (!updatedSavedFarmers.contains(farmerId)) {
        updatedSavedFarmers.add(farmerId);
        final updatedBuyer = buyer.copyWith(savedFarmers: updatedSavedFarmers);
        await buyerCollectionRef.doc(buyerId).update(updatedBuyer.toMap());
        ref.invalidate(buyerProfileProvider);
      }
    }
  } catch (e) {
    throw Exception('Failed to add saved farmer: $e');
  }
});

// Remove saved farmer
final removeSavedFarmerProvider =
    FutureProvider.family<void, String>((ref, farmerId) async {
  try {
    final buyerId = ref.watch(currentBuyerIdProvider);
    if (buyerId.isEmpty) throw Exception('User not authenticated');

    final doc = await buyerCollectionRef.doc(buyerId).get();
    if (doc.exists) {
      final buyer = BuyerModel.fromMap(doc.data() as Map<String, dynamic>);
      final updatedSavedFarmers = List<String>.from(buyer.savedFarmers);
      updatedSavedFarmers.remove(farmerId);
      final updatedBuyer = buyer.copyWith(savedFarmers: updatedSavedFarmers);
      await buyerCollectionRef.doc(buyerId).update(updatedBuyer.toMap());
      ref.invalidate(buyerProfileProvider);
    }
  } catch (e) {
    throw Exception('Failed to remove saved farmer: $e');
  }
});

// Update notification preferences
final updateNotificationPreferencesProvider =
    FutureProvider.family<void, Map<String, bool>>((ref, preferences) async {
  try {
    final buyerId = ref.watch(currentBuyerIdProvider);
    if (buyerId.isEmpty) throw Exception('User not authenticated');

    final doc = await buyerCollectionRef.doc(buyerId).get();
    if (doc.exists) {
      final buyer = BuyerModel.fromMap(doc.data() as Map<String, dynamic>);
      final updatedBuyer = buyer.copyWith(notificationPreferences: preferences);
      await buyerCollectionRef.doc(buyerId).update(updatedBuyer.toMap());
      ref.invalidate(buyerProfileProvider);
    }
  } catch (e) {
    throw Exception('Failed to update preferences: $e');
  }
});

// Get wallet balance
final walletBalanceProvider = FutureProvider<double>((ref) async {
  try {
    final buyerId = ref.watch(currentBuyerIdProvider);
    if (buyerId.isEmpty) return 0;

    final doc = await buyerCollectionRef.doc(buyerId).get();
    if (doc.exists) {
      final profile = BuyerModel.fromMap(doc.data() as Map<String, dynamic>);
      return profile.walletBalance;
    }
    return 0;
  } catch (e) {
    return 0;
  }
});
