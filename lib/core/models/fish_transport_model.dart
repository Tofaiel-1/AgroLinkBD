enum FishVehicleType {
  oxygenPickup,     // জ্যান্ত মাছের জন্য অক্সিজেন সিলিন্ডার পিকআপ
  insulatedIceVan,  // বরফযুক্ত ইনসুলেটেড ভ্যান / ড্রাম ভ্যান
  openTrolley,      // সাধারণ ট্রলি / নসিমন
  coveredTruck      // বড় কাভার্ড ভ্যান (দূরপাল্লা)
}

enum FishTransportStatus {
  requested,
  driverAssigned,
  enRoutePickup,
  loadingFish,
  inTransit,
  delivered,
  cancelled
}

class FishTransportBookingModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final FishVehicleType vehicleType;
  
  final String pickupLocation;
  final String pickupDistrict;
  final double? pickupLat;
  final double? pickupLng;
  
  final String dropoffLocation;
  final String dropoffDistrict;
  final double? dropoffLat;
  final double? dropoffLng;
  
  final String fishType;
  final double fishWeightKg;
  final bool isLiveFish;
  final DateTime pickupTime;
  
  final double estimatedDistanceKm;
  final double estimatedCost;
  
  String? driverId;
  String? driverName;
  String? driverPhone;
  String? vehicleNumber;
  
  FishTransportStatus status;
  final String notes;
  final DateTime createdAt;

  FishTransportBookingModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.vehicleType,
    required this.pickupLocation,
    required this.pickupDistrict,
    this.pickupLat,
    this.pickupLng,
    required this.dropoffLocation,
    required this.dropoffDistrict,
    this.dropoffLat,
    this.dropoffLng,
    required this.fishType,
    required this.fishWeightKg,
    this.isLiveFish = true,
    required this.pickupTime,
    required this.estimatedDistanceKm,
    required this.estimatedCost,
    this.driverId,
    this.driverName,
    this.driverPhone,
    this.vehicleNumber,
    this.status = FishTransportStatus.requested,
    this.notes = '',
    required this.createdAt,
  });

  String get vehicleTypeName {
    switch (vehicleType) {
      case FishVehicleType.oxygenPickup:
        return 'লাইভ অক্সিজেন পিকআপ';
      case FishVehicleType.insulatedIceVan:
        return 'বরফযুক্ত ইনসুলেটেড ভ্যান';
      case FishVehicleType.openTrolley:
        return 'লোকাল ট্রলি / নসিমন';
      case FishVehicleType.coveredTruck:
        return 'বড় কাভার্ড ফিশ ভ্যান';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'vehicleType': vehicleType.name,
      'pickupLocation': pickupLocation,
      'pickupDistrict': pickupDistrict,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'dropoffLocation': dropoffLocation,
      'dropoffDistrict': dropoffDistrict,
      'dropoffLat': dropoffLat,
      'dropoffLng': dropoffLng,
      'fishType': fishType,
      'fishWeightKg': fishWeightKg,
      'isLiveFish': isLiveFish,
      'pickupTime': pickupTime.toIso8601String(),
      'estimatedDistanceKm': estimatedDistanceKm,
      'estimatedCost': estimatedCost,
      'driverId': driverId,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'vehicleNumber': vehicleNumber,
      'status': status.name,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FishTransportBookingModel.fromJson(Map<String, dynamic> json) {
    return FishTransportBookingModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userPhone: json['userPhone'] ?? '',
      vehicleType: FishVehicleType.values.firstWhere(
        (e) => e.name == json['vehicleType'],
        orElse: () => FishVehicleType.oxygenPickup,
      ),
      pickupLocation: json['pickupLocation'] ?? '',
      pickupDistrict: json['pickupDistrict'] ?? '',
      pickupLat: (json['pickupLat'] as num?)?.toDouble(),
      pickupLng: (json['pickupLng'] as num?)?.toDouble(),
      dropoffLocation: json['dropoffLocation'] ?? '',
      dropoffDistrict: json['dropoffDistrict'] ?? '',
      dropoffLat: (json['dropoffLat'] as num?)?.toDouble(),
      dropoffLng: (json['dropoffLng'] as num?)?.toDouble(),
      fishType: json['fishType'] ?? '',
      fishWeightKg: (json['fishWeightKg'] as num?)?.toDouble() ?? 0.0,
      isLiveFish: json['isLiveFish'] ?? true,
      pickupTime: json['pickupTime'] != null
          ? DateTime.parse(json['pickupTime'])
          : DateTime.now(),
      estimatedDistanceKm: (json['estimatedDistanceKm'] as num?)?.toDouble() ?? 0.0,
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ?? 0.0,
      driverId: json['driverId'],
      driverName: json['driverName'],
      driverPhone: json['driverPhone'],
      vehicleNumber: json['vehicleNumber'],
      status: FishTransportStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FishTransportStatus.requested,
      ),
      notes: json['notes'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
