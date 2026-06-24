import 'package:cloud_firestore/cloud_firestore.dart';

// Farm Management Models for Phase 2

class Farm {
  final String id;
  final String userId;
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
    required this.userId,
    required this.name,
    required this.area,
    required this.location,
    required this.crops,
    required this.established,
    required this.soilType,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'area': area,
      'location': location,
      'crops': crops,
      'established': Timestamp.fromDate(established),
      'soilType': soilType,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Farm.fromMap(Map<String, dynamic> map, String documentId) {
    return Farm(
      id: documentId,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      area: (map['area'] ?? 0.0).toDouble(),
      location: map['location'] ?? '',
      crops: List<String>.from(map['crops'] ?? []),
      established: map['established'] != null 
          ? (map['established'] as Timestamp).toDate() 
          : DateTime.now(),
      soilType: map['soilType'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
    );
  }
}

class CropPlanting {
  final String id;
  final String userId;
  final String farmId;
  final String cropName;
  final DateTime plantedDate;
  final DateTime expectedHarvestDate;
  final double area;
  final String soilPreparation;
  final List<String> fertilizersUsed;
  final List<String> pesticidesUsed;
  final double expectedYield;
  final String status; // planning, planted, growing, ready_to_harvest, harvested

  CropPlanting({
    required this.id,
    required this.userId,
    required this.farmId,
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

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'farmId': farmId,
      'cropName': cropName,
      'plantedDate': Timestamp.fromDate(plantedDate),
      'expectedHarvestDate': Timestamp.fromDate(expectedHarvestDate),
      'area': area,
      'soilPreparation': soilPreparation,
      'fertilizersUsed': fertilizersUsed,
      'pesticidesUsed': pesticidesUsed,
      'expectedYield': expectedYield,
      'status': status,
    };
  }

  factory CropPlanting.fromMap(Map<String, dynamic> map, String documentId) {
    return CropPlanting(
      id: documentId,
      userId: map['userId'] ?? '',
      farmId: map['farmId'] ?? '',
      cropName: map['cropName'] ?? '',
      plantedDate: map['plantedDate'] != null 
          ? (map['plantedDate'] as Timestamp).toDate() 
          : DateTime.now(),
      expectedHarvestDate: map['expectedHarvestDate'] != null 
          ? (map['expectedHarvestDate'] as Timestamp).toDate() 
          : DateTime.now(),
      area: (map['area'] ?? 0.0).toDouble(),
      soilPreparation: map['soilPreparation'] ?? '',
      fertilizersUsed: List<String>.from(map['fertilizersUsed'] ?? []),
      pesticidesUsed: List<String>.from(map['pesticidesUsed'] ?? []),
      expectedYield: (map['expectedYield'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'planning',
    );
  }
}

class FarmActivity {
  final String id;
  final String userId;
  final String farmId;
  final String title;
  final String description;
  final DateTime date;
  final String type; // watering, fertilizing, spraying, harvesting
  final double cost;
  final String notes;

  FarmActivity({
    required this.id,
    required this.userId,
    required this.farmId,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    required this.cost,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'farmId': farmId,
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'type': type,
      'cost': cost,
      'notes': notes,
    };
  }

  factory FarmActivity.fromMap(Map<String, dynamic> map, String documentId) {
    return FarmActivity(
      id: documentId,
      userId: map['userId'] ?? '',
      farmId: map['farmId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] != null 
          ? (map['date'] as Timestamp).toDate() 
          : DateTime.now(),
      type: map['type'] ?? '',
      cost: (map['cost'] ?? 0.0).toDouble(),
      notes: map['notes'] ?? '',
    );
  }
}

class FarmExpense {
  final String id;
  final String userId;
  final String farmId;
  final String category; // Fertilizer, Labor, Seeds, Equipment, etc.
  final double amount;
  final DateTime date;
  final String description;

  FarmExpense({required this.id, required this.userId, required this.farmId, required this.category, required this.amount, required this.date, required this.description});

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'farmId': farmId,
      'category': category,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'description': description,
    };
  }

  factory FarmExpense.fromMap(Map<String, dynamic> map, String documentId) {
    return FarmExpense(
      id: documentId,
      userId: map['userId'] ?? '',
      farmId: map['farmId'] ?? '',
      category: map['category'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      date: map['date'] != null ? (map['date'] as Timestamp).toDate() : DateTime.now(),
      description: map['description'] ?? '',
    );
  }
}

class FarmRevenue {
  final String id;
  final String userId;
  final String farmId;
  final String cropName; 
  final double amount; 
  final double quantity; 
  final String unit; 
  final DateTime date;
  final String buyerName;

  FarmRevenue({required this.id, required this.userId, required this.farmId, required this.cropName, required this.amount, required this.quantity, required this.unit, required this.date, required this.buyerName});

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'farmId': farmId,
      'cropName': cropName,
      'amount': amount,
      'quantity': quantity,
      'unit': unit,
      'date': Timestamp.fromDate(date),
      'buyerName': buyerName,
    };
  }

  factory FarmRevenue.fromMap(Map<String, dynamic> map, String documentId) {
    return FarmRevenue(
      id: documentId,
      userId: map['userId'] ?? '',
      farmId: map['farmId'] ?? '',
      cropName: map['cropName'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      quantity: (map['quantity'] ?? 0.0).toDouble(),
      unit: map['unit'] ?? 'kg',
      date: map['date'] != null ? (map['date'] as Timestamp).toDate() : DateTime.now(),
      buyerName: map['buyerName'] ?? '',
    );
  }
}

class FarmInventoryItem {
  final String id;
  final String userId;
  final String name; 
  final String category; 
  final double quantity;
  final String unit; 
  final double valuePerUnit;

  FarmInventoryItem({required this.id, required this.userId, required this.name, required this.category, required this.quantity, required this.unit, required this.valuePerUnit});

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'valuePerUnit': valuePerUnit,
    };
  }

  factory FarmInventoryItem.fromMap(Map<String, dynamic> map, String documentId) {
    return FarmInventoryItem(
      id: documentId,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      quantity: (map['quantity'] ?? 0.0).toDouble(),
      unit: map['unit'] ?? '',
      valuePerUnit: (map['valuePerUnit'] ?? 0.0).toDouble(),
    );
  }
}
