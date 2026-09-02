import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agrolinkbd/core/models/upazila_hub_model.dart';
import 'package:agrolinkbd/core/models/qc_inspection_model.dart';
import 'package:agrolinkbd/core/services/weather_service.dart';

/// Quote and route calculation between Upazila Hubs
class InterHubLogisticsQuote {
  final UpazilaHubModel originHub;
  final UpazilaHubModel destinationHub;
  final double distanceKm;
  final double transitHours;
  final double baseFreightFare;
  final double coldChainFee;
  final double packagingFee;
  final double totalLogisticsCost;
  final String estimatedPickupTime;
  final String estimatedDeliveryTime;
  final String transportVehicleType;
  final String transportVehicleTypeBn;

  const InterHubLogisticsQuote({
    required this.originHub,
    required this.destinationHub,
    required this.distanceKm,
    required this.transitHours,
    required this.baseFreightFare,
    required this.coldChainFee,
    required this.packagingFee,
    required this.totalLogisticsCost,
    required this.estimatedPickupTime,
    required this.estimatedDeliveryTime,
    required this.transportVehicleType,
    required this.transportVehicleTypeBn,
  });

  String getVehicleType(bool isBn) => isBn ? transportVehicleTypeBn : transportVehicleType;
}

class UpazilaHubService {
  static final UpazilaHubService _instance = UpazilaHubService._internal();
  factory UpazilaHubService() => _instance;
  UpazilaHubService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Primary database of flagship Upazila Hubs
  static final List<UpazilaHubModel> _flagshipHubs = [
    // Patuakhali District (Barishal Division)
    const UpazilaHubModel(
      id: 'hub_patuakhali_dumki',
      code: 'HUB-PTK-DUMKI-01',
      name: 'দুমকি এগ্রোলিংক উপজেলা হাব',
      nameEn: 'Dumki AgroLink Upazila Hub',
      upazila: 'Dumki',
      upazilaBn: 'দুমকি',
      district: 'Patuakhali',
      districtBn: 'পটুয়াখালী',
      division: 'Barishal',
      divisionBn: 'বরিশাল',
      latitude: 22.4500,
      longitude: 90.3800,
      managerName: 'কবীর হোসেন (হাব ইনচার্জ)',
      managerPhone: '+8801712345001',
      qcOfficerName: 'কৃষিবিদ শাহিনুর রহমান (সিনিয়র কিউসি অফিসার)',
      hasColdStorage: true,
      coldStorageTempC: 3.5,
      dailyCapacityKg: 15000.0,
      operatingHours: '০৬:০০ AM - ০৯:০০ PM',
      activeShipmentsCount: 28,
      averageRating: 4.95,
    ),
    const UpazilaHubModel(
      id: 'hub_patuakhali_sadar',
      code: 'HUB-PTK-SADAR-01',
      name: 'পটুয়াখালী সদর সেন্ট্রাল হাব',
      nameEn: 'Patuakhali Sadar Central Hub',
      upazila: 'Patuakhali Sadar',
      upazilaBn: 'পটুয়াখালী সদর',
      district: 'Patuakhali',
      districtBn: 'পটুয়াখালী',
      division: 'Barishal',
      divisionBn: 'বরিশাল',
      latitude: 22.3596,
      longitude: 90.3299,
      managerName: 'মোঃ আমিনুল ইসলাম',
      managerPhone: '+8801712345002',
      qcOfficerName: 'ড. ফারহানা সুলতানা',
      hasColdStorage: true,
      coldStorageTempC: 4.0,
      dailyCapacityKg: 25000.0,
      operatingHours: '০৬:০০ AM - ১০:০০ PM',
      activeShipmentsCount: 45,
      averageRating: 4.9,
    ),
    const UpazilaHubModel(
      id: 'hub_patuakhali_bauphal',
      code: 'HUB-PTK-BAUPHAL-01',
      name: 'বাউফল এগ্রোলিংক উপজেলা হাব',
      nameEn: 'Bauphal AgroLink Upazila Hub',
      upazila: 'Bauphal',
      upazilaBn: 'বাউফল',
      district: 'Patuakhali',
      districtBn: 'পটুয়াখালী',
      division: 'Barishal',
      divisionBn: 'বরিশাল',
      latitude: 22.4167,
      longitude: 90.5833,
      managerName: 'জহিরুল হক',
      managerPhone: '+8801712345003',
      qcOfficerName: 'মোঃ আল-আমিন',
      hasColdStorage: true,
      coldStorageTempC: 4.0,
      dailyCapacityKg: 12000.0,
      operatingHours: '০৬:০০ AM - ০৯:০০ PM',
      activeShipmentsCount: 19,
      averageRating: 4.88,
    ),
    const UpazilaHubModel(
      id: 'hub_patuakhali_galachipa',
      code: 'HUB-PTK-GALACHIPA-01',
      name: 'গলাচিপা এগ্রোলিংক উপজেলা হাব',
      nameEn: 'Galachipa AgroLink Upazila Hub',
      upazila: 'Galachipa',
      upazilaBn: 'গলাচিপা',
      district: 'Patuakhali',
      districtBn: 'পটুয়াখালী',
      division: 'Barishal',
      divisionBn: 'বরিশাল',
      latitude: 22.1667,
      longitude: 90.4167,
      managerName: 'তারেক মাহমুদ',
      managerPhone: '+8801712345004',
      qcOfficerName: 'নাজমুল হাসান',
      hasColdStorage: true,
      coldStorageTempC: 2.0,
      dailyCapacityKg: 18000.0,
      operatingHours: '০৬:০০ AM - ০৯:০০ PM',
      activeShipmentsCount: 22,
      averageRating: 4.92,
    ),

    // Natore District (Rajshahi Division)
    const UpazilaHubModel(
      id: 'hub_natore_gurudaspur',
      code: 'HUB-NAT-GURUDAS-01',
      name: 'গুরুদাসপুর এগ্রোলিংক উপজেলা হাব',
      nameEn: 'Gurudaspur AgroLink Upazila Hub',
      upazila: 'Gurudaspur',
      upazilaBn: 'গুরুদাসপুর',
      district: 'Natore',
      districtBn: 'নাটোর',
      division: 'Rajshahi',
      divisionBn: 'রাজশাহী',
      latitude: 24.3667,
      longitude: 89.1500,
      managerName: 'আনিসুর রহমান',
      managerPhone: '+8801712345010',
      qcOfficerName: 'ড. মোস্তাফিজুর রহমান',
      hasColdStorage: true,
      coldStorageTempC: 3.0,
      dailyCapacityKg: 30000.0,
      operatingHours: '০৫:০০ AM - ১০:০০ PM',
      activeShipmentsCount: 52,
      averageRating: 4.98,
    ),
    const UpazilaHubModel(
      id: 'hub_natore_singra',
      code: 'HUB-NAT-SINGRA-01',
      name: 'সিংড়া চলনবিল এগ্রোলিংক হাব',
      nameEn: 'Singra Chalan Beel AgroLink Hub',
      upazila: 'Singra',
      upazilaBn: 'সিংড়া',
      district: 'Natore',
      districtBn: 'নাটোর',
      division: 'Rajshahi',
      divisionBn: 'রাজশাহী',
      latitude: 24.5000,
      longitude: 89.1500,
      managerName: 'মজিবুর রহমান',
      managerPhone: '+8801712345011',
      qcOfficerName: 'রাশেদ খান',
      hasColdStorage: true,
      coldStorageTempC: 2.0,
      dailyCapacityKg: 28000.0,
      operatingHours: '০৫:০০ AM - ১০:০০ PM',
      activeShipmentsCount: 48,
      averageRating: 4.94,
    ),
    const UpazilaHubModel(
      id: 'hub_natore_baraigram',
      code: 'HUB-NAT-BARAIGRAM-01',
      name: 'বড়াইগ্রাম এগ্রোলিংক উপজেলা হাব',
      nameEn: 'Baraigram AgroLink Upazila Hub',
      upazila: 'Baraigram',
      upazilaBn: 'বড়াইগ্রাম',
      district: 'Natore',
      districtBn: 'নাটোর',
      division: 'Rajshahi',
      divisionBn: 'রাজশাহী',
      latitude: 24.3000,
      longitude: 89.1667,
      managerName: 'সেলিম রেজা',
      managerPhone: '+8801712345012',
      qcOfficerName: 'মাহমুদুল হক',
      hasColdStorage: true,
      coldStorageTempC: 4.0,
      dailyCapacityKg: 20000.0,
      operatingHours: '০৬:০০ AM - ০৯:০০ PM',
      activeShipmentsCount: 31,
      averageRating: 4.89,
    ),

    // Dhaka & Gazipur Division
    const UpazilaHubModel(
      id: 'hub_dhaka_savar',
      code: 'HUB-DHA-SAVAR-01',
      name: 'সাভার এগ্রোলিংক মেগা হাব',
      nameEn: 'Savar AgroLink Mega Hub',
      upazila: 'Savar',
      upazilaBn: 'সাভার',
      district: 'Dhaka',
      districtBn: 'ঢাকা',
      division: 'Dhaka',
      divisionBn: 'ঢাকা',
      latitude: 23.8583,
      longitude: 90.2667,
      managerName: 'ইঞ্জিনিয়ার তানভীর আহমেদ',
      managerPhone: '+8801712345020',
      qcOfficerName: 'ড. নুসরাত জাহান',
      hasColdStorage: true,
      coldStorageTempC: 2.0,
      dailyCapacityKg: 50000.0,
      operatingHours: '২৪ ঘণ্টা খোলা (24/7 Operations)',
      activeShipmentsCount: 110,
      averageRating: 4.97,
    ),
    const UpazilaHubModel(
      id: 'hub_gazipur_kaliakair',
      code: 'HUB-GAZ-KALIA-01',
      name: 'কালিয়াকৈর এগ্রোলিংক উপজেলা হাব',
      nameEn: 'Kaliakair AgroLink Upazila Hub',
      upazila: 'Kaliakair',
      upazilaBn: 'কালিয়াকৈর',
      district: 'Gazipur',
      districtBn: 'গাজীপুর',
      division: 'Dhaka',
      divisionBn: 'ঢাকা',
      latitude: 24.0667,
      longitude: 90.2167,
      managerName: 'রেজাউল করিম',
      managerPhone: '+8801712345021',
      qcOfficerName: 'সাদিয়া আক্তার',
      hasColdStorage: true,
      coldStorageTempC: 3.5,
      dailyCapacityKg: 22000.0,
      operatingHours: '০৬:০০ AM - ১০:০০ PM',
      activeShipmentsCount: 38,
      averageRating: 4.91,
    ),
    const UpazilaHubModel(
      id: 'hub_gazipur_sadar',
      code: 'HUB-GAZ-SADAR-01',
      name: 'গাজীপুর সদর সেন্ট্রাল হাব',
      nameEn: 'Gazipur Sadar Central Hub',
      upazila: 'Gazipur Sadar',
      upazilaBn: 'গাজীপুর সদর',
      district: 'Gazipur',
      districtBn: 'গাজীপুর',
      division: 'Dhaka',
      divisionBn: 'ঢাকা',
      latitude: 23.9999,
      longitude: 90.4203,
      managerName: 'হারুনুর রশিদ',
      managerPhone: '+8801712345022',
      qcOfficerName: 'মোঃ শফিকুল ইসলাম',
      hasColdStorage: true,
      coldStorageTempC: 3.0,
      dailyCapacityKg: 35000.0,
      operatingHours: '০৬:০০ AM - ১১:০০ PM',
      activeShipmentsCount: 65,
      averageRating: 4.93,
    ),

    // Rajshahi & Bogura
    const UpazilaHubModel(
      id: 'hub_rajshahi_paba',
      code: 'HUB-RAJ-PABA-01',
      name: 'পবা এগ্রোলিংক উপজেলা হাব',
      nameEn: 'Paba AgroLink Upazila Hub',
      upazila: 'Paba',
      upazilaBn: 'পবা',
      district: 'Rajshahi',
      districtBn: 'রাজশাহী',
      division: 'Rajshahi',
      divisionBn: 'রাজশাহী',
      latitude: 24.4333,
      longitude: 88.6167,
      managerName: 'মাসুদ রানা',
      managerPhone: '+8801712345030',
      qcOfficerName: 'ড. কামরুল হাসান',
      hasColdStorage: true,
      coldStorageTempC: 3.0,
      dailyCapacityKg: 25000.0,
      operatingHours: '০৬:০০ AM - ০৯:০০ PM',
      activeShipmentsCount: 42,
      averageRating: 4.92,
    ),
    const UpazilaHubModel(
      id: 'hub_bogura_sadar',
      code: 'HUB-BOG-SADAR-01',
      name: 'বগুড়া সদর এগ্রো লজিস্টিকস হাব',
      nameEn: 'Bogura Sadar Agro Logistics Hub',
      upazila: 'Bogura Sadar',
      upazilaBn: 'বগুড়া সদর',
      district: 'Bogura',
      districtBn: 'বগুড়া',
      division: 'Rajshahi',
      divisionBn: 'রাজশাহী',
      latitude: 24.8481,
      longitude: 89.3730,
      managerName: 'জাহিদুল ইসলাম',
      managerPhone: '+8801712345035',
      qcOfficerName: 'মোছাঃ ফাতেমা খাতুন',
      hasColdStorage: true,
      coldStorageTempC: 2.5,
      dailyCapacityKg: 40000.0,
      operatingHours: '০৫:০০ AM - ১১:০০ PM',
      activeShipmentsCount: 74,
      averageRating: 4.96,
    ),
  ];

  /// Get all registered Hubs
  List<UpazilaHubModel> getAllHubs() => List.unmodifiable(_flagshipHubs);

  /// Dynamically resolve Upazila Hub for ANY upazila in Bangladesh
  UpazilaHubModel resolveHubByUpazila(String? upazilaName, {String? districtName}) {
    final upaQuery = (upazilaName ?? '').trim().toLowerCase();
    final distQuery = (districtName ?? '').trim().toLowerCase();

    // 1. Direct match in flagship hubs
    for (var hub in _flagshipHubs) {
      if (hub.upazila.toLowerCase() == upaQuery ||
          hub.upazilaBn == upazilaName ||
          (distQuery.isNotEmpty && hub.district.toLowerCase() == distQuery && upaQuery.isEmpty) ||
          upaQuery.contains(hub.upazila.toLowerCase()) ||
          (upazilaName != null && upazilaName.contains(hub.upazilaBn))) {
        return hub;
      }
    }

    // 2. Resolve via district
    String resolvedDist = districtName ?? '';
    if (resolvedDist.isEmpty && upaQuery.isNotEmpty) {
      resolvedDist = WeatherService.resolveDistrictFromUpazila(upazilaName!);
    }
    if (resolvedDist.isEmpty) resolvedDist = 'Patuakhali';

    String resolvedUpaEn = upaQuery.isNotEmpty ? WeatherService.getEnglishUpazilaName(upazilaName!) : '$resolvedDist Sadar';
    String resolvedUpaBn = upaQuery.isNotEmpty ? WeatherService.getBanglaUpazilaName(upazilaName!) : '${WeatherService.getBanglaUpazilaName(resolvedDist)} সদর';
    String distBn = WeatherService.getBanglaUpazilaName(resolvedDist);

    // Dynamic generated hub
    final codeSlug = resolvedUpaEn.replaceAll(' ', '').toUpperCase();
    final distSlug = resolvedDist.substring(0, min(3, resolvedDist.length)).toUpperCase();

    return UpazilaHubModel(
      id: 'hub_${resolvedDist.toLowerCase()}_${resolvedUpaEn.toLowerCase().replaceAll(' ', '_')}',
      code: 'HUB-$distSlug-$codeSlug-01',
      name: '$resolvedUpaBn এগ্রোলিংক উপজেলা হাব',
      nameEn: '$resolvedUpaEn AgroLink Upazila Hub',
      upazila: resolvedUpaEn,
      upazilaBn: resolvedUpaBn,
      district: resolvedDist,
      districtBn: distBn,
      division: 'Barishal',
      divisionBn: 'বরিশাল',
      latitude: 22.3596 + (Random().nextDouble() * 0.2),
      longitude: 90.3299 + (Random().nextDouble() * 0.2),
      managerName: 'মোঃ আব্দুল্লাহ (হাব ইনচার্জ)',
      managerPhone: '+8801700000000',
      qcOfficerName: 'ড. সারোয়ার জাহান (কিউসি অফিসার)',
      hasColdStorage: true,
      coldStorageTempC: 3.5,
      dailyCapacityKg: 15000.0,
      operatingHours: '০৬:০০ AM - ০৯:০০ PM',
      activeShipmentsCount: 20,
      averageRating: 4.9,
    );
  }

  /// Resolve Nearest Hub by Lat/Lng
  UpazilaHubModel resolveNearestHub(double lat, double lng) {
    UpazilaHubModel nearest = _flagshipHubs.first;
    double minDistance = double.infinity;

    for (var hub in _flagshipHubs) {
      double d = _calculateHaversineDistance(lat, lng, hub.latitude, hub.longitude);
      if (d < minDistance) {
        minDistance = d;
        nearest = hub;
      }
    }
    return nearest;
  }

  /// Calculate Inter-Hub Transport Route, Fare, and Timeline
  InterHubLogisticsQuote calculateInterHubLogistics(
    UpazilaHubModel origin,
    UpazilaHubModel destination,
    double weightKg, {
    bool isPerishable = false,
    bool isColdChain = false,
  }) {
    final double distanceKm = _calculateHaversineDistance(
      origin.latitude,
      origin.longitude,
      destination.latitude,
      destination.longitude,
    );

    // Transit speed averages ~35 km/h on highway logistics routes
    double transitHours = max(1.0, (distanceKm / 35.0) + 1.5); // +1.5 hr sorting/packaging

    // Base fare: ৳40 base + ৳1.5 per km + ৳0.6 per kg
    double baseFare = 40.0 + (distanceKm * 1.5) + (weightKg * 0.6);

    // Packaging fee: ৳20 for tamper-proof crates and barcode sealing
    double packagingFee = 20.0 + (weightKg > 50 ? (weightKg * 0.2) : 0.0);

    // Cold chain premium: +30% if cold storage or perishable fish/berries
    double coldChainFee = (isColdChain || isPerishable) ? (baseFare * 0.35) : 0.0;

    double totalCost = baseFare + packagingFee + coldChainFee;

    final now = DateTime.now();
    final pickupTime = now.add(const Duration(minutes: 45));
    final deliveryTime = now.add(Duration(minutes: (transitHours * 60).round()));

    String formatTime(DateTime dt) {
      int h = dt.hour;
      String ampm = h >= 12 ? 'PM' : 'AM';
      int h12 = h % 12;
      if (h12 == 0) h12 = 12;
      return '$h12:${dt.minute.toString().padLeft(2, '0')} $ampm';
    }

    String vehicleType = (isColdChain || isPerishable)
        ? 'Refrigerated Cold-Chain Van (4°C)'
        : (weightKg > 200 ? 'AgroLink Heavy Cargo Truck' : 'Covered Fast Transit Pickup');
    String vehicleTypeBn = (isColdChain || isPerishable)
        ? 'শীতাতপ নিয়ন্ত্রিত কোল্ড-চেইন ভ্যান (৪° সে)'
        : (weightKg > 200 ? 'এগ্রোলিংক হেভি কার্গো ট্রাক' : 'কাভার্ড ফাস্ট ট্রানজিট পিকআপ');

    return InterHubLogisticsQuote(
      originHub: origin,
      destinationHub: destination,
      distanceKm: distanceKm,
      transitHours: transitHours,
      baseFreightFare: baseFare,
      coldChainFee: coldChainFee,
      packagingFee: packagingFee,
      totalLogisticsCost: totalCost,
      estimatedPickupTime: formatTime(pickupTime),
      estimatedDeliveryTime: formatTime(deliveryTime),
      transportVehicleType: vehicleType,
      transportVehicleTypeBn: vehicleTypeBn,
    );
  }

  /// Generate High-Precision Quality Inspection Report at Hub
  QcInspectionModel generateMockQcInspection(
    String orderId,
    String productName,
    double declaredWeightKg,
    UpazilaHubModel originHub,
  ) {
    final rand = Random();
    double testedWeight = declaredWeightKg * (1.0 + (rand.nextDouble() * 0.02 - 0.01)); // ±1%
    double freshness = 94.0 + (rand.nextDouble() * 5.5); // 94% - 99.5%
    double moisture = 10.5 + (rand.nextDouble() * 3.0); // 10.5% - 13.5%
    double defect = 0.2 + (rand.nextDouble() * 0.8); // 0.2% - 1.0%

    String seal = 'SEAL-AGRO-${100000 + rand.nextInt(899999)}';
    String batch = 'BATCH-${originHub.district.substring(0, 3).toUpperCase()}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    return QcInspectionModel(
      id: 'qc_${DateTime.now().millisecondsSinceEpoch}',
      orderId: orderId,
      batchCode: batch,
      hubId: originHub.id,
      hubName: originHub.name,
      hubNameEn: originHub.nameEn,
      inspectorName: originHub.qcOfficerName,
      inspectedAt: DateTime.now(),
      freshnessScore: double.parse(freshness.toStringAsFixed(1)),
      moisturePercent: double.parse(moisture.toStringAsFixed(1)),
      defectPercent: double.parse(defect.toStringAsFixed(1)),
      testedWeightKg: double.parse(testedWeight.toStringAsFixed(2)),
      declaredWeightKg: declaredWeightKg,
      grade: 'Grade A+ (Super Premium)',
      gradeBn: 'গ্রেড এ+ (সুপার প্রিমিয়াম)',
      isApproved: true,
      packagingType: 'Eco-Ventilated Tamper-Proof Crate with Barcode',
      packagingTypeBn: 'বায়ুচলাচলযুক্ত ইকো-ক্রেট ও বারকোড সিল',
      tamperProofSealCode: seal,
      notes: 'Passed all biochemical, freshness index, and digital weight scale verifications.',
      notesBn: 'বায়ো-কেমিক্যাল টেস্ট, ফ্রেশনেস ইনডেক্স ও ডিজিটাল স্কেল পরীক্ষায় শতভাগ উত্তীর্ণ।',
    );
  }

  /// Save QC Inspection to Firestore
  Future<void> saveQcInspection(QcInspectionModel qc) async {
    try {
      await _firestore.collection('qc_inspections').doc(qc.orderId).set(qc.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('⚠️ Error saving QC inspection: $e');
    }
  }

  /// Get QC Inspection for an order
  Future<QcInspectionModel?> getQcInspectionByOrderId(String orderId) async {
    try {
      final doc = await _firestore.collection('qc_inspections').doc(orderId).get();
      if (doc.exists && doc.data() != null) {
        return QcInspectionModel.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      debugPrint('⚠️ Error fetching QC inspection: $e');
    }
    return null;
  }

  /// Haversine Formula for Distance Calculation (km)
  double _calculateHaversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const double p = 0.017453292519943295; // Pi/180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    double km = 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
    return km < 3.0 ? 5.0 : double.parse(km.toStringAsFixed(1));
  }
}
