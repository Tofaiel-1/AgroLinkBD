import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModel {
  final String id;
  final String buyerId;
  final String recipientName;
  final String phoneNumber;
  final String addressLine1;
  final String? addressLine2;
  final String landmark;
  final String city;
  final String district;
  final String thana;
  final String postalCode;
  final String label; // Home, Office, Other
  final bool isDefault;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;

  AddressModel({
    required this.id,
    required this.buyerId,
    required this.recipientName,
    required this.phoneNumber,
    required this.addressLine1,
    this.addressLine2,
    required this.landmark,
    required this.city,
    required this.district,
    required this.thana,
    required this.postalCode,
    required this.label,
    this.isDefault = false,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  String getFullAddress() {
    return '$addressLine1${addressLine2 != null ? ', $addressLine2' : ''}, $landmark, $thana, $district, $postalCode';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'buyerId': buyerId,
      'recipientName': recipientName,
      'phoneNumber': phoneNumber,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'landmark': landmark,
      'city': city,
      'district': district,
      'thana': thana,
      'postalCode': postalCode,
      'label': label,
      'isDefault': isDefault,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt,
    };
  }

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id'] as String? ?? '',
      buyerId: map['buyerId'] as String? ?? '',
      recipientName: map['recipientName'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      addressLine1: map['addressLine1'] as String? ?? '',
      addressLine2: map['addressLine2'] as String?,
      landmark: map['landmark'] as String? ?? '',
      city: map['city'] as String? ?? '',
      district: map['district'] as String? ?? '',
      thana: map['thana'] as String? ?? '',
      postalCode: map['postalCode'] as String? ?? '',
      label: map['label'] as String? ?? 'Home',
      isDefault: map['isDefault'] as bool? ?? false,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  AddressModel copyWith({
    String? id,
    String? buyerId,
    String? recipientName,
    String? phoneNumber,
    String? addressLine1,
    String? addressLine2,
    String? landmark,
    String? city,
    String? district,
    String? thana,
    String? postalCode,
    String? label,
    bool? isDefault,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      recipientName: recipientName ?? this.recipientName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      landmark: landmark ?? this.landmark,
      city: city ?? this.city,
      district: district ?? this.district,
      thana: thana ?? this.thana,
      postalCode: postalCode ?? this.postalCode,
      label: label ?? this.label,
      isDefault: isDefault ?? this.isDefault,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
