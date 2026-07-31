import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:agrolinkbd/core/models/weather_model.dart';
import 'package:agrolinkbd/core/services/location_service.dart';
import 'package:agrolinkbd/core/constants/bd_location_data.dart';

class WeatherService {
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();

  /// Latitude & Longitude map for ALL 64 Bangladesh Districts
  static const Map<String, Map<String, dynamic>> _districtCoordinates = {
    // Rajshahi Division
    'Natore': {'lat': 24.4102, 'lng': 89.0076, 'name': 'নাটোর'},
    'Rajshahi': {'lat': 24.3745, 'lng': 88.6042, 'name': 'রাজশাহী'},
    'Bogra': {'lat': 24.8481, 'lng': 89.3730, 'name': 'বগুড়া'},
    'Bogura': {'lat': 24.8481, 'lng': 89.3730, 'name': 'বগুড়া'},
    'Pabna': {'lat': 24.0064, 'lng': 89.2494, 'name': 'পাবনা'},
    'Sirajganj': {'lat': 24.4534, 'lng': 89.7008, 'name': 'সিরাজগঞ্জ'},
    'Naogaon': {'lat': 24.7936, 'lng': 88.9318, 'name': 'নওগাঁ'},
    'Chapainawabganj': {'lat': 24.5965, 'lng': 88.2775, 'name': 'চাঁপাইনবাবগঞ্জ'},
    'Joypurhat': {'lat': 25.1017, 'lng': 89.0267, 'name': 'জয়পুরহাট'},

    // Dhaka Division
    'Dhaka': {'lat': 23.8103, 'lng': 90.4125, 'name': 'ঢাকা'},
    'Gazipur': {'lat': 23.9999, 'lng': 90.4203, 'name': 'গাজীপুর'},
    'Tangail': {'lat': 24.2513, 'lng': 89.9167, 'name': 'টাঙ্গাইল'},
    'Faridpur': {'lat': 23.6070, 'lng': 89.8406, 'name': 'ফরিদপুর'},
    'Gopalganj': {'lat': 23.0050, 'lng': 89.8266, 'name': 'গোপালগঞ্জ'},
    'Kishoreganj': {'lat': 24.4449, 'lng': 90.7765, 'name': 'কিশোরগঞ্জ'},
    'Madaripur': {'lat': 23.1641, 'lng': 90.1897, 'name': 'মাদারীপুর'},
    'Manikganj': {'lat': 23.8644, 'lng': 90.0047, 'name': 'মানিকগঞ্জ'},
    'Munshiganj': {'lat': 23.5422, 'lng': 90.5305, 'name': 'মুন্সীগঞ্জ'},
    'Narayanganj': {'lat': 23.6238, 'lng': 90.5000, 'name': 'নারায়ণগঞ্জ'},
    'Narsingdi': {'lat': 23.9193, 'lng': 90.7176, 'name': 'নরসিংদী'},
    'Rajbari': {'lat': 23.7574, 'lng': 89.6444, 'name': 'রাজবাড়ী'},
    'Shariatpur': {'lat': 23.2423, 'lng': 90.4348, 'name': 'শরীয়তপুর'},

    // Chattagram Division
    'Chittagong': {'lat': 22.3569, 'lng': 91.7832, 'name': 'চট্টগ্রাম'},
    'Chattogram': {'lat': 22.3569, 'lng': 91.7832, 'name': 'চট্টগ্রাম'},
    'Comilla': {'lat': 23.4607, 'lng': 91.1809, 'name': 'কুমিল্লা'},
    'Cumilla': {'lat': 23.4607, 'lng': 91.1809, 'name': 'কুমিল্লা'},
    'Coxsbazar': {'lat': 21.4272, 'lng': 92.0058, 'name': 'কক্সবাজার'},
    'Cox\'s Bazar': {'lat': 21.4272, 'lng': 92.0058, 'name': 'কক্সবাজার'},
    'Noakhali': {'lat': 22.8696, 'lng': 91.0993, 'name': 'নোয়াখালী'},
    'Brahmanbaria': {'lat': 23.9571, 'lng': 91.1119, 'name': 'ব্রাহ্মণবাড়িয়া'},
    'Chandpur': {'lat': 23.2321, 'lng': 90.6631, 'name': 'চাঁদপুর'},
    'Feni': {'lat': 23.0159, 'lng': 91.3976, 'name': 'ফেনী'},
    'Lakshmipur': {'lat': 22.9425, 'lng': 90.8412, 'name': 'লক্ষ্মীপুর'},
    'Bandarban': {'lat': 22.1953, 'lng': 92.2184, 'name': 'বান্দরবান'},
    'Khagrachhari': {'lat': 23.1193, 'lng': 91.9847, 'name': 'খাগড়াছড়ি'},
    'Rangamati': {'lat': 22.6574, 'lng': 92.1733, 'name': 'রাঙ্গামাটি'},

    // Khulna Division
    'Khulna': {'lat': 22.8456, 'lng': 89.5403, 'name': 'খুলনা'},
    'Jessore': {'lat': 23.1664, 'lng': 89.2081, 'name': 'যশোর'},
    'Jashore': {'lat': 23.1664, 'lng': 89.2081, 'name': 'যশোর'},
    'Kushtia': {'lat': 23.9013, 'lng': 89.1205, 'name': 'কুষ্টিয়া'},
    'Bagerhat': {'lat': 22.6516, 'lng': 89.7859, 'name': 'বাগেরহাট'},
    'Chuadanga': {'lat': 23.6402, 'lng': 88.8418, 'name': 'চুয়াডাঙ্গা'},
    'Jhenaidah': {'lat': 23.5448, 'lng': 89.1539, 'name': 'ঝিনাইদহ'},
    'Magura': {'lat': 23.4873, 'lng': 89.4199, 'name': 'মাগুরা'},
    'Meherpur': {'lat': 23.7622, 'lng': 88.6318, 'name': 'মেহেরপুর'},
    'Narail': {'lat': 23.1725, 'lng': 89.5126, 'name': 'নড়াইল'},
    'Satkhira': {'lat': 22.7185, 'lng': 89.0705, 'name': 'সাতক্ষীরা'},

    // Barisal Division
    'Barisal': {'lat': 22.7010, 'lng': 90.3535, 'name': 'বরিশাল'},
    'Barguna': {'lat': 22.1570, 'lng': 90.1249, 'name': 'বরগুনা'},
    'Bhola': {'lat': 22.6859, 'lng': 90.6481, 'name': 'ভোলা'},
    'Jhalakathi': {'lat': 22.6406, 'lng': 90.1987, 'name': 'ঝালকাঠি'},
    'Patuakhali': {'lat': 22.3596, 'lng': 90.3299, 'name': 'পটুয়াখালী'},
    'Pirojpur': {'lat': 22.5841, 'lng': 89.9720, 'name': 'পিরোজপুর'},

    // Sylhet Division
    'Sylhet': {'lat': 24.8949, 'lng': 91.8687, 'name': 'সিলেট'},
    'Habiganj': {'lat': 24.3749, 'lng': 91.4155, 'name': 'হবিগঞ্জ'},
    'Moulvibazar': {'lat': 24.4829, 'lng': 91.7774, 'name': 'মৌলভীবাজার'},
    'Sunamganj': {'lat': 25.0658, 'lng': 91.4073, 'name': 'সুনামগঞ্জ'},

    // Rangpur Division
    'Rangpur': {'lat': 25.7439, 'lng': 89.2752, 'name': 'রংপুর'},
    'Dinajpur': {'lat': 25.6217, 'lng': 88.6354, 'name': 'দিনাজপুর'},
    'Gaibandha': {'lat': 25.3288, 'lng': 89.5403, 'name': 'গাইবান্ধা'},
    'Kurigram': {'lat': 25.8054, 'lng': 89.6361, 'name': 'কুড়িগ্রাম'},
    'Lalmonirhat': {'lat': 25.9165, 'lng': 89.4532, 'name': 'লালমনিরহাট'},
    'Nilphamari': {'lat': 25.9318, 'lng': 88.8560, 'name': 'নীলফামারী'},
    'Panchagarh': {'lat': 26.3411, 'lng': 88.5541, 'name': 'পঞ্চগড়'},
    'Thakurgaon': {'lat': 26.0337, 'lng': 88.4617, 'name': 'ঠাকুরগাঁও'},

    // Mymensingh Division
    'Mymensingh': {'lat': 24.7471, 'lng': 90.4203, 'name': 'ময়মনসিংহ'},
    'Jamalpur': {'lat': 24.9375, 'lng': 89.9378, 'name': 'জামালপুর'},
    'Netrokona': {'lat': 24.8709, 'lng': 90.7279, 'name': 'নেত্রকোণা'},
    'Sherpur': {'lat': 25.0205, 'lng': 90.0153, 'name': 'শেরপুর'},
  };

  /// Upazila name mapping for English/Bengali names
  static String resolveDistrictFromUpazila(String upazilaOrDistrict) {
    if (upazilaOrDistrict.isEmpty) return 'Natore';
    final query = upazilaOrDistrict.trim().toLowerCase();

    // 1. Direct District check
    for (var dKey in _districtCoordinates.keys) {
      if (dKey.toLowerCase() == query || (_districtCoordinates[dKey]?['name'] as String?) == upazilaOrDistrict) {
        return dKey;
      }
    }

    // 2. Upazila lookup in BDLocationData
    for (var entry in BDLocationData.upazilasByDistrict.entries) {
      String distName = entry.key;
      List<String> upazilas = entry.value;
      for (var upa in upazilas) {
        if (upa.toLowerCase() == query) {
          return distName;
        }
      }
    }

    // 3. Known Upazila hardcoded aliases (Bengali & English)
    if (query.contains('gurudaspur') || query.contains('গুরুদাসপুর') || query.contains('natore') || query.contains('নাটোর')) {
      return 'Natore';
    }
    if (query.contains('savar') || query.contains('সাভার') || query.contains('dhamrai')) {
      return 'Dhaka';
    }

    return 'Natore'; // Default for user context fallback
  }

  /// Fetch live weather by GPS or District / Upazila
  Future<WeatherModel> fetchCurrentWeather({
    String? userDistrict,
    String? userUpazila,
    double? userLat,
    double? userLng,
  }) async {
    double lat = 24.4102; // Default Natore/Gurudaspur
    double lng = 89.0076;
    String locationDisplayName = 'গুরুদাসপুর, নাটোর';

    try {
      if (userLat != null && userLng != null) {
        lat = userLat;
        lng = userLng;
        locationDisplayName = userDistrict ?? 'আপনার অবস্থান (GPS)';
      } else {
        Position? position = await LocationService().getCurrentPosition();
        if (position != null) {
          lat = position.latitude;
          lng = position.longitude;
          String distResolved = userDistrict != null && userDistrict.isNotEmpty ? userDistrict : 'নাটোর';
          String upaResolved = userUpazila != null && userUpazila.isNotEmpty ? userUpazila : 'গুরুদাসপুর';
          locationDisplayName = '$upaResolved, $distResolved';
        } else {
          // Resolve from user Upazila / District strings
          String rawLocation = (userUpazila != null && userUpazila.isNotEmpty) ? userUpazila : (userDistrict ?? 'Natore');
          String targetDistrict = resolveDistrictFromUpazila(rawLocation);
          
          final mapped = _districtCoordinates[targetDistrict] ?? _districtCoordinates['Natore']!;
          lat = mapped['lat'] as double;
          lng = mapped['lng'] as double;

          String upaText = (userUpazila != null && userUpazila.isNotEmpty) ? userUpazila : 'গুরুদাসপুর';
          String distText = mapped['name'] as String;
          locationDisplayName = '$upaText, $distText';
        }
      }
    } catch (e) {
      debugPrint('📍 Weather location resolution warning: $e');
    }

    // 2. Fetch rich weather data from Open-Meteo REST API
    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lng'
        '&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,rain,weather_code,cloud_cover,wind_speed_10m,wind_direction_10m,surface_pressure,uv_index'
        '&hourly=temperature_2m,precipitation_probability,weather_code'
        '&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max'
        '&timezone=auto',
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
}
