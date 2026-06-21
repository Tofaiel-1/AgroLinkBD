import 'package:agrolinkbd/core/models/phase2_models/farm_models.dart';

/// Service for managing farm operations
class FarmService {
  /// Get all farms for current farmer
  Future<List<Farm>> getFarms() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      Farm(
        id: '1',
        name: 'Main Farm',
        area: 10.5,
        location: 'Dhaka',
        crops: ['Tomato', 'Cucumber', 'Lettuce'],
        established: DateTime(2018, 6, 15),
        soilType: 'Loamy',
        latitude: 23.8103,
        longitude: 90.4125,
      ),
      Farm(
        id: '2',
        name: 'Secondary Farm',
        area: 5.2,
        location: 'Narayanganj',
        crops: ['Potato', 'Onion'],
        established: DateTime(2020, 3, 20),
        soilType: 'Clay',
        latitude: 23.6044,
        longitude: 90.4854,
      ),
    ];
  }

  /// Create a new farm
  Future<Farm> createFarm(Farm farm) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return farm;
  }

  /// Update an existing farm
  Future<void> updateFarm(Farm farm) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Implementation will update Firestore
  }

  /// Get crop plantings for a farm
  Future<List<CropPlanting>> getCropPlannings(String farmId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      CropPlanting(
        cropId: '1',
        cropName: 'Tomato',
        plantedDate: DateTime.now().subtract(const Duration(days: 30)),
        expectedHarvestDate: DateTime.now().add(const Duration(days: 60)),
        area: 5.0,
        soilPreparation: 'Tilled and fertilized',
        fertilizersUsed: ['NPK', 'Organic compost'],
        pesticidesUsed: ['Neem oil'],
        expectedYield: 20000.0,
        status: 'growing',
      ),
    ];
  }

  /// Add a new crop planting
  Future<void> addCropPlanting(CropPlanting planting) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Implementation will create in Firestore
  }

  /// Get farm activities log
  Future<List<FarmActivity>> getFarmActivities(String farmId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      FarmActivity(
        id: '1',
        title: 'Watering',
        description: 'Watered tomato field',
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: 'watering',
        cost: 500.0,
        notes: 'Used drip irrigation',
      ),
      FarmActivity(
        id: '2',
        title: 'Fertilizing',
        description: 'Applied NPK fertilizer',
        date: DateTime.now().subtract(const Duration(days: 3)),
        type: 'fertilizing',
        cost: 2500.0,
        notes: 'Applied recommended dose',
      ),
    ];
  }

  /// Log a farm activity
  Future<void> logFarmActivity(FarmActivity activity) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Implementation will create in Firestore
  }
}
