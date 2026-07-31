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

  /// Latitude, Longitude, Bengali Name & Division map for ALL 64 Bangladesh Districts
  static const Map<String, Map<String, dynamic>> _districtCoordinates = {
    // Rajshahi Division
    'Natore': {'lat': 24.4102, 'lng': 89.0076, 'name': 'নাটোর', 'division': 'রাজশাহী'},
    'Rajshahi': {'lat': 24.3745, 'lng': 88.6042, 'name': 'রাজশাহী', 'division': 'রাজশাহী'},
    'Bogra': {'lat': 24.8481, 'lng': 89.3730, 'name': 'বগুড়া', 'division': 'রাজশাহী'},
    'Bogura': {'lat': 24.8481, 'lng': 89.3730, 'name': 'বগুড়া', 'division': 'রাজশাহী'},
    'Pabna': {'lat': 24.0064, 'lng': 89.2494, 'name': 'পাবনা', 'division': 'রাজশাহী'},
    'Sirajganj': {'lat': 24.4534, 'lng': 89.7008, 'name': 'সিরাজগঞ্জ', 'division': 'রাজশাহী'},
    'Naogaon': {'lat': 24.7936, 'lng': 88.9318, 'name': 'নওগাঁ', 'division': 'রাজশাহী'},
    'Chapainawabganj': {'lat': 24.5965, 'lng': 88.2775, 'name': 'চাঁপাইনবাবগঞ্জ', 'division': 'রাজশাহী'},
    'Joypurhat': {'lat': 25.1017, 'lng': 89.0267, 'name': 'জয়পুরহাট', 'division': 'রাজশাহী'},

    // Dhaka Division
    'Dhaka': {'lat': 23.8103, 'lng': 90.4125, 'name': 'ঢাকা', 'division': 'ঢাকা'},
    'Gazipur': {'lat': 23.9999, 'lng': 90.4203, 'name': 'গাজীপুর', 'division': 'ঢাকা'},
    'Tangail': {'lat': 24.2513, 'lng': 89.9167, 'name': 'টাঙ্গাইল', 'division': 'ঢাকা'},
    'Faridpur': {'lat': 23.6070, 'lng': 89.8406, 'name': 'ফরিদপুর', 'division': 'ঢাকা'},
    'Gopalganj': {'lat': 23.0050, 'lng': 89.8266, 'name': 'গোপালগঞ্জ', 'division': 'ঢাকা'},
    'Kishoreganj': {'lat': 24.4449, 'lng': 90.7765, 'name': 'কিশোরগঞ্জ', 'division': 'ঢাকা'},
    'Madaripur': {'lat': 23.1641, 'lng': 90.1897, 'name': 'মাদারীপুর', 'division': 'ঢাকা'},
    'Manikganj': {'lat': 23.8644, 'lng': 90.0047, 'name': 'মানিকগঞ্জ', 'division': 'ঢাকা'},
    'Munshiganj': {'lat': 23.5422, 'lng': 90.5305, 'name': 'মুন্সীগঞ্জ', 'division': 'ঢাকা'},
    'Narayanganj': {'lat': 23.6238, 'lng': 90.5000, 'name': 'নারায়ণগঞ্জ', 'division': 'ঢাকা'},
    'Narsingdi': {'lat': 23.9193, 'lng': 90.7176, 'name': 'নরসিংদী', 'division': 'ঢাকা'},
    'Rajbari': {'lat': 23.7574, 'lng': 89.6444, 'name': 'রাজবাড়ী', 'division': 'ঢাকা'},
    'Shariatpur': {'lat': 23.2423, 'lng': 90.4348, 'name': 'শরীয়তপুর', 'division': 'ঢাকা'},

    // Chattagram Division
    'Chittagong': {'lat': 22.3569, 'lng': 91.7832, 'name': 'চট্টগ্রাম', 'division': 'চট্টগ্রাম'},
    'Chattogram': {'lat': 22.3569, 'lng': 91.7832, 'name': 'চট্টগ্রাম', 'division': 'চট্টগ্রাম'},
    'Comilla': {'lat': 23.4607, 'lng': 91.1809, 'name': 'কুমিল্লা', 'division': 'চট্টগ্রাম'},
    'Cumilla': {'lat': 23.4607, 'lng': 91.1809, 'name': 'কুমিল্লা', 'division': 'চট্টগ্রাম'},
    'Coxsbazar': {'lat': 21.4272, 'lng': 92.0058, 'name': 'কক্সবাজার', 'division': 'চট্টগ্রাম'},
    'Cox\'s Bazar': {'lat': 21.4272, 'lng': 92.0058, 'name': 'কক্সবাজার', 'division': 'চট্টগ্রাম'},
    'Noakhali': {'lat': 22.8696, 'lng': 91.0993, 'name': 'নোয়াখালী', 'division': 'চট্টগ্রাম'},
    'Brahmanbaria': {'lat': 23.9571, 'lng': 91.1119, 'name': 'ব্রাহ্মণবাড়িয়া', 'division': 'চট্টগ্রাম'},
    'Chandpur': {'lat': 23.2321, 'lng': 90.6631, 'name': 'চাঁদপুর', 'division': 'চট্টগ্রাম'},
    'Feni': {'lat': 23.0159, 'lng': 91.3976, 'name': 'ফেনী', 'division': 'চট্টগ্রাম'},
    'Lakshmipur': {'lat': 22.9425, 'lng': 90.8412, 'name': 'লক্ষ্মীপুর', 'division': 'চট্টগ্রাম'},
    'Bandarban': {'lat': 22.1953, 'lng': 92.2184, 'name': 'বান্দরবান', 'division': 'চট্টগ্রাম'},
    'Khagrachhari': {'lat': 23.1193, 'lng': 91.9847, 'name': 'খাগড়াছড়ি', 'division': 'চট্টগ্রাম'},
    'Rangamati': {'lat': 22.6574, 'lng': 92.1733, 'name': 'রাঙ্গামাটি', 'division': 'চট্টগ্রাম'},

    // Khulna Division
    'Khulna': {'lat': 22.8456, 'lng': 89.5403, 'name': 'খুলনা', 'division': 'খুলনা'},
    'Jessore': {'lat': 23.1664, 'lng': 89.2081, 'name': 'যশোর', 'division': 'খুলনা'},
    'Jashore': {'lat': 23.1664, 'lng': 89.2081, 'name': 'যশোর', 'division': 'খুলনা'},
    'Kushtia': {'lat': 23.9013, 'lng': 89.1205, 'name': 'কুষ্টিয়া', 'division': 'খুলনা'},
    'Bagerhat': {'lat': 22.6516, 'lng': 89.7859, 'name': 'বাগেরহাট', 'division': 'খুলনা'},
    'Chuadanga': {'lat': 23.6402, 'lng': 88.8418, 'name': 'চুয়াডাঙ্গা', 'division': 'খুলনা'},
    'Jhenaidah': {'lat': 23.5448, 'lng': 89.1539, 'name': 'ঝিনাইদহ', 'division': 'খুলনা'},
    'Magura': {'lat': 23.4873, 'lng': 89.4199, 'name': 'মাগুরা', 'division': 'খুলনা'},
    'Meherpur': {'lat': 23.7622, 'lng': 88.6318, 'name': 'মেহেরপুর', 'division': 'খুলনা'},
    'Narail': {'lat': 23.1725, 'lng': 89.5126, 'name': 'নড়াইল', 'division': 'খুলনা'},
    'Satkhira': {'lat': 22.7185, 'lng': 89.0705, 'name': 'সাতক্ষীরা', 'division': 'খুলনা'},

    // Barisal Division
    'Barisal': {'lat': 22.7010, 'lng': 90.3535, 'name': 'বরিশাল', 'division': 'বরিশাল'},
    'Barguna': {'lat': 22.1570, 'lng': 90.1249, 'name': 'বরগুনা', 'division': 'বরিশাল'},
    'Bhola': {'lat': 22.6859, 'lng': 90.6481, 'name': 'ভোলা', 'division': 'বরিশাল'},
    'Jhalakathi': {'lat': 22.6406, 'lng': 90.1987, 'name': 'ঝালকাঠি', 'division': 'বরিশাল'},
    'Patuakhali': {'lat': 22.3596, 'lng': 90.3299, 'name': 'পটুয়াখালী', 'division': 'বরিশাল'},
    'Pirojpur': {'lat': 22.5841, 'lng': 89.9720, 'name': 'পিরোজপুর', 'division': 'বরিশাল'},

    // Sylhet Division
    'Sylhet': {'lat': 24.8949, 'lng': 91.8687, 'name': 'সিলেট', 'division': 'সিলেট'},
    'Habiganj': {'lat': 24.3749, 'lng': 91.4155, 'name': 'হবিগঞ্জ', 'division': 'সিলেট'},
    'Moulvibazar': {'lat': 24.4829, 'lng': 91.7774, 'name': 'মৌলভীবাজার', 'division': 'সিলেট'},
    'Sunamganj': {'lat': 25.0658, 'lng': 91.4073, 'name': 'সুনামগঞ্জ', 'division': 'সিলেট'},

    // Rangpur Division
    'Rangpur': {'lat': 25.7439, 'lng': 89.2752, 'name': 'রংপুর', 'division': 'রংপুর'},
    'Dinajpur': {'lat': 25.6217, 'lng': 88.6354, 'name': 'দিনাজপুর', 'division': 'রংপুর'},
    'Gaibandha': {'lat': 25.3288, 'lng': 89.5403, 'name': 'গাইবান্ধা', 'division': 'রংপুর'},
    'Kurigram': {'lat': 25.8054, 'lng': 89.6361, 'name': 'কুড়িগ্রাম', 'division': 'রংপুর'},
    'Lalmonirhat': {'lat': 25.9165, 'lng': 89.4532, 'name': 'লালমনিরহাট', 'division': 'রংপুর'},
    'Nilphamari': {'lat': 25.9318, 'lng': 88.8560, 'name': 'নীলফামারী', 'division': 'রংপুর'},
    'Panchagarh': {'lat': 26.3411, 'lng': 88.5541, 'name': 'পঞ্চগড়', 'division': 'রংপুর'},
    'Thakurgaon': {'lat': 26.0337, 'lng': 88.4617, 'name': 'ঠাকুরগাঁও', 'division': 'রংপুর'},

    // Mymensingh Division
    'Mymensingh': {'lat': 24.7471, 'lng': 90.4203, 'name': 'ময়মনসিংহ', 'division': 'ময়মনসিংহ'},
    'Jamalpur': {'lat': 24.9375, 'lng': 89.9378, 'name': 'জামালপুর', 'division': 'ময়মনসিংহ'},
    'Netrokona': {'lat': 24.8709, 'lng': 90.7279, 'name': 'নেত্রকোণা', 'division': 'ময়মনসিংহ'},
    'Sherpur': {'lat': 25.0205, 'lng': 90.0153, 'name': 'শেরপুর', 'division': 'ময়মনসিংহ'},
  };

  /// Helper to get Bengali script name for Upazilas
  static String getBanglaUpazilaName(String upa) {
    if (upa.isEmpty) return 'গুরুদাসপুর';
    final query = upa.trim().toLowerCase();
    const map = {
      'gurudaspur': 'গুরুদাসপুর',
      'natore sadar': 'নাটোর সদর',
      'singra': 'সিংড়া',
      'baraigram': 'বড়াইগ্রাম',
      'bagatipara': 'বাগাতিপাড়া',
      'lalpur': 'লালপুর',
      'naldanga': 'নলডাঙ্গা',
      'rajshahi sadar': 'রাজশাহী সদর',
      'paba': 'পবা',
      'godagari': 'গোদাগাড়ী',
      'tanore': 'তানোর',
      'bagmara': 'বাগমারা',
      'charghat': 'চারঘাট',
      'bagha': 'বাঘা',
      'durgapur': 'দুর্গাপুর',
      'mohonpur': 'মোহনপুর',
      'bogra sadar': 'বগুড়া সদর',
      'dhaka': 'ঢাকা',
      'savar': 'সাভার',
      'gazipur sadar': 'গাজীপুর সদর',
      'kaliakair': 'কালিয়াকৈর',
      'kapasia': 'কাপাসিয়া',
      'sreepur': 'শ্রীপুর',
    };
    if (map.containsKey(query)) {
      return map[query]!;
    }
    // If already in Bangla characters, return as is
    if (RegExp(r'[\u0980-\u09FF]').hasMatch(upa)) {
      return upa;
    }
    return upa;
  }

  /// Resolve Upazila/District string to matching District key in _districtCoordinates
  static String resolveDistrictFromUpazila(String upazilaOrDistrict) {
    if (upazilaOrDistrict.isEmpty) return 'Natore';
    final query = upazilaOrDistrict.trim().toLowerCase();

    // 0. Known Upazila mappings (Highest Priority)
    if (query.contains('gurudaspur') ||
        query.contains('গুরুদাসপুর') ||
        query.contains('singra') ||
        query.contains('সিংড়া') ||
        query.contains('baraigram') ||
        query.contains('বড়াইগ্রাম') ||
        query.contains('lalpur') ||
        query.contains('লালপুর') ||
        query.contains('bagatipara') ||
        query.contains('বাগাতিপাড়া') ||
        query.contains('naldanga') ||
        query.contains('নলডাঙ্গা') ||
        query.contains('natore') ||
        query.contains('নাটোর')) {
      return 'Natore';
    }
    if (query.contains('gazipur') ||
        query.contains('গাজীপুর') ||
        query.contains('kaliakair') ||
        query.contains('কালিয়াকৈর') ||
        query.contains('kapasia') ||
        query.contains('কাপাসিয়া') ||
        query.contains('sreepur') ||
        query.contains('শ্রীপুর')) {
      return 'Gazipur';
    }
    if (query.contains('savar') ||
        query.contains('সাভার') ||
        query.contains('dhamrai')) {
      return 'Dhaka';
    }

    // 1. Upazila lookup in BDLocationData.upazilasByDistrict
    for (var entry in BDLocationData.upazilasByDistrict.entries) {
      String distName = entry.key;
      List<String> upazilas = entry.value;
      for (var upa in upazilas) {
        if (upa.toLowerCase() == query || query.contains(upa.toLowerCase())) {
          return distName;
        }
      }
    }

    // 2. Check if input matches District key directly or Bengali name
    for (var dKey in _districtCoordinates.keys) {
      if (dKey.toLowerCase() == query ||
          (_districtCoordinates[dKey]?['name'] as String?) ==
              upazilaOrDistrict) {
        return dKey;
      }
    }

    return 'Natore';
  }

  /// Fetch live weather by GPS or District / Upazila
  Future<WeatherModel> fetchCurrentWeather({
    String? userDistrict,
    String? userUpazila,
    double? userLat,
    double? userLng,
    bool forceGps = false,
  }) async {
    double lat = 24.4102; // Natore default
    double lng = 89.0076;
    String locationDisplayName = 'গুরুদাসপুর, নাটোর (রাজশাহী)';

    try {
      // 1. If forceGps is true (user tapped GPS button explicitly)
      if (forceGps) {
        Position? position = await LocationService().getCurrentPosition();
        if (position != null) {
          lat = position.latitude;
          lng = position.longitude;
          locationDisplayName = 'আপনার জিপিএস অবস্থান';
        }
      }
      // 2. Prioritize User's Profile / Configured Location (Upazila & District)
      else {
        String rawUpazila = (userUpazila != null && userUpazila.isNotEmpty)
            ? userUpazila
            : 'Gurudaspur';
        String rawDistrict = (userDistrict != null && userDistrict.isNotEmpty)
            ? userDistrict
            : 'Natore';

        // Resolve District key from Upazila FIRST
        String resolvedDistrictKey = resolveDistrictFromUpazila(rawUpazila);
        // Only fallback to userDistrict if upazila was not explicitly provided
        if ((userUpazila == null || userUpazila.isEmpty) &&
            userDistrict != null &&
            userDistrict.isNotEmpty) {
          resolvedDistrictKey = resolveDistrictFromUpazila(rawDistrict);
        }

        final mapped = _districtCoordinates[resolvedDistrictKey] ??
            _districtCoordinates['Natore']!;
        lat = mapped['lat'] as double;
        lng = mapped['lng'] as double;

        String banglaUpa = getBanglaUpazilaName(rawUpazila);
        String banglaDist = mapped['name'] as String;
        String divText = mapped['division'] as String? ?? 'রাজশাহী';

        locationDisplayName = '$banglaUpa, $banglaDist ($divText)';
        debugPrint(
            '📍 Weather location resolved: $locationDisplayName ($lat, $lng)');
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
