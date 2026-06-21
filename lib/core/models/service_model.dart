import 'package:cloud_firestore/cloud_firestore.dart';

enum ServiceStatus { active, inactive }

class ServiceModel {
  final String id;
  final String providerId;
  final String name;
  final String description;
  final double price;
  final String priceUnit; // e.g., '/hour', '/acre', '/session'
  final String? imageUrl;
  final double rating;
  final int bookingsCount;
  final ServiceStatus status;
  final DateTime createdAt;

  ServiceModel({
    required this.id,
    required this.providerId,
    required this.name,
    required this.description,
    required this.price,
    required this.priceUnit,
    this.imageUrl,
    this.rating = 0.0,
    this.bookingsCount = 0,
    this.status = ServiceStatus.active,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'providerId': providerId,
      'name': name,
      'description': description,
      'price': price,
      'priceUnit': priceUnit,
      'imageUrl': imageUrl,
      'rating': rating,
      'bookingsCount': bookingsCount,
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedCreatedAt;
    try {
      final rawCreatedAt = json['createdAt'];
      if (rawCreatedAt is DateTime) {
        parsedCreatedAt = rawCreatedAt;
      } else if (rawCreatedAt is String) {
        parsedCreatedAt = DateTime.parse(rawCreatedAt);
      } else if (rawCreatedAt != null && rawCreatedAt.toDate != null) {
        parsedCreatedAt = rawCreatedAt.toDate();
      } else {
        parsedCreatedAt = DateTime.now();
      }
    } catch (_) {
      parsedCreatedAt = DateTime.now();
    }

    return ServiceModel(
      id: json['id'] ?? '',
      providerId: json['providerId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      priceUnit: json['priceUnit'] ?? '',
      imageUrl: json['imageUrl'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      bookingsCount: json['bookingsCount'] ?? 0,
      status: ServiceStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => ServiceStatus.active,
      ),
      createdAt: parsedCreatedAt,
    );
  }

  ServiceModel copyWith({
    String? id,
    String? providerId,
    String? name,
    String? description,
    double? price,
    String? priceUnit,
    String? imageUrl,
    double? rating,
    int? bookingsCount,
    ServiceStatus? status,
    DateTime? createdAt,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      priceUnit: priceUnit ?? this.priceUnit,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      bookingsCount: bookingsCount ?? this.bookingsCount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
