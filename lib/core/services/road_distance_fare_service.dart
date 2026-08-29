import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:agrolinkbd/core/services/location_service.dart';

/// Vehicle Types for Agricultural Transport
enum AgroVehicleType {
  pickupVan,       // পিকআপ ভ্যান (১-১.৫ টন)
  mediumTruck,     // মাঝারি ট্রাক (৩-৫ টন)
  largeTruck,      // বড় ট্রাক (৭-১০ টন)
  oxygenFishVan,   // লাইভ ফিশ অক্সিজেন ভ্যান
  insulatedIceVan, // হিমায়িত/আইস ভ্যান
  tractorTrolley,  // ট্রাক্টর ট্রলি
  cngCarrier,      // সিএনজি এগ্রো ক্যারিয়ার
}

/// Comprehensive Road Route & Fare Calculation Result
class RouteFareEstimate {
  final double distanceKm;
  final int durationMinutes;
  final double baseFare;
  final double distanceFare;
  final double tollFee;
  final double totalFare;
  final double backhaulDiscountFare; // ফিরতি ট্রিপের ৪০% কম ভাড়া
  final String vehicleNameBangla;
  final String estimatedTimeText;
  final bool isRoadRoutingOnline;
  final List<String> applicableTolls;

  RouteFareEstimate({
    required this.distanceKm,
    required this.durationMinutes,
    required this.baseFare,
    required this.distanceFare,
    required this.tollFee,
    required this.totalFare,
    required this.backhaulDiscountFare,
    required this.vehicleNameBangla,
    required this.estimatedTimeText,
    required this.isRoadRoutingOnline,
    required this.applicableTolls,
  });
}

class RoadDistanceFareService {
  static final RoadDistanceFareService _instance = RoadDistanceFareService._internal();
  factory RoadDistanceFareService() => _instance;
  RoadDistanceFareService._internal();

  final LocationService _locationService = LocationService();

  /// Vehicle Pricing Matrix
  static const Map<AgroVehicleType, Map<String, dynamic>> vehicleRates = {
    AgroVehicleType.pickupVan: {
      'nameBn': 'পিকআপ ভ্যান (১-১.৫ টন)',
      'base': 800.0,
      'perKm': 25.0,
      'capacity': '১.৫ টন',
    },
    AgroVehicleType.mediumTruck: {
      'nameBn': 'মাঝারি ট্রাক (৩-৫ টন)',
      'base': 1500.0,
      'perKm': 35.0,
      'capacity': '৫ টন',
    },
    AgroVehicleType.largeTruck: {
      'nameBn': 'বড় ট্রাক (৭-১০ টন)',
      'base': 2500.0,
      'perKm': 45.0,
      'capacity': '১০ টন',
    },
    AgroVehicleType.oxygenFishVan: {
      'nameBn': 'লাইভ মাছ অক্সিজেন ভ্যান',
      'base': 1800.0,
      'perKm': 40.0,
      'capacity': 'অক্সিজেন ট্যাংক সহ',
    },
    AgroVehicleType.insulatedIceVan: {
      'nameBn': 'হিমায়িত/আইস ভ্যান',
      'base': 2000.0,
      'perKm': 42.0,
      'capacity': 'কোল্ড চেইন ৩ টন',
    },
    AgroVehicleType.tractorTrolley: {
      'nameBn': 'পাওয়ার টিলার/ট্রাক্টর ট্রলি',
      'base': 500.0,
      'perKm': 20.0,
      'capacity': '২ টন (লোকাল)',
    },
    AgroVehicleType.cngCarrier: {
      'nameBn': 'সিএনজি এগ্রো ক্যারিয়ার',
      'base': 300.0,
      'perKm': 15.0,
      'capacity': '৫০০ কেজি',
    },
  };

  /// 100% Free Road Distance & Duration using OpenStreetMap OSRM Routing API
  Future<Map<String, dynamic>> getFreeRoadDistanceAndDuration({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    // 1. Try public free OSRM Routing API
    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/$startLng,$startLat;$endLng,$endLat?overview=false',
      );
      final response = await http.get(
        url,
        headers: {'User-Agent': 'AgroLinkBD-App/1.0 (info@agrolinkbd.com)'},
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'] as List<dynamic>?;
        if (routes != null && routes.isNotEmpty) {
          final route = routes[0];
          final double distanceMeters = (route['distance'] as num).toDouble();
          final double durationSeconds = (route['duration'] as num).toDouble();

          final double km = distanceMeters / 1000.0;
          final int minutes = (durationSeconds / 60.0).round();

          return {
            'distanceKm': km,
            'durationMinutes': minutes,
            'isOnline': true,
          };
        }
      }
    } catch (e) {
      debugPrint('OSRM free routing warning: $e');
    }

    // 2. Offline Fallback: Haversine Geodesic Distance × 1.28 (Bangladesh Road Curvature Factor)
    double straightKm = _haversineKm(startLat, startLng, endLat, endLng);
    double roadKm = straightKm * 1.28; // Empirical highway tortuosity factor in BD
    if (roadKm < 2.0) roadKm = 2.0;

    // Average driving speed in Bangladesh highways/regional roads ~ 40 km/h
    int estMinutes = ((roadKm / 40.0) * 60).round() + 15;

    return {
      'distanceKm': double.parse(roadKm.toStringAsFixed(1)),
      'durationMinutes': estMinutes,
      'isOnline': false,
    };
  }

  /// Calculate Exact Fare for Vehicle, Distance, Tolls, and Backhaul Discount
  Future<RouteFareEstimate> calculateFare({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    AgroVehicleType vehicleType = AgroVehicleType.pickupVan,
    bool isReturnTrip = false,
  }) async {
    final routeInfo = await getFreeRoadDistanceAndDuration(
      startLat: startLat,
      startLng: startLng,
      endLat: endLat,
      endLng: endLng,
    );

    final double distanceKm = routeInfo['distanceKm'] as double;
    final int durationMinutes = routeInfo['durationMinutes'] as int;
    final bool isOnline = routeInfo['isOnline'] as bool;

    final rateConfig = vehicleRates[vehicleType] ?? vehicleRates[AgroVehicleType.pickupVan]!;
    final double baseRate = rateConfig['base'] as double;
    final double perKmRate = rateConfig['perKm'] as double;
    final String nameBn = rateConfig['nameBn'] as String;

    // Calculate Tolls
    final tolls = _detectMajorBridges(startLat, startLng, endLat, endLng, vehicleType);
    double totalToll = 0;
    for (var toll in tolls) {
      totalToll += toll['fee'] as double;
    }

    double distanceFare = distanceKm * perKmRate;
    double grossFare = baseRate + distanceFare + totalToll;

    // Return trip backhaul discount: 40% off the distance fare
    double backhaulDiscountFare = (baseRate * 0.7) + (distanceFare * 0.6) + totalToll;

    String timeText;
    if (durationMinutes >= 60) {
      final hours = durationMinutes ~/ 60;
      final mins = durationMinutes % 60;
      timeText = '$hours ঘণ্টা $mins মিনিট';
    } else {
      timeText = '$durationMinutes মিনিট';
    }

    return RouteFareEstimate(
      distanceKm: double.parse(distanceKm.toStringAsFixed(1)),
      durationMinutes: durationMinutes,
      baseFare: baseRate,
      distanceFare: double.parse(distanceFare.toStringAsFixed(0)),
      tollFee: totalToll,
      totalFare: isReturnTrip ? double.parse(backhaulDiscountFare.toStringAsFixed(0)) : double.parse(grossFare.toStringAsFixed(0)),
      backhaulDiscountFare: double.parse(backhaulDiscountFare.toStringAsFixed(0)),
      vehicleNameBangla: nameBn,
      estimatedTimeText: timeText,
      isRoadRoutingOnline: isOnline,
      applicableTolls: tolls.map((t) => '${t['name']} (৳${t['fee'].toInt()})').toList(),
    );
  }

  /// Calculate distance between two named districts (e.g. 'Natore' to 'Dhaka')
  Future<RouteFareEstimate?> calculateFareBetweenDistricts({
    required String pickupDistrict,
    required String dropoffDistrict,
    AgroVehicleType vehicleType = AgroVehicleType.pickupVan,
    bool isReturnTrip = false,
  }) async {
    final pickupCoords = _locationService.getDistrictCoordinates(pickupDistrict);
    final dropoffCoords = _locationService.getDistrictCoordinates(dropoffDistrict);

    if (pickupCoords == null || dropoffCoords == null) return null;

    return await calculateFare(
      startLat: pickupCoords['lat']!,
      startLng: pickupCoords['lng']!,
      endLat: dropoffCoords['lat']!,
      endLng: dropoffCoords['lng']!,
      vehicleType: vehicleType,
      isReturnTrip: isReturnTrip,
    );
  }

  /// Detect Bangladesh Major Toll Bridges (Padma, Jamuna, Meghna) on route
  List<Map<String, dynamic>> _detectMajorBridges(
      double lat1, double lng1, double lat2, double lng2, AgroVehicleType vType) {
    List<Map<String, dynamic>> detected = [];

    // Padma Bridge Check (Crossing Southern to Central/Dhaka: Lat crossing ~23.45, Lng ~90.26)
    if ((lat1 < 23.3 && lat2 > 23.6) || (lat1 > 23.6 && lat2 < 23.3)) {
      if ((lng1 < 90.5 && lng2 > 89.5) || (lng1 > 89.5 && lng2 < 90.5)) {
        double fee = (vType == AgroVehicleType.largeTruck || vType == AgroVehicleType.mediumTruck) ? 1400.0 : 800.0;
        detected.add({'name': 'পদ্মা সেতু টোল', 'fee': fee});
      }
    }

    // Bangabandhu / Jamuna Bridge Check (Crossing Western/Northern to Central/Dhaka: Lng crossing ~89.75)
    if ((lng1 < 89.5 && lng2 > 90.0) || (lng1 > 90.0 && lng2 < 89.5)) {
      if ((lat1 > 23.8 && lat2 > 23.8)) {
        double fee = (vType == AgroVehicleType.largeTruck || vType == AgroVehicleType.mediumTruck) ? 1400.0 : 900.0;
        detected.add({'name': 'বঙ্গবন্ধু যমুনা সেতু টোল', 'fee': fee});
      }
    }

    // Meghna Bridge Check (Crossing Eastern/Chattogram/Sylhet to Dhaka: Lng crossing ~90.6)
    if ((lng1 < 90.4 && lng2 > 90.8) || (lng1 > 90.8 && lng2 < 90.4)) {
      detected.add({'name': 'মেঘনা ও গোমতী সেতু টোল', 'fee': 300.0});
    }

    return detected;
  }

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const double p = 0.017453292519943295;
    final a = 0.5 - cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}
