enum FishAuctionStatus {
  upcoming,
  live,
  ended,
  awarded,
  cancelled
}

enum FishCondition {
  liveInWater,      // জ্যান্ত মাছ (অক্সিজেন ট্যাংকে)
  icedFresh,        // বরফ দেওয়া তাজা মাছ
  frozen            // ফ্রোজেন মাছ
}

class FishBid {
  final String id;
  final String bidderId;
  final String bidderName;
  final String bidderPhone;
  final String? bidderOrganization; // e.g. "কাওরান বাজার মেসার্স রহিম মৎস্য আড়ত"
  final double bidAmountPerKg;
  final double totalBidAmount;
  final DateTime timestamp;
  final bool isWinning;

  FishBid({
    required this.id,
    required this.bidderId,
    required this.bidderName,
    required this.bidderPhone,
    this.bidderOrganization,
    required this.bidAmountPerKg,
    required this.totalBidAmount,
    required this.timestamp,
    this.isWinning = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bidderId': bidderId,
      'bidderName': bidderName,
      'bidderPhone': bidderPhone,
      'bidderOrganization': bidderOrganization,
      'bidAmountPerKg': bidAmountPerKg,
      'totalBidAmount': totalBidAmount,
      'timestamp': timestamp.toIso8601String(),
      'isWinning': isWinning,
    };
  }

  factory FishBid.fromJson(Map<String, dynamic> json) {
    return FishBid(
      id: json['id'] ?? '',
      bidderId: json['bidderId'] ?? '',
      bidderName: json['bidderName'] ?? '',
      bidderPhone: json['bidderPhone'] ?? '',
      bidderOrganization: json['bidderOrganization'],
      bidAmountPerKg: (json['bidAmountPerKg'] as num?)?.toDouble() ?? 0.0,
      totalBidAmount: (json['totalBidAmount'] as num?)?.toDouble() ?? 0.0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isWinning: json['isWinning'] ?? false,
    );
  }
}

class FishAuctionModel {
  final String id;
  final String farmerId;
  final String farmerName;
  final String farmerPhone;
  final String farmLocation;
  final String district;
  final String upazila;
  
  final String fishSpecies;       // e.g. "দেশি রুই", "পাঙ্গাশ", "কাতলা", "গলদা চিংড়ি"
  final String lotTitle;          // e.g. "পুকুর-১ এর ৫০০ কেজি জ্যান্ত রুই লট"
  final double estimatedTotalKg;  // e.g. 500.0
  final double avgWeightGram;     // e.g. 1500.0 (1.5 kg per fish)
  final FishCondition condition;   // liveInWater, icedFresh
  final String grade;             // "Grade A+", "Grade A", "Standard"
  final List<String> images;
  final String? videoUrl;
  
  final double startingPricePerKg; // প্রারম্ভিক দর প্রতি কেজি (৳)
  final double? reservePricePerKg;  // সর্বনিম্ন প্রত্যাশিত গোপন দর (৳)
  final double minBidIncrement;    // ন্যূনতম বৃদ্ধি (যেমন: ৳৫/কেজি)
  
  double? currentHighestBidPerKg;
  String? highestBidderId;
  String? highestBidderName;
  
  final DateTime startTime;
  final DateTime endTime;
  FishAuctionStatus status;
  final List<FishBid> bids;
  
  final bool providesOxygenTransport;
  final String description;
  final DateTime createdAt;

  FishAuctionModel({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.farmerPhone,
    required this.farmLocation,
    required this.district,
    required this.upazila,
    required this.fishSpecies,
    required this.lotTitle,
    required this.estimatedTotalKg,
    required this.avgWeightGram,
    required this.condition,
    this.grade = 'Grade A',
    required this.images,
    this.videoUrl,
    required this.startingPricePerKg,
    this.reservePricePerKg,
    this.minBidIncrement = 5.0,
    this.currentHighestBidPerKg,
    this.highestBidderId,
    this.highestBidderName,
    required this.startTime,
    required this.endTime,
    this.status = FishAuctionStatus.live,
    this.bids = const [],
    this.providesOxygenTransport = true,
    this.description = '',
    required this.createdAt,
  });

  double get currentTotalEstimatedValue {
    final rate = currentHighestBidPerKg ?? startingPricePerKg;
    return rate * estimatedTotalKg;
  }

  bool get isLive {
    final now = DateTime.now();
    return status == FishAuctionStatus.live &&
        now.isAfter(startTime) &&
        now.isBefore(endTime);
  }

  Duration get remainingTime {
    final now = DateTime.now();
    if (now.isAfter(endTime)) return Duration.zero;
    return endTime.difference(now);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'farmerPhone': farmerPhone,
      'farmLocation': farmLocation,
      'district': district,
      'upazila': upazila,
      'fishSpecies': fishSpecies,
      'lotTitle': lotTitle,
      'estimatedTotalKg': estimatedTotalKg,
      'avgWeightGram': avgWeightGram,
      'condition': condition.name,
      'grade': grade,
      'images': images,
      'videoUrl': videoUrl,
      'startingPricePerKg': startingPricePerKg,
      'reservePricePerKg': reservePricePerKg,
      'minBidIncrement': minBidIncrement,
      'currentHighestBidPerKg': currentHighestBidPerKg,
      'highestBidderId': highestBidderId,
      'highestBidderName': highestBidderName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status.name,
      'bids': bids.map((b) => b.toJson()).toList(),
      'providesOxygenTransport': providesOxygenTransport,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FishAuctionModel.fromJson(Map<String, dynamic> json) {
    return FishAuctionModel(
      id: json['id'] ?? '',
      farmerId: json['farmerId'] ?? '',
      farmerName: json['farmerName'] ?? '',
      farmerPhone: json['farmerPhone'] ?? '',
      farmLocation: json['farmLocation'] ?? '',
      district: json['district'] ?? '',
      upazila: json['upazila'] ?? '',
      fishSpecies: json['fishSpecies'] ?? '',
      lotTitle: json['lotTitle'] ?? '',
      estimatedTotalKg: (json['estimatedTotalKg'] as num?)?.toDouble() ?? 0.0,
      avgWeightGram: (json['avgWeightGram'] as num?)?.toDouble() ?? 0.0,
      condition: FishCondition.values.firstWhere(
        (e) => e.name == json['condition'],
        orElse: () => FishCondition.liveInWater,
      ),
      grade: json['grade'] ?? 'Grade A',
      images: List<String>.from(json['images'] ?? []),
      videoUrl: json['videoUrl'],
      startingPricePerKg: (json['startingPricePerKg'] as num?)?.toDouble() ?? 0.0,
      reservePricePerKg: (json['reservePricePerKg'] as num?)?.toDouble(),
      minBidIncrement: (json['minBidIncrement'] as num?)?.toDouble() ?? 5.0,
      currentHighestBidPerKg: (json['currentHighestBidPerKg'] as num?)?.toDouble(),
      highestBidderId: json['highestBidderId'],
      highestBidderName: json['highestBidderName'],
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : DateTime.now(),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : DateTime.now().add(const Duration(hours: 24)),
      status: FishAuctionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FishAuctionStatus.live,
      ),
      bids: json['bids'] != null
          ? (json['bids'] as List).map((b) => FishBid.fromJson(b)).toList()
          : [],
      providesOxygenTransport: json['providesOxygenTransport'] ?? true,
      description: json['description'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}
