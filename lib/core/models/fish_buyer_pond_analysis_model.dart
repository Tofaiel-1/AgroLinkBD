class FishBuyerPondAnalysisModel {
  final String id;
  final String buyerId;
  final String buyerName;
  final String pondId;
  final String pondName;
  final String farmerName;
  final String location;
  final String district;
  final String fishSpecies;
  
  // Pond & Biomass Bio-Metrics
  final double pondSizeDecimal; // আয়তন (শতক)
  final int totalEstimatedCount; // মোট মাছ সংখ্যা
  final double avgWeightGram; // গড় ওজন (গ্রাম)
  final double estimatedTotalYieldKg; // মোট আনুমানিক উৎপাদন (কেজি)
  final double uniformityPercentage; // সাইজের সমসত্ত্বতা (যেমন: ৮৮%)
  final String grade; // "Grade A+ (তাজা জ্যান্ত)"
  
  // Water Quality & Safety Metrics
  final double dissolvedOxygen; // দ্রবীভূত অক্সিজেন (mg/L)
  final double phLevel; // pH মান
  final double ammoniaPpm; // অ্যামোনিয়া (ppm)
  final double salinityPpt; // লবণাক্ততা (ppt)
  final double waterDepthFeet; // পানির গভীরতা (ফুট)
  final bool isFormalinFree; // ফরমালিন মুক্ত সার্টিফাইড
  final bool isOrganicFeed; // প্রাকৃতিক/সার্টিফাইড ফিড
  final int safetyScore; // নিরাপত্তা স্কোর (১-১০০)
  
  // Commercial Wholesale Financials
  final double farmerAskingPricePerKg; // খামারের মূল্য (৳/কেজি)
  final double targetMarketSalePricePerKg; // আড়ত/বাজার বিক্রয় দর (৳/কেজি)
  final double transportPackagingCostPerKg; // পরিবহন ও প্যাকেজিং খরচ (৳/কেজি)
  final double shrinkagePercentage; // পরিবহন ড্রপ/ঘাটতি (যেমন: ২.৫%)
  final double netLandingCostPerKg; // নিট ল্যান্ডিং খরচ (৳/কেজি)
  final double projectedNetProfit; // মোট সম্ভাব্য নিট লাভ (৳)
  final double projectedRoiPercentage; // আনুমানিক মুনাফার হার (%)
  
  // Inspection & Sampling
  final bool sampleRequested;
  final String sampleStatus; // 'none', 'pending', 'confirmed', 'completed'
  final String? inspectorNotes;
  final DateTime createdAt;

  FishBuyerPondAnalysisModel({
    required this.id,
    required this.buyerId,
    required this.buyerName,
    required this.pondId,
    required this.pondName,
    required this.farmerName,
    required this.location,
    required this.district,
    required this.fishSpecies,
    required this.pondSizeDecimal,
    required this.totalEstimatedCount,
    required this.avgWeightGram,
    required this.estimatedTotalYieldKg,
    this.uniformityPercentage = 90.0,
    this.grade = 'Grade A+',
    this.dissolvedOxygen = 6.8,
    this.phLevel = 7.6,
    this.ammoniaPpm = 0.02,
    this.salinityPpt = 0.0,
    this.waterDepthFeet = 5.5,
    this.isFormalinFree = true,
    this.isOrganicFeed = true,
    this.safetyScore = 95,
    required this.farmerAskingPricePerKg,
    required this.targetMarketSalePricePerKg,
    this.transportPackagingCostPerKg = 15.0,
    this.shrinkagePercentage = 2.0,
    required this.netLandingCostPerKg,
    required this.projectedNetProfit,
    required this.projectedRoiPercentage,
    this.sampleRequested = false,
    this.sampleStatus = 'none',
    this.inspectorNotes,
    required this.createdAt,
  });

  double get estimatedTotalMaunds => estimatedTotalYieldKg / 40.0;
  double get estimatedTotalTons => estimatedTotalYieldKg / 1000.0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'pondId': pondId,
      'pondName': pondName,
      'farmerName': farmerName,
      'location': location,
      'district': district,
      'fishSpecies': fishSpecies,
      'pondSizeDecimal': pondSizeDecimal,
      'totalEstimatedCount': totalEstimatedCount,
      'avgWeightGram': avgWeightGram,
      'estimatedTotalYieldKg': estimatedTotalYieldKg,
      'uniformityPercentage': uniformityPercentage,
      'grade': grade,
      'dissolvedOxygen': dissolvedOxygen,
      'phLevel': phLevel,
      'ammoniaPpm': ammoniaPpm,
      'salinityPpt': salinityPpt,
      'waterDepthFeet': waterDepthFeet,
      'isFormalinFree': isFormalinFree,
      'isOrganicFeed': isOrganicFeed,
      'safetyScore': safetyScore,
      'farmerAskingPricePerKg': farmerAskingPricePerKg,
      'targetMarketSalePricePerKg': targetMarketSalePricePerKg,
      'transportPackagingCostPerKg': transportPackagingCostPerKg,
      'shrinkagePercentage': shrinkagePercentage,
      'netLandingCostPerKg': netLandingCostPerKg,
      'projectedNetProfit': projectedNetProfit,
      'projectedRoiPercentage': projectedRoiPercentage,
      'sampleRequested': sampleRequested,
      'sampleStatus': sampleStatus,
      'inspectorNotes': inspectorNotes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FishBuyerPondAnalysisModel.fromJson(Map<String, dynamic> json) {
    return FishBuyerPondAnalysisModel(
      id: json['id'] ?? '',
      buyerId: json['buyerId'] ?? '',
      buyerName: json['buyerName'] ?? '',
      pondId: json['pondId'] ?? '',
      pondName: json['pondName'] ?? '',
      farmerName: json['farmerName'] ?? '',
      location: json['location'] ?? '',
      district: json['district'] ?? '',
      fishSpecies: json['fishSpecies'] ?? '',
      pondSizeDecimal: (json['pondSizeDecimal'] as num?)?.toDouble() ?? 50.0,
      totalEstimatedCount: json['totalEstimatedCount'] ?? 1000,
      avgWeightGram: (json['avgWeightGram'] as num?)?.toDouble() ?? 1200.0,
      estimatedTotalYieldKg: (json['estimatedTotalYieldKg'] as num?)?.toDouble() ?? 1200.0,
      uniformityPercentage: (json['uniformityPercentage'] as num?)?.toDouble() ?? 90.0,
      grade: json['grade'] ?? 'Grade A+',
      dissolvedOxygen: (json['dissolvedOxygen'] as num?)?.toDouble() ?? 6.8,
      phLevel: (json['phLevel'] as num?)?.toDouble() ?? 7.6,
      ammoniaPpm: (json['ammoniaPpm'] as num?)?.toDouble() ?? 0.02,
      salinityPpt: (json['salinityPpt'] as num?)?.toDouble() ?? 0.0,
      waterDepthFeet: (json['waterDepthFeet'] as num?)?.toDouble() ?? 5.5,
      isFormalinFree: json['isFormalinFree'] ?? true,
      isOrganicFeed: json['isOrganicFeed'] ?? true,
      safetyScore: json['safetyScore'] ?? 95,
      farmerAskingPricePerKg: (json['farmerAskingPricePerKg'] as num?)?.toDouble() ?? 280.0,
      targetMarketSalePricePerKg: (json['targetMarketSalePricePerKg'] as num?)?.toDouble() ?? 350.0,
      transportPackagingCostPerKg: (json['transportPackagingCostPerKg'] as num?)?.toDouble() ?? 15.0,
      shrinkagePercentage: (json['shrinkagePercentage'] as num?)?.toDouble() ?? 2.0,
      netLandingCostPerKg: (json['netLandingCostPerKg'] as num?)?.toDouble() ?? 301.0,
      projectedNetProfit: (json['projectedNetProfit'] as num?)?.toDouble() ?? 58800.0,
      projectedRoiPercentage: (json['projectedRoiPercentage'] as num?)?.toDouble() ?? 16.2,
      sampleRequested: json['sampleRequested'] ?? false,
      sampleStatus: json['sampleStatus'] ?? 'none',
      inspectorNotes: json['inspectorNotes'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}
