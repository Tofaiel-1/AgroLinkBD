enum ContractStatus { draft, active, completed, cancelled }

class ContractFarmingModel {
  final String id;
  final String companyId;
  final String companyName;
  final String cropType;
  final double requiredQuantity;
  final String unit;
  final double pricePerUnit;
  final DateTime deliveryDate;
  final String deliveryLocation;
  final String qualityStandards;
  final String termsAndConditions;
  final List<ContractParticipantModel> participants;
  final ContractStatus status;
  final DateTime createdAt;
  final DateTime? closedAt;

  ContractFarmingModel({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.cropType,
    required this.requiredQuantity,
    required this.unit,
    required this.pricePerUnit,
    required this.deliveryDate,
    required this.deliveryLocation,
    required this.qualityStandards,
    required this.termsAndConditions,
    this.participants = const [],
    required this.status,
    required this.createdAt,
    this.closedAt,
  });

  double get totalValue => requiredQuantity * pricePerUnit;
  double get fulfilledQuantity =>
      participants.fold(0.0, (sum, p) => sum + p.committedQuantity);
  double get remainingQuantity => requiredQuantity - fulfilledQuantity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'companyName': companyName,
      'cropType': cropType,
      'requiredQuantity': requiredQuantity,
      'unit': unit,
      'pricePerUnit': pricePerUnit,
      'deliveryDate': deliveryDate.toIso8601String(),
      'deliveryLocation': deliveryLocation,
      'qualityStandards': qualityStandards,
      'termsAndConditions': termsAndConditions,
      'participants': participants.map((p) => p.toJson()).toList(),
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'closedAt': closedAt?.toIso8601String(),
    };
  }

  factory ContractFarmingModel.fromJson(Map<String, dynamic> json) {
    return ContractFarmingModel(
      id: json['id'],
      companyId: json['companyId'],
      companyName: json['companyName'],
      cropType: json['cropType'],
      requiredQuantity: json['requiredQuantity'].toDouble(),
      unit: json['unit'],
      pricePerUnit: json['pricePerUnit'].toDouble(),
      deliveryDate: DateTime.parse(json['deliveryDate']),
      deliveryLocation: json['deliveryLocation'],
      qualityStandards: json['qualityStandards'],
      termsAndConditions: json['termsAndConditions'],
      participants: json['participants'] != null
          ? (json['participants'] as List)
                .map((p) => ContractParticipantModel.fromJson(p))
                .toList()
          : [],
      status: ContractStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
      closedAt: json['closedAt'] != null
          ? DateTime.parse(json['closedAt'])
          : null,
    );
  }
}

class ContractParticipantModel {
  final String id;
  final String farmerId;
  final String farmerName;
  final String farmerPhone;
  final double committedQuantity;
  final DateTime joinedDate;
  final bool agreementSigned;
  final DateTime? signedDate;
  final double? deliveredQuantity;
  final DateTime? deliveryDate;

  ContractParticipantModel({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.farmerPhone,
    required this.committedQuantity,
    required this.joinedDate,
    this.agreementSigned = false,
    this.signedDate,
    this.deliveredQuantity,
    this.deliveryDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'farmerPhone': farmerPhone,
      'committedQuantity': committedQuantity,
      'joinedDate': joinedDate.toIso8601String(),
      'agreementSigned': agreementSigned,
      'signedDate': signedDate?.toIso8601String(),
      'deliveredQuantity': deliveredQuantity,
      'deliveryDate': deliveryDate?.toIso8601String(),
    };
  }

  factory ContractParticipantModel.fromJson(Map<String, dynamic> json) {
    return ContractParticipantModel(
      id: json['id'],
      farmerId: json['farmerId'],
      farmerName: json['farmerName'],
      farmerPhone: json['farmerPhone'],
      committedQuantity: json['committedQuantity'].toDouble(),
      joinedDate: DateTime.parse(json['joinedDate']),
      agreementSigned: json['agreementSigned'] ?? false,
      signedDate: json['signedDate'] != null
          ? DateTime.parse(json['signedDate'])
          : null,
      deliveredQuantity: json['deliveredQuantity']?.toDouble(),
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'])
          : null,
    );
  }
}
