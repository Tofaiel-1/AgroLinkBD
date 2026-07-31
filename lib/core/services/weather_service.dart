import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:agrolinkbd/core/models/weather_model.dart';
import 'package:agrolinkbd/core/services/location_service.dart';

class WeatherService {
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();

  /// Latitude & Longitude map for major Bangladesh Districts
  static const Map<String, Map<String, double>> _districtCoordinates = {
    'Dhaka': {'lat': 23.8103, 'lng': 90.4125, 'name': 'ঢাকা'},
    'Gazipur': {'lat': 23.9999, 'lng': 90.4203, 'name': 'গাজীপুর'},
    'Rajshahi': {'lat': 24.3745, 'lng': 88.6042, 'name': 'রাজশাহী'},
    'Chittagong': {'lat': 22.3569, 'lng': 91.7832, 'name': 'চট্টগ্রাম'},
    'Chattogram': {'lat': 22.3569, 'lng': 91.7832, 'name': 'চট্টগ্রাম'},
    'Sylhet': {'lat': 24.8949, 'lng': 91.8687, 'name': 'সিলেট'},
    'Khulna': {'lat': 22.8456, 'lng': 89.5403, 'name': 'খুলনা'},
    'Barisal': {'lat': 22.7010, 'lng': 90.3535, 'name': 'বরিশাল'},
    'Rangpur': {'lat': 25.7439, 'lng': 89.2752, 'name': 'রংপুর'},
    'Mymensingh': {'lat': 24.7471, 'lng': 90.4203, 'name': 'ময়মনসিংহ'},
    'Comilla': {'lat': 23.4607, 'lng': 91.1809, 'name': 'কুমিল্লা'},
    'Cumilla': {'lat': 23.4607, 'lng': 91.1809, 'name': 'কুমিল্লা'},
    'Bogra': {'lat': 24.8481, 'lng': 89.3730, 'name': 'বগুড়া'},
    'Jessore': {'lat': 23.1664, 'lng': 89.2081, 'name': 'যশোর'},
    'Dinajpur': {'lat': 25.6217, 'lng': 88.6354, 'name': 'দিনাজপুর'},
    'Pabna': {'lat': 24.0064, 'lng': 89.2494, 'name': 'পাবনা'},
    'Faridpur': {'lat': 23.6070, 'lng': 89.8406, 'name': 'ফরিদপুর'},
    'Noakhali': {'lat': 22.8696, 'lng': 91.0993, 'name': 'নোয়াখালী'},
    'Tangail': {'lat': 24.2513, 'lng': 89.9167, 'name': 'টাঙ্গাইল'},
    'Cox\'s Bazar': {'lat': 21.4272, 'lng': 92.0058, 'name': 'কক্সবাজার'},
  };

  /// Fetch live weather by GPS or District
  Future<WeatherModel> fetchCurrentWeather({
    String? userDistrict,
    String? userUpazila,
    double? userLat,
    double? userLng,
  }) async {
    double lat = 23.9999;
    double lng = 90.4203;
    String locationDisplayName = 'গাজীপুর, ঢাকা';

    // 1. Try GPS location if provided or via LocationService
    try {
      if (userLat != null && userLng != null) {
        lat = userLat;
        lng = userLng;
        locationDisplayName = userDistrict ?? 'আপনার বর্তমান অবস্থান';
      } else {
        Position? position = await LocationService().getCurrentPosition();
        if (position != null) {
          lat = position.latitude;
          lng = position.longitude;
          locationDisplayName = userDistrict != null && userDistrict.isNotEmpty
              ? '${userUpazila != null ? "$userUpazila, " : ""}$userDistrict'
              : 'আপনার অবস্থান (GPS)';
        } else if (userDistrict != null && userDistrict.isNotEmpty) {
          // Resolve district coordinates
          final mapped = _resolveDistrict(userDistrict);
          lat = mapped['lat'] as double;
          lng = mapped['lng'] as double;
          locationDisplayName = '${userUpazila != null && userUpazila.isNotEmpty ? "$userUpazila, " : ""}${mapped['name']}';
        }
      }
    } catch (e) {
      debugPrint('📍 Weather location resolution warning: $e');
    }

    // 2. Fetch from Open-Meteo REST API
    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lng&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,rain,weather_code,wind_speed_10m&hourly=precipitation_probability&timezone=auto',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherModel.fromJson(data, locationDisplayName);
      } else {
        debugPrint('❌ Open-Meteo API returned status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('⚠️ Weather fetch network error: $e');
    }

    // 3. Fallback
    return WeatherModel.defaultFallback(locationDisplayName);
  }

  Map<String, dynamic> _resolveDistrict(String district) {
    final key = _districtCoordinates.keys.firstWhere(
      (k) => k.toLowerCase() == district.trim().toLowerCase(),
      orElse: () => 'Gazipur',
    );
    return _districtCoordinates[key]!;
  }
}
