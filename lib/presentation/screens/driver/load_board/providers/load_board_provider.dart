import 'dart:math';
import 'package:flutter/material.dart';
import 'package:agrolinkbd/core/models/transport_model.dart';

class LoadBoardProvider extends ChangeNotifier {
  List<TransportRequestModel> _allTrips = [];
  List<TransportRequestModel> _filteredTrips = [];
  
  // Driver's current location (mocked initially to Dhaka)
  double _currentLat = 23.8103;
  double _currentLng = 90.4125;
  String _currentLocationName = "ঢাকা (Dhaka)";

  // Filters
  double _minPayment = 0.0;
  String _selectedTruckSize = 'All';

  LoadBoardProvider() {
    _generateMockTrips();
    _applyFiltersAndSort();
  }

  List<TransportRequestModel> get filteredTrips => _filteredTrips;
  double get currentLat => _currentLat;
  double get currentLng => _currentLng;
  String get currentLocationName => _currentLocationName;

  void updateLocation(double lat, double lng, String name) {
    _currentLat = lat;
    _currentLng = lng;
    _currentLocationName = name;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void updateFilters({double? minPayment, String? truckSize}) {
    if (minPayment != null) _minPayment = minPayment;
    if (truckSize != null) _selectedTruckSize = truckSize;
    _applyFiltersAndSort();
    notifyListeners();
  }

  double calculateDistance(double lat2, double lon2) {
    return _haversineDistance(_currentLat, _currentLng, lat2, lon2);
  }

  double _haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295; // Math.PI / 180
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p) / 2 + 
            c(lat1 * p) * c(lat2 * p) * 
            (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  void _applyFiltersAndSort() {
    _filteredTrips = _allTrips.where((trip) {
      if (_minPayment > 0 && (trip.agreedPrice ?? 0) < _minPayment) {
        return false;
      }
      
      // Simple logic to map weight to truck size (for demonstration)
      String requiredSize = 'All';
      if (trip.weight <= 1000) requiredSize = '1 Ton Pickup';
      else if (trip.weight <= 5000) requiredSize = '5 Ton Truck';
      else requiredSize = '10+ Ton Truck';

      if (_selectedTruckSize != 'All' && requiredSize != _selectedTruckSize) {
        return false;
      }

      return true;
    }).toList();

    // Sort by distance (nearest first)
    _filteredTrips.sort((a, b) {
      final distA = calculateDistance(a.pickupLatitude ?? 0, a.pickupLongitude ?? 0);
      final distB = calculateDistance(b.pickupLatitude ?? 0, b.pickupLongitude ?? 0);
      return distA.compareTo(distB);
    });
  }

  void _generateMockTrips() {
    _allTrips = [
      TransportRequestModel(
        id: 'TRP-1001',
        farmerId: 'F1',
        farmerName: 'রহিম মিয়া',
        farmerPhone: '01711000000',
        pickupLocation: 'সাভার, ঢাকা',
        pickupLatitude: 23.8388,
        pickupLongitude: 90.2674,
        deliveryLocation: 'কারওয়ান বাজার, ঢাকা',
        deliveryLatitude: 23.7516,
        deliveryLongitude: 90.3934,
        productType: 'কাঁচা টমেটো',
        weight: 1500, // 1.5 tons
        pickupDate: DateTime.now().add(const Duration(hours: 2)),
        status: TransportStatus.pending,
        agreedPrice: 3500,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      TransportRequestModel(
        id: 'TRP-1002',
        farmerId: 'F2',
        farmerName: 'করিম শেখ',
        farmerPhone: '01722000000',
        pickupLocation: 'গাজীপুর',
        pickupLatitude: 23.9999,
        pickupLongitude: 90.4203,
        deliveryLocation: 'যশোর সদর',
        deliveryLatitude: 23.1634,
        deliveryLongitude: 89.2182,
        productType: 'আলু',
        weight: 8000, // 8 tons
        pickupDate: DateTime.now().add(const Duration(hours: 5)),
        status: TransportStatus.pending,
        agreedPrice: 12000,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      TransportRequestModel(
        id: 'TRP-1003',
        farmerId: 'F3',
        farmerName: 'আজিজ মন্ডল',
        farmerPhone: '01733000000',
        pickupLocation: 'রাজশাহী',
        pickupLatitude: 24.3745,
        pickupLongitude: 88.6042,
        deliveryLocation: 'যাত্রাবাড়ী, ঢাকা',
        deliveryLatitude: 23.7104,
        deliveryLongitude: 90.4326,
        productType: 'আম (ফজলি)',
        weight: 4500, // 4.5 tons
        pickupDate: DateTime.now().add(const Duration(days: 1)),
        status: TransportStatus.pending,
        agreedPrice: 15000,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      TransportRequestModel(
        id: 'TRP-1004',
        farmerId: 'F4',
        farmerName: 'সোলায়মান আলী',
        farmerPhone: '01744000000',
        pickupLocation: 'বগুড়া',
        pickupLatitude: 24.8465,
        pickupLongitude: 89.3777,
        deliveryLocation: 'সাভার, ঢাকা',
        deliveryLatitude: 23.8388,
        deliveryLongitude: 90.2674,
        productType: 'ধান (মিনিকেট)',
        weight: 12000, // 12 tons
        pickupDate: DateTime.now().add(const Duration(hours: 12)),
        status: TransportStatus.pending,
        agreedPrice: 18000,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      TransportRequestModel(
        id: 'TRP-1005',
        farmerId: 'F5',
        farmerName: 'কাদের বক্স',
        farmerPhone: '01755000000',
        pickupLocation: 'মুন্সিগঞ্জ',
        pickupLatitude: 23.4981,
        pickupLongitude: 90.4127,
        deliveryLocation: 'পুরান ঢাকা',
        deliveryLatitude: 23.7106,
        deliveryLongitude: 90.3978,
        productType: 'আলু (ডায়মন্ড)',
        weight: 500, // 0.5 tons
        pickupDate: DateTime.now().add(const Duration(minutes: 30)),
        status: TransportStatus.pending,
        agreedPrice: 1200,
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
    ];
  }
}
