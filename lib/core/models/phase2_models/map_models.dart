// Map Models for Phase 2

class MapLocation {
  final double latitude;
  final double longitude;
  final String address;
  final String title;
  final DateTime timestamp;

  MapLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.title,
    required this.timestamp,
  });
}

class DeliveryRoute {
  final String deliveryId;
  final MapLocation pickup;
  final MapLocation delivery;
  final List<MapLocation> waypoints;
  final String status; // pending, in_transit, delivered
  final double estimatedTime; // in minutes
  final double distance; // in km

  DeliveryRoute({
    required this.deliveryId,
    required this.pickup,
    required this.delivery,
    required this.waypoints,
    required this.status,
    required this.estimatedTime,
    required this.distance,
  });
}

class OrderTrackingData {
  final String orderId;
  final MapLocation pickupLocation;
  final MapLocation deliveryLocation;
  final String driverName;
  final double driverRating;
  final String vehicleNumber;
  final String status;
  final DateTime estimatedDelivery;

  OrderTrackingData({
    required this.orderId,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.driverName,
    required this.driverRating,
    required this.vehicleNumber,
    required this.status,
    required this.estimatedDelivery,
  });
}
