enum UserType {
  farmer,
  buyer,
  driver,
  serviceProvider,
  company,
  seller,
  expert,
  // Fisheries specific roles
  fishFarmer,
  fishBuyer,
  fishDriver,
  fishServiceProvider,
  fishCompany,
  fishExpert,
  hatchery
}

enum UserStatus { active, inactive, suspended, verified }

class UserModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final UserType userType;
  final UserStatus status;
  final String? profileImage;
  final String? nidNumber;
  final String? address; // For backward compatibility
  final String? district;
  final String? upazila;
  final String? unionName; // New
  final String? village; // New
  final double? latitude;
  final double? longitude;
  final bool isPremium;
  final DateTime? premiumExpiryDate;
  final double rating;
  final int totalRatings;
  final double farmerRating; // খামারিদের দেওয়া রেটিং (1-5)
  final double paymentScore; // পেমেন্ট সম্পূর্ণ করার রেটিং (1-5)
  final double transportScore; // ট্রান্সপোর্ট ও রিসিভ রেটিং (1-5)
  final double trustScore; // সর্বজনীন ট্রাস্ট ও বিশ্বস্ততা স্কোর (0.0 to 100.0)
  final int fraudReports; // প্রতারণা ও ভুয়া রিপোর্ট সংখ্যা
  final int cancelledOrders; // অর্ডার বাতিল সংখ্যা
  final int paymentDefaults; // পেমেন্ট বকেয়া বা বিরোধ সংখ্যা
  final int lateDeliveries; // বিলম্ব বা অনুপস্থিতি সংখ্যা
  final int totalOrders; // মোট সম্পন্ন ক্রয়/অর্ডার সংখ্যা
  final double totalSpent; // মোট পরিশোধিত খরচ
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final double mainBalance;
  final String? mainBalancePin;
  final String domain; // 'agriculture' or 'fisheries'

  // Farmer specific
  final double? totalLand; // in acres
  final List<String>? cropTypes;

  // Service Provider specific
  final List<String>? machineryTypes;
  final double? hourlyRate;
  final int? yearsOfExperience;

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
    this.email,
    required this.userType,
    required this.status,
    this.profileImage,
    this.nidNumber,
    this.address,
    this.district,
    this.upazila,
    this.unionName,
    this.village,
    this.latitude,
    this.longitude,
    this.isPremium = false,
    this.premiumExpiryDate,
    this.rating = 0.0,
    this.totalRatings = 0,
    this.farmerRating = 0.0,
    this.paymentScore = 0.0,
    this.transportScore = 0.0,
    this.totalOrders = 0,
    this.totalSpent = 0.0,
    required this.createdAt,
    this.lastLoginAt,
    this.mainBalance = 500.0, // Giving 500 default balance for testing
    this.mainBalancePin,
    this.trustScore = 100.0,
    this.fraudReports = 0,
    this.cancelledOrders = 0,
    this.paymentDefaults = 0,
    this.lateDeliveries = 0,
    this.domain = 'agriculture',
    this.totalLand,
    this.cropTypes,
    this.machineryTypes,
    this.hourlyRate,
    this.yearsOfExperience,
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
      'userType': userType.name,
      'role': userType.name,
      'userRole': userType.name,
      'status': status.name,
      'profileImage': profileImage,
      'nidNumber': nidNumber,
      'address': address,
      'district': district,
      'upazila': upazila,
      'unionName': unionName,
      'village': village,
      'latitude': latitude,
      'longitude': longitude,
      'isPremium': isPremium,
      'premiumExpiryDate': premiumExpiryDate?.toIso8601String(),
      'rating': rating,
      'totalRatings': totalRatings,
      'farmerRating': farmerRating,
      'paymentScore': paymentScore,
      'transportScore': transportScore,
      'trustScore': trustScore,
      'fraudReports': fraudReports,
      'cancelledOrders': cancelledOrders,
      'paymentDefaults': paymentDefaults,
      'lateDeliveries': lateDeliveries,
      'totalOrders': totalOrders,
      'totalSpent': totalSpent,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'mainBalance': mainBalance,
      'mainBalancePin': mainBalancePin,
      'domain': domain,
      'totalLand': totalLand,
      'cropTypes': cropTypes,
      'machineryTypes': machineryTypes,
      'hourlyRate': hourlyRate,
      'yearsOfExperience': yearsOfExperience,
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
      email: json['email'],
      userType: () {
        final raw = (json['userType'] ?? json['role'] ?? json['userRole'])?.toString();
        final rawDomain = (json['domain'] ?? json['userDomain'])?.toString().toLowerCase() ?? '';
        final rawName = (json['name'] ?? '').toString().toLowerCase();
        final rawEmail = (json['email'] ?? '').toString().toLowerCase();

        final isFisheriesContext = rawDomain == 'fisheries' ||
            rawName.contains('fish') ||
            rawEmail.contains('fish') ||
            rawName.contains('মৎস্য') ||
            rawName.contains('মাছ');

        // Strong Name / Email Priority Checks to prevent stale or defaulted Firestore roles:
        final isDriverByName = rawName.contains('driver') ||
            rawEmail.contains('driver') ||
            rawName.contains('চালক') ||
            rawName.contains('পরিবহন');

        final isBuyerByName = rawName.contains('buyer') ||
            rawEmail.contains('buyer') ||
            rawName.contains('ক্রেতা') ||
            rawName.contains('পাইকারি');

        final isHatcheryByName = rawName.contains('hatchery') ||
            rawEmail.contains('hatchery') ||
            rawName.contains('হ্যাচারি');

        final isExpertByName = rawName.contains('expert') ||
            rawEmail.contains('expert') ||
            rawName.contains('বিশেষজ্ঞ');

        final isServiceProviderByName = rawName.contains('service') ||
            rawEmail.contains('service') ||
            rawName.contains('সেবা');

        final isCompanyByName = rawName.contains('company') ||
            rawEmail.contains('company') ||
            rawName.contains('কোম্পানি');

        if (isDriverByName) {
          return isFisheriesContext ? UserType.fishDriver : UserType.driver;
        }
        if (isBuyerByName) {
          return isFisheriesContext ? UserType.fishBuyer : UserType.buyer;
        }
        if (isHatcheryByName) {
          return UserType.hatchery;
        }
        if (isExpertByName) {
          return isFisheriesContext ? UserType.fishExpert : UserType.expert;
        }
        if (isServiceProviderByName) {
          return isFisheriesContext ? UserType.fishServiceProvider : UserType.serviceProvider;
        }
        if (isCompanyByName) {
          return isFisheriesContext ? UserType.fishCompany : UserType.company;
        }

        if (raw == null || raw.isEmpty) {
          return isFisheriesContext ? UserType.fishFarmer : UserType.farmer;
        }

        final clean = raw
            .replaceAll('UserType.', '')
            .replaceAll('UserRole.', '')
            .replaceAll('_', '')
            .replaceAll(' ', '')
            .replaceAll('-', '')
            .toLowerCase();

        // 1. Explicit Driver Checks
        if (clean == 'fishdriver' ||
            clean.contains('fishdriver') ||
            clean.contains('মৎস্যপরিবহন') ||
            clean.contains('মাছপরিবহন') ||
            (clean.contains('driver') && isFisheriesContext) ||
            (clean.contains('চালক') && isFisheriesContext) ||
            (clean.contains('পরিবহন') && isFisheriesContext)) {
          return UserType.fishDriver;
        }
        if (clean == 'driver' || clean.contains('driver') || clean.contains('চালক') || clean.contains('পরিবহন')) {
          return isFisheriesContext ? UserType.fishDriver : UserType.driver;
        }

        // 2. Explicit Buyer Checks
        if (clean == 'fishbuyer' ||
            clean.contains('fishbuyer') ||
            clean.contains('মাছক্রেতা') ||
            clean.contains('মৎস্যক্রেতা') ||
            clean.contains('পাইকারিক্রেতা') ||
            (clean.contains('buyer') && isFisheriesContext) ||
            (clean.contains('ক্রেতা') && isFisheriesContext)) {
          return UserType.fishBuyer;
        }
        if (clean == 'buyer' || clean.contains('buyer') || clean.contains('ক্রেতা') || clean.contains('পাইকারি')) {
          return isFisheriesContext ? UserType.fishBuyer : UserType.buyer;
        }

        // 3. Exact UserType enum matches
        for (var t in UserType.values) {
          if (t.name.toLowerCase() == clean) {
            if (t == UserType.driver && isFisheriesContext) return UserType.fishDriver;
            if (t == UserType.buyer && isFisheriesContext) return UserType.fishBuyer;
            if (t == UserType.farmer && isFisheriesContext) return UserType.fishFarmer;
            if (t == UserType.serviceProvider && isFisheriesContext) return UserType.fishServiceProvider;
            if (t == UserType.company && isFisheriesContext) return UserType.fishCompany;
            if (t == UserType.expert && isFisheriesContext) return UserType.fishExpert;
            return t;
          }
        }

        // 4. Other Fisheries Roles
        if (clean == 'hatchery' || clean == 'hatcheryowner' || clean.contains('হ্যাচারি')) {
          return UserType.hatchery;
        }
        if (clean == 'fishexpert' || (clean == 'expert' && isFisheriesContext) || (clean.contains('বিশেষজ্ঞ') && isFisheriesContext)) {
          return UserType.fishExpert;
        }
        if (clean == 'fishserviceprovider' || (clean == 'serviceprovider' && isFisheriesContext) || (clean.contains('সেবা') && isFisheriesContext)) {
          return UserType.fishServiceProvider;
        }
        if (clean == 'fishcompany' || (clean == 'company' && isFisheriesContext) || (clean.contains('কোম্পানি') && isFisheriesContext)) {
          return UserType.fishCompany;
        }
        if (clean == 'fishfarmer' ||
            clean == 'fishfarming' ||
            clean == 'fisherman' ||
            clean == 'aquaculture' ||
            clean.contains('মৎস্যচাষী') ||
            clean.contains('মাছচাষী') ||
            (clean.contains('চাষী') && isFisheriesContext) ||
            (clean == 'farmer' && isFisheriesContext) ||
            (clean == 'fish' && isFisheriesContext) ||
            (clean == 'fisheries')) {
          return UserType.fishFarmer;
        }

        // 5. Agriculture Fallbacks
        if (clean == 'serviceprovider' || clean.contains('সেবা')) return UserType.serviceProvider;
        if (clean == 'company' || clean.contains('কোম্পানি')) return UserType.company;
        if (clean == 'seller' || clean.contains('বিক্রেতা')) return UserType.seller;
        if (clean == 'expert' || clean.contains('বিশেষজ্ঞ')) return UserType.expert;

        return isFisheriesContext ? UserType.fishFarmer : UserType.farmer;
      }(),
      status: UserStatus.values.firstWhere(
        (e) => e.toString() == json['status'] || e.name.toLowerCase() == json['status']?.toString().toLowerCase(),
        orElse: () => UserStatus.active,
      ),
      profileImage: json['profileImage'],
      nidNumber: json['nidNumber'],
      address: json['address'],
      district: json['district'],
      upazila: json['upazila'],
      unionName: json['unionName'],
      village: json['village'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isPremium: json['isPremium'] ?? false,
      premiumExpiryDate: json['premiumExpiryDate'] != null
          ? DateTime.tryParse(json['premiumExpiryDate'].toString())
          : null,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: (json['totalRatings'] as num?)?.toInt() ?? 0,
      farmerRating: (json['farmerRating'] as num?)?.toDouble() ?? 0.0,
      paymentScore: (json['paymentScore'] as num?)?.toDouble() ?? 0.0,
      transportScore: (json['transportScore'] as num?)?.toDouble() ?? 0.0,
      trustScore: (json['trustScore'] as num?)?.toDouble() ?? 100.0,
      fraudReports: (json['fraudReports'] as num?)?.toInt() ?? 0,
      cancelledOrders: (json['cancelledOrders'] as num?)?.toInt() ?? 0,
      paymentDefaults: (json['paymentDefaults'] as num?)?.toInt() ?? 0,
      lateDeliveries: (json['lateDeliveries'] as num?)?.toInt() ?? 0,
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      createdAt: parsedCreatedAt,
      lastLoginAt: parsedLastLogin,
      mainBalance: (json['mainBalance'] as num?)?.toDouble() ?? 0.0,
      mainBalancePin: json['mainBalancePin'],
      domain: () {
        final explicitDomain = (json['domain'] ?? json['userDomain'])?.toString().toLowerCase();
        if (explicitDomain != null && (explicitDomain == 'fisheries' || explicitDomain == 'agriculture')) {
          return explicitDomain;
        }
        final rawRole = (json['userType'] ?? json['role'] ?? json['userRole'])?.toString().toLowerCase() ?? '';
        final rawName = (json['name'] ?? '').toString().toLowerCase();
        final rawEmail = (json['email'] ?? '').toString().toLowerCase();
        if (rawRole.contains('fish') ||
            rawRole.contains('hatchery') ||
            rawRole.contains('মৎস্য') ||
            rawRole.contains('মাছ') ||
            rawName.contains('fish') ||
            rawEmail.contains('fish')) {
          return 'fisheries';
        }
        return 'agriculture';
      }(),
      totalLand: (json['totalLand'] as num?)?.toDouble(),
      cropTypes: json['cropTypes'] != null
          ? List<String>.from(json['cropTypes'])
          : null,
      machineryTypes: json['machineryTypes'] != null
          ? List<String>.from(json['machineryTypes'])
          : null,
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble(),
      yearsOfExperience: json['yearsOfExperience'] is int ? json['yearsOfExperience'] : (json['yearsOfExperience'] != null ? int.tryParse(json['yearsOfExperience'].toString()) : null),
      vehicleType: json['vehicleType'],
      vehicleNumber: json['vehicleNumber'],
      loadCapacity: (json['loadCapacity'] as num?)?.toDouble(),
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
    String? unionName,
    String? village,
    double? latitude,
    double? longitude,
    bool? isPremium,
    DateTime? premiumExpiryDate,
    double? rating,
    int? totalRatings,
    double? farmerRating,
    double? paymentScore,
    double? transportScore,
    double? trustScore,
    int? fraudReports,
    int? cancelledOrders,
    int? paymentDefaults,
    int? lateDeliveries,
    int? totalOrders,
    double? totalSpent,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    double? mainBalance,
    String? mainBalancePin,
    String? domain,
    double? totalLand,
    List<String>? cropTypes,
    List<String>? machineryTypes,
    double? hourlyRate,
    int? yearsOfExperience,
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
      unionName: unionName ?? this.unionName,
      village: village ?? this.village,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiryDate: premiumExpiryDate ?? this.premiumExpiryDate,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      farmerRating: farmerRating ?? this.farmerRating,
      paymentScore: paymentScore ?? this.paymentScore,
      transportScore: transportScore ?? this.transportScore,
      trustScore: trustScore ?? this.trustScore,
      fraudReports: fraudReports ?? this.fraudReports,
      cancelledOrders: cancelledOrders ?? this.cancelledOrders,
      paymentDefaults: paymentDefaults ?? this.paymentDefaults,
      lateDeliveries: lateDeliveries ?? this.lateDeliveries,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpent: totalSpent ?? this.totalSpent,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      mainBalance: mainBalance ?? this.mainBalance,
      mainBalancePin: mainBalancePin ?? this.mainBalancePin,
      domain: domain ?? this.domain,
      totalLand: totalLand ?? this.totalLand,
      cropTypes: cropTypes ?? this.cropTypes,
      machineryTypes: machineryTypes ?? this.machineryTypes,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      loadCapacity: loadCapacity ?? this.loadCapacity,
      companyName: companyName ?? this.companyName,
      tradeLicense: tradeLicense ?? this.tradeLicense,
    );
  }
}
