import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String productId;
  final String orderId;
  final String buyerId;
  final String buyerName;
  final String? buyerPhoto;
  final int rating;
  final String title;
  final String comment;
  final List<String> images;
  final int helpfulCount;
  final String? farmerReply;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.orderId,
    required this.buyerId,
    required this.buyerName,
    this.buyerPhoto,
    required this.rating,
    required this.title,
    required this.comment,
    this.images = const [],
    this.helpfulCount = 0,
    this.farmerReply,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'orderId': orderId,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'buyerPhoto': buyerPhoto,
      'rating': rating,
      'title': title,
      'comment': comment,
      'images': images,
      'helpfulCount': helpfulCount,
      'farmerReply': farmerReply,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] as String? ?? '',
      productId: map['productId'] as String? ?? '',
      orderId: map['orderId'] as String? ?? '',
      buyerId: map['buyerId'] as String? ?? '',
      buyerName: map['buyerName'] as String? ?? '',
      buyerPhoto: map['buyerPhoto'] as String?,
      rating: map['rating'] as int? ?? 3,
      title: map['title'] as String? ?? '',
      comment: map['comment'] as String? ?? '',
      images: List<String>.from(map['images'] as List? ?? []),
      helpfulCount: map['helpfulCount'] as int? ?? 0,
      farmerReply: map['farmerReply'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
