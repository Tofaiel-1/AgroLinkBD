import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistItemModel {
  final String id;
  final String productId;
  final String buyerId;
  final DateTime savedAt;
  final bool priceNotification;
  final double? targetPrice;

  WishlistItemModel({
    required this.id,
    required this.productId,
    required this.buyerId,
    required this.savedAt,
    this.priceNotification = false,
    this.targetPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'buyerId': buyerId,
      'savedAt': savedAt,
      'priceNotification': priceNotification,
      'targetPrice': targetPrice,
    };
  }

  factory WishlistItemModel.fromMap(Map<String, dynamic> map) {
    return WishlistItemModel(
      id: map['id'] as String? ?? '',
      productId: map['productId'] as String? ?? '',
      buyerId: map['buyerId'] as String? ?? '',
      savedAt: (map['savedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      priceNotification: map['priceNotification'] as bool? ?? false,
      targetPrice: (map['targetPrice'] as num?)?.toDouble(),
    );
  }
}
