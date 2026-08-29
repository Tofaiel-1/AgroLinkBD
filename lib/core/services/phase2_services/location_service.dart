import 'package:agrolinkbd/core/models/phase2_models/map_models.dart';
import 'package:agrolinkbd/core/services/location_service.dart' as core_loc;

/// Service for managing location operations in phase 2
class LocationService {
  final core_loc.LocationService _coreLocationService = core_loc.LocationService();

  /// Get current user location with real GPS & reverse geocoded address
  Future<MapLocation> getCurrentLocation() async {
    final pos = await _coreLocationService.getCurrentPosition();
    if (pos != null) {
      final res = await _coreLocationService.resolveAddressFromCoordinates(pos.latitude, pos.longitude);
      return MapLocation(
        latitude: pos.latitude,
        longitude: pos.longitude,
        address: res.formattedAddress,
        title: '${res.upazilaBangla}, ${res.districtBangla}',
        timestamp: DateTime.now(),
      );
    }

    final fallback = await _coreLocationService.getCurrentLocationAddress();
    return MapLocation(
      latitude: fallback.latitude,
      longitude: fallback.longitude,
      address: fallback.formattedAddress,
      title: fallback.formattedAddress,
      timestamp: DateTime.now(),
    );
  }

  /// Stream location updates with real GPS
  Stream<MapLocation> getLocationStream() async* {
    await for (final pos in _coreLocationService.getPositionStream()) {
      yield MapLocation(
        latitude: pos.latitude,
        longitude: pos.longitude,
        address: 'লাইভ অবস্থান: (${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)})',
        title: 'বর্তমান লোকেশন',
        timestamp: DateTime.now(),
      );
    }
  }

  /// Calculate distance between two locations with precise geodesic formula (in km)
  Future<double> getDistanceBetween(MapLocation a, MapLocation b) async {
    return _coreLocationService.calculateDistance(
      startLatitude: a.latitude,
      startLongitude: a.longitude,
      endLatitude: b.latitude,
      endLongitude: b.longitude,
    );
  }

  /// Get address from coordinates using Nominatim & BD Database
  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    final res = await _coreLocationService.resolveAddressFromCoordinates(latitude, longitude);
    return res.formattedAddress;
  }
}
