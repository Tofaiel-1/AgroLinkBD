import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a rigorous Quality Control (QC) inspection conducted at an AgroLink Upazila Hub
class QcInspectionModel {
  final String id;
  final String orderId;
  final String batchCode;
  final String hubId;
  final String hubName;
  final String hubNameEn;
  final String inspectorName;
  final DateTime inspectedAt;
  final double freshnessScore; // 0.0 to 100.0%
  final double moisturePercent; // e.g. 12.5%
  final double defectPercent; // e.g. 0.8%
  final double testedWeightKg;
  final double declaredWeightKg;
  final String grade; // e.g. Grade A+ (Super Premium), Grade A (Standard/Export), Grade B (Commercial)
  final String gradeBn; // e.g. গ্রেড এ+ (সুপার প্রিমিয়াম)
  final bool isApproved;
  final String packagingType; // e.g. Eco Ventilated Crate, Nitrogen Vacuum Seal, Insulated Ice Box
  final String packagingTypeBn;
  final String tamperProofSealCode; // e.g. SEAL-BD-892147
  final String notes;
  final String notesBn;

  const QcInspectionModel({
    required this.id,
    required this.orderId,
    required this.batchCode,
    required this.hubId,
    required this.hubName,
    required this.hubNameEn,
    required this.inspectorName,
    required this.inspectedAt,
    required this.freshnessScore,
    required this.moisturePercent,
    required this.defectPercent,
    required this.testedWeightKg,
    required this.declaredWeightKg,
    required this.grade,
    required this.gradeBn,
    this.isApproved = true,
    required this.packagingType,
    required this.packagingTypeBn,
    required this.tamperProofSealCode,
    required this.notes,
    required this.notesBn,
  });

  String getHubName(bool isBn) => isBn ? hubName : hubNameEn;
  String getGrade(bool isBn) => isBn ? gradeBn : grade;
  String getPackagingType(bool isBn) => isBn ? packagingTypeBn : packagingType;
  String getNotes(bool isBn) => isBn ? notesBn : notes;

  factory QcInspectionModel.fromMap(Map<String, dynamic> map, String id) {
    return QcInspectionModel(
      id: id,
      orderId: map['orderId'] ?? '',
      batchCode: map['batchCode'] ?? 'BATCH-BD-0000',
      hubId: map['hubId'] ?? '',
      hubName: map['hubName'] ?? 'উপজেলা হাব',
      hubNameEn: map['hubNameEn'] ?? 'Upazila Hub',
      inspectorName: map['inspectorName'] ?? 'Dr. QC Agronomist',
      inspectedAt: (map['inspectedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      freshnessScore: (map['freshnessScore'] as num?)?.toDouble() ?? 96.0,
      moisturePercent: (map['moisturePercent'] as num?)?.toDouble() ?? 12.0,
      defectPercent: (map['defectPercent'] as num?)?.toDouble() ?? 0.8,
      testedWeightKg: (map['testedWeightKg'] as num?)?.toDouble() ?? 50.0,
      declaredWeightKg: (map['declaredWeightKg'] as num?)?.toDouble() ?? 50.0,
      grade: map['grade'] ?? 'Grade A+ (Super Premium)',
      gradeBn: map['gradeBn'] ?? 'গ্রেড এ+ (সুপার প্রিমিয়াম)',
      isApproved: map['isApproved'] ?? true,
      packagingType: map['packagingType'] ?? 'Eco-Ventilated Crate with Barcode Seal',
      packagingTypeBn: map['packagingTypeBn'] ?? 'ইকো-ভেন্টিলেটেড ক্রেট ও বারকোড সিল',
      tamperProofSealCode: map['tamperProofSealCode'] ?? 'SEAL-BD-1001',
      notes: map['notes'] ?? 'Product passed multi-spectral freshness and digital weight verification.',
      notesBn: map['notesBn'] ?? 'পণ্যটি ডিজিটাল ওজন ও আর্দ্রতা পরীক্ষায় শতভাগ উত্তীর্ণ হয়েছে।',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'batchCode': batchCode,
      'hubId': hubId,
      'hubName': hubName,
      'hubNameEn': hubNameEn,
      'inspectorName': inspectorName,
      'inspectedAt': Timestamp.fromDate(inspectedAt),
      'freshnessScore': freshnessScore,
      'moisturePercent': moisturePercent,
      'defectPercent': defectPercent,
      'testedWeightKg': testedWeightKg,
      'declaredWeightKg': declaredWeightKg,
      'grade': grade,
      'gradeBn': gradeBn,
      'isApproved': isApproved,
      'packagingType': packagingType,
      'packagingTypeBn': packagingTypeBn,
      'tamperProofSealCode': tamperProofSealCode,
      'notes': notes,
      'notesBn': notesBn,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
