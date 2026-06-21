import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agrolinkbd/presentation/buyer/providers/buyer_profile_provider.dart';

/// Service to initialize buyer data when user registers or logs in as buyer
class BuyerInitializationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialize buyer after registration
  /// Call this immediately after user registers as a buyer
  static Future<bool> initializeBuyerAfterRegistration({
    required String userId,
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      debugPrint('🛍️ Initializing buyer profile for new user: $userId');

      // Create buyer profile document
      await _firestore.collection('buyer_profiles').doc(userId).set({
        'id': userId,
        'name': name,
        'email': email,
        'phone': phone,
        'profilePhoto': null,
        'walletBalance': 0.0,
        'savedFarmers': [],
        'wishlistProducts': [],
        'defaultAddressId': null,
        'totalSpent': 0.0,
        'totalOrdersPlaced': 0,
        'averageRating': 0.0,
        'memberSince': FieldValue.serverTimestamp(),
        'isKycVerified': false,
        'savedCouponCodes': [],
        'referralEarnings': 0,
        'preferredLanguage': 'bn',
        'darkModeEnabled': false,
        'notificationPreferences': {
          'orderUpdates': true,
          'promotions': true,
          'alerts': true,
        },
        'preferredCategories': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Buyer profile initialized successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to initialize buyer profile: $e');
      return false;
    }
  }

  /// Initialize buyer session after login
  /// Call this after user logs in as buyer
  static Future<bool> initializeBuyerSession({
    required String userId,
    required WidgetRef ref,
  }) async {
    try {
      debugPrint('📱 Initializing buyer session for user: $userId');

      // Set the current buyer ID in the provider
      ref.read(currentBuyerIdProvider.notifier).state = userId;

      // Check if buyer profile exists
      final doc =
          await _firestore.collection('buyer_profiles').doc(userId).get();

      if (!doc.exists) {
        debugPrint('⚠️ Buyer profile does not exist, creating default profile');

        // Create default profile if it doesn't exist
        await _firestore.collection('buyer_profiles').doc(userId).set({
          'id': userId,
          'walletBalance': 0.0,
          'savedFarmers': [],
          'wishlistProducts': [],
          'totalSpent': 0.0,
          'totalOrdersPlaced': 0,
          'averageRating': 0.0,
          'isKycVerified': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      debugPrint('✅ Buyer session initialized successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to initialize buyer session: $e');
      return false;
    }
  }

  /// Check if buyer profile exists
  static Future<bool> buyerProfileExists(String userId) async {
    try {
      final doc =
          await _firestore.collection('buyer_profiles').doc(userId).get();
      return doc.exists;
    } catch (e) {
      debugPrint('❌ Error checking buyer profile: $e');
      return false;
    }
  }

  /// Ensure all required Firestore collections exist
  /// Call this once during app initialization
  static Future<void> ensureCollectionsExist() async {
    try {
      debugPrint('📦 Checking required Firestore collections...');

      final collections = [
        'buyer_profiles',
        'products',
        'carts',
        'orders',
        'addresses',
        'wishlists',
        'reviews',
        'categories',
      ];

      for (final collection in collections) {
        try {
          await _firestore.collection(collection).limit(1).get();
          debugPrint('✅ Collection exists: $collection');
        } catch (e) {
          debugPrint('⚠️ Collection may not exist: $collection (this is ok)');
        }
      }

      debugPrint('✅ Collection check completed');
    } catch (e) {
      debugPrint('⚠️ Error checking collections: $e');
    }
  }
}
