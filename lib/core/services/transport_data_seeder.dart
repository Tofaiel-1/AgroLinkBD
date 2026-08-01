import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class TransportDataSeeder {
  // Full Bangladesh District -> Upazila map (Agricultural regions)
  static final Map<String, List<String>> _locations = {
    'Natore': ['Gurudaspur', 'Singra', 'Natore Sadar', 'Baraigram', 'Lalpur', 'Bagatipara'],
    'Bogura': ['Shibganj', 'Sherpur', 'Kahaloo', 'Nandigram', 'Sariakandi', 'Bogura Sadar'],
    'Rajshahi': ['Paba', 'Godagari', 'Mohanpur', 'Tanore', 'Bagmara', 'Charghat'],
    'Dhaka': ['Savar', 'Keraniganj', 'Dhamrai', 'Nawabganj', 'Dohar'],
    'Dinajpur': ['Birol', 'Bochaganj', 'Khansama', 'Parbatipur', 'Nawabganj', 'Chirirbandar'],
    'Jessore': ['Abhaynagar', 'Bagherpara', 'Chaugachha', 'Jhikargachha', 'Keshabpur'],
    'Mymensingh': ['Trishal', 'Phulpur', 'Haluaghat', 'Muktagacha', 'Bhaluka'],
    'Rangpur': ['Pirganj', 'Kaunia', 'Mithapukur', 'Badarganj', 'Gangachara'],
    'Cumilla': ['Chandina', 'Daudkandi', 'Homna', 'Muradnagar', 'Debidwar'],
    'Faridpur': ['Bhanga', 'Boalmari', 'Alfadanga', 'Madhukhali', 'Nagarkanda'],
  };

  static final List<String> _vehicleSizes = ['Small', 'Mid', 'Big'];

  static String _generateFakeId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final randomStr = (random.nextInt(900000) + 100000).toString();
    return 'UID_$timestamp$randomStr';
  }

  static String _getVehicleType(String size) {
    switch (size) {
      case 'Small': return 'Pickup (Tata Ace)';
      case 'Mid': return 'Medium Truck (14ft)';
      case 'Big': return 'Heavy Truck (18ft+)';
      default: return 'Truck';
    }
  }

  static String _getCapacity(String size) {
    switch (size) {
      case 'Small': return '1-2 Ton';
      case 'Mid': return '3-5 Ton';
      case 'Big': return '6-10 Ton';
      default: return 'Unknown';
    }
  }

  // Approximate center coordinates for each upazila (for distance calc)
  static final Map<String, Map<String, double>> _upazilaCoordinates = {
    'Gurudaspur': {'lat': 24.1817, 'lng': 89.0264},
    'Singra': {'lat': 24.2500, 'lng': 88.9950},
    'Natore Sadar': {'lat': 24.4200, 'lng': 89.0000},
    'Baraigram': {'lat': 24.1320, 'lng': 89.0820},
    'Lalpur': {'lat': 24.0817, 'lng': 88.9431},
    'Bagatipara': {'lat': 24.3217, 'lng': 89.0764},
    'Shibganj': {'lat': 24.7200, 'lng': 89.2800},
    'Sherpur': {'lat': 24.6100, 'lng': 89.3800},
    'Paba': {'lat': 24.3800, 'lng': 88.7500},
    'Godagari': {'lat': 24.5300, 'lng': 88.4800},
  };

  static Future<void> seedDatabase() async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();
    final random = Random();
    
    int counter = 1;

    try {
      for (final district in _locations.keys) {
        final upazilas = _locations[district]!;
        
        for (final upazila in upazilas) {
          for (final size in _vehicleSizes) {
            final uid = _generateFakeId();
            final docRef = firestore.collection('users').doc(uid);
            
            final name = 'Driver $counter ($upazila)';
            final email = 'driver${counter}_${upazila.toLowerCase().replaceAll(' ', '_')}@agrolink.com';
            final phone = '017${(10000000 + counter).toString().padLeft(8, '0')}';
            
            // More realistic fares based on vehicle size
            double baseFare;
            double perKmRate;
            switch (size) {
              case 'Small':
                baseFare = 200.0 + (random.nextInt(4) * 50); // 200-350
                perKmRate = 25.0 + (random.nextInt(3) * 5); // 25-35
                break;
              case 'Mid':
                baseFare = 400.0 + (random.nextInt(4) * 100); // 400-700
                perKmRate = 45.0 + (random.nextInt(3) * 10); // 45-65
                break;
              case 'Big':
              default:
                baseFare = 700.0 + (random.nextInt(4) * 150); // 700-1150
                perKmRate = 70.0 + (random.nextInt(3) * 15); // 70-100
            }

            final coords = _upazilaCoordinates[upazila];
            
            final driverData = {
              'uid': uid,
              'name': name,
              'email': email,
              'phone': phone,
              'userType': 'Driver',
              'district': district,
              'upazila': upazila,
              'vehicleSize': size,
              'vehicleType': _getVehicleType(size),
              'capacity': _getCapacity(size),
              'isAvailable': true,
              'baseFare': baseFare,
              'perKmRate': perKmRate,
              'vehicleNumber': 'DHA-11-${(1000 + counter)}',
              'rating': 4.0 + (random.nextDouble() * 1.0), // 4.0 - 5.0
              'totalTrips': 10 + random.nextInt(90),
              if (coords != null) 'latitude': coords['lat'],
              if (coords != null) 'longitude': coords['lng'],
              'createdAt': FieldValue.serverTimestamp(),
            };

            batch.set(docRef, driverData);
            counter++;
          }
        }
      }

      await batch.commit();
      debugPrint('Successfully seeded ${counter - 1} dummy drivers!');
      
    } catch (e) {
      debugPrint('Error seeding data: $e');
      rethrow;
    }
  }

  /// Returns a flat list of all supported districts
  static List<String> getAllDistricts() => _locations.keys.toList();

  /// Returns upazilas for a district
  static List<String> getUpazilas(String district) =>
      _locations[district] ?? [];

  /// Returns the full location map
  static Map<String, List<String>> get locations => _locations;

  /// Returns coordinates for an upazila (if available)
  static Map<String, double>? getCoordinates(String upazila) =>
      _upazilaCoordinates[upazila];
}
