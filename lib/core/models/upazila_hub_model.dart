import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents an AgroLink Upazila Hub in Bangladesh
class UpazilaHubModel {
  final String id;
  final String code; // e.g. HUB-PTK-DUMKI-01
  final String name; // e.g. দুমকি এগ্রোলিংক উপজেলা হাব
  final String nameEn; // e.g. Dumki AgroLink Upazila Hub
  final String upazila; // Dumki
  final String upazilaBn; // দুমকি
  final String district; // Patuakhali
  final String districtBn; // পটুয়াখালী
  final String division; // Barishal
  final String divisionBn; // বরিশাল
  final double latitude;
  final double longitude;
  final String managerName;
  final String managerPhone;
  final String qcOfficerName;
  final bool hasColdStorage;
  final double? coldStorageTempC; // e.g. 4.0 °C
  final double dailyCapacityKg; // e.g. 5000 kg/day
  final String operatingHours; // e.g. 07:00 AM - 09:00 PM
  final bool isActive;
  final int activeShipmentsCount;
  final double averageRating;

  const UpazilaHubModel({
    required this.id,
    required this.code,
    required this.name,
    required this.nameEn,
    required this.upazila,
    required this.upazilaBn,
    required this.district,
    required this.districtBn,
    required this.division,
    required this.divisionBn,
    required this.latitude,
    required this.longitude,
    required this.managerName,
    required this.managerPhone,
    required this.qcOfficerName,
    this.hasColdStorage = true,
    this.coldStorageTempC = 4.0,
    this.dailyCapacityKg = 10000.0,
    this.operatingHours = '07:00 AM - 09:00 PM',
    this.isActive = true,
    this.activeShipmentsCount = 14,
    this.averageRating = 4.9,
  });

  String getName(bool isBn) => isBn ? name : nameEn;

  String getUpazila(bool isBn) => isBn ? upazilaBn : upazila;

  String getDistrict(bool isBn) => isBn ? districtBn : district;

  String getDivision(bool isBn) => isBn ? divisionBn : division;

  String getFormattedAddress(bool isBn) {
    if (isBn) {
      return '$upazilaBn, $districtBn ($divisionBn)';
    }
    return '$upazila, $district ($division)';
  }

  factory UpazilaHubModel.fromMap(Map<String, dynamic> map, String id) {
    return UpazilaHubModel(
      id: id,
      code: map['code'] ?? 'HUB-BD-01',
      name: map['name'] ?? 'এগ্রোলিংক উপজেলা হাব',
      nameEn: map['nameEn'] ?? 'AgroLink Upazila Hub',
      upazila: map['upazila'] ?? 'Sadar',
      upazilaBn: map['upazilaBn'] ?? 'সদর',
      district: map['district'] ?? 'Dhaka',
      districtBn: map['districtBn'] ?? 'ঢাকা',
      division: map['division'] ?? 'Dhaka',
      divisionBn: map['divisionBn'] ?? 'ঢাকা',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 23.8103,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 90.4125,
      managerName: map['managerName'] ?? 'Md. Hub Manager',
      managerPhone: map['managerPhone'] ?? '+8801700000000',
      qcOfficerName: map['qcOfficerName'] ?? 'Dr. QC Agronomist',
      hasColdStorage: map['hasColdStorage'] ?? true,
      coldStorageTempC: (map['coldStorageTempC'] as num?)?.toDouble() ?? 4.0,
      dailyCapacityKg: (map['dailyCapacityKg'] as num?)?.toDouble() ?? 10000.0,
      operatingHours: map['operatingHours'] ?? '07:00 AM - 09:00 PM',
      isActive: map['isActive'] ?? true,
      activeShipmentsCount: (map['activeShipmentsCount'] as num?)?.toInt() ?? 12,
      averageRating: (map['averageRating'] as num?)?.toDouble() ?? 4.9,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'nameEn': nameEn,
      'upazila': upazila,
      'upazilaBn': upazilaBn,
      'district': district,
      'districtBn': districtBn,
      'division': division,
      'divisionBn': divisionBn,
      'latitude': latitude,
      'longitude': longitude,
      'managerName': managerName,
      'managerPhone': managerPhone,
      'qcOfficerName': qcOfficerName,
      'hasColdStorage': hasColdStorage,
      'coldStorageTempC': coldStorageTempC,
      'dailyCapacityKg': dailyCapacityKg,
      'operatingHours': operatingHours,
      'isActive': isActive,
      'activeShipmentsCount': activeShipmentsCount,
      'averageRating': averageRating,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
