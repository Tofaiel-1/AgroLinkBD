import 'package:cloud_firestore/cloud_firestore.dart';

/// Fish Trip Model for Fish Transport Drivers
/// Represents a logged logistics delivery for Live Oxygen Vans, Insulated Ice Trucks, etc.
class FishTripModel {
  final String id;
  final String driverId;
  final String driverName;
  final String driverPhone;
  final String pickupLocation;
  final String dropLocation;
  final String fishSpecies;
  final double weightKg;
  final bool isLive;
  final String vehicleType; // e.g. 'oxygenPickup', 'insulatedIceVan', 'mediumTruck'
  final double distanceKm;
  final double totalFare; // Gross revenue
  final double fuelExpense; // Diesel / fuel cost
  final double oxygenExpense; // Oxygen cylinder / Ice cost
  final double netIncome; // totalFare - (fuelExpense + oxygenExpense)
  final double survivalRate; // percentage (e.g. 99.8)
  final double rating; // 1.0 - 5.0
  final String status; // 'completed', 'in_transit', 'cancelled'
  final DateTime completedAt;
  final DateTime createdAt;
  final String? notes;

  FishTripModel({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.driverPhone,
    required this.pickupLocation,
    required this.dropLocation,
    required this.fishSpecies,
    required this.weightKg,
    this.isLive = true,
    this.vehicleType = 'oxygenPickup',
    required this.distanceKm,
    required this.totalFare,
    required this.fuelExpense,
    required this.oxygenExpense,
    double? netIncome,
    this.survivalRate = 99.8,
    this.rating = 5.0,
    this.status = 'completed',
    required this.completedAt,
    DateTime? createdAt,
    this.notes,
  })  : netIncome = netIncome ?? (totalFare - (fuelExpense + oxygenExpense)),
        createdAt = createdAt ?? DateTime.now();

  double get weightMaunds => weightKg / 40.0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverId': driverId,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'pickupLocation': pickupLocation,
      'dropLocation': dropLocation,
      'fishSpecies': fishSpecies,
      'weightKg': weightKg,
      'isLive': isLive,
      'vehicleType': vehicleType,
      'distanceKm': distanceKm,
      'totalFare': totalFare,
      'fuelExpense': fuelExpense,
      'oxygenExpense': oxygenExpense,
      'netIncome': netIncome,
      'survivalRate': survivalRate,
      'rating': rating,
      'status': status,
      'completedAt': Timestamp.fromDate(completedAt),
      'createdAt': Timestamp.fromDate(createdAt),
      'notes': notes,
    };
  }

  factory FishTripModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    final fare = (json['totalFare'] as num?)?.toDouble() ?? 0.0;
    final fuel = (json['fuelExpense'] as num?)?.toDouble() ?? 0.0;
    final oxy = (json['oxygenExpense'] as num?)?.toDouble() ?? 0.0;
    final net = (json['netIncome'] as num?)?.toDouble() ?? (fare - (fuel + oxy));

    return FishTripModel(
      id: json['id']?.toString() ?? '',
      driverId: json['driverId']?.toString() ?? '',
      driverName: json['driverName']?.toString() ?? 'Fish Driver',
      driverPhone: json['driverPhone']?.toString() ?? '',
      pickupLocation: json['pickupLocation']?.toString() ?? 'সিংড়া, নাটোর',
      dropLocation: json['dropLocation']?.toString() ?? 'যাত্রাবাড়ী আড়ত, ঢাকা',
      fishSpecies: json['fishSpecies']?.toString() ?? 'জ্যান্ত রুই ও কাতলা',
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0.0,
      isLive: json['isLive'] as bool? ?? true,
      vehicleType: json['vehicleType']?.toString() ?? 'oxygenPickup',
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
      totalFare: fare,
      fuelExpense: fuel,
      oxygenExpense: oxy,
      netIncome: net,
      survivalRate: (json['survivalRate'] as num?)?.toDouble() ?? 99.8,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      status: json['status']?.toString() ?? 'completed',
      completedAt: parseDate(json['completedAt']),
      createdAt: parseDate(json['createdAt']),
      notes: json['notes']?.toString(),
    );
  }

  FishTripModel copyWith({
    String? id,
    String? driverId,
    String? driverName,
    String? driverPhone,
    String? pickupLocation,
    String? dropLocation,
    String? fishSpecies,
    double? weightKg,
    bool? isLive,
    String? vehicleType,
    double? distanceKm,
    double? totalFare,
    double? fuelExpense,
    double? oxygenExpense,
    double? netIncome,
    double? survivalRate,
    double? rating,
    String? status,
    DateTime? completedAt,
    DateTime? createdAt,
    String? notes,
  }) {
    return FishTripModel(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropLocation: dropLocation ?? this.dropLocation,
      fishSpecies: fishSpecies ?? this.fishSpecies,
      weightKg: weightKg ?? this.weightKg,
      isLive: isLive ?? this.isLive,
      vehicleType: vehicleType ?? this.vehicleType,
      distanceKm: distanceKm ?? this.distanceKm,
      totalFare: totalFare ?? this.totalFare,
      fuelExpense: fuelExpense ?? this.fuelExpense,
      oxygenExpense: oxygenExpense ?? this.oxygenExpense,
      netIncome: netIncome ?? this.netIncome,
      survivalRate: survivalRate ?? this.survivalRate,
      rating: rating ?? this.rating,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
    );
  }
}
