// Farm Management Models for Phase 2

class Farm {
  final String id;
  final String name;
  final double area; // in hectares
  final String location;
  final List<String> crops;
  final DateTime established;
  final String soilType;
  final double latitude;
  final double longitude;

  Farm({
    required this.id,
    required this.name,
    required this.area,
    required this.location,
    required this.crops,
    required this.established,
    required this.soilType,
    required this.latitude,
    required this.longitude,
  });
}

class CropPlanting {
  final String cropId;
  final String cropName;
  final DateTime plantedDate;
  final DateTime expectedHarvestDate;
  final double area;
  final String soilPreparation;
  final List<String> fertilizersUsed;
  final List<String> pesticidesUsed;
  final double expectedYield;
  final String
      status; // planning, planted, growing, ready_to_harvest, harvested

  CropPlanting({
    required this.cropId,
    required this.cropName,
    required this.plantedDate,
    required this.expectedHarvestDate,
    required this.area,
    required this.soilPreparation,
    required this.fertilizersUsed,
    required this.pesticidesUsed,
    required this.expectedYield,
    required this.status,
  });
}

class FarmActivity {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String type; // watering, fertilizing, spraying, harvesting
  final double cost;
  final String notes;

  FarmActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    required this.cost,
    required this.notes,
  });
}
