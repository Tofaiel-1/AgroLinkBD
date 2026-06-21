enum TransportStatus {
  pending,
  bidding,
  accepted,
  inTransit,
  delivered,
  cancelled,
}

class TransportRequestModel {
  final String id;
  final String farmerId;
  final String farmerName;
  final String farmerPhone;
  final String pickupLocation;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final String deliveryLocation;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final String productType;
  final double weight; // in kg
  final DateTime pickupDate;
  final String? specialInstructions;
  final TransportStatus status;
  final List<TransportBidModel> bids;
  final String? acceptedDriverId;
  final String? acceptedDriverName;
  final double? agreedPrice;
  final DateTime createdAt;
  final DateTime? completedAt;

  TransportRequestModel({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.farmerPhone,
    required this.pickupLocation,
    this.pickupLatitude,
    this.pickupLongitude,
    required this.deliveryLocation,
    this.deliveryLatitude,
    this.deliveryLongitude,
    required this.productType,
    required this.weight,
    required this.pickupDate,
    this.specialInstructions,
    required this.status,
    this.bids = const [],
    this.acceptedDriverId,
    this.acceptedDriverName,
    this.agreedPrice,
    required this.createdAt,
    this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'farmerPhone': farmerPhone,
      'pickupLocation': pickupLocation,
      'pickupLatitude': pickupLatitude,
      'pickupLongitude': pickupLongitude,
      'deliveryLocation': deliveryLocation,
      'deliveryLatitude': deliveryLatitude,
      'deliveryLongitude': deliveryLongitude,
      'productType': productType,
      'weight': weight,
      'pickupDate': pickupDate.toIso8601String(),
      'specialInstructions': specialInstructions,
      'status': status.toString(),
      'bids': bids.map((bid) => bid.toJson()).toList(),
      'acceptedDriverId': acceptedDriverId,
      'acceptedDriverName': acceptedDriverName,
      'agreedPrice': agreedPrice,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory TransportRequestModel.fromJson(Map<String, dynamic> json) {
    return TransportRequestModel(
      id: json['id'],
      farmerId: json['farmerId'],
      farmerName: json['farmerName'],
      farmerPhone: json['farmerPhone'],
      pickupLocation: json['pickupLocation'],
      pickupLatitude: json['pickupLatitude']?.toDouble(),
      pickupLongitude: json['pickupLongitude']?.toDouble(),
      deliveryLocation: json['deliveryLocation'],
      deliveryLatitude: json['deliveryLatitude']?.toDouble(),
      deliveryLongitude: json['deliveryLongitude']?.toDouble(),
      productType: json['productType'],
      weight: json['weight'].toDouble(),
      pickupDate: DateTime.parse(json['pickupDate']),
      specialInstructions: json['specialInstructions'],
      status: TransportStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      bids: json['bids'] != null
          ? (json['bids'] as List)
                .map((bid) => TransportBidModel.fromJson(bid))
                .toList()
          : [],
      acceptedDriverId: json['acceptedDriverId'],
      acceptedDriverName: json['acceptedDriverName'],
      agreedPrice: json['agreedPrice']?.toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }
}

class TransportBidModel {
  final String id;
  final String driverId;
  final String driverName;
  final String driverPhone;
  final String vehicleType;
  final String vehicleNumber;
  final double bidAmount;
  final String? message;
  final DateTime timestamp;

  TransportBidModel({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.driverPhone,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.bidAmount,
    this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverId': driverId,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'bidAmount': bidAmount,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TransportBidModel.fromJson(Map<String, dynamic> json) {
    return TransportBidModel(
      id: json['id'],
      driverId: json['driverId'],
      driverName: json['driverName'],
      driverPhone: json['driverPhone'],
      vehicleType: json['vehicleType'],
      vehicleNumber: json['vehicleNumber'],
      bidAmount: json['bidAmount'].toDouble(),
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
