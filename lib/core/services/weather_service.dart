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

  /// Latitude, Longitude, Bengali Name, English Name & Division map for ALL 64 Bangladesh Districts
  static const Map<String, Map<String, dynamic>> _districtCoordinates = {
    // Rajshahi Division
    'Natore': {'lat': 24.4102, 'lng': 89.0076, 'name': 'নাটোর', 'nameEn': 'Natore', 'division': 'রাজশাহী', 'divisionEn': 'Rajshahi'},
    'Rajshahi': {'lat': 24.3745, 'lng': 88.6042, 'name': 'রাজশাহী', 'nameEn': 'Rajshahi', 'division': 'রাজশাহী', 'divisionEn': 'Rajshahi'},
    'Bogura': {'lat': 24.8481, 'lng': 89.3730, 'name': 'বগুড়া', 'nameEn': 'Bogura', 'division': 'রাজশাহী', 'divisionEn': 'Rajshahi'},
    'Bogra': {'lat': 24.8481, 'lng': 89.3730, 'name': 'বগুড়া', 'nameEn': 'Bogura', 'division': 'রাজশাহী', 'divisionEn': 'Rajshahi'},
    'Pabna': {'lat': 24.0064, 'lng': 89.2494, 'name': 'পাবনা', 'nameEn': 'Pabna', 'division': 'রাজশাহী', 'divisionEn': 'Rajshahi'},
    'Sirajganj': {'lat': 24.4534, 'lng': 89.7008, 'name': 'সিরাজগঞ্জ', 'nameEn': 'Sirajganj', 'division': 'রাজশাহী', 'divisionEn': 'Rajshahi'},
    'Naogaon': {'lat': 24.7936, 'lng': 88.9318, 'name': 'নওগাঁ', 'nameEn': 'Naogaon', 'division': 'রাজশাহী', 'divisionEn': 'Rajshahi'},
    'Chapainawabganj': {'lat': 24.5965, 'lng': 88.2775, 'name': 'চাঁপাইনবাবগঞ্জ', 'nameEn': 'Chapainawabganj', 'division': 'রাজশাহী', 'divisionEn': 'Rajshahi'},
    'Joypurhat': {'lat': 25.1017, 'lng': 89.0267, 'name': 'জয়পুরহাট', 'nameEn': 'Joypurhat', 'division': 'রাজশাহী', 'divisionEn': 'Rajshahi'},

    // Dhaka Division
    'Dhaka': {'lat': 23.8103, 'lng': 90.4125, 'name': 'ঢাকা', 'nameEn': 'Dhaka', 'division': 'ঢাকা', 'divisionEn': 'Dhaka'},
    'Gazipur': {'lat': 23.9999, 'lng': 90.4203, 'name': 'গাজীপুর', 'nameEn': 'Gazipur', 'division': 'ঢাকা', 'divisionEn': 'Dhaka'},
    'Tangail': {'lat': 24.2513, 'lng': 89.9167, 'name': 'টাঙ্গাইল', 'nameEn': 'Tangail', 'division': 'ঢাকা', 'divisionEn': 'Dhaka'},
    'Faridpur': {'lat': 23.6070, 'lng': 89.8406, 'name': 'ফরিদপুর', 'nameEn': 'Faridpur', 'division': 'ঢাকা', 'divisionEn': 'Dhaka'},
    'Gopalganj': {'lat': 23.0050, 'lng': 89.8266, 'name': 'গোপালগঞ্জ', 'nameEn': 'Gopalganj', 'division': 'ঢাকা', 'divisionEn': 'Dhaka'},
    'Kishoreganj': {'lat': 24.4449, 'lng': 90.7765, 'name': 'কিশোরগঞ্জ', 'nameEn': 'Kishoreganj', 'division': 'ঢাকা', 'divisionEn': 'Dhaka'},
    'Madaripur': {'lat': 23.1641, 'lng': 90.1897, 'name': 'মাদারীপুর', 'nameEn': 'Madaripur', 'division': 'ঢাকা', 'divisionEn': 'Dhaka'},
    'Manikganj': {'lat': 23.8644, 'lng': 90.0047, 'name': 'মানিকগঞ্জ', 'nameEn': 'Manikganj', 'division': 'ঢাকা', 'divisionEn': 'Dhaka'},
    'Munshiganj': {'lat': 23.5422, 'lng': 90.5305, 'name': 'মুন্সীগঞ্জ', 'nameEn': 'Munshiganj', 'division': 'ঢাকা', 'divisionEn': 'Dhaka'},
    'Narayanganj': {'lat': 23.6238, 'lng': 90.5000, 'name': 'নারায়ণগঞ্জ', 'nameEn': 'Narayanganj', 'division': 'ঢাকা', 'divisionEn': 'Dhaka'},
    'Narsingdi': {'lat': 23.9193, 'lng': 90.7176, 'name': 'নরসিংদী', 'nameEn': 'Narsingdi', 'division': 'ঢাকা', 'divisionEn': 'Dhaka'},
    'Rajbari': {'lat': 23.7574, 'lng': 89.6444, 'name': 'রাজবাড়ী', 'nameEn': 'Rajbari', 'division': 'ঢাকা', 'divisionEn': 'Dhaka'},
    'Shariatpur': {'lat': 23.2423, 'lng': 90.4348, 'name': 'শরীয়তপুর', 'nameEn': 'Shariatpur', 'division': 'ঢাকা', 'divisionEn': 'Dhaka'},

    // Chattagram Division
    'Chattogram': {'lat': 22.3569, 'lng': 91.7832, 'name': 'চট্টগ্রাম', 'nameEn': 'Chattogram', 'division': 'চট্টগ্রাম', 'divisionEn': 'Chattogram'},
    'Chittagong': {'lat': 22.3569, 'lng': 91.7832, 'name': 'চট্টগ্রাম', 'nameEn': 'Chattogram', 'division': 'চট্টগ্রাম', 'divisionEn': 'Chattogram'},
    'Cumilla': {'lat': 23.4607, 'lng': 91.1809, 'name': 'কুমিল্লা', 'nameEn': 'Cumilla', 'division': 'চট্টগ্রাম', 'divisionEn': 'Chattogram'},
    'Comilla': {'lat': 23.4607, 'lng': 91.1809, 'name': 'কুমিল্লা', 'nameEn': 'Cumilla', 'division': 'চট্টগ্রাম', 'divisionEn': 'Chattogram'},
    'Coxsbazar': {'lat': 21.4272, 'lng': 92.0058, 'name': 'কক্সবাজার', 'nameEn': 'Cox\'s Bazar', 'division': 'চট্টগ্রাম', 'divisionEn': 'Chattogram'},
    'Cox\'s Bazar': {'lat': 21.4272, 'lng': 92.0058, 'name': 'কক্সবাজার', 'nameEn': 'Cox\'s Bazar', 'division': 'চট্টগ্রাম', 'divisionEn': 'Chattogram'},
    'Noakhali': {'lat': 22.8696, 'lng': 91.0993, 'name': 'নোয়াখালী', 'nameEn': 'Noakhali', 'division': 'চট্টগ্রাম', 'divisionEn': 'Chattogram'},
    'Brahmanbaria': {'lat': 23.9571, 'lng': 91.1119, 'name': 'ব্রাহ্মণবাড়িয়া', 'nameEn': 'Brahmanbaria', 'division': 'চট্টগ্রাম', 'divisionEn': 'Chattogram'},
    'Chandpur': {'lat': 23.2321, 'lng': 90.6631, 'name': 'চাঁদপুর', 'nameEn': 'Chandpur', 'division': 'চট্টগ্রাম', 'divisionEn': 'Chattogram'},
    'Feni': {'lat': 23.0159, 'lng': 91.3976, 'name': 'ফেনী', 'nameEn': 'Feni', 'division': 'চট্টগ্রাম', 'divisionEn': 'Chattogram'},
    'Lakshmipur': {'lat': 22.9425, 'lng': 90.8412, 'name': 'লক্ষ্মীপুর', 'nameEn': 'Lakshmipur', 'division': 'চট্টগ্রাম', 'divisionEn': 'Chattogram'},
    'Bandarban': {'lat': 22.1953, 'lng': 92.2184, 'name': 'বান্দরবান', 'nameEn': 'Bandarban', 'division': 'চট্টগ্রাম', 'divisionEn': 'Chattogram'},
    'Khagrachhari': {'lat': 23.1193, 'lng': 91.9847, 'name': 'খাগড়াছড়ি', 'nameEn': 'Khagrachhari', 'division': 'চট্টগ্রাম', 'divisionEn': 'Chattogram'},
    'Rangamati': {'lat': 22.6574, 'lng': 92.1733, 'name': 'রাঙ্গামাটি', 'nameEn': 'Rangamati', 'division': 'চট্টগ্রাম', 'divisionEn': 'Chattogram'},

    // Khulna Division
    'Khulna': {'lat': 22.8456, 'lng': 89.5403, 'name': 'খুলনা', 'nameEn': 'Khulna', 'division': 'খুলনা', 'divisionEn': 'Khulna'},
    'Jashore': {'lat': 23.1664, 'lng': 89.2081, 'name': 'যশোর', 'nameEn': 'Jashore', 'division': 'খুলনা', 'divisionEn': 'Khulna'},
    'Jessore': {'lat': 23.1664, 'lng': 89.2081, 'name': 'যশোর', 'nameEn': 'Jashore', 'division': 'খুলনা', 'divisionEn': 'Khulna'},
    'Kushtia': {'lat': 23.9013, 'lng': 89.1205, 'name': 'কুষ্টিয়া', 'nameEn': 'Kushtia', 'division': 'খুলনা', 'divisionEn': 'Khulna'},
    'Bagerhat': {'lat': 22.6516, 'lng': 89.7859, 'name': 'বাগেরহাট', 'nameEn': 'Bagerhat', 'division': 'খুলনা', 'divisionEn': 'Khulna'},
    'Chuadanga': {'lat': 23.6402, 'lng': 88.8418, 'name': 'চুয়াডাঙ্গা', 'nameEn': 'Chuadanga', 'division': 'খুলনা', 'divisionEn': 'Khulna'},
    'Jhenaidah': {'lat': 23.5448, 'lng': 89.1539, 'name': 'ঝিনাইদহ', 'nameEn': 'Jhenaidah', 'division': 'খুলনা', 'divisionEn': 'Khulna'},
    'Magura': {'lat': 23.4873, 'lng': 89.4199, 'name': 'মাগুরা', 'nameEn': 'Magura', 'division': 'খুলনা', 'divisionEn': 'Khulna'},
    'Meherpur': {'lat': 23.7622, 'lng': 88.6318, 'name': 'মেহেরপুর', 'nameEn': 'Meherpur', 'division': 'খুলনা', 'divisionEn': 'Khulna'},
    'Narail': {'lat': 23.1725, 'lng': 89.5126, 'name': 'নড়াইল', 'nameEn': 'Narail', 'division': 'খুলনা', 'divisionEn': 'Khulna'},
    'Satkhira': {'lat': 22.7185, 'lng': 89.0705, 'name': 'সাতক্ষীরা', 'nameEn': 'Satkhira', 'division': 'খুলনা', 'divisionEn': 'Khulna'},

    // Barishal Division
    'Barishal': {'lat': 22.7010, 'lng': 90.3535, 'name': 'বরিশাল', 'nameEn': 'Barishal', 'division': 'বরিশাল', 'divisionEn': 'Barishal'},
    'Barisal': {'lat': 22.7010, 'lng': 90.3535, 'name': 'বরিশাল', 'nameEn': 'Barishal', 'division': 'বরিশাল', 'divisionEn': 'Barishal'},
    'Barguna': {'lat': 22.1570, 'lng': 90.1249, 'name': 'বরগুনা', 'nameEn': 'Barguna', 'division': 'বরিশাল', 'divisionEn': 'Barishal'},
    'Bhola': {'lat': 22.6859, 'lng': 90.6481, 'name': 'ভোলা', 'nameEn': 'Bhola', 'division': 'বরিশাল', 'divisionEn': 'Barishal'},
    'Jhalokati': {'lat': 22.6406, 'lng': 90.1987, 'name': 'ঝালকাঠি', 'nameEn': 'Jhalokati', 'division': 'বরিশাল', 'divisionEn': 'Barishal'},
    'Jhalakathi': {'lat': 22.6406, 'lng': 90.1987, 'name': 'ঝালকাঠি', 'nameEn': 'Jhalokati', 'division': 'বরিশাল', 'divisionEn': 'Barishal'},
    'Patuakhali': {'lat': 22.3596, 'lng': 90.3299, 'name': 'পটুয়াখালী', 'nameEn': 'Patuakhali', 'division': 'বরিশাল', 'divisionEn': 'Barishal'},
    'Pirojpur': {'lat': 22.5841, 'lng': 89.9720, 'name': 'পিরোজপুর', 'nameEn': 'Pirojpur', 'division': 'বরিশাল', 'divisionEn': 'Barishal'},

    // Sylhet Division
    'Sylhet': {'lat': 24.8949, 'lng': 91.8687, 'name': 'সিলেট', 'nameEn': 'Sylhet', 'division': 'সিলেট', 'divisionEn': 'Sylhet'},
    'Habiganj': {'lat': 24.3749, 'lng': 91.4155, 'name': 'হবিগঞ্জ', 'nameEn': 'Habiganj', 'division': 'সিলেট', 'divisionEn': 'Sylhet'},
    'Moulvibazar': {'lat': 24.4829, 'lng': 91.7774, 'name': 'মৌলভীবাজার', 'nameEn': 'Moulvibazar', 'division': 'সিলেট', 'divisionEn': 'Sylhet'},
    'Sunamganj': {'lat': 25.0658, 'lng': 91.4073, 'name': 'সুনামগঞ্জ', 'nameEn': 'Sunamganj', 'division': 'সিলেট', 'divisionEn': 'Sylhet'},

    // Rangpur Division
    'Rangpur': {'lat': 25.7439, 'lng': 89.2752, 'name': 'রংপুর', 'nameEn': 'Rangpur', 'division': 'রংপুর', 'divisionEn': 'Rangpur'},
    'Dinajpur': {'lat': 25.6217, 'lng': 88.6354, 'name': 'দিনাজপুর', 'nameEn': 'Dinajpur', 'division': 'রংপুর', 'divisionEn': 'Rangpur'},
    'Gaibandha': {'lat': 25.3288, 'lng': 89.5403, 'name': 'গাইবান্ধা', 'nameEn': 'Gaibandha', 'division': 'রংপুর', 'divisionEn': 'Rangpur'},
    'Kurigram': {'lat': 25.8054, 'lng': 89.6361, 'name': 'কুড়িগ্রাম', 'nameEn': 'Kurigram', 'division': 'রংপুর', 'divisionEn': 'Rangpur'},
    'Lalmonirhat': {'lat': 25.9165, 'lng': 89.4532, 'name': 'লালমনিরহাট', 'nameEn': 'Lalmonirhat', 'division': 'রংপুর', 'divisionEn': 'Rangpur'},
    'Nilphamari': {'lat': 25.9318, 'lng': 88.8560, 'name': 'নীলফামারী', 'nameEn': 'Nilphamari', 'division': 'রংপুর', 'divisionEn': 'Rangpur'},
    'Panchagarh': {'lat': 26.3411, 'lng': 88.5541, 'name': 'পঞ্চগড়', 'nameEn': 'Panchagarh', 'division': 'রংপুর', 'divisionEn': 'Rangpur'},
    'Thakurgaon': {'lat': 26.0337, 'lng': 88.4617, 'name': 'ঠাকুরগাঁও', 'nameEn': 'Thakurgaon', 'division': 'রংপুর', 'divisionEn': 'Rangpur'},

    // Mymensingh Division
    'Mymensingh': {'lat': 24.7471, 'lng': 90.4203, 'name': 'ময়মনসিংহ', 'nameEn': 'Mymensingh', 'division': 'ময়মনসিংহ', 'divisionEn': 'Mymensingh'},
    'Jamalpur': {'lat': 24.9375, 'lng': 89.9378, 'name': 'জামালপুর', 'nameEn': 'Jamalpur', 'division': 'ময়মনসিংহ', 'divisionEn': 'Mymensingh'},
    'Netrokona': {'lat': 24.8709, 'lng': 90.7279, 'name': 'নেত্রকোণা', 'nameEn': 'Netrokona', 'division': 'ময়মনসিংহ', 'divisionEn': 'Mymensingh'},
    'Sherpur': {'lat': 25.0205, 'lng': 90.0153, 'name': 'শেরপুর', 'nameEn': 'Sherpur', 'division': 'ময়মনসিংহ', 'divisionEn': 'Mymensingh'},
  };

  /// Helper to get Bengali script name for Upazilas
  static String getBanglaUpazilaName(String upa) {
    if (upa.isEmpty) return 'দুমকি';
    final query = upa.trim().toLowerCase();
    const map = {
      // Patuakhali
      'dumki': 'দুমকি',
      'দুমকি': 'দুমকি',
      'bauphal': 'বাউফল',
      'বাউফল': 'বাউফল',
      'galachipa': 'গলাচিপা',
      'গলাচিপা': 'গলাচিপা',
      'kalapara': 'কলাপাড়া',
      'কলাপাড়া': 'কলাপাড়া',
      'mirzaganj': 'মির্জাগঞ্জ',
      'মির্জাগঞ্জ': 'মির্জাগঞ্জ',
      'dashmina': 'দশমিনা',
      'দশমিনা': 'দশমিনা',
      'rangabali': 'রাঙ্গাবালী',
      'রাঙ্গাবালী': 'রাঙ্গাবালী',
      'patuakhali sadar': 'পটুয়াখালী সদর',
      'পটুয়াখালী সদর': 'পটুয়াখালী সদর',
      'patuakhali': 'পটুয়াখালী',

      // Natore
      'gurudaspur': 'গুরুদাসপুর',
      'natore sadar': 'নাটোর সদর',
      'singra': 'সিংড়া',
      'baraigram': 'বড়াইগ্রাম',
      'bagatipara': 'বাগাতিপাড়া',
      'lalpur': 'লালপুর',
      'naldanga': 'নলডাঙ্গা',

      // Rajshahi
      'rajshahi sadar': 'রাজশাহী সদর',
      'paba': 'পবা',
      'godagari': 'গোদাগাড়ী',
      'tanore': 'তানোর',
      'bagmara': 'বাগমারা',
      'charghat': 'চারঘাট',
      'bagha': 'বাঘা',
      'durgapur': 'দুর্গাপুর',
      'mohonpur': 'মোহনপুর',
      'puthia': 'পুঠিয়া',

      // Bogura
      'bogra sadar': 'বগুড়া সদর',
      'bogura sadar': 'বগুড়া সদর',
      'shibganj': 'শিবগঞ্জ',
      'sherpur': 'শেরপুর',
      'dhunat': 'ধুনট',
      'gabtali': 'গাবতলী',
      'kahaloo': 'কাহালু',
      'nandigram': 'নন্দীগ্রাম',
      'sariakandi': 'সারিয়াকান্দি',
      'shajahanpur': 'শাজাহানপুর',
      'sonatala': 'সোনাতলা',

      // Dhaka & Gazipur
      'dhaka': 'ঢাকা',
      'savar': 'সাভার',
      'dhamrai': 'ধামরাই',
      'keraniganj': 'কেরানীগঞ্জ',
      'gazipur sadar': 'গাজীপুর সদর',
      'kaliakair': 'কালিয়াকৈর',
      'kapasia': 'কাপাসিয়া',
      'sreepur': 'শ্রীপুর',
      'kaliganj': 'কালীগঞ্জ',
    };

    if (map.containsKey(query)) {
      return map[query]!;
    }
    if (RegExp(r'[\u0980-\u09FF]').hasMatch(upa)) {
      return upa;
    }
    return upa;
  }

  /// Helper to get English script name for Upazilas
  static String getEnglishUpazilaName(String upa) {
    if (upa.isEmpty) return 'Dumki';
    final query = upa.trim().toLowerCase();
    const map = {
      // Patuakhali
      'dumki': 'Dumki',
      'দুমকি': 'Dumki',
      'bauphal': 'Bauphal',
      'বাউফল': 'Bauphal',
      'galachipa': 'Galachipa',
      'গলাচিপা': 'Galachipa',
      'kalapara': 'Kalapara',
      'কলাপাড়া': 'Kalapara',
      'mirzaganj': 'Mirzaganj',
      'মির্জাগঞ্জ': 'Mirzaganj',
      'dashmina': 'Dashmina',
      'দশমিনা': 'Dashmina',
      'rangabali': 'Rangabali',
      'রাঙ্গাবালী': 'Rangabali',
      'patuakhali sadar': 'Patuakhali Sadar',
      'পটুয়াখালী সদর': 'Patuakhali Sadar',
      'পটুয়াখালী': 'Patuakhali',

      // Natore
      'gurudaspur': 'Gurudaspur',
      'গুরুদাসপুর': 'Gurudaspur',
      'singra': 'Singra',
      'সিংড়া': 'Singra',
      'সিংড়া': 'Singra',
      'baraigram': 'Baraigram',
      'বড়াইগ্রাম': 'Baraigram',
      'বড়াইগ্রাম': 'Baraigram',
      'bagatipara': 'Bagatipara',
      'বাগাতিপাড়া': 'Bagatipara',
      'বাগাতিপাড়া': 'Bagatipara',
      'lalpur': 'Lalpur',
      'লালপুর': 'Lalpur',
      'naldanga': 'Naldanga',
      'নলডাঙ্গা': 'Naldanga',
      'natore sadar': 'Natore Sadar',
      'নাটোর সদর': 'Natore Sadar',

      // Rajshahi
      'rajshahi': 'Rajshahi',
      'রাজশাহী': 'Rajshahi',
      'rajshahi sadar': 'Rajshahi Sadar',
      'রাজশাহী সদর': 'Rajshahi Sadar',
      'paba': 'Paba',
      'পবা': 'Paba',
      'godagari': 'Godagari',
      'গোদাগাড়ী': 'Godagari',
      'গোদাগাড়ী': 'Godagari',
      'tanore': 'Tanore',
      'তানোর': 'Tanore',
      'bagmara': 'Bagmara',
      'বাগমারা': 'Bagmara',
      'charghat': 'Charghat',
      'চারঘাট': 'Charghat',
      'bagha': 'Bagha',
      'বাঘা': 'Bagha',
      'durgapur': 'Durgapur',
      'দুর্গাপুর': 'Durgapur',
      'mohonpur': 'Mohonpur',
      'মোহনপুর': 'Mohonpur',
      'puthia': 'Puthia',
      'পুঠিয়া': 'Puthia',
      'পুঠিয়া': 'Puthia',

      // Bogura
      'bogura': 'Bogura',
      'বগুড়া': 'Bogura',
      'বগুড়া': 'Bogura',
      'bogra': 'Bogura',
      'bogura sadar': 'Bogura Sadar',
      'বগুড়া সদর': 'Bogura Sadar',
      'bogra sadar': 'Bogura Sadar',
      'shibganj': 'Shibganj',
      'শিবগঞ্জ': 'Shibganj',
      'sherpur': 'Sherpur',
      'শেরপুর': 'Sherpur',
      'dhunat': 'Dhunat',
      'ধুনট': 'Dhunat',
      'gabtali': 'Gabtali',
      'গাবতলী': 'Gabtali',
      'kahaloo': 'Kahaloo',
      'কাহালু': 'Kahaloo',
      'nandigram': 'Nandigram',
      'নন্দীগ্রাম': 'Nandigram',
      'sariakandi': 'Sariakandi',
      'সারিয়াকান্দি': 'Sariakandi',
      'shajahanpur': 'Shajahanpur',
      'শাজাহানপুর': 'Shajahanpur',
      'sonatala': 'Sonatala',
      'সোনাতলা': 'Sonatala',

      // Dhaka & Gazipur
      'dhaka': 'Dhaka',
      'ঢাকা': 'Dhaka',
      'savar': 'Savar',
      'সাভার': 'Savar',
      'dhamrai': 'Dhamrai',
      'ধামরাই': 'Dhamrai',
      'keraniganj': 'Keraniganj',
      'কেরানীগঞ্জ': 'Keraniganj',
      'gazipur': 'Gazipur',
      'গাজীপুর': 'Gazipur',
      'gazipur sadar': 'Gazipur Sadar',
      'গাজীপুর সদর': 'Gazipur Sadar',
      'kaliakair': 'Kaliakair',
      'কালিয়াকৈর': 'Kaliakair',
      'কালিয়াকৈর': 'Kaliakair',
      'kapasia': 'Kapasia',
      'কাপাসিয়া': 'Kapasia',
      'কাপাসিয়া': 'Kapasia',
      'sreepur': 'Sreepur',
      'শ্রীপুর': 'Sreepur',
      'kaliganj': 'Kaliganj',
      'কালীগঞ্জ': 'Kaliganj',
    };

    if (map.containsKey(query)) {
      return map[query]!;
    }

    // Lookup in BDLocationData
    for (var entry in BDLocationData.upazilasByDistrict.entries) {
      for (var u in entry.value) {
        if (u.toLowerCase() == query) return u;
      }
    }

    if (!RegExp(r'[\u0980-\u09FF]').hasMatch(upa)) {
      return upa.split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
    }
    return upa;
  }

  /// Resolve Upazila/District string to matching District key in _districtCoordinates
  static String resolveDistrictFromUpazila(String upazilaOrDistrict) {
    if (upazilaOrDistrict.isEmpty) return 'Patuakhali';
    final query = upazilaOrDistrict.trim().toLowerCase();

    // Patuakhali Upazilas
    if (query.contains('dumki') ||
        query.contains('দুমকি') ||
        query.contains('bauphal') ||
        query.contains('বাউফল') ||
        query.contains('galachipa') ||
        query.contains('গলাচিপা') ||
        query.contains('kalapara') ||
        query.contains('কলাপাড়া') ||
        query.contains('mirzaganj') ||
        query.contains('মির্জাগঞ্জ') ||
        query.contains('dashmina') ||
        query.contains('দশমিনা') ||
        query.contains('rangabali') ||
        query.contains('রাঙ্গাবালী') ||
        query.contains('patuakhali') ||
        query.contains('পটুয়াখালী') ||
        query.contains('পটুয়াখালী')) {
      return 'Patuakhali';
    }

    // Natore Upazilas
    if (query.contains('gurudaspur') ||
        query.contains('গুরুদাসপুর') ||
        query.contains('singra') ||
        query.contains('সিংড়া') ||
        query.contains('সিংড়া') ||
        query.contains('baraigram') ||
        query.contains('বড়াইগ্রাম') ||
        query.contains('বড়াইগ্রাম') ||
        query.contains('lalpur') ||
        query.contains('লালপুর') ||
        query.contains('bagatipara') ||
        query.contains('বাগাতিপাড়া') ||
        query.contains('বাগাতিপাড়া') ||
        query.contains('naldanga') ||
        query.contains('নলডাঙ্গা') ||
        query.contains('natore') ||
        query.contains('নাটোর')) {
      return 'Natore';
    }

    // Gazipur Upazilas
    if (query.contains('gazipur') ||
        query.contains('গাজীপুর') ||
        query.contains('kaliakair') ||
        query.contains('কালিয়াকৈর') ||
        query.contains('কালিয়াকৈর') ||
        query.contains('kapasia') ||
        query.contains('কাপাসিয়া') ||
        query.contains('কাপাসিয়া') ||
        query.contains('sreepur') ||
        query.contains('শ্রীপুর')) {
      return 'Gazipur';
    }

    // Dhaka Upazilas
    if (query.contains('savar') ||
        query.contains('সাভার') ||
        query.contains('dhamrai') ||
        query.contains('ধামরাই') ||
        query.contains('dhaka') ||
        query.contains('ঢাকা')) {
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
          (_districtCoordinates[dKey]?['name'] as String?) == upazilaOrDistrict ||
          (_districtCoordinates[dKey]?['nameEn'] as String?)?.toLowerCase() == query) {
        return dKey;
      }
    }

    return 'Patuakhali';
  }

  /// Fetch live weather by GPS or District / Upazila
  Future<WeatherModel> fetchCurrentWeather({
    String? userDistrict,
    String? userUpazila,
    double? userLat,
    double? userLng,
    bool forceGps = false,
  }) async {
    double lat = 22.3596; // Patuakhali center
    double lng = 90.3299;
    String locationDisplayName = 'দুমকি, পটুয়াখালী (বরিশাল)';
    String locationDisplayNameEn = 'Dumki, Patuakhali (Barishal)';

    try {
      final locService = LocationService();

      // 1. If explicit coordinates provided or forceGps is true
      if (userLat != null && userLng != null) {
        lat = userLat;
        lng = userLng;
        final res = await locService.resolveAddressFromCoordinates(lat, lng);
        locationDisplayName = res.formattedAddress;
        locationDisplayNameEn = res.formattedAddressEn;
      } else if (forceGps) {
        Position? position = await locService.getCurrentPosition();
        if (position != null) {
          lat = position.latitude;
          lng = position.longitude;
          final res = await locService.resolveAddressFromCoordinates(lat, lng);
          locationDisplayName = res.formattedAddress;
          locationDisplayNameEn = res.formattedAddressEn;
        }
      }
      // 2. Prioritize User's Profile Location if given
      else if ((userUpazila != null && userUpazila.isNotEmpty) ||
          (userDistrict != null && userDistrict.isNotEmpty)) {
        String rawUpazila = userUpazila ?? '';
        String rawDistrict = userDistrict ?? '';

        String resolvedDistrictKey = rawDistrict;
        if (rawUpazila.isNotEmpty) {
          resolvedDistrictKey = resolveDistrictFromUpazila(rawUpazila);
        }
        if (resolvedDistrictKey.isEmpty && rawDistrict.isNotEmpty) {
          resolvedDistrictKey = resolveDistrictFromUpazila(rawDistrict);
        }

        final mapped = _districtCoordinates[resolvedDistrictKey] ??
            _districtCoordinates['Patuakhali']!;
        lat = mapped['lat'] as double;
        lng = mapped['lng'] as double;

        String banglaUpa = rawUpazila.isNotEmpty ? getBanglaUpazilaName(rawUpazila) : '${mapped['name']} সদর';
        String englishUpa = rawUpazila.isNotEmpty ? getEnglishUpazilaName(rawUpazila) : '$resolvedDistrictKey Sadar';
        String banglaDist = mapped['name'] as String;
        String englishDist = mapped['nameEn'] as String? ?? resolvedDistrictKey;
        String banglaDiv = mapped['division'] as String? ?? 'বরিশাল';
        String englishDiv = mapped['divisionEn'] as String? ?? 'Barishal';

        locationDisplayName = '$banglaUpa, $banglaDist ($banglaDiv)';
        locationDisplayNameEn = '$englishUpa, $englishDist ($englishDiv)';
      }
      // 3. Otherwise, try real GPS location before fallback
      else {
        Position? position = await locService.getCurrentPosition();
        if (position != null) {
          lat = position.latitude;
          lng = position.longitude;
          final res = await locService.resolveAddressFromCoordinates(lat, lng);
          locationDisplayName = res.formattedAddress;
          locationDisplayNameEn = res.formattedAddressEn;
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
        '&timezone=Asia%2FDhaka',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherModel.fromJson(data, locationDisplayName, locationNameEn: locationDisplayNameEn);
      } else {
        debugPrint('❌ Open-Meteo API returned status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('⚠️ Weather fetch network error: $e');
    }

    // 3. Fallback
    return WeatherModel.defaultFallback(locationDisplayName, locationEn: locationDisplayNameEn);
  }
}
