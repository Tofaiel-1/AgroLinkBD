import 'dart:math' as math;

/// Utilities for map operations
class MapUtils {
  /// Calculate distance between two points using Haversine formula
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double R = 6371; // Radius of Earth in km

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        (math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2));

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final double distance = R * c;

    return distance;
  }

  /// Convert degrees to radians
  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Estimate time based on distance and speed
  static int estimateTimeInMinutes(double distanceInKm, double speedInKmh) {
    return (distanceInKm / speedInKmh * 60).toInt();
  }

  /// Format distance for display
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).toStringAsFixed(0)}m';
    }
    return '${distanceInKm.toStringAsFixed(1)}km';
  }

  /// Check if point is within bounds
  static bool isPointWithinBounds(
    double lat,
    double lon,
    double minLat,
    double minLon,
    double maxLat,
    double maxLon,
  ) {
    return lat >= minLat && lat <= maxLat && lon >= minLon && lon <= maxLon;
  }
}
