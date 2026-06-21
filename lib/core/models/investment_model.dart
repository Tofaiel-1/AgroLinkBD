enum InvestmentStatus { active, funded, completed, cancelled }

class InvestmentModel {
  final String id;
  final String farmerId;
  final String farmerName;
  final String farmerPhone;
  final String title;
  final String description;
  final String cropType;
  final double landSize;
  final double targetAmount;
  final double raisedAmount;
  final double expectedReturn; // percentage
  final DateTime harvestDate;
  final List<String> images;
  final List<InvestorModel> investors;
  final InvestmentStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;

  InvestmentModel({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.farmerPhone,
    required this.title,
    required this.description,
    required this.cropType,
    required this.landSize,
    required this.targetAmount,
    this.raisedAmount = 0.0,
    required this.expectedReturn,
    required this.harvestDate,
    required this.images,
    this.investors = const [],
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  double get fundingProgress => (raisedAmount / targetAmount) * 100;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'farmerPhone': farmerPhone,
      'title': title,
      'description': description,
      'cropType': cropType,
      'landSize': landSize,
      'targetAmount': targetAmount,
      'raisedAmount': raisedAmount,
      'expectedReturn': expectedReturn,
      'harvestDate': harvestDate.toIso8601String(),
      'images': images,
      'investors': investors.map((inv) => inv.toJson()).toList(),
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory InvestmentModel.fromJson(Map<String, dynamic> json) {
    return InvestmentModel(
      id: json['id'],
      farmerId: json['farmerId'],
      farmerName: json['farmerName'],
      farmerPhone: json['farmerPhone'],
      title: json['title'],
      description: json['description'],
      cropType: json['cropType'],
      landSize: json['landSize'].toDouble(),
      targetAmount: json['targetAmount'].toDouble(),
      raisedAmount: (json['raisedAmount'] ?? 0.0).toDouble(),
      expectedReturn: json['expectedReturn'].toDouble(),
      harvestDate: DateTime.parse(json['harvestDate']),
      images: List<String>.from(json['images']),
      investors: json['investors'] != null
          ? (json['investors'] as List)
                .map((inv) => InvestorModel.fromJson(inv))
                .toList()
          : [],
      status: InvestmentStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }
}

class InvestorModel {
  final String id;
  final String investorId;
  final String investorName;
  final double amount;
  final DateTime investmentDate;
  final double? returnAmount;
  final DateTime? returnDate;

  InvestorModel({
    required this.id,
    required this.investorId,
    required this.investorName,
    required this.amount,
    required this.investmentDate,
    this.returnAmount,
    this.returnDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'investorId': investorId,
      'investorName': investorName,
      'amount': amount,
      'investmentDate': investmentDate.toIso8601String(),
      'returnAmount': returnAmount,
      'returnDate': returnDate?.toIso8601String(),
    };
  }

  factory InvestorModel.fromJson(Map<String, dynamic> json) {
    return InvestorModel(
      id: json['id'],
      investorId: json['investorId'],
      investorName: json['investorName'],
      amount: json['amount'].toDouble(),
      investmentDate: DateTime.parse(json['investmentDate']),
      returnAmount: json['returnAmount']?.toDouble(),
      returnDate: json['returnDate'] != null
          ? DateTime.parse(json['returnDate'])
          : null,
    );
  }
}
