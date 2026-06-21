import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agrolinkbd/presentation/buyer/models/address_model.dart';

final addressesCollectionRef =
    FirebaseFirestore.instance.collection('addresses');
final currentBuyerIdProvider = StateProvider<String>((ref) => '');

// Fetch all addresses for current buyer
final addressesProvider = FutureProvider<List<AddressModel>>((ref) async {
  try {
    final buyerId = ref.watch(currentBuyerIdProvider);
    if (buyerId.isEmpty) return [];

    final snapshot =
        await addressesCollectionRef.where('buyerId', isEqualTo: buyerId).get();

    return snapshot.docs
        .map((doc) => AddressModel.fromMap(doc.data()))
        .toList();
  } catch (e) {
    throw Exception('Failed to fetch addresses: $e');
  }
});

// Fetch default address
final defaultAddressProvider = FutureProvider<AddressModel?>((ref) async {
  try {
    final buyerId = ref.watch(currentBuyerIdProvider);
    if (buyerId.isEmpty) return null;

    final snapshot = await addressesCollectionRef
        .where('buyerId', isEqualTo: buyerId)
        .where('isDefault', isEqualTo: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return AddressModel.fromMap(snapshot.docs.first.data());
    }

    // Return first address if no default
    final allSnapshot = await addressesCollectionRef
        .where('buyerId', isEqualTo: buyerId)
        .limit(1)
        .get();

    if (allSnapshot.docs.isNotEmpty) {
      return AddressModel.fromMap(allSnapshot.docs.first.data());
    }

    return null;
  } catch (e) {
    return null;
  }
});

// Add new address
final addAddressProvider =
    FutureProvider.family<void, AddressModel>((ref, address) async {
  try {
    final buyerId = ref.watch(currentBuyerIdProvider);
    if (buyerId.isEmpty) throw Exception('User not authenticated');

    final newAddress = address.copyWith(id: addressesCollectionRef.doc().id);
    await addressesCollectionRef.add(newAddress.toMap());
    ref.invalidate(addressesProvider);
  } catch (e) {
    throw Exception('Failed to add address: $e');
  }
});

// Update address
final updateAddressProvider =
    FutureProvider.family<void, AddressModel>((ref, address) async {
  try {
    await addressesCollectionRef.doc(address.id).update(address.toMap());
    ref.invalidate(addressesProvider);
  } catch (e) {
    throw Exception('Failed to update address: $e');
  }
});

// Delete address
final deleteAddressProvider =
    FutureProvider.family<void, String>((ref, addressId) async {
  try {
    await addressesCollectionRef.doc(addressId).delete();
    ref.invalidate(addressesProvider);
  } catch (e) {
    throw Exception('Failed to delete address: $e');
  }
});

// Set default address
final setDefaultAddressProvider =
    FutureProvider.family<void, String>((ref, addressId) async {
  try {
    final buyerId = ref.watch(currentBuyerIdProvider);
    if (buyerId.isEmpty) throw Exception('User not authenticated');

    // Get all user's addresses
    final snapshot =
        await addressesCollectionRef.where('buyerId', isEqualTo: buyerId).get();

    // Remove default from all addresses
    for (final doc in snapshot.docs) {
      if (doc.data()['isDefault'] == true) {
        await doc.reference.update({'isDefault': false});
      }
    }

    // Set new default
    await addressesCollectionRef.doc(addressId).update({'isDefault': true});
    ref.invalidate(addressesProvider);
  } catch (e) {
    throw Exception('Failed to set default address: $e');
  }
});

// Get address by ID
final addressByIdProvider =
    FutureProvider.family<AddressModel?, String>((ref, addressId) async {
  try {
    final doc = await addressesCollectionRef.doc(addressId).get();
    if (doc.exists) {
      return AddressModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  } catch (e) {
    return null;
  }
});
