import 'package:agrolinkbd/core/models/phase2_models/farm_models.dart';

/// Mock data for farm management module testing
class FarmMocks {
  /// Sample farms
  static List<Farm> getSampleFarms() {
    return [
      Farm(
        id: '1',
        name: 'Main Agricultural Farm',
        area: 15.5,
        location: 'Savar, Dhaka',
        crops: ['Tomato', 'Cucumber', 'Lettuce', 'Spinach'],
        established: DateTime(2018, 6, 15),
        soilType: 'Loamy',
        latitude: 23.8450,
        longitude: 90.2717,
      ),
      Farm(
        id: '2',
        name: 'Secondary Farm',
        area: 8.2,
        location: 'Narayanganj',
        crops: ['Potato', 'Onion', 'Garlic'],
        established: DateTime(2020, 3, 20),
        soilType: 'Clay',
        latitude: 23.6044,
        longitude: 90.4854,
      ),
      Farm(
        id: '3',
        name: 'Organic Farm',
        area: 5.8,
        location: 'Gazipur',
        crops: ['Organic Vegetables', 'Herbs'],
        established: DateTime(2021, 1, 10),
        soilType: 'Sandy Loam',
        latitude: 23.9800,
        longitude: 90.4167,
      ),
    ];
  }

  /// Sample crop plantings
  static List<CropPlanting> getSampleCropPlantings() {
    return [
      CropPlanting(
        cropId: 'CROP_001',
        cropName: 'Tomato',
        plantedDate: DateTime.now().subtract(const Duration(days: 30)),
        expectedHarvestDate: DateTime.now().add(const Duration(days: 30)),
        area: 5.0,
        soilPreparation: 'Tilled and enriched with organic compost',
        fertilizersUsed: ['NPK 20:20:20', 'Organic manure'],
        pesticidesUsed: ['Neem oil'],
        expectedYield: 25000.0,
        status: 'growing',
      ),
      CropPlanting(
        cropId: 'CROP_002',
        cropName: 'Potato',
        plantedDate: DateTime.now().subtract(const Duration(days: 60)),
        expectedHarvestDate: DateTime.now().add(const Duration(days: 10)),
        area: 3.5,
        soilPreparation: 'Deep plowing and ridging',
        fertilizersUsed: ['Potassium fertilizer', 'DAP'],
        pesticidesUsed: ['Fungicide'],
        expectedYield: 15000.0,
        status: 'ready_to_harvest',
      ),
    ];
  }

  /// Sample farm activities
  static List<FarmActivity> getSampleFarmActivities() {
    return [
      FarmActivity(
        id: 'ACT_001',
        title: 'Field Watering',
        description: 'Watered tomato field with drip irrigation',
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: 'watering',
        cost: 500.0,
        notes: 'Early morning watering, 3 hours duration',
      ),
      FarmActivity(
        id: 'ACT_002',
        title: 'Fertilizer Application',
        description: 'Applied NPK fertilizer to potato field',
        date: DateTime.now().subtract(const Duration(days: 3)),
        type: 'fertilizing',
        cost: 2500.0,
        notes: '50kg applied, weather was favorable',
      ),
      FarmActivity(
        id: 'ACT_003',
        title: 'Pest Control Spraying',
        description: 'Sprayed organic pesticide',
        date: DateTime.now().subtract(const Duration(days: 5)),
        type: 'spraying',
        cost: 1500.0,
        notes: 'Used neem oil spray on tomato plants',
      ),
      FarmActivity(
        id: 'ACT_004',
        title: 'Harvesting',
        description: 'Harvested ripe tomatoes',
        date: DateTime.now().subtract(const Duration(days: 7)),
        type: 'harvesting',
        cost: 3000.0,
        notes: 'Collected 500kg of quality tomatoes',
      ),
    ];
  }
}
