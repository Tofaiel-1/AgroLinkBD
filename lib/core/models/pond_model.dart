import 'package:cloud_firestore/cloud_firestore.dart';

DateTime _parsePondDate(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  return DateTime.now();
}

double _parsePondDouble(dynamic value, [double defaultValue = 0.0]) {
  if (value == null) return defaultValue;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? defaultValue;
  return defaultValue;
}

int _parsePondInt(dynamic value, [int defaultValue = 0]) {
  if (value == null) return defaultValue;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}

class PondActivityModel {
  final String id;
  final String title;
  final String description;
  final double amount;
  final DateTime date;
  final String type; // e.g., 'Feed', 'Medicine', 'Stock', 'Maintenance', 'Harvest', 'Sale'
  final bool isIncome;
  final String performedBy;
  final String invoiceOrReceiptUrl;

  PondActivityModel({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.date,
    required this.type,
    this.isIncome = false,
    this.performedBy = 'ফার্ম সুপারভাইজার',
    this.invoiceOrReceiptUrl = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'type': type,
      'isIncome': isIncome,
      'performedBy': performedBy,
      'invoiceOrReceiptUrl': invoiceOrReceiptUrl,
    };
  }

  factory PondActivityModel.fromMap(Map<String, dynamic> map) {
    return PondActivityModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      amount: _parsePondDouble(map['amount']),
      date: _parsePondDate(map['date']),
      type: map['type']?.toString() ?? 'Feed',
      isIncome: map['isIncome'] == true,
      performedBy: map['performedBy']?.toString() ?? 'ফার্ম সুপারভাইজার',
      invoiceOrReceiptUrl: map['invoiceOrReceiptUrl']?.toString() ?? '',
    );
  }
}

class PondModel {
  final String id;
  final String userId;
  final String name;
  final String area;
  final String fishSpecies;
  final DateTime stockedDate;
  final int totalFishCount;
  
  // Telemetry & Water Health IoT Sensors
  String status; // 'স্বাভাবিক' (Optimal), 'সতর্কতা' (Warning), 'ঝুঁকিপূর্ণ' (Critical), 'হারভেস্ট প্রস্তুত' (Ready)
  double ph; // e.g. 7.4
  double ammonia; // mg/L e.g. 0.015
  double dissolvedOxygen; // mg/L e.g. 6.8
  double temperature; // °C e.g. 28.5
  double salinity; // ppt e.g. 1.2
  double waterClarity; // cm e.g. 32.0
  double nitrite; // mg/L e.g. 0.005
  double alkalinity; // mg/L e.g. 120.0

  // Biomass & Lifecycle Growth
  double avgWeightGrams; // e.g. 1200
  double targetHarvestWeightGrams; // e.g. 1800
  String growthStage; // 'নার্সারি ও রেণু', 'বাড়ন্ত পর্যায়', 'প্রাক-হারভেস্ট', 'হারভেস্ট প্রস্তুত'
  int totalCycleDays; // e.g. 180
  double expectedMarketPricePerKg; // e.g. 380
  double fcr; // Feed Conversion Ratio e.g. 1.25
  double survivalRatePercent; // e.g. 94.0%
  double dailyFeedingKg; // e.g. 45.0 kg
  String feedBrand; // e.g. 'মেগা ফিড ফ্লোটিং প্রোটিন ২৮%'
  
  // Smart Farm Hardware & Automation
  bool aeratorOn;
  int aeratorCount;
  bool autoFeederActive;
  String farmCategory; // 'বাণিজ্যিক কার্প পুকুর', 'বায়োফ্লক ট্যাংক', 'চিংড়ি ঘের', 'আরএএস সিস্টেম', 'হ্যাচারি'
  String bioSecurityGrade; // 'Grade A+ (SPF Certified)'
  String waterSource;
  String imageUrl;
  List<String> galleryUrls;
  String location;
  String farmManagerName;
  String managerPhone;

  // Track activities and costs
  List<PondActivityModel> activities;

  PondModel({
    required this.id,
    this.userId = '',
    required this.name,
    required this.area,
    required this.fishSpecies,
    required this.stockedDate,
    required this.totalFishCount,
    this.status = 'স্বাভাবিক',
    this.ph = 7.2,
    this.ammonia = 0.015,
    this.dissolvedOxygen = 6.5,
    this.temperature = 28.0,
    this.salinity = 1.0,
    this.waterClarity = 30.0,
    this.nitrite = 0.005,
    this.alkalinity = 120.0,
    this.avgWeightGrams = 850,
    this.targetHarvestWeightGrams = 1500,
    this.growthStage = 'বাড়ন্ত পর্যায়',
    this.totalCycleDays = 180,
    this.expectedMarketPricePerKg = 350.0,
    this.fcr = 1.28,
    this.survivalRatePercent = 94.0,
    this.dailyFeedingKg = 45.0,
    this.feedBrand = 'মেগা ফিড ফ্লোটিং প্রোটিন ২৮%',
    this.aeratorOn = true,
    this.aeratorCount = 4,
    this.autoFeederActive = true,
    this.farmCategory = 'বাণিজ্যিক কার্প পুকুর',
    this.bioSecurityGrade = 'Grade A+ (শতভাগ রোগমুক্ত)',
    this.waterSource = 'নদীর মিষ্টি পানি ও গভীর নলকূপ',
    this.imageUrl = 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=900&auto=format&fit=crop&q=80',
    this.galleryUrls = const [],
    this.location = 'চাঁদপুর মৎস্য জোন',
    this.farmManagerName = 'মোঃ তোফায়েল আহমেদ',
    this.managerPhone = '01711223344',
    List<PondActivityModel>? activities,
  }) : activities = activities ?? [];

  double get totalCost {
    return activities.where((a) => a.isIncome != true).fold(0.0, (sum, activity) => sum + activity.amount);
  }

  double get totalIncome {
    return activities.where((a) => a.isIncome == true).fold(0.0, (sum, activity) => sum + activity.amount);
  }

  int get daysSinceStocked {
    return DateTime.now().difference(stockedDate).inDays;
  }

  int get daysRemainingForHarvest {
    int remaining = totalCycleDays - daysSinceStocked;
    return remaining < 0 ? 0 : remaining;
  }

  double get progressPercentage {
    if (totalCycleDays <= 0) return 1.0;
    double progress = daysSinceStocked / totalCycleDays;
    return progress.clamp(0.0, 1.0);
  }

  double get currentTotalBiomassKg {
    return (totalFishCount * (survivalRatePercent / 100.0) * avgWeightGrams) / 1000.0;
  }

  double get projectedValuation {
    return currentTotalBiomassKg * expectedMarketPricePerKg;
  }

  double get estimatedNetProfit {
    return projectedValuation + totalIncome - totalCost;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'area': area,
      'fishSpecies': fishSpecies,
      'stockedDate': Timestamp.fromDate(stockedDate),
      'totalFishCount': totalFishCount,
      'status': status,
      'ph': ph,
      'ammonia': ammonia,
      'dissolvedOxygen': dissolvedOxygen,
      'temperature': temperature,
      'salinity': salinity,
      'waterClarity': waterClarity,
      'nitrite': nitrite,
      'alkalinity': alkalinity,
      'avgWeightGrams': avgWeightGrams,
      'targetHarvestWeightGrams': targetHarvestWeightGrams,
      'growthStage': growthStage,
      'totalCycleDays': totalCycleDays,
      'expectedMarketPricePerKg': expectedMarketPricePerKg,
      'fcr': fcr,
      'survivalRatePercent': survivalRatePercent,
      'dailyFeedingKg': dailyFeedingKg,
      'feedBrand': feedBrand,
      'aeratorOn': aeratorOn,
      'aeratorCount': aeratorCount,
      'autoFeederActive': autoFeederActive,
      'farmCategory': farmCategory,
      'bioSecurityGrade': bioSecurityGrade,
      'waterSource': waterSource,
      'imageUrl': imageUrl,
      'galleryUrls': galleryUrls,
      'location': location,
      'farmManagerName': farmManagerName,
      'managerPhone': managerPhone,
      'activities': activities.map((a) => a.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory PondModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    final activitiesRaw = map['activities'] as List<dynamic>? ?? [];
    final parsedActivities = activitiesRaw
        .map((a) => PondActivityModel.fromMap(Map<String, dynamic>.from(a as Map)))
        .toList();

    return PondModel(
      id: docId ?? map['id']?.toString() ?? 'POND_${DateTime.now().millisecondsSinceEpoch}',
      userId: map['userId']?.toString() ?? '',
      name: map['name']?.toString() ?? 'বাণিজ্যিক পুকুর',
      area: map['area']?.toString() ?? '১.০ একর',
      fishSpecies: map['fishSpecies']?.toString() ?? 'রুই ও কাতলা',
      stockedDate: _parsePondDate(map['stockedDate']),
      totalFishCount: _parsePondInt(map['totalFishCount'], 5000),
      status: map['status']?.toString() ?? 'স্বাভাবিক',
      ph: _parsePondDouble(map['ph'], 7.2),
      ammonia: _parsePondDouble(map['ammonia'], 0.015),
      dissolvedOxygen: _parsePondDouble(map['dissolvedOxygen'], 6.5),
      temperature: _parsePondDouble(map['temperature'], 28.0),
      salinity: _parsePondDouble(map['salinity'], 1.0),
      waterClarity: _parsePondDouble(map['waterClarity'], 30.0),
      nitrite: _parsePondDouble(map['nitrite'], 0.005),
      alkalinity: _parsePondDouble(map['alkalinity'], 120.0),
      avgWeightGrams: _parsePondDouble(map['avgWeightGrams'], 850.0),
      targetHarvestWeightGrams: _parsePondDouble(map['targetHarvestWeightGrams'], 1500.0),
      growthStage: map['growthStage']?.toString() ?? 'বাড়ন্ত পর্যায়',
      totalCycleDays: _parsePondInt(map['totalCycleDays'], 180),
      expectedMarketPricePerKg: _parsePondDouble(map['expectedMarketPricePerKg'], 350.0),
      fcr: _parsePondDouble(map['fcr'], 1.28),
      survivalRatePercent: _parsePondDouble(map['survivalRatePercent'], 94.0),
      dailyFeedingKg: _parsePondDouble(map['dailyFeedingKg'], 45.0),
      feedBrand: map['feedBrand']?.toString() ?? 'মেগা ফিড ফ্লোটিং প্রোটিন ২৮%',
      aeratorOn: map['aeratorOn'] == true,
      aeratorCount: _parsePondInt(map['aeratorCount'], 4),
      autoFeederActive: map['autoFeederActive'] == true,
      farmCategory: map['farmCategory']?.toString() ?? 'বাণিজ্যিক কার্প পুকুর',
      bioSecurityGrade: map['bioSecurityGrade']?.toString() ?? 'Grade A+ (শতভাগ রোগমুক্ত)',
      waterSource: map['waterSource']?.toString() ?? 'নদীর মিষ্টি পানি ও গভীর নলকূপ',
      imageUrl: map['imageUrl']?.toString() ?? 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=900&auto=format&fit=crop&q=80',
      galleryUrls: List<String>.from(map['galleryUrls'] ?? []),
      location: map['location']?.toString() ?? 'চাঁদপুর মৎস্য জোন',
      farmManagerName: map['farmManagerName']?.toString() ?? '',
      managerPhone: map['managerPhone']?.toString() ?? '',
      activities: parsedActivities,
    );
  }
}
