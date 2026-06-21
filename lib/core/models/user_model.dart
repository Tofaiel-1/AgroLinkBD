enum UserType { farmer, buyer, driver, serviceProvider, company }

enum UserStatus { active, inactive, suspended, verified }

class UserModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final UserType userType;
  final UserStatus status;
  final String? profileImage;
  final String? nidNumber;
  final String? address;
  final String? district;
  final String? upazila;
  final double? latitude;
  final double? longitude;
  final bool isPremium;
  final DateTime? premiumExpiryDate;
  final double rating;
  final int totalRatings;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  // Farmer specific
  final double? totalLand; // in acres
  final List<String>? cropTypes;

  // Service Provider specific
  final List<String>? machineryTypes;
  final double? hourlyRate;

  // Driver specific
  final String? vehicleType;
  final String? vehicleNumber;
  final double? loadCapacity;

  // Company specific
  final String? companyName;
  final String? tradeLicense;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.userType,
    required this.status,
    this.profileImage,
    this.nidNumber,
    this.address,
    this.district,
    this.upazila,
    this.latitude,
    this.longitude,
    this.isPremium = false,
    this.premiumExpiryDate,
    this.rating = 0.0,
    this.totalRatings = 0,
    required this.createdAt,
    this.lastLoginAt,
    this.totalLand,
    this.cropTypes,
    this.machineryTypes,
    this.hourlyRate,
    this.vehicleType,
    this.vehicleNumber,
    this.loadCapacity,
    this.companyName,
    this.tradeLicense,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'userType': userType.toString(),
      'status': status.toString(),
      'profileImage': profileImage,
      'nidNumber': nidNumber,
      'address': address,
      'district': district,
      'upazila': upazila,
      'latitude': latitude,
      'longitude': longitude,
      'isPremium': isPremium,
      'premiumExpiryDate': premiumExpiryDate?.toIso8601String(),
      'rating': rating,
      'totalRatings': totalRatings,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'totalLand': totalLand,
      'cropTypes': cropTypes,
      'machineryTypes': machineryTypes,
      'hourlyRate': hourlyRate,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'loadCapacity': loadCapacity,
      'companyName': companyName,
      'tradeLicense': tradeLicense,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle createdAt which might be a Firestore Timestamp or ISO string
    DateTime parsedCreatedAt;
    try {
      final rawCreatedAt = json['createdAt'];
      if (rawCreatedAt is DateTime) {
        parsedCreatedAt = rawCreatedAt;
      } else if (rawCreatedAt is String) {
        parsedCreatedAt = DateTime.parse(rawCreatedAt);
      } else if (rawCreatedAt != null && rawCreatedAt.toDate != null) {
        // Firestore Timestamp
        parsedCreatedAt = rawCreatedAt.toDate();
      } else {
        parsedCreatedAt = DateTime.now();
      }
    } catch (_) {
      parsedCreatedAt = DateTime.now();
    }

    // Handle lastLoginAt similarly
    DateTime? parsedLastLogin;
    try {
      final rawLastLogin = json['lastLoginAt'];
      if (rawLastLogin is DateTime) {
        parsedLastLogin = rawLastLogin;
      } else if (rawLastLogin is String) {
        parsedLastLogin = DateTime.parse(rawLastLogin);
      } else if (rawLastLogin != null && rawLastLogin.toDate != null) {
        parsedLastLogin = rawLastLogin.toDate();
      }
    } catch (_) {
      parsedLastLogin = null;
    }

    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      userType: UserType.values.firstWhere(
        (e) => e.toString() == json['userType'],
        orElse: () => UserType.farmer,
      ),
      status: UserStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => UserStatus.active,
      ),
      profileImage: json['profileImage'],
      nidNumber: json['nidNumber'],
      address: json['address'],
      district: json['district'],
      upazila: json['upazila'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      isPremium: json['isPremium'] ?? false,
      premiumExpiryDate: json['premiumExpiryDate'] != null
          ? DateTime.tryParse(json['premiumExpiryDate'].toString())
          : null,
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalRatings: json['totalRatings'] ?? 0,
      createdAt: parsedCreatedAt,
      lastLoginAt: parsedLastLogin,
      totalLand: json['totalLand']?.toDouble(),
      cropTypes: json['cropTypes'] != null
          ? List<String>.from(json['cropTypes'])
          : null,
      machineryTypes: json['machineryTypes'] != null
          ? List<String>.from(json['machineryTypes'])
          : null,
      hourlyRate: json['hourlyRate']?.toDouble(),
      vehicleType: json['vehicleType'],
      vehicleNumber: json['vehicleNumber'],
      loadCapacity: json['loadCapacity']?.toDouble(),
      companyName: json['companyName'],
      tradeLicense: json['tradeLicense'],
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    UserType? userType,
    UserStatus? status,
    String? profileImage,
    String? nidNumber,
    String? address,
    String? district,
    String? upazila,
    double? latitude,
    double? longitude,
    bool? isPremium,
    DateTime? premiumExpiryDate,
    double? rating,
    int? totalRatings,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    double? totalLand,
    List<String>? cropTypes,
    List<String>? machineryTypes,
    double? hourlyRate,
    String? vehicleType,
    String? vehicleNumber,
    double? loadCapacity,
    String? companyName,
    String? tradeLicense,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      status: status ?? this.status,
      profileImage: profileImage ?? this.profileImage,
      nidNumber: nidNumber ?? this.nidNumber,
      address: address ?? this.address,
      district: district ?? this.district,
      upazila: upazila ?? this.upazila,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiryDate: premiumExpiryDate ?? this.premiumExpiryDate,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      totalLand: totalLand ?? this.totalLand,
      cropTypes: cropTypes ?? this.cropTypes,
      machineryTypes: machineryTypes ?? this.machineryTypes,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      loadCapacity: loadCapacity ?? this.loadCapacity,
      companyName: companyName ?? this.companyName,
      tradeLicense: tradeLicense ?? this.tradeLicense,
    );
  }
}
