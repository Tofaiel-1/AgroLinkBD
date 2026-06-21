import 'package:cloud_firestore/cloud_firestore.dart';

class BuyerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profilePhoto;
  final double walletBalance;
  final List<String> savedFarmers;
  final List<String> wishlistProducts;
  final String? defaultAddressId;
  final double totalSpent;
  final int totalOrdersPlaced;
  final double averageRating;
  final DateTime memberSince;
  final bool isKycVerified;
  final List<String> savedCouponCodes;
  final int referralEarnings;
  final String preferredLanguage;
  final bool darkModeEnabled;
  final Map<String, bool> notificationPreferences;
  final List<String> preferredCategories;
  final DateTime createdAt;
  final DateTime updatedAt;

  BuyerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profilePhoto,
    this.walletBalance = 0,
    this.savedFarmers = const [],
    this.wishlistProducts = const [],
    this.defaultAddressId,
    this.totalSpent = 0,
    this.totalOrdersPlaced = 0,
    this.averageRating = 0,
    required this.memberSince,
    this.isKycVerified = false,
    this.savedCouponCodes = const [],
    this.referralEarnings = 0,
    this.preferredLanguage = 'bn',
    this.darkModeEnabled = false,
    this.notificationPreferences = const {
      'orderUpdates': true,
      'promotions': true,
      'alerts': true,
    },
    this.preferredCategories = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profilePhoto': profilePhoto,
      'walletBalance': walletBalance,
      'savedFarmers': savedFarmers,
      'wishlistProducts': wishlistProducts,
      'defaultAddressId': defaultAddressId,
      'totalSpent': totalSpent,
      'totalOrdersPlaced': totalOrdersPlaced,
      'averageRating': averageRating,
      'memberSince': memberSince,
      'isKycVerified': isKycVerified,
      'savedCouponCodes': savedCouponCodes,
      'referralEarnings': referralEarnings,
      'preferredLanguage': preferredLanguage,
      'darkModeEnabled': darkModeEnabled,
      'notificationPreferences': notificationPreferences,
      'preferredCategories': preferredCategories,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory BuyerModel.fromMap(Map<String, dynamic> map) {
    return BuyerModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      profilePhoto: map['profilePhoto'] as String?,
      walletBalance: (map['walletBalance'] as num?)?.toDouble() ?? 0,
      savedFarmers: List<String>.from(map['savedFarmers'] as List? ?? []),
      wishlistProducts:
          List<String>.from(map['wishlistProducts'] as List? ?? []),
      defaultAddressId: map['defaultAddressId'] as String?,
      totalSpent: (map['totalSpent'] as num?)?.toDouble() ?? 0,
      totalOrdersPlaced: map['totalOrdersPlaced'] as int? ?? 0,
      averageRating: (map['averageRating'] as num?)?.toDouble() ?? 0,
      memberSince:
          (map['memberSince'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isKycVerified: map['isKycVerified'] as bool? ?? false,
      savedCouponCodes:
          List<String>.from(map['savedCouponCodes'] as List? ?? []),
      referralEarnings: map['referralEarnings'] as int? ?? 0,
      preferredLanguage: map['preferredLanguage'] as String? ?? 'bn',
      darkModeEnabled: map['darkModeEnabled'] as bool? ?? false,
      notificationPreferences:
          Map<String, bool>.from(map['notificationPreferences'] as Map? ?? {}),
      preferredCategories:
          List<String>.from(map['preferredCategories'] as List? ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  BuyerModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profilePhoto,
    double? walletBalance,
    List<String>? savedFarmers,
    List<String>? wishlistProducts,
    String? defaultAddressId,
    double? totalSpent,
    int? totalOrdersPlaced,
    double? averageRating,
    DateTime? memberSince,
    bool? isKycVerified,
    List<String>? savedCouponCodes,
    int? referralEarnings,
    String? preferredLanguage,
    bool? darkModeEnabled,
    Map<String, bool>? notificationPreferences,
    List<String>? preferredCategories,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BuyerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      walletBalance: walletBalance ?? this.walletBalance,
      savedFarmers: savedFarmers ?? this.savedFarmers,
      wishlistProducts: wishlistProducts ?? this.wishlistProducts,
      defaultAddressId: defaultAddressId ?? this.defaultAddressId,
      totalSpent: totalSpent ?? this.totalSpent,
      totalOrdersPlaced: totalOrdersPlaced ?? this.totalOrdersPlaced,
      averageRating: averageRating ?? this.averageRating,
      memberSince: memberSince ?? this.memberSince,
      isKycVerified: isKycVerified ?? this.isKycVerified,
      savedCouponCodes: savedCouponCodes ?? this.savedCouponCodes,
      referralEarnings: referralEarnings ?? this.referralEarnings,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
      preferredCategories: preferredCategories ?? this.preferredCategories,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
