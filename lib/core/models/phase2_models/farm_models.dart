import 'package:cloud_firestore/cloud_firestore.dart';

// ============================================================================
// ULTRA PRO MAX FARM & AQUACULTURE MANAGEMENT ENTERPRISE MODELS
// ============================================================================

enum FarmType {
  fishPond, // কার্প ও দেশি মাছের বাণিজ্যিক পুকুর
  biofloc, // হাই-ডেনসিটি সার্কুলার বায়োফ্লক ট্যাংক
  rasAquaculture, // আধুনিক রিসার্কুলেটিং অ্যাকুয়াকালচার সিস্টেম
  shrimpGher, // উপকূলীয় বাগদা ও গলদা চিংড়ি ঘের
  hatchery, // পোনা ও ব্রুডস্টক হ্যাচারি কমপ্লেক্স
  cropField, // উন্নত শস্য ও উদ্যানতাত্ত্বিক খেত
  greenhouse, // আধুনিক গ্রিনহাউস ও পলিনেট শেড
  dairyLivestock, // ডেইরি ও প্রাণিসম্পদ খামার
  mixedAgro, // সমন্বিত মৎস্য ও কৃষি প্রকল্প
}

extension FarmTypeExtension on FarmType {
  String get displayNameBn {
    switch (this) {
      case FarmType.fishPond:
        return 'বাণিজ্যিক মৎস্য পুকুর';
      case FarmType.biofloc:
        return 'বায়োফ্লক ট্যাংক ইউনিট';
      case FarmType.rasAquaculture:
        return 'আরএএস (RAS) স্মার্ট অ্যাকুয়াকালচার';
      case FarmType.shrimpGher:
        return 'উপকূলীয় চিংড়ি ঘের';
      case FarmType.hatchery:
        return 'হ্যাচারি ও ব্রুডস্টক কমপ্লেক্স';
      case FarmType.cropField:
        return 'উন্নত শস্য ও ফসল খেত';
      case FarmType.greenhouse:
        return 'স্মার্ট গ্রিনহাউস শেড';
      case FarmType.dairyLivestock:
        return 'ডেইরি ও গবাদিপশু খামার';
      case FarmType.mixedAgro:
        return 'সমন্বিত মৎস্য ও কৃষি প্রকল্প';
    }
  }

  String get defaultImage {
    switch (this) {
      case FarmType.fishPond:
        return 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=900&auto=format&fit=crop&q=80';
      case FarmType.biofloc:
        return 'https://images.unsplash.com/photo-1524704654690-b56c05c78a00?w=900&auto=format&fit=crop&q=80';
      case FarmType.rasAquaculture:
        return 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=900&auto=format&fit=crop&q=80';
      case FarmType.shrimpGher:
        return 'https://images.unsplash.com/photo-1559742811-822873691df8?w=900&auto=format&fit=crop&q=80';
      case FarmType.hatchery:
        return 'https://images.unsplash.com/photo-1534483509719-3feaee7c30da?w=900&auto=format&fit=crop&q=80';
      case FarmType.cropField:
        return 'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=900&auto=format&fit=crop&q=80';
      case FarmType.greenhouse:
        return 'https://images.unsplash.com/photo-1585320806297-9794b3e4eeae?w=900&auto=format&fit=crop&q=80';
      case FarmType.dairyLivestock:
        return 'https://images.unsplash.com/photo-1527153857715-3908f2ae5e81?w=900&auto=format&fit=crop&q=80';
      case FarmType.mixedAgro:
        return 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=900&auto=format&fit=crop&q=80';
    }
  }
}

DateTime _parseFarmDate(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  return DateTime.now();
}

double _parseFarmDouble(dynamic value, [double defaultValue = 0.0]) {
  if (value == null) return defaultValue;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? defaultValue;
  return defaultValue;
}

int _parseFarmInt(dynamic value, [int defaultValue = 0]) {
  if (value == null) return defaultValue;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}

// ----------------------------------------------------------------------------
// 1. FARM ENTERPRISE MODEL
// ----------------------------------------------------------------------------

class Farm {
  final String id;
  final String userId;
  final String name;
  final double area; // in acres or hectares
  final String areaUnit; // 'একর', 'শতাংশ', 'হেক্টর'
  final String location;
  final String district;
  final String upazila;
  final List<String> crops; // Fish species or crop types
  final DateTime established;
  final String soilType;
  final double latitude;
  final double longitude;
  
  // Pro Max Aquaculture & Commercial Farm Attributes
  final String farmTypeStr;
  final String imageUrl;
  final List<String> galleryUrls;
  final String waterSource; // 'নদীর মিষ্টি পানি', 'গভীর নলকূপ', 'জোয়ার-ভাটার লোনা খাঁড়ি'
  final double depthFeet;
  final int pondCount;
  final String bioSecurityRating; // 'Grade A+ (SPF Certified)', 'আন্তর্জাতিক সনদপ্রাপ্ত'
  final String farmManagerName;
  final String managerPhone;
  final String status; // 'সক্রিয় ও উৎপাদনশীল', 'প্রস্তুতিমূলক', 'হারভেস্ট চলমান'
  final String description;

  // Real-time Telemetry & Smart Automation
  final double dissolvedOxygen; // mg/L e.g. 6.8
  final double ph; // e.g. 7.4
  final double temperature; // °C e.g. 28.5
  final double ammonia; // mg/L e.g. 0.015
  final double salinity; // ppt e.g. 1.2
  final double turbidity; // cm e.g. 35.0
  final bool aeratorOn;
  final int aeratorTurbinesCount;
  final bool autoFeederActive;
  final double currentBiomassKg;
  final double estimatedValuation;

  Farm({
    required this.id,
    required this.userId,
    required this.name,
    required this.area,
    this.areaUnit = 'একর',
    required this.location,
    this.district = '',
    this.upazila = '',
    required this.crops,
    required this.established,
    required this.soilType,
    required this.latitude,
    required this.longitude,
    this.farmTypeStr = 'বাণিজ্যিক মৎস্য পুকুর',
    this.imageUrl = 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=900&auto=format&fit=crop&q=80',
    this.galleryUrls = const [],
    this.waterSource = 'নদীর মিষ্টি পানি ও গভীর নলকূপ',
    this.depthFeet = 6.5,
    this.pondCount = 3,
    this.bioSecurityRating = 'Grade A+ (শতভাগ রোগমুক্ত)',
    this.farmManagerName = '',
    this.managerPhone = '',
    this.status = 'সক্রিয় ও উৎপাদনশীল',
    this.description = '',
    this.dissolvedOxygen = 6.8,
    this.ph = 7.4,
    this.temperature = 28.0,
    this.ammonia = 0.015,
    this.salinity = 1.0,
    this.turbidity = 32.0,
    this.aeratorOn = true,
    this.aeratorTurbinesCount = 4,
    this.autoFeederActive = true,
    this.currentBiomassKg = 8500.0,
    this.estimatedValuation = 3200000.0,
  });

  FarmType get farmType {
    if (farmTypeStr.contains('বায়োফ্লক') || farmTypeStr.contains('biofloc')) return FarmType.biofloc;
    if (farmTypeStr.contains('আরএএস') || farmTypeStr.contains('ras')) return FarmType.rasAquaculture;
    if (farmTypeStr.contains('চিংড়ি') || farmTypeStr.contains('gher')) return FarmType.shrimpGher;
    if (farmTypeStr.contains('হ্যাচারি') || farmTypeStr.contains('hatchery')) return FarmType.hatchery;
    if (farmTypeStr.contains('গ্রিনহাউস') || farmTypeStr.contains('greenhouse')) return FarmType.greenhouse;
    if (farmTypeStr.contains('ডেইরি') || farmTypeStr.contains('dairy')) return FarmType.dairyLivestock;
    if (farmTypeStr.contains('শস্য') || farmTypeStr.contains('crop')) return FarmType.cropField;
    if (farmTypeStr.contains('সমন্বিত') || farmTypeStr.contains('mixed')) return FarmType.mixedAgro;
    return FarmType.fishPond;
  }

  bool get isFisheryFarm =>
      farmType == FarmType.fishPond ||
      farmType == FarmType.biofloc ||
      farmType == FarmType.rasAquaculture ||
      farmType == FarmType.shrimpGher ||
      farmType == FarmType.hatchery ||
      farmType == FarmType.mixedAgro;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'area': area,
      'areaUnit': areaUnit,
      'location': location,
      'district': district,
      'upazila': upazila,
      'crops': crops,
      'established': Timestamp.fromDate(established),
      'soilType': soilType,
      'latitude': latitude,
      'longitude': longitude,
      'farmTypeStr': farmTypeStr,
      'imageUrl': imageUrl,
      'galleryUrls': galleryUrls,
      'waterSource': waterSource,
      'depthFeet': depthFeet,
      'pondCount': pondCount,
      'bioSecurityRating': bioSecurityRating,
      'farmManagerName': farmManagerName,
      'managerPhone': managerPhone,
      'status': status,
      'description': description,
      'dissolvedOxygen': dissolvedOxygen,
      'ph': ph,
      'temperature': temperature,
      'ammonia': ammonia,
      'salinity': salinity,
      'turbidity': turbidity,
      'aeratorOn': aeratorOn,
      'aeratorTurbinesCount': aeratorTurbinesCount,
      'autoFeederActive': autoFeederActive,
      'currentBiomassKg': currentBiomassKg,
      'estimatedValuation': estimatedValuation,
    };
  }

  factory Farm.fromMap(Map<String, dynamic> map, String documentId) {
    return Farm(
      id: documentId,
      userId: map['userId']?.toString() ?? '',
      name: map['name']?.toString() ?? 'আমার খামার',
      area: _parseFarmDouble(map['area'], 1.0),
      areaUnit: map['areaUnit']?.toString() ?? 'একর',
      location: map['location']?.toString() ?? '',
      district: map['district']?.toString() ?? '',
      upazila: map['upazila']?.toString() ?? '',
      crops: List<String>.from(map['crops'] ?? []),
      established: _parseFarmDate(map['established']),
      soilType: map['soilType']?.toString() ?? 'দোআঁশ ও এঁটেল মাটি',
      latitude: _parseFarmDouble(map['latitude'], 23.8103),
      longitude: _parseFarmDouble(map['longitude'], 90.4125),
      farmTypeStr: map['farmTypeStr']?.toString() ?? 'বাণিজ্যিক মৎস্য পুকুর',
      imageUrl: map['imageUrl']?.toString() ?? 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=900&auto=format&fit=crop&q=80',
      galleryUrls: List<String>.from(map['galleryUrls'] ?? []),
      waterSource: map['waterSource']?.toString() ?? 'নদীর মিষ্টি পানি ও গভীর নলকূপ',
      depthFeet: _parseFarmDouble(map['depthFeet'], 6.5),
      pondCount: _parseFarmInt(map['pondCount'], 3),
      bioSecurityRating: map['bioSecurityRating']?.toString() ?? 'Grade A+ (শতভাগ রোগমুক্ত)',
      farmManagerName: map['farmManagerName']?.toString() ?? '',
      managerPhone: map['managerPhone']?.toString() ?? '',
      status: map['status']?.toString() ?? 'সক্রিয় ও উৎপাদনশীল',
      description: map['description']?.toString() ?? '',
      dissolvedOxygen: _parseFarmDouble(map['dissolvedOxygen'], 6.8),
      ph: _parseFarmDouble(map['ph'], 7.4),
      temperature: _parseFarmDouble(map['temperature'], 28.0),
      ammonia: _parseFarmDouble(map['ammonia'], 0.015),
      salinity: _parseFarmDouble(map['salinity'], 1.0),
      turbidity: _parseFarmDouble(map['turbidity'], 32.0),
      aeratorOn: map['aeratorOn'] == true,
      aeratorTurbinesCount: _parseFarmInt(map['aeratorTurbinesCount'], 4),
      autoFeederActive: map['autoFeederActive'] == true,
      currentBiomassKg: _parseFarmDouble(map['currentBiomassKg'], 8500.0),
      estimatedValuation: _parseFarmDouble(map['estimatedValuation'], 3200000.0),
    );
  }
}

// ----------------------------------------------------------------------------
// 2. CROP & AQUACULTURE BATCH PRODUCTION MODEL
// ----------------------------------------------------------------------------

class CropPlanting {
  final String id;
  final String userId;
  final String farmId;
  final String farmName;
  final String cropName; // Fish species (e.g. রুই, কাতলা, বাগদা) or crop name
  final String batchCode; // e.g. BATCH-2026-F01
  final DateTime plantedDate; // Stocking date
  final DateTime expectedHarvestDate;
  final double area;
  final String areaUnit;
  final String soilPreparation;
  final List<String> fertilizersUsed;
  final List<String> pesticidesUsed; // Probiotics or pest treatments
  final double expectedYield; // in KG or Tons
  final String status; // planning, planted, growing, ready_to_harvest, harvested
  
  // Pro Max Aquaculture Lifecycle & Biomass Dynamics
  final bool isAquaculture;
  final int stockingQuantity; // Total fingerlings / seeds
  final double initialAvgWeightGrams; // e.g. 50g
  final double currentAvgWeightGrams; // e.g. 1450g
  final double targetHarvestWeightGrams; // e.g. 1800g
  final double fcr; // Feed Conversion Ratio e.g. 1.28
  final double survivalRatePercent; // e.g. 94.5%
  final String growthStage; // 'নার্সারি ও রেণু', 'বাড়ন্ত পর্যায়', 'প্রাক-হারভেস্ট', 'হারভেস্ট প্রস্তুত'
  final double dailyFeedingKg;
  final String feedBrand;
  final double expectedMarketRatePerKg;
  final double totalInvestedCost;
  final String healthRating; // '১০০% সুস্থ ও প্রাণবন্ত', 'নিবিড় পর্যবেক্ষণ'
  final String imageUrl;

  CropPlanting({
    required this.id,
    required this.userId,
    required this.farmId,
    this.farmName = '',
    required this.cropName,
    this.batchCode = 'BATCH-F01',
    required this.plantedDate,
    required this.expectedHarvestDate,
    required this.area,
    this.areaUnit = 'একর',
    required this.soilPreparation,
    required this.fertilizersUsed,
    required this.pesticidesUsed,
    required this.expectedYield,
    required this.status,
    this.isAquaculture = true,
    this.stockingQuantity = 8000,
    this.initialAvgWeightGrams = 50.0,
    this.currentAvgWeightGrams = 1450.0,
    this.targetHarvestWeightGrams = 1800.0,
    this.fcr = 1.28,
    this.survivalRatePercent = 94.5,
    this.growthStage = 'বাড়ন্ত পর্যায়',
    this.dailyFeedingKg = 85.0,
    this.feedBrand = 'মেগা ফিড ফ্লোটিং প্রোটিন ২৮%',
    this.expectedMarketRatePerKg = 380.0,
    this.totalInvestedCost = 450000.0,
    this.healthRating = '১০০% সুস্থ ও প্রাণবন্ত',
    this.imageUrl = 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800&auto=format&fit=crop&q=80',
  });

  double get currentBiomassKg => (stockingQuantity * (survivalRatePercent / 100.0) * currentAvgWeightGrams) / 1000.0;
  double get projectedRevenue => currentBiomassKg * expectedMarketRatePerKg;
  double get projectedProfit => projectedRevenue - totalInvestedCost;
  int get daysSinceStocked => DateTime.now().difference(plantedDate).inDays;
  int get daysRemainingForHarvest {
    final diff = expectedHarvestDate.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }
  double get cycleProgress {
    final totalDays = expectedHarvestDate.difference(plantedDate).inDays;
    if (totalDays <= 0) return 1.0;
    return (daysSinceStocked / totalDays).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'farmId': farmId,
      'farmName': farmName,
      'cropName': cropName,
      'batchCode': batchCode,
      'plantedDate': Timestamp.fromDate(plantedDate),
      'expectedHarvestDate': Timestamp.fromDate(expectedHarvestDate),
      'area': area,
      'areaUnit': areaUnit,
      'soilPreparation': soilPreparation,
      'fertilizersUsed': fertilizersUsed,
      'pesticidesUsed': pesticidesUsed,
      'expectedYield': expectedYield,
      'status': status,
      'isAquaculture': isAquaculture,
      'stockingQuantity': stockingQuantity,
      'initialAvgWeightGrams': initialAvgWeightGrams,
      'currentAvgWeightGrams': currentAvgWeightGrams,
      'targetHarvestWeightGrams': targetHarvestWeightGrams,
      'fcr': fcr,
      'survivalRatePercent': survivalRatePercent,
      'growthStage': growthStage,
      'dailyFeedingKg': dailyFeedingKg,
      'feedBrand': feedBrand,
      'expectedMarketRatePerKg': expectedMarketRatePerKg,
      'totalInvestedCost': totalInvestedCost,
      'healthRating': healthRating,
      'imageUrl': imageUrl,
    };
  }

  factory CropPlanting.fromMap(Map<String, dynamic> map, String documentId) {
    return CropPlanting(
      id: documentId,
      userId: map['userId']?.toString() ?? '',
      farmId: map['farmId']?.toString() ?? '',
      farmName: map['farmName']?.toString() ?? '',
      cropName: map['cropName']?.toString() ?? 'রুই ও কাতলা মাছ',
      batchCode: map['batchCode']?.toString() ?? 'BATCH-F01',
      plantedDate: _parseFarmDate(map['plantedDate']),
      expectedHarvestDate: _parseFarmDate(map['expectedHarvestDate']),
      area: _parseFarmDouble(map['area'], 1.0),
      areaUnit: map['areaUnit']?.toString() ?? 'একর',
      soilPreparation: map['soilPreparation']?.toString() ?? 'পুকুর শুকিয়ে চুন ও পানি ট্রিটমেন্ট',
      fertilizersUsed: List<String>.from(map['fertilizersUsed'] ?? []),
      pesticidesUsed: List<String>.from(map['pesticidesUsed'] ?? []),
      expectedYield: _parseFarmDouble(map['expectedYield'], 10000.0),
      status: map['status']?.toString() ?? 'growing',
      isAquaculture: map['isAquaculture'] ?? true,
      stockingQuantity: _parseFarmInt(map['stockingQuantity'], 8000),
      initialAvgWeightGrams: _parseFarmDouble(map['initialAvgWeightGrams'], 50.0),
      currentAvgWeightGrams: _parseFarmDouble(map['currentAvgWeightGrams'], 1450.0),
      targetHarvestWeightGrams: _parseFarmDouble(map['targetHarvestWeightGrams'], 1800.0),
      fcr: _parseFarmDouble(map['fcr'], 1.28),
      survivalRatePercent: _parseFarmDouble(map['survivalRatePercent'], 94.5),
      growthStage: map['growthStage']?.toString() ?? 'বাড়ন্ত পর্যায়',
      dailyFeedingKg: _parseFarmDouble(map['dailyFeedingKg'], 85.0),
      feedBrand: map['feedBrand']?.toString() ?? 'মেগা ফিড ফ্লোটিং প্রোটিন ২৮%',
      expectedMarketRatePerKg: _parseFarmDouble(map['expectedMarketRatePerKg'], 380.0),
      totalInvestedCost: _parseFarmDouble(map['totalInvestedCost'], 450000.0),
      healthRating: map['healthRating']?.toString() ?? '১০০% সুস্থ ও প্রাণবন্ত',
      imageUrl: map['imageUrl']?.toString() ?? 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800&auto=format&fit=crop&q=80',
    );
  }
}

// ----------------------------------------------------------------------------
// 3. REAL-TIME WATER QUALITY TELEMETRY & SENSOR LOG
// ----------------------------------------------------------------------------

class WaterQualityLog {
  final String id;
  final String farmId;
  final String pondId;
  final DateTime timestamp;
  final double dissolvedOxygen; // mg/L
  final double ph;
  final double temperature; // °C
  final double salinity; // ppt
  final double ammonia; // mg/L
  final double nitrite; // mg/L
  final double turbidity; // cm
  final String status; // 'Optimal', 'Warning', 'Critical'
  final String notes;
  final bool aeratorTriggered;

  WaterQualityLog({
    required this.id,
    required this.farmId,
    required this.pondId,
    required this.timestamp,
    required this.dissolvedOxygen,
    required this.ph,
    required this.temperature,
    required this.salinity,
    required this.ammonia,
    required this.nitrite,
    required this.turbidity,
    this.status = 'Optimal',
    this.notes = '',
    this.aeratorTriggered = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'farmId': farmId,
      'pondId': pondId,
      'timestamp': Timestamp.fromDate(timestamp),
      'dissolvedOxygen': dissolvedOxygen,
      'ph': ph,
      'temperature': temperature,
      'salinity': salinity,
      'ammonia': ammonia,
      'nitrite': nitrite,
      'turbidity': turbidity,
      'status': status,
      'notes': notes,
      'aeratorTriggered': aeratorTriggered,
    };
  }

  factory WaterQualityLog.fromMap(Map<String, dynamic> map, String documentId) {
    return WaterQualityLog(
      id: documentId,
      farmId: map['farmId']?.toString() ?? '',
      pondId: map['pondId']?.toString() ?? '',
      timestamp: _parseFarmDate(map['timestamp']),
      dissolvedOxygen: _parseFarmDouble(map['dissolvedOxygen'], 6.5),
      ph: _parseFarmDouble(map['ph'], 7.4),
      temperature: _parseFarmDouble(map['temperature'], 28.0),
      salinity: _parseFarmDouble(map['salinity'], 1.0),
      ammonia: _parseFarmDouble(map['ammonia'], 0.01),
      nitrite: _parseFarmDouble(map['nitrite'], 0.005),
      turbidity: _parseFarmDouble(map['turbidity'], 30.0),
      status: map['status']?.toString() ?? 'Optimal',
      notes: map['notes']?.toString() ?? '',
      aeratorTriggered: map['aeratorTriggered'] == true,
    );
  }
}

// ----------------------------------------------------------------------------
// 4. DAILY FEED LEDGER & SCHEDULE
// ----------------------------------------------------------------------------

class FeedLedgerEntry {
  final String id;
  final String farmId;
  final String batchId;
  final DateTime date;
  final String timeSlot; // 'ভোর ৬:৩০ AM', 'দুপুর ১২:০০ PM', 'সন্ধ্যা ৫:৩০ PM'
  final String feedBrand;
  final double proteinPercent;
  final double quantityKg;
  final double costPerKg;
  final double totalCost;
  final double appetiteResponsePercent;
  final String feederType; // 'অটোমেটিক স্মার্ট ফিডার', 'ম্যানুয়াল ছিটানো'
  final String notes;

  FeedLedgerEntry({
    required this.id,
    required this.farmId,
    required this.batchId,
    required this.date,
    required this.timeSlot,
    required this.feedBrand,
    required this.proteinPercent,
    required this.quantityKg,
    required this.costPerKg,
    required this.totalCost,
    this.appetiteResponsePercent = 95.0,
    this.feederType = 'অটোমেটিক স্মার্ট ফিডার',
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'farmId': farmId,
      'batchId': batchId,
      'date': Timestamp.fromDate(date),
      'timeSlot': timeSlot,
      'feedBrand': feedBrand,
      'proteinPercent': proteinPercent,
      'quantityKg': quantityKg,
      'costPerKg': costPerKg,
      'totalCost': totalCost,
      'appetiteResponsePercent': appetiteResponsePercent,
      'feederType': feederType,
      'notes': notes,
    };
  }

  factory FeedLedgerEntry.fromMap(Map<String, dynamic> map, String documentId) {
    return FeedLedgerEntry(
      id: documentId,
      farmId: map['farmId']?.toString() ?? '',
      batchId: map['batchId']?.toString() ?? '',
      date: _parseFarmDate(map['date']),
      timeSlot: map['timeSlot']?.toString() ?? 'সকাল ৭:০০ AM',
      feedBrand: map['feedBrand']?.toString() ?? 'মেগা ফিড ফ্লোটিং',
      proteinPercent: _parseFarmDouble(map['proteinPercent'], 28.0),
      quantityKg: _parseFarmDouble(map['quantityKg'], 40.0),
      costPerKg: _parseFarmDouble(map['costPerKg'], 75.0),
      totalCost: _parseFarmDouble(map['totalCost'], 3000.0),
      appetiteResponsePercent: _parseFarmDouble(map['appetiteResponsePercent'], 95.0),
      feederType: map['feederType']?.toString() ?? 'অটোমেটিক স্মার্ট ফিডার',
      notes: map['notes']?.toString() ?? '',
    );
  }
}

// ----------------------------------------------------------------------------
// 5. FARM ACTIVITY & BIO-SECURITY LOG
// ----------------------------------------------------------------------------

class FarmActivity {
  final String id;
  final String userId;
  final String farmId;
  final String title;
  final String description;
  final DateTime date;
  final String type; // 'feeding', 'water_treatment', 'aeration', 'sampling', 'disease_check', 'fertilizing', 'harvesting'
  final double cost;
  final String notes;
  final String performedBy;
  final bool isCompleted;
  final String imageUrl;

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
    this.performedBy = 'ফার্ম ম্যানেজার',
    this.isCompleted = true,
    this.imageUrl = '',
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
      'performedBy': performedBy,
      'isCompleted': isCompleted,
      'imageUrl': imageUrl,
    };
  }

  factory FarmActivity.fromMap(Map<String, dynamic> map, String documentId) {
    return FarmActivity(
      id: documentId,
      userId: map['userId']?.toString() ?? '',
      farmId: map['farmId']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      date: _parseFarmDate(map['date']),
      type: map['type']?.toString() ?? 'watering',
      cost: _parseFarmDouble(map['cost'], 0.0),
      notes: map['notes']?.toString() ?? '',
      performedBy: map['performedBy']?.toString() ?? 'ফার্ম ম্যানেজার',
      isCompleted: map['isCompleted'] ?? true,
      imageUrl: map['imageUrl']?.toString() ?? '',
    );
  }
}

// ----------------------------------------------------------------------------
// 6. FARM EXPENSE MODEL (FINANCIAL ACCOUNTING)
// ----------------------------------------------------------------------------

class FarmExpense {
  final String id;
  final String userId;
  final String farmId;
  final String category; // 'খাদ্য ও ফিড', 'পোনা ও রেণু', 'বিদ্যুৎ ও জ্বালানি', 'শ্রমিক ও মজুরি', 'ওষুধ ও প্রোবায়োটিক', 'যন্ত্রাংশ ও রক্ষণাবেক্ষণ'
  final double amount;
  final DateTime date;
  final String description;
  final String vendorName;
  final String voucherNo;
  final String paymentMethod; // 'বিকাশ / নগদ', 'ব্যাংক ট্রান্সফার', 'ক্যাশ'
  final bool isVerified;

  FarmExpense({
    required this.id,
    required this.userId,
    required this.farmId,
    required this.category,
    required this.amount,
    required this.date,
    required this.description,
    this.vendorName = '',
    this.voucherNo = '',
    this.paymentMethod = 'ক্যাশ',
    this.isVerified = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'farmId': farmId,
      'category': category,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'description': description,
      'vendorName': vendorName,
      'voucherNo': voucherNo,
      'paymentMethod': paymentMethod,
      'isVerified': isVerified,
    };
  }

  factory FarmExpense.fromMap(Map<String, dynamic> map, String documentId) {
    return FarmExpense(
      id: documentId,
      userId: map['userId']?.toString() ?? '',
      farmId: map['farmId']?.toString() ?? '',
      category: map['category']?.toString() ?? 'খাদ্য ও ফিড',
      amount: _parseFarmDouble(map['amount']),
      date: _parseFarmDate(map['date']),
      description: map['description']?.toString() ?? '',
      vendorName: map['vendorName']?.toString() ?? '',
      voucherNo: map['voucherNo']?.toString() ?? '',
      paymentMethod: map['paymentMethod']?.toString() ?? 'ক্যাশ',
      isVerified: map['isVerified'] ?? true,
    );
  }
}

// ----------------------------------------------------------------------------
// 7. FARM REVENUE & SALES MODEL
// ----------------------------------------------------------------------------

class FarmRevenue {
  final String id;
  final String userId;
  final String farmId;
  final String cropName; // মাছের প্রজাতি বা ফসলের নাম
  final double amount; // মোট বিক্রয় মূল্য
  final double quantity; // বিক্রয়কৃত পরিমাণ
  final String unit; // 'কেজি', 'মণ', 'টন', 'হাজার পিস'
  final double ratePerUnit; // প্রতি কেজির দর
  final DateTime date;
  final String buyerName; // আড়তদার বা ক্রেতার নাম
  final String salesChannel; // 'বিগ ফিশ মার্কেটপ্লেস', 'লাইভ নিলাম', 'আড়ত লট', 'খুচরা সেল'
  final String invoiceNo;
  final String paymentStatus; // 'পরিশোধিত', 'বকেয়া', 'অগ্রিম বায়না'

  FarmRevenue({
    required this.id,
    required this.userId,
    required this.farmId,
    required this.cropName,
    required this.amount,
    required this.quantity,
    required this.unit,
    this.ratePerUnit = 0.0,
    required this.date,
    required this.buyerName,
    this.salesChannel = 'বিগ ফিশ মার্কেটপ্লেস',
    this.invoiceNo = '',
    this.paymentStatus = 'পরিশোধিত',
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'farmId': farmId,
      'cropName': cropName,
      'amount': amount,
      'quantity': quantity,
      'unit': unit,
      'ratePerUnit': ratePerUnit > 0 ? ratePerUnit : (quantity > 0 ? amount / quantity : 0.0),
      'date': Timestamp.fromDate(date),
      'buyerName': buyerName,
      'salesChannel': salesChannel,
      'invoiceNo': invoiceNo,
      'paymentStatus': paymentStatus,
    };
  }

  factory FarmRevenue.fromMap(Map<String, dynamic> map, String documentId) {
    final qty = _parseFarmDouble(map['quantity'], 1.0);
    final amt = _parseFarmDouble(map['amount'], 0.0);
    final rate = _parseFarmDouble(map['ratePerUnit'], qty > 0 ? amt / qty : 0.0);

    return FarmRevenue(
      id: documentId,
      userId: map['userId']?.toString() ?? '',
      farmId: map['farmId']?.toString() ?? '',
      cropName: map['cropName']?.toString() ?? 'রুই ও কাতলা মাছ',
      amount: amt,
      quantity: qty,
      unit: map['unit']?.toString() ?? 'কেজি',
      ratePerUnit: rate,
      date: _parseFarmDate(map['date']),
      buyerName: map['buyerName']?.toString() ?? 'চাঁদপুর মোহনা আড়ত',
      salesChannel: map['salesChannel']?.toString() ?? 'বিগ ফিশ মার্কেটপ্লেস',
      invoiceNo: map['invoiceNo']?.toString() ?? '',
      paymentStatus: map['paymentStatus']?.toString() ?? 'পরিশোধিত',
    );
  }
}

// ----------------------------------------------------------------------------
// 8. FARM INVENTORY & WAREHOUSE ITEM
// ----------------------------------------------------------------------------

class FarmInventoryItem {
  final String id;
  final String userId;
  final String name; // e.g. 'মেগা ফ্লোটিং ফিড ২৮%', 'বায়ো-প্রোবায়োটিক ইকো'
  final String category; // 'মাছের খাদ্য ও ফিড', 'ওষুধ ও প্রোবায়োটিক', 'চুন ও জিওলাইট', 'অক্সিজেন ট্যাবলেট', 'সার ও পুষ্টি উপাদান', 'যন্ত্রাংশ ও জাল'
  final double quantity;
  final String unit; // 'বস্তা (৫০ কেজি)', 'কেজি', 'লিটার', 'প্যাকেট'
  final double valuePerUnit;
  final double minThreshold; // Reorder alert threshold
  final String supplier;
  final DateTime? expiryDate;
  final String storageLocation;

  FarmInventoryItem({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.valuePerUnit,
    this.minThreshold = 5.0,
    this.supplier = '',
    this.expiryDate,
    this.storageLocation = 'প্রধান গোডাউন',
  });

  bool get isLowStock => quantity <= minThreshold;
  double get totalStockValue => quantity * valuePerUnit;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'valuePerUnit': valuePerUnit,
      'minThreshold': minThreshold,
      'supplier': supplier,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'storageLocation': storageLocation,
    };
  }

  factory FarmInventoryItem.fromMap(Map<String, dynamic> map, String documentId) {
    return FarmInventoryItem(
      id: documentId,
      userId: map['userId']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      category: map['category']?.toString() ?? 'মাছের খাদ্য ও ফিড',
      quantity: _parseFarmDouble(map['quantity']),
      unit: map['unit']?.toString() ?? 'বস্তা',
      valuePerUnit: _parseFarmDouble(map['valuePerUnit']),
      minThreshold: _parseFarmDouble(map['minThreshold'], 5.0),
      supplier: map['supplier']?.toString() ?? '',
      expiryDate: map['expiryDate'] != null ? _parseFarmDate(map['expiryDate']) : null,
      storageLocation: map['storageLocation']?.toString() ?? 'প্রধান গোডাউন',
    );
  }
}

// ----------------------------------------------------------------------------
// 9. HARVEST YIELD TRACKING LOG
// ----------------------------------------------------------------------------

class HarvestTrackingLog {
  final String id;
  final String farmId;
  final String batchId;
  final DateTime harvestDate;
  final String fishSpecies;
  final double totalHarvestWeightKg;
  final double avgPieceWeightGrams;
  final String grade; // 'গ্রেড-১ (এক্সপোর্ট)', 'গ্রেড-২ (প্রিমিয়াম)'
  final String harvestType; // 'সম্পূর্ণ হারভেস্ট', 'আংশিক তোলা'
  final double marketPricePerKg;
  final double totalRevenue;
  final String wholesalerName;
  final String transportVehicle;

  HarvestTrackingLog({
    required this.id,
    required this.farmId,
    required this.batchId,
    required this.harvestDate,
    required this.fishSpecies,
    required this.totalHarvestWeightKg,
    required this.avgPieceWeightGrams,
    this.grade = 'গ্রেড-১ (এক্সপোর্ট)',
    this.harvestType = 'আংশিক তোলা',
    required this.marketPricePerKg,
    required this.totalRevenue,
    this.wholesalerName = 'চাঁদপুর মেগা ফিশারি ঘাট',
    this.transportVehicle = 'লাইভ অক্সিজেন ভ্যান (ঢাকা-মেট্রো-ন-১১৪২)',
  });

  Map<String, dynamic> toMap() {
    return {
      'farmId': farmId,
      'batchId': batchId,
      'harvestDate': Timestamp.fromDate(harvestDate),
      'fishSpecies': fishSpecies,
      'totalHarvestWeightKg': totalHarvestWeightKg,
      'avgPieceWeightGrams': avgPieceWeightGrams,
      'grade': grade,
      'harvestType': harvestType,
      'marketPricePerKg': marketPricePerKg,
      'totalRevenue': totalRevenue,
      'wholesalerName': wholesalerName,
      'transportVehicle': transportVehicle,
    };
  }

  factory HarvestTrackingLog.fromMap(Map<String, dynamic> map, String documentId) {
    return HarvestTrackingLog(
      id: documentId,
      farmId: map['farmId']?.toString() ?? '',
      batchId: map['batchId']?.toString() ?? '',
      harvestDate: _parseFarmDate(map['harvestDate']),
      fishSpecies: map['fishSpecies']?.toString() ?? 'রুই ও কাতলা',
      totalHarvestWeightKg: _parseFarmDouble(map['totalHarvestWeightKg'], 1500.0),
      avgPieceWeightGrams: _parseFarmDouble(map['avgPieceWeightGrams'], 1600.0),
      grade: map['grade']?.toString() ?? 'গ্রেড-১ (এক্সপোর্ট)',
      harvestType: map['harvestType']?.toString() ?? 'আংশিক তোলা',
      marketPricePerKg: _parseFarmDouble(map['marketPricePerKg'], 380.0),
      totalRevenue: _parseFarmDouble(map['totalRevenue'], 570000.0),
      wholesalerName: map['wholesalerName']?.toString() ?? 'চাঁদপুর মেগা ফিশারি ঘাট',
      transportVehicle: map['transportVehicle']?.toString() ?? 'লাইভ অক্সিজেন ভ্যান',
    );
  }
}
