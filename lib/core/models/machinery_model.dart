enum MachineryType {
  tractor,
  harvester,
  thresher,
  plough,
  seeder,
  sprayer,
  irrigationPump,
  other,
}

enum BookingStatus { pending, confirmed, inProgress, completed, cancelled }

class MachineryModel {
  final String id;
  final String ownerId;
  final String ownerName;
  final String ownerPhone;
  final MachineryType type;
  final String name;
  final String description;
  final List<String> images;
  final double hourlyRate;
  final double dailyRate;
  final String? location;
  final String? district;
  final String? upazila;
  final double? latitude;
  final double? longitude;
  final bool isAvailable;
  final double rating;
  final int totalRatings;
  final DateTime createdAt;

  MachineryModel({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.ownerPhone,
    required this.type,
    required this.name,
    required this.description,
    required this.images,
    required this.hourlyRate,
    required this.dailyRate,
    this.location,
    this.district,
    this.upazila,
    this.latitude,
    this.longitude,
    this.isAvailable = true,
    this.rating = 0.0,
    this.totalRatings = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
      'type': type.toString(),
      'name': name,
      'description': description,
      'images': images,
      'hourlyRate': hourlyRate,
      'dailyRate': dailyRate,
      'location': location,
      'district': district,
      'upazila': upazila,
      'latitude': latitude,
      'longitude': longitude,
      'isAvailable': isAvailable,
      'rating': rating,
      'totalRatings': totalRatings,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MachineryModel.fromJson(Map<String, dynamic> json) {
    return MachineryModel(
      id: json['id'],
      ownerId: json['ownerId'],
      ownerName: json['ownerName'],
      ownerPhone: json['ownerPhone'],
      type: MachineryType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      name: json['name'],
      description: json['description'],
      images: List<String>.from(json['images']),
      hourlyRate: json['hourlyRate'].toDouble(),
      dailyRate: json['dailyRate'].toDouble(),
      location: json['location'],
      district: json['district'],
      upazila: json['upazila'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      isAvailable: json['isAvailable'] ?? true,
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalRatings: json['totalRatings'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class MachineryBookingModel {
  final String id;
  final String machineryId;
  final String farmerId;
  final String farmerName;
  final String farmerPhone;
  final String ownerId;
  final String ownerName;
  final DateTime bookingDate;
  final int hours;
  final double landSize;
  final String location;
  final double? latitude;
  final double? longitude;
  final double totalPrice;
  final BookingStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;

  MachineryBookingModel({
    required this.id,
    required this.machineryId,
    required this.farmerId,
    required this.farmerName,
    required this.farmerPhone,
    required this.ownerId,
    required this.ownerName,
    required this.bookingDate,
    required this.hours,
    required this.landSize,
    required this.location,
    this.latitude,
    this.longitude,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'machineryId': machineryId,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'farmerPhone': farmerPhone,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'bookingDate': bookingDate.toIso8601String(),
      'hours': hours,
      'landSize': landSize,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'totalPrice': totalPrice,
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory MachineryBookingModel.fromJson(Map<String, dynamic> json) {
    return MachineryBookingModel(
      id: json['id'],
      machineryId: json['machineryId'],
      farmerId: json['farmerId'],
      farmerName: json['farmerName'],
      farmerPhone: json['farmerPhone'],
      ownerId: json['ownerId'],
      ownerName: json['ownerName'],
      bookingDate: DateTime.parse(json['bookingDate']),
      hours: json['hours'],
      landSize: json['landSize'].toDouble(),
      location: json['location'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      totalPrice: json['totalPrice'].toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }
}
