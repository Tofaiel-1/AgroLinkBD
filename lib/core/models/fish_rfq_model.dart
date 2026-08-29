enum FishRfqStatus {
  open,
  bidsReceived,
  accepted,
  fulfilled,
  expired
}

class FishFarmerQuote {
  final String id;
  final String farmerId;
  final String farmerName;
  final String farmerPhone;
  final String farmLocation;
  final double offeredPricePerKg;
  final double availableQuantityKg;
  final double avgWeightGram;
  final bool isLiveInWater;
  final String message;
  final DateTime timestamp;
  final bool isAccepted;

  FishFarmerQuote({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.farmerPhone,
    required this.farmLocation,
    required this.offeredPricePerKg,
    required this.availableQuantityKg,
    required this.avgWeightGram,
    this.isLiveInWater = true,
    this.message = '',
    required this.timestamp,
    this.isAccepted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'farmerPhone': farmerPhone,
      'farmLocation': farmLocation,
      'offeredPricePerKg': offeredPricePerKg,
      'availableQuantityKg': availableQuantityKg,
      'avgWeightGram': avgWeightGram,
      'isLiveInWater': isLiveInWater,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isAccepted': isAccepted,
    };
  }

  factory FishFarmerQuote.fromJson(Map<String, dynamic> json) {
    return FishFarmerQuote(
      id: json['id'] ?? '',
      farmerId: json['farmerId'] ?? '',
      farmerName: json['farmerName'] ?? '',
      farmerPhone: json['farmerPhone'] ?? '',
      farmLocation: json['farmLocation'] ?? '',
      offeredPricePerKg: (json['offeredPricePerKg'] as num?)?.toDouble() ?? 0.0,
      availableQuantityKg: (json['availableQuantityKg'] as num?)?.toDouble() ?? 0.0,
      avgWeightGram: (json['avgWeightGram'] as num?)?.toDouble() ?? 0.0,
      isLiveInWater: json['isLiveInWater'] ?? true,
      message: json['message'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isAccepted: json['isAccepted'] ?? false,
    );
  }
}

class FishRfqModel {
  final String id;
  final String buyerId;
  final String buyerName;
  final String buyerPhone;
  final String buyerType; // e.g. "আড়তদার", "রেস্তোরাঁ চেইন", "সুপারশপ", "পাইকার"
  final String destinationAddress;
  final String destinationDistrict;
  
  final String fishSpecies;
  final double requiredQuantityKg;
  final double minAvgWeightGram;
  final bool requiresLiveFish; // জ্যান্ত মাছ আবশ্যক কিনা
  final double targetBudgetPerKg;
  final DateTime deliveryDeadline;
  
  FishRfqStatus status;
  final List<FishFarmerQuote> quotes;
  final String? acceptedQuoteId;
  final String notes;
  final DateTime createdAt;

  FishRfqModel({
    required this.id,
    required this.buyerId,
    required this.buyerName,
    required this.buyerPhone,
    required this.buyerType,
    required this.destinationAddress,
    required this.destinationDistrict,
    required this.fishSpecies,
    required this.requiredQuantityKg,
    required this.minAvgWeightGram,
    this.requiresLiveFish = true,
    required this.targetBudgetPerKg,
    required this.deliveryDeadline,
    this.status = FishRfqStatus.open,
    this.quotes = const [],
    this.acceptedQuoteId,
    this.notes = '',
    required this.createdAt,
  });

  double get estimatedTotalBudget => requiredQuantityKg * targetBudgetPerKg;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'buyerPhone': buyerPhone,
      'buyerType': buyerType,
      'destinationAddress': destinationAddress,
      'destinationDistrict': destinationDistrict,
      'fishSpecies': fishSpecies,
      'requiredQuantityKg': requiredQuantityKg,
      'minAvgWeightGram': minAvgWeightGram,
      'requiresLiveFish': requiresLiveFish,
      'targetBudgetPerKg': targetBudgetPerKg,
      'deliveryDeadline': deliveryDeadline.toIso8601String(),
      'status': status.name,
      'quotes': quotes.map((q) => q.toJson()).toList(),
      'acceptedQuoteId': acceptedQuoteId,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FishRfqModel.fromJson(Map<String, dynamic> json) {
    return FishRfqModel(
      id: json['id'] ?? '',
      buyerId: json['buyerId'] ?? '',
      buyerName: json['buyerName'] ?? '',
      buyerPhone: json['buyerPhone'] ?? '',
      buyerType: json['buyerType'] ?? 'পাইকার',
      destinationAddress: json['destinationAddress'] ?? '',
      destinationDistrict: json['destinationDistrict'] ?? '',
      fishSpecies: json['fishSpecies'] ?? '',
      requiredQuantityKg: (json['requiredQuantityKg'] as num?)?.toDouble() ?? 0.0,
      minAvgWeightGram: (json['minAvgWeightGram'] as num?)?.toDouble() ?? 0.0,
      requiresLiveFish: json['requiresLiveFish'] ?? true,
      targetBudgetPerKg: (json['targetBudgetPerKg'] as num?)?.toDouble() ?? 0.0,
      deliveryDeadline: json['deliveryDeadline'] != null
          ? DateTime.parse(json['deliveryDeadline'])
          : DateTime.now().add(const Duration(days: 2)),
      status: FishRfqStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FishRfqStatus.open,
      ),
      quotes: json['quotes'] != null
          ? (json['quotes'] as List).map((q) => FishFarmerQuote.fromJson(q)).toList()
          : [],
      acceptedQuoteId: json['acceptedQuoteId'],
      notes: json['notes'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
