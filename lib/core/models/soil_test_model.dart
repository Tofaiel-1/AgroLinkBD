enum SoilType { clay, loam, sandy, silt, peat, chalk }

enum SoilHealthStatus { excellent, good, average, poor }

class SoilTestModel {
  final String id;
  final String farmerId;
  final String location;
  final String? district;
  final double? latitude;
  final double? longitude;
  final String imageUrl;
  final SoilType? soilType;
  final SoilHealthStatus? healthStatus;
  final Map<String, dynamic>? nutrients; // N, P, K levels
  final List<String> recommendations;
  final DateTime testedAt;

  SoilTestModel({
    required this.id,
    required this.farmerId,
    required this.location,
    this.district,
    this.latitude,
    this.longitude,
    required this.imageUrl,
    this.soilType,
    this.healthStatus,
    this.nutrients,
    this.recommendations = const [],
    required this.testedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'location': location,
      'district': district,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'soilType': soilType?.toString(),
      'healthStatus': healthStatus?.toString(),
      'nutrients': nutrients,
      'recommendations': recommendations,
      'testedAt': testedAt.toIso8601String(),
    };
  }

  factory SoilTestModel.fromJson(Map<String, dynamic> json) {
    return SoilTestModel(
      id: json['id'],
      farmerId: json['farmerId'],
      location: json['location'],
      district: json['district'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      imageUrl: json['imageUrl'],
      soilType: json['soilType'] != null
          ? SoilType.values.firstWhere((e) => e.toString() == json['soilType'])
          : null,
      healthStatus: json['healthStatus'] != null
          ? SoilHealthStatus.values.firstWhere(
              (e) => e.toString() == json['healthStatus'],
            )
          : null,
      nutrients: json['nutrients'],
      recommendations: json['recommendations'] != null
          ? List<String>.from(json['recommendations'])
          : [],
      testedAt: DateTime.parse(json['testedAt']),
    );
  }
}
