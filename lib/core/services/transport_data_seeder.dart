import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class TransportDataSeeder {
  // Hardcoded District -> Upazila map
  static final Map<String, List<String>> _locations = {
    'Bogura': ['Shibganj', 'Sherpur', 'Kahaloo', 'Nandigram', 'Sariakandi'],
    'Dhaka': ['Savar', 'Keraniganj', 'Dhamrai', 'Nawabganj', 'Dohar'],
    'Rajshahi': ['Paba', 'Godagari', 'Mohanpur', 'Tanore', 'Bagmara'],
    'Dinajpur': ['Birol', 'Bochaganj', 'Khansama', 'Parbatipur', 'Nawabganj'],
    'Jessore': ['Abhaynagar', 'Bagherpara', 'Chaugachha', 'Jhikargachha', 'Keshabpur'],
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

  static Future<void> seedDatabase() async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();
    
    int counter = 1;

    try {
      for (final district in _locations.keys) {
        final upazilas = _locations[district]!;
        
        for (final upazila in upazilas) {
          for (final size in _vehicleSizes) {
            final uid = _generateFakeId();
            final docRef = firestore.collection('users').doc(uid);
            
            // Generate some mock data
            final name = 'Driver $counter ($upazila)';
            final email = 'driver${counter}_${upazila.toLowerCase()}@test.com';
            final phone = '017${(10000000 + counter).toString().padLeft(8, '0')}';
            final password = 'password123';
            
            final driverData = {
              'uid': uid,
              'name': name,
              'email': email,
              'password': password, // Storing for testing visibility
              'phone': phone,
              'userType': 'Driver',
              'district': district,
              'upazila': upazila,
              'vehicleSize': size,
              'vehicleType': _getVehicleType(size),
              'capacity': _getCapacity(size),
              'isAvailable': true,
              // Random base fare and per km rate to make demo realistic
              'baseFare': 300.0 + (Random().nextInt(3) * 100), // 300 to 500
              'perKmRate': 40.0 + (Random().nextInt(3) * 10), // 40 to 60
              'vehicleNumber': 'DHA-11-${(1000 + counter)}',
              'createdAt': FieldValue.serverTimestamp(),
            };

            batch.set(docRef, driverData);
            counter++;
          }
        }
      }

      // Commit the batch
      await batch.commit();
      debugPrint('Successfully seeded ${counter - 1} dummy drivers!');
      
    } catch (e) {
      debugPrint('Error seeding data: $e');
      rethrow;
    }
  }
}
