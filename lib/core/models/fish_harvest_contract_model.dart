enum FishContractStatus {
  openForBidding,   // খামারি অফার দিয়েছেন, ক্রেতা খুঁজছেন
  depositPaid,      // ক্রেতা অগ্রিম ২০-৩০% এসক্রোতে জমা দিয়েছেন
  inGrowth,         // মাছ বৃদ্ধির পর্যায়ে রয়েছে
  harvestReady,     // হারভেস্ট প্রস্তুত
  harvestCompleted, // মাছ ধরা ও ওজন সম্পন্ন
  delivered,        // ডেলিভারি সম্পন্ন ও ফুল পেমেন্ট রিলিজ
  cancelled
}

class FishHarvestContractModel {
  final String id;
  final String farmerId;
  final String farmerName;
  final String farmerPhone;
  final String pondId;
  final String pondName;
  final String location;
  final String district;
  
  final String fishSpecies;
  final double estimatedYieldKg;   // প্রত্যাশিত ফলন (কেজি)
  final double targetAvgWeightGram; // টার্গেট গড় ওজন (যেমন ১.৫ কেজি)
  final DateTime expectedHarvestDate; // সম্ভাব্য মাছ ধরার তারিখ
  
  final double agreedPricePerKg;    // চুক্তিবদ্ধ দর প্রতি কেজি (৳)
  final double advancePercentage;   // অগ্রিম শতাংশ (e.g. 25%)
  
  String? buyerId;
  String? buyerName;
  String? buyerPhone;
  String? buyerOrganization;
  
  double advancePaidAmount;         // অগ্রিম পরিশোধিত অর্থ (৳)
  double finalSettledAmount;        // চূড়ান্ত মোট বিল (৳)
  
  FishContractStatus status;
  final String waterQualityReport;
  final String feedingProtocol;     // e.g. "মেগা ভাসমান ফিড ও প্রাকৃতিক প্লাঙ্কটন"
  final DateTime createdAt;

  FishHarvestContractModel({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.farmerPhone,
    required this.pondId,
    required this.pondName,
    required this.location,
    required this.district,
    required this.fishSpecies,
    required this.estimatedYieldKg,
    required this.targetAvgWeightGram,
    required this.expectedHarvestDate,
    required this.agreedPricePerKg,
    this.advancePercentage = 25.0,
    this.buyerId,
    this.buyerName,
    this.buyerPhone,
    this.buyerOrganization,
    this.advancePaidAmount = 0.0,
    this.finalSettledAmount = 0.0,
    this.status = FishContractStatus.openForBidding,
    this.waterQualityReport = 'pH 7.4, অ্যামোনিয়া ০.০, অক্সিজেন ৬.৫ ppm',
    this.feedingProtocol = 'উন্নত ভাসমান ফিড',
    required this.createdAt,
  });

  double get estimatedTotalValue => estimatedYieldKg * agreedPricePerKg;
  double get requiredAdvanceAmount => (estimatedTotalValue * advancePercentage) / 100.0;
  int get daysUntilHarvest => expectedHarvestDate.difference(DateTime.now()).inDays;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'farmerPhone': farmerPhone,
      'pondId': pondId,
      'pondName': pondName,
      'location': location,
      'district': district,
      'fishSpecies': fishSpecies,
      'estimatedYieldKg': estimatedYieldKg,
      'targetAvgWeightGram': targetAvgWeightGram,
      'expectedHarvestDate': expectedHarvestDate.toIso8601String(),
      'agreedPricePerKg': agreedPricePerKg,
      'advancePercentage': advancePercentage,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'buyerPhone': buyerPhone,
      'buyerOrganization': buyerOrganization,
      'advancePaidAmount': advancePaidAmount,
      'finalSettledAmount': finalSettledAmount,
      'status': status.name,
      'waterQualityReport': waterQualityReport,
      'feedingProtocol': feedingProtocol,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FishHarvestContractModel.fromJson(Map<String, dynamic> json) {
    return FishHarvestContractModel(
      id: json['id'] ?? '',
      farmerId: json['farmerId'] ?? '',
      farmerName: json['farmerName'] ?? '',
      farmerPhone: json['farmerPhone'] ?? '',
      pondId: json['pondId'] ?? '',
      pondName: json['pondName'] ?? '',
      location: json['location'] ?? '',
      district: json['district'] ?? '',
      fishSpecies: json['fishSpecies'] ?? '',
      estimatedYieldKg: (json['estimatedYieldKg'] as num?)?.toDouble() ?? 0.0,
      targetAvgWeightGram: (json['targetAvgWeightGram'] as num?)?.toDouble() ?? 0.0,
      expectedHarvestDate: json['expectedHarvestDate'] != null
          ? DateTime.parse(json['expectedHarvestDate'])
          : DateTime.now().add(const Duration(days: 30)),
      agreedPricePerKg: (json['agreedPricePerKg'] as num?)?.toDouble() ?? 0.0,
      advancePercentage: (json['advancePercentage'] as num?)?.toDouble() ?? 25.0,
      buyerId: json['buyerId'],
      buyerName: json['buyerName'],
      buyerPhone: json['buyerPhone'],
      buyerOrganization: json['buyerOrganization'],
      advancePaidAmount: (json['advancePaidAmount'] as num?)?.toDouble() ?? 0.0,
      finalSettledAmount: (json['finalSettledAmount'] as num?)?.toDouble() ?? 0.0,
      status: FishContractStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FishContractStatus.openForBidding,
      ),
      waterQualityReport: json['waterQualityReport'] ?? '',
      feedingProtocol: json['feedingProtocol'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
