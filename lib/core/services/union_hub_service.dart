import 'dart:math';
import 'package:agrolinkbd/core/models/union_hub_model.dart';
import 'package:agrolinkbd/core/models/qc_inspection_model.dart';
import 'package:agrolinkbd/core/constants/bd_union_data.dart';

/// Union Hub Service
/// Manages all Union-level hubs across Bangladesh
/// Provides hub resolution, QC, logistics quote, and route calculation
class UnionHubService {
  static final UnionHubService _instance = UnionHubService._internal();
  factory UnionHubService() => _instance;
  UnionHubService._internal();

  // ─────────────────────────────────────────────
  // MOCK DATA MANAGERS
  // ─────────────────────────────────────────────

  static const List<String> _managerFirstNames = [
    'Abdur Rahman', 'Md. Karim', 'Rahim Uddin', 'Shahidul Islam',
    'Nurul Haque', 'Faruk Ahmed', 'Anwarul Islam', 'Bazlur Rahman',
    'Rafiqul Islam', 'Saiful Islam', 'Monir Hossain', 'Alamin',
  ];
  static const List<String> _qcOfficerNames = [
    'Fatema Begum', 'Sumaiya Akter', 'Roksana Begum', 'Nasrin Begum',
    'Mahmuda Khanam', 'Sharmin Akter', 'Lutfun Nahar', 'Morshed Alam',
    'Kamal Hossain', 'Jamal Uddin', 'Nur Islam', 'Arifa Begum',
  ];
  static const List<String> _phonePrefixes = [
    '0171', '0173', '0175', '0177', '0181', '0188', '0191',
  ];

  // ─────────────────────────────────────────────
  // CORE: Resolve Hub from Union Data
  // ─────────────────────────────────────────────

  /// Generate a deterministic but realistic UnionHubModel for any union
  UnionHubModel generateHubForUnion({
    required Map<String, dynamic> unionData,
    required String district,
    String? districtBn,
    String? division,
  }) {
    final unionEn = unionData['en'] as String;
    final unionBn = unionData['bn'] as String;
    final upazila = unionData['upazila'] as String;
    final lat = (unionData['lat'] ?? 23.8) as double;
    final lng = (unionData['lng'] ?? 90.4) as double;
    final divisionStr = division ?? BDUnionData.getDivisionForDistrict(district);
    final districtBnStr = districtBn ?? BDUnionData.districtBnNames[district] ?? district;
    final divisionBn = BDUnionData.divisionBnNames[divisionStr] ?? divisionStr;

    // Deterministic seed from union name
    final seed = unionEn.codeUnits.fold(0, (a, b) => a + b);
    final rng = Random(seed);

    final hubCode = 'UH-${district.substring(0, min(3, district.length)).toUpperCase()}-'
        '${upazila.substring(0, min(3, upazila.length)).toUpperCase()}-'
        '${(seed % 9000 + 1000)}';

    final manager = _managerFirstNames[seed % _managerFirstNames.length];
    final qcOfficer = _qcOfficerNames[(seed * 3) % _qcOfficerNames.length];
    final phonePrefix = _phonePrefixes[seed % _phonePrefixes.length];
    final phoneSuffix = (seed * 7 % 9000000 + 1000000).toString();
    final phone = '$phonePrefix$phoneSuffix';

    final hasCold = rng.nextDouble() > 0.45;
    final hasPkg = true;
    final hasWeigh = rng.nextDouble() > 0.25;
    final hasQr = rng.nextDouble() > 0.15;
    final coldCapacity = hasCold ? (rng.nextInt(15) + 3) : 0;
    final dailyCap = (rng.nextInt(800) + 300);
    final rating = 3.5 + rng.nextDouble() * 1.5;
    final activeOrders = rng.nextInt(30);
    final totalShipments = rng.nextInt(2000) + 100;
    final utilization = rng.nextDouble() * 90;
    final isActive = rng.nextDouble() > 0.05;
    final statusVal = isActive ? 'active' : 'maintenance';

    return UnionHubModel(
      hubId: 'union_hub_${hubCode.toLowerCase().replaceAll('-', '_')}',
      hubCode: hubCode,
      unionName: unionEn,
      upazila: upazila,
      district: district,
      division: divisionStr,
      unionNameBn: unionBn,
      upazilaBn: _getUpazilaBn(upazila),
      districtBn: districtBnStr,
      divisionBn: divisionBn,
      managerName: manager,
      managerPhone: phone,
      qcOfficerName: qcOfficer,
      address: '$unionEn Union, $upazila Upazila, $district',
      addressBn: '$unionBn ইউনিয়ন, $upazila উপজেলা, $districtBnStr',
      hasColdStorage: hasCold,
      hasPackagingUnit: hasPkg,
      hasWeighbridge: hasWeigh,
      hasQrScanner: hasQr,
      coldStorageCapacityTons: coldCapacity,
      dailyCapacityKg: dailyCap,
      rating: double.parse(rating.toStringAsFixed(1)),
      activeOrders: activeOrders,
      totalShipments: totalShipments,
      utilizationPercent: double.parse(utilization.toStringAsFixed(1)),
      isActive: isActive,
      status: statusVal,
      latitude: lat + (rng.nextDouble() - 0.5) * 0.05,
      longitude: lng + (rng.nextDouble() - 0.5) * 0.05,
    );
  }

  /// Get all hubs for a given district (generates them from static data)
  List<UnionHubModel> getHubsByDistrict(String district) {
    final unions = BDUnionData.getUnionsByDistrict(district);
    return unions
        .map((u) => generateHubForUnion(unionData: u, district: district))
        .toList();
  }

  /// Get hubs by division (aggregates all districts in that division)
  List<UnionHubModel> getHubsByDivision(String division) {
    final results = <UnionHubModel>[];
    for (final entry in BDUnionData.districtDivisionMap.entries) {
      if (entry.value == division) {
        results.addAll(getHubsByDistrict(entry.key));
      }
    }
    return results;
  }

  /// Get all available hubs (for directory listing)
  List<UnionHubModel> getAllHubs() {
    final results = <UnionHubModel>[];
    for (final district in BDUnionData.districtsWithUnionData) {
      results.addAll(getHubsByDistrict(district));
    }
    return results;
  }

  /// Resolve nearest hub to given GPS coordinates
  UnionHubModel? resolveNearestHub(double lat, double lng) {
    UnionHubModel? nearest;
    double minDist = double.infinity;

    for (final district in BDUnionData.districtsWithUnionData) {
      final hubs = getHubsByDistrict(district);
      for (final hub in hubs) {
        final dist = _haversine(lat, lng, hub.latitude, hub.longitude);
        if (dist < minDist) {
          minDist = dist;
          nearest = hub;
        }
      }
    }
    return nearest;
  }

  /// Resolve hub by district name
  UnionHubModel resolveHubByDistrict(String district) {
    final hubs = getHubsByDistrict(district);
    if (hubs.isEmpty) return _fallbackHub(district);
    return hubs.first;
  }

  /// Search hubs by query string (name, upazila, district)
  List<UnionHubModel> searchHubs(String query, {String? divisionFilter}) {
    final q = query.toLowerCase();
    final results = divisionFilter != null
        ? getHubsByDivision(divisionFilter)
        : getAllHubs();

    return results.where((hub) =>
      hub.unionName.toLowerCase().contains(q) ||
      hub.upazila.toLowerCase().contains(q) ||
      hub.district.toLowerCase().contains(q) ||
      hub.hubCode.toLowerCase().contains(q) ||
      hub.unionNameBn.contains(query) ||
      hub.districtBn.contains(query)
    ).toList();
  }

  // ─────────────────────────────────────────────
  // QC INSPECTION GENERATION
  // ─────────────────────────────────────────────

  /// Generate a realistic QC Inspection for a given order/product at a Union Hub
  QcInspectionModel generateQcInspection({
    required String orderId,
    required double weightKg,
    required UnionHubModel hub,
  }) {
    final seed = (orderId.codeUnits.fold(0, (a, b) => a + b) + hub.hubCode.codeUnits.fold(0, (a, b) => a + b)).toInt();
    final rng = Random(seed);

    final freshnessScore = 70.0 + rng.nextDouble() * 30.0;
    final moisturePercent = 5.0 + rng.nextDouble() * 20.0;
    final defectPercent = rng.nextDouble() * 8.0;
    final actualWeight = weightKg * (0.97 + rng.nextDouble() * 0.06);

    String grade;
    String gradeBn;
    String packagingType;
    String packagingTypeBn;
    if (freshnessScore >= 90 && defectPercent < 3) {
      grade = 'Grade A+ (Super Premium)';
      gradeBn = 'গ্রেড এ+ (সুপার প্রিমিয়াম)';
      packagingType = 'Nitrogen Vacuum Seal — Export Grade';
      packagingTypeBn = 'নাইট্রোজেন ভ্যাকুয়াম সিল — রপ্তানি গ্রেড';
    } else if (freshnessScore >= 80 && defectPercent < 5) {
      grade = 'Grade A (Standard/Export)';
      gradeBn = 'গ্রেড এ (স্ট্যান্ডার্ড/রপ্তানি)';
      packagingType = 'Eco-Ventilated Crate with Barcode Seal';
      packagingTypeBn = 'ইকো-ভেন্টিলেটেড ক্রেট ও বারকোড সিল';
    } else if (freshnessScore >= 70 && defectPercent < 8) {
      grade = 'Grade B (Commercial)';
      gradeBn = 'গ্রেড বি (কমার্শিয়াল)';
      packagingType = 'Standard Jute Sack with AgroLink Seal';
      packagingTypeBn = 'স্ট্যান্ডার্ড পাটের বস্তা ও AgroLink সিল';
    } else {
      grade = 'Grade C (Below Standard)';
      gradeBn = 'গ্রেড সি (মানের নিচে)';
      packagingType = 'Bulk Loose — Requires Re-sorting';
      packagingTypeBn = 'বাল্ক লুজ — পুনরায় বাছাই প্রয়োজন';
    }

    final inspectorName = hub.qcOfficerName;
    final batchCode = 'BATCH-${hub.hubCode}-${rng.nextInt(99999).toString().padLeft(5, '0')}';
    final sealCode = 'SEAL-AGRO-${rng.nextInt(999999).toString().padLeft(6, '0')}';
    final isPassed = !grade.startsWith('Grade C');

    return QcInspectionModel(
      id: 'qc_${orderId}_${hub.hubCode}',
      orderId: orderId,
      batchCode: batchCode,
      hubId: hub.hubId,
      hubName: hub.fullNameBn,
      hubNameEn: hub.fullName,
      inspectorName: inspectorName,
      inspectedAt: DateTime.now(),
      freshnessScore: double.parse(freshnessScore.toStringAsFixed(1)),
      moisturePercent: double.parse(moisturePercent.toStringAsFixed(1)),
      defectPercent: double.parse(defectPercent.toStringAsFixed(1)),
      testedWeightKg: double.parse(actualWeight.toStringAsFixed(2)),
      declaredWeightKg: weightKg,
      grade: grade,
      gradeBn: gradeBn,
      isApproved: isPassed,
      packagingType: packagingType,
      packagingTypeBn: packagingTypeBn,
      tamperProofSealCode: sealCode,
      notes: isPassed
          ? 'Product meets AgroLink quality standards at ${ hub.unionName} Union Hub. Approved for shipment.'
          : 'Product requires additional sorting. Below minimum export standard.',
      notesBn: isPassed
          ? 'পণ্যটি ${hub.unionNameBn} ইউনিয়ন হাবে AgroLink মান পূরণ করেছে। পরিবহনের জন্য অনুমোদিত।'
          : 'পণ্যটির অতিরিক্ত বাছাই প্রয়োজন। ন্যূনতম রপ্তানি মান পূরণ হয়নি।',
    );
  }

  // ─────────────────────────────────────────────
  // LOGISTICS ROUTE CALCULATOR
  // ─────────────────────────────────────────────

  /// Calculate inter-hub logistics quote between two Union Hubs
  UnionHubLogisticsQuote calculateLogisticsQuote({
    required UnionHubModel origin,
    required UnionHubModel destination,
    required double cargoWeightKg,
    bool isColdChain = false,
  }) {
    final distKm = origin.distanceTo(destination);

    // Determine transit type
    String transitType;
    String routeDesc;
    String routeDescBn;
    if (origin.upazila == destination.upazila) {
      transitType = 'direct';
      routeDesc = '${origin.unionName} → ${destination.unionName} (Same Upazila — Direct)';
      routeDescBn = '${origin.unionNameBn} → ${destination.unionNameBn} (একই উপজেলা — সরাসরি)';
    } else if (origin.district == destination.district) {
      transitType = 'via-upazila';
      routeDesc = '${origin.unionName} → ${origin.upazila} Hub → ${destination.upazila} Hub → ${destination.unionName}';
      routeDescBn = '${origin.unionNameBn} → ${origin.upazilaBn} হাব → ${destination.upazilaBn} হাব → ${destination.unionNameBn}';
    } else {
      transitType = 'via-district';
      routeDesc = '${origin.unionName} → ${origin.upazila} Hub → ${origin.district} Gateway → ${destination.district} Gateway → ${destination.upazila} Hub → ${destination.unionName}';
      routeDescBn = '${origin.unionNameBn} → ${origin.upazilaBn} হাব → ${origin.districtBn} গেটওয়ে → ${destination.districtBn} গেটওয়ে → ${destination.upazilaBn} হাব → ${destination.unionNameBn}';
    }

    // Fare calculation
    const double baseRate = 80.0; // BDT base
    final double distanceFare = distKm * 2.5;
    final double weightFare = cargoWeightKg * 0.8;
    final double coldChainSurcharge = isColdChain ? (cargoWeightKg * 1.5 + 150) : 0;
    const double packagingFee = 50.0;
    const double qcFee = 30.0;
    final double total = baseRate + distanceFare + weightFare + coldChainSurcharge + packagingFee + qcFee;

    // ETA calculation
    int etaHours;
    if (transitType == 'direct') {
      etaHours = 2 + (distKm / 20).round();
    } else if (transitType == 'via-upazila') {
      etaHours = 4 + (distKm / 25).round();
    } else {
      etaHours = 8 + (distKm / 30).round();
    }

    return UnionHubLogisticsQuote(
      origin: origin,
      destination: destination,
      distanceKm: double.parse(distKm.toStringAsFixed(1)),
      cargoWeightKg: cargoWeightKg,
      isColdChain: isColdChain,
      baseFareBDT: baseRate,
      distanceFareBDT: double.parse(distanceFare.toStringAsFixed(2)),
      weightFareBDT: double.parse(weightFare.toStringAsFixed(2)),
      coldChainSurcharge: double.parse(coldChainSurcharge.toStringAsFixed(2)),
      packagingFee: packagingFee,
      qcFee: qcFee,
      totalFareBDT: double.parse(total.toStringAsFixed(2)),
      etaHours: etaHours,
      routeDescription: routeDesc,
      routeDescriptionBn: routeDescBn,
      transitType: transitType,
    );
  }

  // ─────────────────────────────────────────────
  // STATS & ANALYTICS
  // ─────────────────────────────────────────────

  /// Get live stats for a specific district
  Map<String, dynamic> getDistrictHubStats(String district) {
    final hubs = getHubsByDistrict(district);
    final active = hubs.where((h) => h.isActive).length;
    final coldCount = hubs.where((h) => h.hasColdStorage).length;
    final avgRating = hubs.isEmpty ? 0.0 : hubs.map((h) => h.rating).reduce((a, b) => a + b) / hubs.length;
    final totalOrders = hubs.map((h) => h.activeOrders).fold(0, (a, b) => a + b);
    final avgUtil = hubs.isEmpty ? 0.0 : hubs.map((h) => h.utilizationPercent).reduce((a, b) => a + b) / hubs.length;

    return {
      'total': hubs.length,
      'active': active,
      'coldStorage': coldCount,
      'avgRating': double.parse(avgRating.toStringAsFixed(1)),
      'totalActiveOrders': totalOrders,
      'avgUtilization': double.parse(avgUtil.toStringAsFixed(1)),
    };
  }

  // ─────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────

  double _haversine(double lat1, double lng1, double lat2, double lng2) {
    const R = 6371.0;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLng = (lng2 - lng1) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
        sin(dLng / 2) * sin(dLng / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  String _getUpazilaBn(String upazila) {
    // Basic bangla suffix mapping
    const Map<String, String> direct = {
      'Dumki': 'দুমকি', 'Bauphal': 'বাউফল', 'Galachipa': 'গলাচিপা',
      'Kalapara': 'কলাপাড়া', 'Mirzaganj': 'মির্জাগঞ্জ', 'Dashmina': 'দশমিনা',
      'Rangabali': 'রাঙ্গাবালী', 'Gurudaspur': 'গুরুদাসপুর', 'Natore Sadar': 'নাটোর সদর',
      'Baraigram': 'বড়াইগ্রাম', 'Singra': 'সিংড়া', 'Bagatipara': 'বাগাতিপাড়া',
      'Lalpur': 'লালপুর', 'Naldanga': 'নলডাঙ্গা', 'Paba': 'পবা',
      'Godagari': 'গোদাগাড়ী', 'Tanore': 'তানোর', 'Bogura Sadar': 'বগুড়া সদর',
      'Shibganj': 'শিবগঞ্জ', 'Gabtali': 'গাবতলী', 'Dhunat': 'ধুনট',
      'Mirsarai': 'মীরসরাই', 'Anwara': 'আনোয়ারা', 'Patiya': 'পটিয়া',
      'Hathazari': 'হাটহাজারী', 'Raozan': 'রাউজান', 'Sitakunda': 'সীতাকুণ্ড',
      'Savar': 'সাভার', 'Dhamrai': 'ধামরাই', 'Gazipur Sadar': 'গাজীপুর সদর',
      'Tangail Sadar': 'টাঙ্গাইল সদর', 'Rangpur Sadar': 'রংপুর সদর',
      'Mymensingh Sadar': 'ময়মনসিংহ সদর', 'Sylhet Sadar': 'সিলেট সদর',
    };
    if (direct.containsKey(upazila)) return direct[upazila]!;
    // For unknown ones, return as-is with ' উপজেলা'
    return '$upazila উপজেলা';
  }

  UnionHubModel _fallbackHub(String district) {
    final districtBn = BDUnionData.districtBnNames[district] ?? district;
    return UnionHubModel(
      hubId: 'union_hub_fallback_${district.toLowerCase()}',
      hubCode: 'UH-${district.substring(0, min(3, district.length)).toUpperCase()}-000',
      unionName: '$district Sadar Union',
      upazila: '$district Sadar',
      district: district,
      division: BDUnionData.getDivisionForDistrict(district),
      unionNameBn: '$districtBn সদর ইউনিয়ন',
      upazilaBn: '$districtBn সদর',
      districtBn: districtBn,
      divisionBn: BDUnionData.divisionBnNames[BDUnionData.getDivisionForDistrict(district)] ?? '',
      managerName: 'Md. Karim',
      managerPhone: '01712345678',
      qcOfficerName: 'Fatema Begum',
      address: '$district Sadar, $district',
      addressBn: '$districtBn সদর, $districtBn',
      hasColdStorage: true,
      hasPackagingUnit: true,
      hasWeighbridge: true,
      hasQrScanner: true,
      coldStorageCapacityTons: 10,
      dailyCapacityKg: 1000,
      rating: 4.2,
      activeOrders: 5,
      totalShipments: 500,
      utilizationPercent: 50.0,
      isActive: true,
      status: 'active',
      latitude: 23.8,
      longitude: 90.4,
    );
  }
}
