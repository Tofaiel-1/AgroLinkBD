import 'package:agrolinkbd/core/models/phase2_models/map_models.dart';

/// Service for managing location operations
class LocationService {
  /// Get current user location
  Future<MapLocation> getCurrentLocation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MapLocation(
      latitude: 23.8103,
      longitude: 90.4125,
      address: 'Dhaka, Bangladesh',
      title: 'Current Location',
      timestamp: DateTime.now(),
    );
  }

  /// Stream location updates
  Stream<MapLocation> getLocationStream() async* {
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(seconds: 2));
      yield MapLocation(
        latitude: 23.8103 + (i * 0.001),
        longitude: 90.4125 + (i * 0.001),
        address: 'Location Update $i',
        title: 'Current Location',
        timestamp: DateTime.now(),
      );
    }
  }

  /// Calculate distance between two locations
  Future<double> getDistanceBetween(MapLocation a, MapLocation b) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Simple distance calculation (not accurate, use real geolocation package)
    final lat1 = a.latitude;
    final lon1 = a.longitude;
    final lat2 = b.latitude;
    final lon2 = b.longitude;

    const R = 6371; // Radius of earth in km
    final latDiff = lat2 - lat1;
    final lonDiff = lon2 - lon1;

    final distance = 2 * R * (latDiff.abs() + lonDiff.abs()) / 2;

    return distance;
  }

  /// Get address from coordinates
  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return 'Location at ($latitude, $longitude)';
  }
}
