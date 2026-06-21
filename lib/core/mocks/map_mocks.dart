import 'package:agrolinkbd/core/models/phase2_models/map_models.dart';

/// Mock data for map module testing
class MapMocks {
  /// Sample delivery routes
  static List<DeliveryRoute> getSampleRoutes() {
    return [
      DeliveryRoute(
        deliveryId: 'DL_001',
        pickup: MapLocation(
          latitude: 23.8103,
          longitude: 90.4125,
          address: 'Dhaka Central Market',
          title: 'Market',
          timestamp: DateTime.now(),
        ),
        delivery: MapLocation(
          latitude: 23.8200,
          longitude: 90.4250,
          address: 'Gulshan Avenue',
          title: 'Home',
          timestamp: DateTime.now(),
        ),
        waypoints: [],
        status: 'in_transit',
        estimatedTime: 18.5,
        distance: 8.2,
      ),
      DeliveryRoute(
        deliveryId: 'DL_002',
        pickup: MapLocation(
          latitude: 23.8103,
          longitude: 90.4125,
          address: 'Market Area',
          title: 'Pickup',
          timestamp: DateTime.now(),
        ),
        delivery: MapLocation(
          latitude: 23.7800,
          longitude: 90.3900,
          address: 'Banani District',
          title: 'Delivery',
          timestamp: DateTime.now(),
        ),
        waypoints: [],
        status: 'pending',
        estimatedTime: 25.0,
        distance: 12.5,
      ),
    ];
  }

  /// Sample order tracking data
  static List<OrderTrackingData> getSampleOrderTracking() {
    return [
      OrderTrackingData(
        orderId: 'ORD_001',
        pickupLocation: MapLocation(
          latitude: 23.8103,
          longitude: 90.4125,
          address: 'Farm Fresh Market',
          title: 'Pickup',
          timestamp: DateTime.now(),
        ),
        deliveryLocation: MapLocation(
          latitude: 23.8200,
          longitude: 90.4250,
          address: 'Your Address',
          title: 'Delivery',
          timestamp: DateTime.now(),
        ),
        driverName: 'Ahmed Hasan',
        driverRating: 4.8,
        vehicleNumber: 'DH 45 AB 123',
        status: 'in_transit',
        estimatedDelivery: DateTime.now().add(const Duration(minutes: 15)),
      ),
    ];
  }

  /// Sample nearby locations
  static List<MapLocation> getSampleNearbyLocations() {
    return [
      MapLocation(
        latitude: 23.8103,
        longitude: 90.4125,
        address: 'Badda,Dhaka 1212',
        title: 'Fresh Farm Market 1',
        timestamp: DateTime.now(),
      ),
      MapLocation(
        latitude: 23.8150,
        longitude: 90.4180,
        address: 'Gulshan 2, Dhaka',
        title: 'Organic Store',
        timestamp: DateTime.now(),
      ),
      MapLocation(
        latitude: 23.8050,
        longitude: 90.4080,
        address: 'Baridhara, Dhaka',
        title: 'Agricultural Hub',
        timestamp: DateTime.now(),
      ),
    ];
  }
}
