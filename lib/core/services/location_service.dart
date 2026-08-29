import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

/// Structured Result for Geocoded Location in Bangladesh
class LocationAddressResult {
  final String district;
  final String districtBangla;
  final String upazila;
  final String upazilaBangla;
  final String division;
  final String divisionBangla;
  final String formattedAddress;
  final double latitude;
  final double longitude;
  final bool isGpsPrecise;

  LocationAddressResult({
    required this.district,
    required this.districtBangla,
    required this.upazila,
    required this.upazilaBangla,
    required this.division,
    required this.divisionBangla,
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
    this.isGpsPrecise = true,
  });
}

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // 64 Bangladesh Districts Database with Lat/Lng and Bangla names
  static const Map<String, Map<String, dynamic>> bdDistrictMap = {
    'Dhaka': {'lat': 23.8103, 'lng': 90.4125, 'nameBn': 'ঢাকা', 'div': 'Dhaka', 'divBn': 'ঢাকা'},
    'Gazipur': {'lat': 24.0023, 'lng': 90.4264, 'nameBn': 'গাজীপুর', 'div': 'Dhaka', 'divBn': 'ঢাকা'},
    'Narayanganj': {'lat': 23.6238, 'lng': 90.5000, 'nameBn': 'নারায়ণগঞ্জ', 'div': 'Dhaka', 'divBn': 'ঢাকা'},
    'Tangail': {'lat': 24.2513, 'lng': 89.9167, 'nameBn': 'টাঙ্গাইল', 'div': 'Dhaka', 'divBn': 'ঢাকা'},
    'Faridpur': {'lat': 23.6071, 'lng': 89.8429, 'nameBn': 'ফরিদপুর', 'div': 'Dhaka', 'divBn': 'ঢাকা'},
    'Manikganj': {'lat': 23.8617, 'lng': 90.0003, 'nameBn': 'মানিকগঞ্জ', 'div': 'Dhaka', 'divBn': 'ঢাকা'},
    'Munshiganj': {'lat': 23.5422, 'lng': 90.5305, 'nameBn': 'মুন্সীগঞ্জ', 'div': 'Dhaka', 'divBn': 'ঢাকা'},
    'Narsingdi': {'lat': 23.9322, 'lng': 90.7154, 'nameBn': 'নরসিংদী', 'div': 'Dhaka', 'divBn': 'ঢাকা'},
    'Gopalganj': {'lat': 23.0051, 'lng': 89.8266, 'nameBn': 'গোপালগঞ্জ', 'div': 'Dhaka', 'divBn': 'ঢাকা'},
    'Madaripur': {'lat': 23.1641, 'lng': 90.1897, 'nameBn': 'মাদারীপুর', 'div': 'Dhaka', 'divBn': 'ঢাকা'},
    'Rajbari': {'lat': 23.7574, 'lng': 89.6445, 'nameBn': 'রাজবাড়ী', 'div': 'Dhaka', 'divBn': 'ঢাকা'},
    'Shariatpur': {'lat': 23.2423, 'lng': 90.4348, 'nameBn': 'শরীয়তপুর', 'div': 'Dhaka', 'divBn': 'ঢাকা'},
    'Kishoreganj': {'lat': 24.4449, 'lng': 90.7766, 'nameBn': 'কিশোরগঞ্জ', 'div': 'Dhaka', 'divBn': 'ঢাকা'},

    // Chattogram Division
    'Chattogram': {'lat': 22.3569, 'lng': 91.7832, 'nameBn': 'চট্টগ্রাম', 'div': 'Chattogram', 'divBn': 'চট্টগ্রাম'},
    'Coxsbazar': {'lat': 21.4272, 'lng': 92.0058, 'nameBn': 'কক্সবাজার', 'div': 'Chattogram', 'divBn': 'চট্টগ্রাম'},
    'Cumilla': {'lat': 23.4607, 'lng': 91.1809, 'nameBn': 'কুমিল্লা', 'div': 'Chattogram', 'divBn': 'চট্টগ্রাম'},
    'Feni': {'lat': 23.0159, 'lng': 91.3976, 'nameBn': 'ফেনী', 'div': 'Chattogram', 'divBn': 'চট্টগ্রাম'},
    'Brahmanbaria': {'lat': 23.9571, 'lng': 91.1119, 'nameBn': 'ব্রাহ্মণবাড়িয়া', 'div': 'Chattogram', 'divBn': 'চট্টগ্রাম'},
    'Chandpur': {'lat': 23.2333, 'lng': 90.6667, 'nameBn': 'চাঁদপুর', 'div': 'Chattogram', 'divBn': 'চট্টগ্রাম'},
    'Noakhali': {'lat': 22.8696, 'lng': 91.0995, 'nameBn': 'নোয়াখালী', 'div': 'Chattogram', 'divBn': 'চট্টগ্রাম'},
    'Lakshmipur': {'lat': 22.9425, 'lng': 90.8412, 'nameBn': 'লক্ষ্মীপুর', 'div': 'Chattogram', 'divBn': 'চট্টগ্রাম'},
    'Rangamati': {'lat': 22.7324, 'lng': 92.2985, 'nameBn': 'রাঙ্গামাটি', 'div': 'Chattogram', 'divBn': 'চট্টগ্রাম'},
    'Khagrachhari': {'lat': 23.1193, 'lng': 91.9847, 'nameBn': 'খাগড়াছড়ি', 'div': 'Chattogram', 'divBn': 'চট্টগ্রাম'},
    'Bandarban': {'lat': 22.1953, 'lng': 92.2184, 'nameBn': 'বান্দরবান', 'div': 'Chattogram', 'divBn': 'চট্টগ্রাম'},

    // Rajshahi Division
    'Rajshahi': {'lat': 24.3745, 'lng': 88.6042, 'nameBn': 'রাজশাহী', 'div': 'Rajshahi', 'divBn': 'রাজশাহী'},
    'Bogura': {'lat': 24.8465, 'lng': 89.3777, 'nameBn': 'বগুড়া', 'div': 'Rajshahi', 'divBn': 'রাজশাহী'},
    'Pabna': {'lat': 24.0064, 'lng': 89.2372, 'nameBn': 'পাবনা', 'div': 'Rajshahi', 'divBn': 'রাজশাহী'},
    'Sirajganj': {'lat': 24.4534, 'lng': 89.7008, 'nameBn': 'সিরাজগঞ্জ', 'div': 'Rajshahi', 'divBn': 'রাজশাহী'},
    'Natore': {'lat': 24.4102, 'lng': 89.0076, 'nameBn': 'নাটোর', 'div': 'Rajshahi', 'divBn': 'রাজশাহী'},
    'Naogaon': {'lat': 24.7936, 'lng': 88.9318, 'nameBn': 'নওগাঁ', 'div': 'Rajshahi', 'divBn': 'রাজশাহী'},
    'Chapainawabganj': {'lat': 24.5965, 'lng': 88.2775, 'nameBn': 'চাঁপাইনবাবগঞ্জ', 'div': 'Rajshahi', 'divBn': 'রাজশাহী'},
    'Joypurhat': {'lat': 25.1017, 'lng': 89.0277, 'nameBn': 'জয়পুরহাট', 'div': 'Rajshahi', 'divBn': 'রাজশাহী'},

    // Khulna Division
    'Khulna': {'lat': 22.8456, 'lng': 89.5403, 'nameBn': 'খুলনা', 'div': 'Khulna', 'divBn': 'খুলনা'},
    'Jashore': {'lat': 23.1664, 'lng': 89.2081, 'nameBn': 'যশোর', 'div': 'Khulna', 'divBn': 'খুলনা'},
    'Kushtia': {'lat': 23.9013, 'lng': 89.1205, 'nameBn': 'কুষ্টিয়া', 'div': 'Khulna', 'divBn': 'খুলনা'},
    'Satkhira': {'lat': 22.7185, 'lng': 89.0705, 'nameBn': 'সাতক্ষীরা', 'div': 'Khulna', 'divBn': 'খুলনা'},
    'Bagerhat': {'lat': 22.6516, 'lng': 89.7859, 'nameBn': 'বাগেরহাট', 'div': 'Khulna', 'divBn': 'খুলনা'},
    'Jhenaidah': {'lat': 23.5448, 'lng': 89.1539, 'nameBn': 'ঝিনাইদহ', 'div': 'Khulna', 'divBn': 'খুলনা'},
    'Chuadanga': {'lat': 23.6402, 'lng': 88.8418, 'nameBn': 'চুয়াডাঙ্গা', 'div': 'Khulna', 'divBn': 'খুলনা'},
    'Meherpur': {'lat': 23.7622, 'lng': 88.6318, 'nameBn': 'মেহেরপুর', 'div': 'Khulna', 'divBn': 'খুলনা'},
    'Narail': {'lat': 23.1725, 'lng': 89.5127, 'nameBn': 'নড়াইল', 'div': 'Khulna', 'divBn': 'খুলনা'},
    'Magura': {'lat': 23.4873, 'lng': 89.4199, 'nameBn': 'মাগুরা', 'div': 'Khulna', 'divBn': 'খুলনা'},

    // Barishal Division
    'Barishal': {'lat': 22.7010, 'lng': 90.3535, 'nameBn': 'বরিশাল', 'div': 'Barishal', 'divBn': 'বরিশাল'},
    'Patuakhali': {'lat': 22.3596, 'lng': 90.3299, 'nameBn': 'পটুয়াখালী', 'div': 'Barishal', 'divBn': 'বরিশাল'},
    'Bhola': {'lat': 22.6859, 'lng': 90.6482, 'nameBn': 'ভোলা', 'div': 'Barishal', 'divBn': 'বরিশাল'},
    'Pirojpur': {'lat': 22.5841, 'lng': 89.9720, 'nameBn': 'পিরোজপুর', 'div': 'Barishal', 'divBn': 'বরিশাল'},
    'Barguna': {'lat': 22.1570, 'lng': 90.1256, 'nameBn': 'বরগুনা', 'div': 'Barishal', 'divBn': 'বরিশাল'},
    'Jhalokati': {'lat': 22.6406, 'lng': 90.1987, 'nameBn': 'ঝালকাঠি', 'div': 'Barishal', 'divBn': 'বরিশাল'},

    // Sylhet Division
    'Sylhet': {'lat': 24.8949, 'lng': 91.8687, 'nameBn': 'সিলেট', 'div': 'Sylhet', 'divBn': 'সিলেট'},
    'Moulvibazar': {'lat': 24.4829, 'lng': 91.7774, 'nameBn': 'মৌলভীবাজার', 'div': 'Sylhet', 'divBn': 'সিলেট'},
    'Habiganj': {'lat': 24.3749, 'lng': 91.4155, 'nameBn': 'হবিগঞ্জ', 'div': 'Sylhet', 'divBn': 'সিলেট'},
    'Sunamganj': {'lat': 25.0658, 'lng': 91.3950, 'nameBn': 'সুনামগঞ্জ', 'div': 'Sylhet', 'divBn': 'সিলেট'},

    // Rangpur Division
    'Rangpur': {'lat': 25.7439, 'lng': 89.2752, 'nameBn': 'রংপুর', 'div': 'Rangpur', 'divBn': 'রংপুর'},
    'Dinajpur': {'lat': 25.6217, 'lng': 88.6354, 'nameBn': 'দিনাজপুর', 'div': 'Rangpur', 'divBn': 'রংপুর'},
    'Kurigram': {'lat': 25.8054, 'lng': 89.6362, 'nameBn': 'কুড়িগ্রাম', 'div': 'Rangpur', 'divBn': 'রংপুর'},
    'Gaibandha': {'lat': 25.3288, 'lng': 89.5406, 'nameBn': 'গাইবান্ধা', 'div': 'Rangpur', 'divBn': 'রংপুর'},
    'Nilphamari': {'lat': 25.9318, 'lng': 88.8560, 'nameBn': 'নীলফামারী', 'div': 'Rangpur', 'divBn': 'রংপুর'},
    'Lalmonirhat': {'lat': 25.9923, 'lng': 89.2847, 'nameBn': 'লালমনিরহাট', 'div': 'Rangpur', 'divBn': 'রংপুর'},
    'Thakurgaon': {'lat': 26.0337, 'lng': 88.4617, 'nameBn': 'ঠাকুরগাঁও', 'div': 'Rangpur', 'divBn': 'রংপুর'},
    'Panchagarh': {'lat': 26.3411, 'lng': 88.5542, 'nameBn': 'পঞ্চগড়', 'div': 'Rangpur', 'divBn': 'রংপুর'},

    // Mymensingh Division
    'Mymensingh': {'lat': 24.7471, 'lng': 90.4203, 'nameBn': 'ময়মনসিংহ', 'div': 'Mymensingh', 'divBn': 'ময়মনসিংহ'},
    'Jamalpur': {'lat': 24.9375, 'lng': 89.9378, 'nameBn': 'জামালপুর', 'div': 'Mymensingh', 'divBn': 'ময়মনসিংহ'},
    'Netrokona': {'lat': 24.8709, 'lng': 90.7279, 'nameBn': 'নেত্রকোণা', 'div': 'Mymensingh', 'divBn': 'ময়মনসিংহ'},
    'Sherpur': {'lat': 25.0205, 'lng': 90.0153, 'nameBn': 'শেরপুর', 'div': 'Mymensingh', 'divBn': 'ময়মনসিংহ'},
  };

  Future<void> initialize() async {
    await requestLocationPermission();
  }

  // Request location permission
  Future<bool> requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
    } catch (e) {
      PermissionStatus status = await Permission.location.request();
      return status.isGranted;
    }
  }

  // Check if location permission is granted
  Future<bool> isLocationPermissionGranted() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
    } catch (e) {
      PermissionStatus status = await Permission.location.status;
      return status.isGranted;
    }
  }

  // Get current position with timeout
  Future<Position?> getCurrentPosition() async {
    bool hasPermission = await isLocationPermissionGranted();
    if (!hasPermission) {
      hasPermission = await requestLocationPermission();
      if (!hasPermission) return null;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 7),
      );
      return position;
    } catch (e) {
      try {
        // Fallback to last known position
        Position? lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) return lastKnown;
      } catch (_) {}
      debugPrint('Error getting precise GPS: $e');
      return null;
    }
  }

  // Calculate distance between two coordinates (in km)
  double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
          startLatitude,
          startLongitude,
          endLatitude,
          endLongitude,
        ) /
        1000; // Convert to km
  }

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Get continuous location stream
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50, // Update every 50 meters
      ),
    );
  }

  /// 100% Free Reverse Geocoding via OpenStreetMap / Nominatim API + Offline BD Database
  Future<LocationAddressResult> resolveAddressFromCoordinates(double lat, double lng) async {
    // 1. Try Free OpenStreetMap Nominatim API
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1&accept-language=bn,en',
      );
      final response = await http.get(
        url,
        headers: {'User-Agent': 'AgroLinkBD-App/1.0 (info@agrolinkbd.com)'},
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'] as Map<String, dynamic>?;

        if (address != null) {
          String rawDistrict = address['state_district'] ?? address['county'] ?? address['city'] ?? '';
          String rawUpazila = address['suburb'] ?? address['municipality'] ?? address['town'] ?? address['village'] ?? address['neighbourhood'] ?? '';

          // Clean district string
          String districtKey = _normalizeDistrictName(rawDistrict);
          if (districtKey.isEmpty) {
            districtKey = getNearestDistrictKey(lat, lng);
          }

          final distInfo = bdDistrictMap[districtKey] ?? bdDistrictMap['Dhaka']!;
          String upaName = rawUpazila.isNotEmpty ? rawUpazila : '${distInfo['nameBn']} সদর';
          String formatted = '$upaName, ${distInfo['nameBn']} (${distInfo['divBn']})';

          return LocationAddressResult(
            district: districtKey,
            districtBangla: distInfo['nameBn'],
            upazila: rawUpazila.isNotEmpty ? rawUpazila : '$districtKey Sadar',
            upazilaBangla: upaName,
            division: distInfo['div'],
            divisionBangla: distInfo['divBn'],
            formattedAddress: formatted,
            latitude: lat,
            longitude: lng,
            isGpsPrecise: true,
          );
        }
      }
    } catch (e) {
      debugPrint('Nominatim free geocoding warning: $e');
    }

    // 2. Offline Fallback using Nearest BD District Matrix
    final districtKey = getNearestDistrictKey(lat, lng);
    final distInfo = bdDistrictMap[districtKey] ?? bdDistrictMap['Dhaka']!;

    return LocationAddressResult(
      district: districtKey,
      districtBangla: distInfo['nameBn'],
      upazila: '$districtKey Sadar',
      upazilaBangla: '${distInfo['nameBn']} সদর',
      division: distInfo['div'],
      divisionBangla: distInfo['divBn'],
      formattedAddress: '${distInfo['nameBn']} সদর, ${distInfo['nameBn']} (${distInfo['divBn']})',
      latitude: lat,
      longitude: lng,
      isGpsPrecise: false,
    );
  }

  /// Automatically get current real location formatted address
  Future<LocationAddressResult> getCurrentLocationAddress() async {
    final pos = await getCurrentPosition();
    if (pos != null) {
      return await resolveAddressFromCoordinates(pos.latitude, pos.longitude);
    }

    // Default fallback to Dhaka Center
    return LocationAddressResult(
      district: 'Dhaka',
      districtBangla: 'ঢাকা',
      upazila: 'Dhaka Sadar',
      upazilaBangla: 'ঢাকা সদর',
      division: 'Dhaka',
      divisionBangla: 'ঢাকা',
      formattedAddress: 'ঢাকা সদর, ঢাকা',
      latitude: 23.8103,
      longitude: 90.4125,
      isGpsPrecise: false,
    );
  }

  /// Find nearest district key using Haversine algorithm
  String getNearestDistrictKey(double lat, double lng) {
    String nearestKey = 'Dhaka';
    double minDistance = double.infinity;

    bdDistrictMap.forEach((key, val) {
      double dLat = val['lat'] as double;
      double dLng = val['lng'] as double;
      double dist = _haversineKm(lat, lng, dLat, dLng);
      if (dist < minDistance) {
        minDistance = dist;
        nearestKey = key;
      }
    });

    return nearestKey;
  }

  /// Get coordinates for any district name (Bangla or English)
  Map<String, double>? getDistrictCoordinates(String name) {
    String cleanName = _normalizeDistrictName(name);
    if (bdDistrictMap.containsKey(cleanName)) {
      return {
        'lat': bdDistrictMap[cleanName]!['lat'] as double,
        'lng': bdDistrictMap[cleanName]!['lng'] as double,
      };
    }
    return null;
  }

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const double p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 - cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R * asin...
  }

  String _normalizeDistrictName(String raw) {
    String text = raw.trim().toLowerCase().replaceAll('জেলা', '').replaceAll('district', '').trim();
    for (var key in bdDistrictMap.keys) {
      if (key.toLowerCase() == text || bdDistrictMap[key]!['nameBn'] == raw.trim()) {
        return key;
      }
    }
    for (var key in bdDistrictMap.keys) {
      if (text.contains(key.toLowerCase()) || text.contains(bdDistrictMap[key]!['nameBn'])) {
        return key;
      }
    }
    return '';
  }
}
