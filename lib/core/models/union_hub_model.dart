import 'dart:math';

/// Union Hub Model — represents an AgroLink hub at the Union level
/// Every union in Bangladesh gets its own AgroLink Union Hub
class UnionHubModel {
  final String hubId;
  final String hubCode;

  // Location (English)
  final String unionName;
  final String upazila;
  final String district;
  final String division;

  // Location (Bangla)
  final String unionNameBn;
  final String upazilaBn;
  final String districtBn;
  final String divisionBn;

  // Hub Details
  final String managerName;
  final String managerPhone;
  final String qcOfficerName;
  final String address;
  final String addressBn;

  // Capabilities
  final bool hasColdStorage;
  final bool hasPackagingUnit;
  final bool hasWeighbridge;
  final bool hasQrScanner;
  final int coldStorageCapacityTons;
  final int dailyCapacityKg;

  // Status
  final double rating;
  final int activeOrders;
  final int totalShipments;
  final double utilizationPercent;
  final bool isActive;
  final String status;  // 'active', 'maintenance', 'inactive'

  // GPS
  final double latitude;
  final double longitude;

  // Hierarchy
  final String? parentUpazilaHubId;

  const UnionHubModel({
    required this.hubId,
    required this.hubCode,
    required this.unionName,
    required this.upazila,
    required this.district,
    required this.division,
    required this.unionNameBn,
    required this.upazilaBn,
    required this.districtBn,
    required this.divisionBn,
    required this.managerName,
    required this.managerPhone,
    required this.qcOfficerName,
    required this.address,
    required this.addressBn,
    required this.hasColdStorage,
    required this.hasPackagingUnit,
    required this.hasWeighbridge,
    required this.hasQrScanner,
    required this.coldStorageCapacityTons,
    required this.dailyCapacityKg,
    required this.rating,
    required this.activeOrders,
    required this.totalShipments,
    required this.utilizationPercent,
    required this.isActive,
    required this.status,
    required this.latitude,
    required this.longitude,
    this.parentUpazilaHubId,
  });

  /// Full hub name in English
  String get fullName => '$unionName Union Hub, $upazila';

  /// Full hub name in Bangla
  String get fullNameBn => '$unionNameBn ইউনিয়ন হাব, $upazilaBn';

  /// District + Upazila in English
  String get locationFull => '$upazila, $district, $division';

  /// District + Upazila in Bangla
  String get locationFullBn => '$upazilaBn, $districtBn, $divisionBn';

  /// Status badge color key
  String get statusKey {
    if (!isActive) return 'inactive';
    if (utilizationPercent > 85) return 'full';
    if (utilizationPercent > 60) return 'busy';
    return 'available';
  }

  /// Hub tier based on capabilities
  String get tier {
    int score = 0;
    if (hasColdStorage) score += 3;
    if (hasPackagingUnit) score += 2;
    if (hasWeighbridge) score += 2;
    if (hasQrScanner) score += 1;
    if (score >= 7) return 'Gold';
    if (score >= 4) return 'Silver';
    return 'Bronze';
  }

  String get tierBn {
    switch (tier) {
      case 'Gold': return 'গোল্ড';
      case 'Silver': return 'সিলভার';
      default: return 'ব্রোঞ্জ';
    }
  }

  /// Generate a quick QR payload for a drop-off pass
  String get qrPayload =>
      'AGRO-UNION-HUB|$hubCode|$unionName|$upazila|$district|${DateTime.now().millisecondsSinceEpoch}';

  Map<String, dynamic> toMap() => {
    'hubId': hubId,
    'hubCode': hubCode,
    'unionName': unionName,
    'upazila': upazila,
    'district': district,
    'division': division,
    'unionNameBn': unionNameBn,
    'upazilaBn': upazilaBn,
    'districtBn': districtBn,
    'divisionBn': divisionBn,
    'managerName': managerName,
    'managerPhone': managerPhone,
    'qcOfficerName': qcOfficerName,
    'address': address,
    'addressBn': addressBn,
    'hasColdStorage': hasColdStorage,
    'hasPackagingUnit': hasPackagingUnit,
    'hasWeighbridge': hasWeighbridge,
    'hasQrScanner': hasQrScanner,
    'coldStorageCapacityTons': coldStorageCapacityTons,
    'dailyCapacityKg': dailyCapacityKg,
    'rating': rating,
    'activeOrders': activeOrders,
    'totalShipments': totalShipments,
    'utilizationPercent': utilizationPercent,
    'isActive': isActive,
    'status': status,
    'latitude': latitude,
    'longitude': longitude,
    'parentUpazilaHubId': parentUpazilaHubId,
  };

  factory UnionHubModel.fromMap(Map<String, dynamic> map) => UnionHubModel(
    hubId: map['hubId'] ?? '',
    hubCode: map['hubCode'] ?? '',
    unionName: map['unionName'] ?? '',
    upazila: map['upazila'] ?? '',
    district: map['district'] ?? '',
    division: map['division'] ?? '',
    unionNameBn: map['unionNameBn'] ?? '',
    upazilaBn: map['upazilaBn'] ?? '',
    districtBn: map['districtBn'] ?? '',
    divisionBn: map['divisionBn'] ?? '',
    managerName: map['managerName'] ?? '',
    managerPhone: map['managerPhone'] ?? '',
    qcOfficerName: map['qcOfficerName'] ?? '',
    address: map['address'] ?? '',
    addressBn: map['addressBn'] ?? '',
    hasColdStorage: map['hasColdStorage'] ?? false,
    hasPackagingUnit: map['hasPackagingUnit'] ?? true,
    hasWeighbridge: map['hasWeighbridge'] ?? true,
    hasQrScanner: map['hasQrScanner'] ?? true,
    coldStorageCapacityTons: map['coldStorageCapacityTons'] ?? 0,
    dailyCapacityKg: map['dailyCapacityKg'] ?? 500,
    rating: (map['rating'] ?? 4.0).toDouble(),
    activeOrders: map['activeOrders'] ?? 0,
    totalShipments: map['totalShipments'] ?? 0,
    utilizationPercent: (map['utilizationPercent'] ?? 0.0).toDouble(),
    isActive: map['isActive'] ?? true,
    status: map['status'] ?? 'active',
    latitude: (map['latitude'] ?? 23.8).toDouble(),
    longitude: (map['longitude'] ?? 90.4).toDouble(),
    parentUpazilaHubId: map['parentUpazilaHubId'],
  );

  UnionHubModel copyWith({
    int? activeOrders,
    double? utilizationPercent,
    String? status,
    double? rating,
  }) => UnionHubModel(
    hubId: hubId, hubCode: hubCode, unionName: unionName, upazila: upazila,
    district: district, division: division, unionNameBn: unionNameBn,
    upazilaBn: upazilaBn, districtBn: districtBn, divisionBn: divisionBn,
    managerName: managerName, managerPhone: managerPhone, qcOfficerName: qcOfficerName,
    address: address, addressBn: addressBn, hasColdStorage: hasColdStorage,
    hasPackagingUnit: hasPackagingUnit, hasWeighbridge: hasWeighbridge,
    hasQrScanner: hasQrScanner, coldStorageCapacityTons: coldStorageCapacityTons,
    dailyCapacityKg: dailyCapacityKg,
    rating: rating ?? this.rating,
    activeOrders: activeOrders ?? this.activeOrders,
    totalShipments: totalShipments,
    utilizationPercent: utilizationPercent ?? this.utilizationPercent,
    isActive: isActive,
    status: status ?? this.status,
    latitude: latitude, longitude: longitude,
    parentUpazilaHubId: parentUpazilaHubId,
  );

  /// Compute distance in km to another hub using Haversine formula
  double distanceTo(UnionHubModel other) {
    const R = 6371.0;
    final lat1 = latitude * pi / 180;
    final lat2 = other.latitude * pi / 180;
    final dlat = (other.latitude - latitude) * pi / 180;
    final dlng = (other.longitude - longitude) * pi / 180;
    final a = sin(dlat / 2) * sin(dlat / 2) +
        cos(lat1) * cos(lat2) * sin(dlng / 2) * sin(dlng / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }
}

/// Inter-Union Hub Logistics Quote
class UnionHubLogisticsQuote {
  final UnionHubModel origin;
  final UnionHubModel destination;
  final double distanceKm;
  final double cargoWeightKg;
  final bool isColdChain;

  final double baseFareBDT;
  final double distanceFareBDT;
  final double weightFareBDT;
  final double coldChainSurcharge;
  final double packagingFee;
  final double qcFee;
  final double totalFareBDT;

  final int etaHours;
  final String routeDescription;
  final String routeDescriptionBn;
  final String transitType; // 'direct', 'via-upazila', 'via-district'

  const UnionHubLogisticsQuote({
    required this.origin,
    required this.destination,
    required this.distanceKm,
    required this.cargoWeightKg,
    required this.isColdChain,
    required this.baseFareBDT,
    required this.distanceFareBDT,
    required this.weightFareBDT,
    required this.coldChainSurcharge,
    required this.packagingFee,
    required this.qcFee,
    required this.totalFareBDT,
    required this.etaHours,
    required this.routeDescription,
    required this.routeDescriptionBn,
    required this.transitType,
  });
}
