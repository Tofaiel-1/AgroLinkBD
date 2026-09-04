import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/fish_auction_model.dart';
import '../models/fish_harvest_contract_model.dart';
import '../models/fish_rfq_model.dart';
import '../models/fish_transport_model.dart';

class FishAuctionService extends GetxController {
  static FishAuctionService get to => Get.find<FishAuctionService>();

  final RxList<FishAuctionModel> auctions = <FishAuctionModel>[].obs;
  final RxList<FishHarvestContractModel> contracts = <FishHarvestContractModel>[].obs;
  final RxList<FishRfqModel> rfqs = <FishRfqModel>[].obs;
  final RxList<FishTransportBookingModel> transportBookings = <FishTransportBookingModel>[].obs;

  // VIP Auction Access for Buyers
  final RxBool hasVipAuctionAccess = false.obs;
  final Rx<DateTime?> vipExpiryDate = Rx<DateTime?>(null);
  final RxString vipPlanName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSampleAuctions();
    _loadSampleContracts();
    _loadSampleRfqs();
    _loadSampleTransport();
    _initFirestoreAuctionStream();
    checkCurrentUserVipStatus();
  }

  void _initFirestoreAuctionStream() {
    try {
      FirebaseFirestore.instance
          .collection('fish_auctions')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final List<FishAuctionModel> firestoreAuctions = [];
          for (var doc in snapshot.docs) {
            try {
              final data = doc.data();
              data['id'] = doc.id;
              firestoreAuctions.add(FishAuctionModel.fromJson(data));
            } catch (e) {
              // Parse fallback
            }
          }

          // Merge with sample auctions (avoiding duplicate IDs)
          final existingIds = firestoreAuctions.map((a) => a.id).toSet();
          final remainingSamples = _sampleAuctions.where((a) => !existingIds.contains(a.id)).toList();
          auctions.assignAll([...firestoreAuctions, ...remainingSamples]);
        }
      }, onError: (err) {
        // Fallback to sample data
      });
    } catch (_) {}
  }

  Future<bool> checkCurrentUserVipStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      hasVipAuctionAccess.value = false;
      return false;
    }
    return checkUserVipStatus(user.uid);
  }

  Future<bool> checkUserVipStatus(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('auction_memberships').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final expiresAtStr = data['expiresAt'] as String?;
        if (expiresAtStr != null) {
          final expiry = DateTime.tryParse(expiresAtStr);
          if (expiry != null && expiry.isAfter(DateTime.now())) {
            hasVipAuctionAccess.value = true;
            vipExpiryDate.value = expiry;
            vipPlanName.value = (data['planName'] as String?) ?? 'VIP Auction Pass';
            return true;
          }
        }
      }

      // Check user document flag as well
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data()!;
        if (userData['hasLiveAuctionAccess'] == true) {
          hasVipAuctionAccess.value = true;
          vipPlanName.value = 'VIP Wholesale Bidder';
          return true;
        }
      }

      hasVipAuctionAccess.value = false;
      return false;
    } catch (_) {
      return hasVipAuctionAccess.value;
    }
  }

  Future<bool> activateVipMembership({
    required String uid,
    required String userName,
    required String userPhone,
    required String userEmail,
    required String planId,
    required String planName,
    required double price,
    required int durationDays,
  }) async {
    try {
      final now = DateTime.now();
      final expiresAt = now.add(Duration(days: durationDays));

      await FirebaseFirestore.instance.collection('auction_memberships').doc(uid).set({
        'userId': uid,
        'userName': userName,
        'userPhone': userPhone,
        'userEmail': userEmail,
        'planId': planId,
        'planName': planName,
        'amountPaid': price,
        'paymentGateway': 'SSLCommerz',
        'status': 'active',
        'activatedAt': now.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'hasLiveAuctionAccess': true,
        'auctionMembershipTier': planName,
        'auctionMembershipExpiresAt': expiresAt.toIso8601String(),
      }, SetOptions(merge: true));

      hasVipAuctionAccess.value = true;
      vipExpiryDate.value = expiresAt;
      vipPlanName.value = planName;
      return true;
    } catch (e) {
      // Local activation fallback
      hasVipAuctionAccess.value = true;
      vipExpiryDate.value = DateTime.now().add(Duration(days: durationDays));
      vipPlanName.value = planName;
      return true;
    }
  }

  final List<FishAuctionModel> _sampleAuctions = [
    FishAuctionModel(
      id: 'AUC-FISH-101',
      farmerId: 'farmer_01',
      farmerName: 'মোঃ আব্দুল কুদ্দুস',
      farmerPhone: '01711223344',
      farmLocation: 'চলনবিল অ্যাগ্রো ফিশারিজ, নাটোর',
      district: 'নাটোর',
      upazila: 'সিংড়া',
      fishSpecies: 'দেশি রুই ও কাতলা (মিক্সড)',
      lotTitle: 'পুকুর-১ এর ৮০০ কেজি জ্যান্ত রুই ও কাতলা লট',
      estimatedTotalKg: 800.0,
      avgWeightGram: 1800.0,
      condition: FishCondition.liveInWater,
      grade: 'Grade A+ (তাজা জ্যান্ত)',
      images: [
        'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788505454/images_jzjue9.jpg',
        'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788505305/images_l53fvw.jpg',
      ],
      startingPricePerKg: 320.0,
      reservePricePerKg: 360.0,
      minBidIncrement: 5.0,
      currentHighestBidPerKg: 355.0,
      highestBidderId: 'buyer_01',
      highestBidderName: 'মেসার্স ভাই ভাই মৎস্য আড়ত, যাত্রাবাড়ী',
      startTime: DateTime.now().subtract(const Duration(hours: 4)),
      endTime: DateTime.now().add(const Duration(hours: 18)),
      status: FishAuctionStatus.live,
      providesOxygenTransport: true,
      description: '১০০% প্রাকৃতিক খাদ্য ও খৈল দিয়ে বড় করা। সরাসরি পুকুর সেচে জ্যান্ত ড্রামে সরবরাহ করা হবে।',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      bids: [
        FishBid(
          id: 'BID-01',
          bidderId: 'buyer_02',
          bidderName: 'আল-মদিনা ফিশ মার্ট, মিরপুর',
          bidderPhone: '01819001122',
          bidAmountPerKg: 330.0,
          totalBidAmount: 330.0 * 800,
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        FishBid(
          id: 'BID-02',
          bidderId: 'buyer_03',
          bidderName: 'কাওরান বাজার মেগা পাইকার',
          bidderPhone: '01912345678',
          bidAmountPerKg: 345.0,
          totalBidAmount: 345.0 * 800,
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        FishBid(
          id: 'BID-03',
          bidderId: 'buyer_01',
          bidderName: 'মেসার্স ভাই ভাই মৎস্য আড়ত, যাত্রাবাড়ী',
          bidderPhone: '01715998877',
          bidAmountPerKg: 355.0,
          totalBidAmount: 355.0 * 800,
          timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
          isWinning: true,
        ),
      ],
    ),
    FishAuctionModel(
      id: 'AUC-FISH-102',
      farmerId: 'farmer_02',
      farmerName: 'হাজী রফিকুল ইসলাম',
      farmerPhone: '01988776655',
      farmLocation: 'শ্যামনগর বাগদা ঘের, সাতক্ষীরা',
      district: 'সাতক্ষীরা',
      upazila: 'শ্যামনগর',
      fishSpecies: 'রপ্তানি গ্রেড বাগদা চিংড়ি',
      lotTitle: 'সাতক্ষীরার তাজা বাগদা চিংড়ি (৩০০ কেজি লট)',
      estimatedTotalKg: 300.0,
      avgWeightGram: 45.0,
      condition: FishCondition.icedFresh,
      grade: 'Export Grade 1',
      images: [
        'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788505088/images_yhiizh.jpg',
      ],
      startingPricePerKg: 850.0,
      reservePricePerKg: 920.0,
      minBidIncrement: 10.0,
      currentHighestBidPerKg: 910.0,
      highestBidderId: 'buyer_exp_01',
      highestBidderName: 'বেঙ্গল সি-ফুড প্রসেসিং লিমিটেড',
      startTime: DateTime.now().subtract(const Duration(hours: 8)),
      endTime: DateTime.now().add(const Duration(hours: 14)),
      status: FishAuctionStatus.live,
      providesOxygenTransport: false,
      description: 'ঘের থেকে ভোরে আহরিত আন্তর্জাতিক মানসম্পন্ন বাগদা চিংড়ি। বরফ ঢাকা অবস্থায় ডেলিভারি।',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      bids: [
        FishBid(
          id: 'BID-04',
          bidderId: 'buyer_exp_01',
          bidderName: 'বেঙ্গল সি-ফুড প্রসেসিং লিমিটেড',
          bidderPhone: '01711000000',
          bidAmountPerKg: 910.0,
          totalBidAmount: 910.0 * 300,
          timestamp: DateTime.now().subtract(const Duration(minutes: 50)),
          isWinning: true,
        ),
      ],
    ),
    FishAuctionModel(
      id: 'AUC-FISH-103',
      farmerId: 'farmer_03',
      farmerName: 'কামাল হোসেন বায়োফ্লক',
      farmerPhone: '01677889900',
      farmLocation: 'ত্রিশাল অ্যাকোয়া হাব, ময়মনসিংহ',
      district: 'ময়মনসিংহ',
      upazila: 'ত্রিশাল',
      fishSpecies: 'বায়োফ্লক তাজা শিং ও পাবদা',
      lotTitle: '৪৫০ কেজি জ্যান্ত দেশি শিং ও পাবদা মাছ',
      estimatedTotalKg: 450.0,
      avgWeightGram: 120.0,
      condition: FishCondition.liveInWater,
      grade: 'Grade A',
      images: [
        'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788505500/images_f9axtg.jpg',
      ],
      startingPricePerKg: 420.0,
      reservePricePerKg: 460.0,
      minBidIncrement: 5.0,
      currentHighestBidPerKg: 440.0,
      highestBidderId: 'buyer_05',
      highestBidderName: 'ঢাকা প্রিমিয়াম ফিশ বাজার',
      startTime: DateTime.now().subtract(const Duration(hours: 1)),
      endTime: DateTime.now().add(const Duration(hours: 22)),
      status: FishAuctionStatus.live,
      providesOxygenTransport: true,
      description: '১০০% জীবন্ত শিং ও পাবদা মাছ। অক্সিজেন ট্যাংকে অক্ষত অবস্থায় ঢাকা পৌঁছে দেওয়া হবে।',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    FishAuctionModel(
      id: 'AUC-FISH-104',
      farmerId: 'farmer_04',
      farmerName: 'চাঁদপুর রিভার ক্যাচ কো-অপারেটিভ',
      farmerPhone: '01711002233',
      farmLocation: 'চাঁদপুর মোহনা ফিশারি ঘাট',
      district: 'চাঁদপুর',
      upazila: 'চাঁদপুর সদর',
      fishSpecies: 'পদ্মার তাজা রূপালী ইলিশ',
      lotTitle: 'চাঁদপুর মোহনার পদ্মার ইলিশ (৫০০ কেজি লট ১.৩-১.৫ কেজি সাইজ)',
      estimatedTotalKg: 500.0,
      avgWeightGram: 1400.0,
      condition: FishCondition.icedFresh,
      grade: 'Grade A+ Padma Fresh',
      images: [
        'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788504670/images_qbleou.jpg',
        'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788505394/images_yr8obg.jpg',
      ],
      startingPricePerKg: 1350.0,
      reservePricePerKg: 1450.0,
      minBidIncrement: 20.0,
      currentHighestBidPerKg: 1420.0,
      highestBidderId: 'buyer_mega_01',
      highestBidderName: 'কারওয়ান বাজার সেন্ট্রাল ফিশ মার্কেট',
      startTime: DateTime.now().subtract(const Duration(hours: 2)),
      endTime: DateTime.now().add(const Duration(hours: 10)),
      status: FishAuctionStatus.live,
      providesOxygenTransport: false,
      description: 'আজ ভোরে চাঁদপুর মোহনা থেকে আহরিত ১০০% ফরমালিনমুক্ত টাটকা চকচকে রূপালী ইলিশের পাইকারি লট।',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  void _loadSampleAuctions() {
    auctions.assignAll(_sampleAuctions);
  }

  void _loadSampleContracts() {
    contracts.assignAll([
      FishHarvestContractModel(
        id: 'CNT-FISH-201',
        farmerId: 'farmer_01',
        farmerName: 'মোঃ আব্দুল কুদ্দুস',
        farmerPhone: '01711223344',
        pondId: 'POND-01',
        pondName: 'পুকুর-২ (বড় দিঘি)',
        location: 'সিংড়া, নাটোর',
        district: 'নাটোর',
        fishSpecies: 'দেশি কাতলা ও ব্রিগেড',
        estimatedYieldKg: 1500.0,
        targetAvgWeightGram: 2500.0,
        expectedHarvestDate: DateTime.now().add(const Duration(days: 28)),
        agreedPricePerKg: 380.0,
        advancePercentage: 25.0,
        status: FishContractStatus.openForBidding,
        waterQualityReport: 'pH 7.6, অ্যামোনিয়া ০.০ ppm, নিয়মিত প্লাঙ্কটন সমৃদ্ধ',
        feedingProtocol: 'মেগা ফ্লোটিং ফিড ও খৈল-কুঁড়া মিশ্রণ',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      FishHarvestContractModel(
        id: 'CNT-FISH-202',
        farmerId: 'farmer_02',
        farmerName: 'সাতক্ষীরা ঘের মালিক সমিতি',
        farmerPhone: '01712334455',
        pondId: 'POND-03',
        pondName: 'ঘের নং-৫',
        location: 'কালিগঞ্জ, সাতক্ষীরা',
        district: 'সাতক্ষীরা',
        fishSpecies: 'গলদা ও বাগদা চিংড়ি',
        estimatedYieldKg: 600.0,
        targetAvgWeightGram: 80.0,
        expectedHarvestDate: DateTime.now().add(const Duration(days: 15)),
        agreedPricePerKg: 950.0,
        advancePercentage: 30.0,
        buyerId: 'buyer_exp_01',
        buyerName: 'বেঙ্গল সি-ফুড লিমিটেড',
        buyerPhone: '01711000000',
        advancePaidAmount: 171000.0,
        status: FishContractStatus.depositPaid,
        waterQualityReport: 'লবণাক্ততা ১৫ ppt, দ্রবীভূত অক্সিজেন ৭.২ ppm',
        feedingProtocol: 'সিপি প্রিমিয়াম চিংড়ি ফিড',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ]);
  }

  void _loadSampleRfqs() {
    rfqs.assignAll([
      FishRfqModel(
        id: 'RFQ-FISH-301',
        buyerId: 'buyer_rest_01',
        buyerName: 'ক্যাফে রিও ও গ্র্যান্ড রেস্তোরাঁ গ্রুপ',
        buyerPhone: '01719887766',
        buyerType: 'রেস্তোরাঁ চেইন',
        destinationAddress: 'ধানমন্ডি ২৭, ঢাকা',
        destinationDistrict: 'ঢাকা',
        fishSpecies: 'জ্যান্ত দেশি রুই (১.৫ - ২ কেজি)',
        requiredQuantityKg: 500.0,
        minAvgWeightGram: 1500.0,
        requiresLiveFish: true,
        targetBudgetPerKg: 340.0,
        deliveryDeadline: DateTime.now().add(const Duration(days: 3)),
        status: FishRfqStatus.open,
        notes: 'প্রতি শুক্রবার সকালে জ্যান্ত অবস্থায় ডেলিভারি নিশ্চিত করতে হবে। এসক্রো পেমেন্ট অগ্রিম রেডি।',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        quotes: [
          FishFarmerQuote(
            id: 'Q-01',
            farmerId: 'farmer_01',
            farmerName: 'মোঃ আব্দুল কুদ্দুস',
            farmerPhone: '01711223344',
            farmLocation: 'সিংড়া, নাটোর',
            offeredPricePerKg: 345.0,
            availableQuantityKg: 500.0,
            avgWeightGram: 1600.0,
            isLiveInWater: true,
            message: 'আমাদের নিজস্ব অক্সিজেন ভ্যানে সকালে ডেলিভারি দেওয়া সম্ভব।',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          ),
        ],
      ),
      FishRfqModel(
        id: 'RFQ-FISH-302',
        buyerId: 'buyer_super_01',
        buyerName: 'স্বপ্নের বাজার চেইন',
        buyerPhone: '01811223344',
        buyerType: 'সুপারশপ',
        destinationAddress: 'তেজগাঁও সেন্ট্রাল ওয়্যারহাউস, ঢাকা',
        destinationDistrict: 'ঢাকা',
        fishSpecies: 'তাজা পাঙ্গাশ (বড় সাইজ ২.৫ কেজি+)',
        requiredQuantityKg: 1200.0,
        minAvgWeightGram: 2500.0,
        requiresLiveFish: false,
        targetBudgetPerKg: 180.0,
        deliveryDeadline: DateTime.now().add(const Duration(days: 4)),
        status: FishRfqStatus.open,
        notes: 'মাটিমুক্ত গন্ধহীন পুকুরে চাষকৃত বড় পাঙ্গাশ বরফ দিয়ে ডেলিভারি দিতে হবে।',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ]);
  }

  void _loadSampleTransport() {
    transportBookings.assignAll([
      FishTransportBookingModel(
        id: 'TR-FISH-401',
        userId: 'farmer_01',
        userName: 'মোঃ আব্দুল কুদ্দুস',
        userPhone: '01711223344',
        vehicleType: FishVehicleType.oxygenPickup,
        pickupLocation: 'সিংড়া বাজার, নাটোর',
        pickupDistrict: 'নাটোর',
        dropoffLocation: 'যাত্রাবাড়ী আড়ত, ঢাকা',
        dropoffDistrict: 'ঢাকা',
        fishType: 'জ্যান্ত রুই ও কাতলা',
        fishWeightKg: 800.0,
        isLiveFish: true,
        pickupTime: DateTime.now().add(const Duration(hours: 6)),
        estimatedDistanceKm: 210.0,
        estimatedCost: 8500.0,
        driverId: 'driver_01',
        driverName: 'মোঃ বাবুল হোসেন',
        driverPhone: '01712998877',
        vehicleNumber: 'ঢাকা মেট্রো-ন ১১-২২৩৩ (অক্সিজেন ভ্যান)',
        status: FishTransportStatus.driverAssigned,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ]);
  }

  // --- ACTIONS ---

  Future<void> addAuction(FishAuctionModel auction) async {
    auctions.insert(0, auction);
    try {
      await FirebaseFirestore.instance
          .collection('fish_auctions')
          .doc(auction.id)
          .set(auction.toJson());
    } catch (_) {}
  }

  Future<bool> placeBid({
    required String auctionId,
    required String bidderId,
    required String bidderName,
    required String bidderPhone,
    String? bidderOrganization,
    required double bidAmountPerKg,
  }) async {
    final index = auctions.indexWhere((a) => a.id == auctionId);
    if (index == -1) return false;

    final auction = auctions[index];
    final currentBest = auction.currentHighestBidPerKg ?? auction.startingPricePerKg;

    if (bidAmountPerKg < currentBest + auction.minBidIncrement) {
      return false;
    }

    final newBid = FishBid(
      id: 'BID-${DateTime.now().millisecondsSinceEpoch}',
      bidderId: bidderId,
      bidderName: bidderName,
      bidderPhone: bidderPhone,
      bidderOrganization: bidderOrganization,
      bidAmountPerKg: bidAmountPerKg,
      totalBidAmount: bidAmountPerKg * auction.estimatedTotalKg,
      timestamp: DateTime.now(),
      isWinning: true,
    );

    // Update existing bids winning flag
    final List<FishBid> updatedBids = auction.bids.map<FishBid>((b) => FishBid(
      id: b.id,
      bidderId: b.bidderId,
      bidderName: b.bidderName,
      bidderPhone: b.bidderPhone,
      bidderOrganization: b.bidderOrganization,
      bidAmountPerKg: b.bidAmountPerKg,
      totalBidAmount: b.totalBidAmount,
      timestamp: b.timestamp,
      isWinning: false,
    )).toList();

    updatedBids.insert(0, newBid);

    auction.currentHighestBidPerKg = bidAmountPerKg;
    auction.highestBidderId = bidderId;
    auction.highestBidderName = bidderName;

    auctions[index] = FishAuctionModel(
      id: auction.id,
      farmerId: auction.farmerId,
      farmerName: auction.farmerName,
      farmerPhone: auction.farmerPhone,
      farmLocation: auction.farmLocation,
      district: auction.district,
      upazila: auction.upazila,
      fishSpecies: auction.fishSpecies,
      lotTitle: auction.lotTitle,
      estimatedTotalKg: auction.estimatedTotalKg,
      avgWeightGram: auction.avgWeightGram,
      condition: auction.condition,
      grade: auction.grade,
      images: auction.images,
      videoUrl: auction.videoUrl,
      startingPricePerKg: auction.startingPricePerKg,
      reservePricePerKg: auction.reservePricePerKg,
      minBidIncrement: auction.minBidIncrement,
      currentHighestBidPerKg: bidAmountPerKg,
      highestBidderId: bidderId,
      highestBidderName: bidderName,
      startTime: auction.startTime,
      endTime: auction.endTime,
      status: auction.status,
      bids: updatedBids,
      providesOxygenTransport: auction.providesOxygenTransport,
      description: auction.description,
      createdAt: auction.createdAt,
    );

    auctions.refresh();

    // Async sync to Firestore
    try {
      await FirebaseFirestore.instance.collection('fish_auctions').doc(auctionId).set({
        'currentHighestBidPerKg': bidAmountPerKg,
        'highestBidderId': bidderId,
        'highestBidderName': bidderName,
        'bids': updatedBids.map((b) => b.toJson()).toList(),
      }, SetOptions(merge: true));
    } catch (_) {}

    return true;
  }

  void addContract(FishHarvestContractModel contract) {
    contracts.insert(0, contract);
  }

  void addRfq(FishRfqModel rfq) {
    rfqs.insert(0, rfq);
  }

  void submitRfqQuote(String rfqId, FishFarmerQuote quote) {
    final index = rfqs.indexWhere((r) => r.id == rfqId);
    if (index != -1) {
      final rfq = rfqs[index];
      final newQuotes = List<FishFarmerQuote>.from(rfq.quotes)..add(quote);
      rfqs[index] = FishRfqModel(
        id: rfq.id,
        buyerId: rfq.buyerId,
        buyerName: rfq.buyerName,
        buyerPhone: rfq.buyerPhone,
        buyerType: rfq.buyerType,
        destinationAddress: rfq.destinationAddress,
        destinationDistrict: rfq.destinationDistrict,
        fishSpecies: rfq.fishSpecies,
        requiredQuantityKg: rfq.requiredQuantityKg,
        minAvgWeightGram: rfq.minAvgWeightGram,
        requiresLiveFish: rfq.requiresLiveFish,
        targetBudgetPerKg: rfq.targetBudgetPerKg,
        deliveryDeadline: rfq.deliveryDeadline,
        status: FishRfqStatus.bidsReceived,
        quotes: newQuotes,
        acceptedQuoteId: rfq.acceptedQuoteId,
        notes: rfq.notes,
        createdAt: rfq.createdAt,
      );
      rfqs.refresh();
    }
  }

  void addTransportBooking(FishTransportBookingModel booking) {
    transportBookings.insert(0, booking);
  }
}
