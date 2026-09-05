import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:agrolinkbd/core/models/market_price_model.dart';
import 'package:agrolinkbd/core/services/market_price_service.dart';

enum PriceSuggestionType {
  decrease, // Current price is higher than benchmark -> suggest lowering to sell fast
  increase, // Current price is lower than benchmark -> suggest raising to protect profit
  optimal,  // Current price is within +/- 5% of benchmark -> good standing
}

class PriceSuggestion {
  final String itemId;
  final String itemName;
  final String? category;
  final double currentPrice;
  final double benchmarkPrice;
  final double diffPercent;
  final PriceSuggestionType type;
  final double recommendedPrice;
  final String unit;
  final String headlineBn;
  final String headlineEn;
  final String reasonBn;
  final String reasonEn;
  final bool isFishLot;

  PriceSuggestion({
    required this.itemId,
    required this.itemName,
    this.category,
    required this.currentPrice,
    required this.benchmarkPrice,
    required this.diffPercent,
    required this.type,
    required this.recommendedPrice,
    this.unit = 'কেজি',
    required this.headlineBn,
    required this.headlineEn,
    required this.reasonBn,
    required this.reasonEn,
    this.isFishLot = false,
  });
}

class MarketPriceAdvisoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MarketPriceService _marketPriceService = MarketPriceService();

  /// Stream latest Super Admin price command from `admin_price_logs`
  Stream<Map<String, dynamic>?> streamLatestAdminCommand() {
    return _firestore
        .collection('admin_price_logs')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return {
        ...snapshot.docs.first.data(),
        'id': snapshot.docs.first.id,
      };
    });
  }

  /// Stream current benchmark rates from `market_prices`
  Stream<List<MarketPriceModel>> streamBenchmarks() {
    return _marketPriceService.streamCurrentMarketPrices();
  }

  /// Match a product or fish species name against benchmark list
  MarketPriceModel? findMatchingBenchmark(String itemName, List<MarketPriceModel> benchmarks, {String? category}) {
    if (benchmarks.isEmpty || itemName.trim().isEmpty) return null;

    final query = itemName.trim().toLowerCase();

    // 1. Direct name match (Bengali or English)
    for (final b in benchmarks) {
      final bName = b.productName.toLowerCase();
      final bId = b.id.toLowerCase();
      if (query == bName || query == bId || bName.contains(query) || query.contains(bName)) {
        return b;
      }
    }

    // 2. Keyword normalization for common species & produce
    final Map<String, List<String>> aliases = {
      'rui_fish': ['রুই', 'রুই মাছ', 'rui', 'rohu', 'কার্প'],
      'katla_fish': ['কাতলা', 'কাতল', 'katla', 'catla'],
      'mrigel_fish': ['মৃগেল', 'মৃগেল মাছ', 'mrigel'],
      'pangas_fish': ['পাঙ্গাস', 'পাঙ্গাশ', 'pangas', 'pangash'],
      'tilapia_fish': ['তেলাপিয়া', 'তেলাপিয়া মাছ', 'tilapia'],
      'shrimp': ['চিংড়ি', 'বাগদা', 'গলদা', 'shrimp', 'prawn'],
      'shing_fish': ['শিং', 'শিং মাছ', 'shing', 'singhi'],
      'magur_fish': ['মাগুর', 'মাগুর মাছ', 'magur'],
      'pabda_fish': ['পাবদা', 'পাবদা মাছ', 'pabda'],
      'tomato': ['টমেটো', 'tomato'],
      'potato': ['আলু', 'potato'],
      'onion': ['পেঁয়াজ', 'পিয়াজ', 'onion'],
      'chilli': ['মরিচ', 'কাঁচা মরিচ', 'chilli', 'pepper'],
      'rice': ['চাল', 'ধান', 'মিনিকেট', 'নাজিরশাইল', 'rice', 'paddy'],
      'mango': ['আম', 'হিমসাগর', 'ল্যাংড়া', 'আম্রপালি', 'mango'],
    };

    for (final entry in aliases.entries) {
      final key = entry.key;
      final matchWords = entry.value;
      if (matchWords.any((w) => query.contains(w.toLowerCase()))) {
        final found = benchmarks.firstWhere(
          (b) => b.id.toLowerCase().contains(key) || b.productName.toLowerCase().contains(matchWords.first),
          orElse: () => benchmarks.firstWhere(
            (b) => matchWords.any((w) => b.productName.toLowerCase().contains(w)),
            orElse: () => benchmarks.first,
          ),
        );
        return found;
      }
    }

    // 3. Category match fallback
    if (category != null && category.isNotEmpty) {
      final catMatches = benchmarks.where((b) => b.category.toLowerCase() == category.toLowerCase()).toList();
      if (catMatches.isNotEmpty) return catMatches.first;
    }

    return null;
  }

  /// Analyze a given item price against benchmarks and yield a clear suggestion
  PriceSuggestion analyzePrice({
    required String itemId,
    required String itemName,
    required double currentPrice,
    required List<MarketPriceModel> benchmarks,
    String? category,
    String unit = 'কেজি',
    bool isFishLot = false,
  }) {
    final benchmark = findMatchingBenchmark(itemName, benchmarks, category: category);

    if (benchmark == null || benchmark.currentPrice <= 0) {
      return PriceSuggestion(
        itemId: itemId,
        itemName: itemName,
        category: category,
        currentPrice: currentPrice,
        benchmarkPrice: currentPrice,
        diffPercent: 0,
        type: PriceSuggestionType.optimal,
        recommendedPrice: currentPrice,
        unit: unit,
        headlineBn: '✅ বাজারদরের তথ্য পাওয়া যায়নি',
        headlineEn: '✅ No Benchmark Available',
        reasonBn: 'এই পণ্যের নির্দিষ্ট সুপার এডমিন বেঞ্চমার্ক মূল্য নির্ধারণাধীন রয়েছে।',
        reasonEn: 'No benchmark price is set for this specific produce yet.',
        isFishLot: isFishLot,
      );
    }

    final double benchmarkPrice = benchmark.currentPrice;
    final double diff = currentPrice - benchmarkPrice;
    final double diffPercent = (diff / benchmarkPrice) * 100;

    if (diffPercent > 5.0) {
      // Overpriced: Suggest decrease to prevent spoilage / unsold lots
      return PriceSuggestion(
        itemId: itemId,
        itemName: itemName,
        category: category ?? benchmark.category,
        currentPrice: currentPrice,
        benchmarkPrice: benchmarkPrice,
        diffPercent: diffPercent,
        type: PriceSuggestionType.decrease,
        recommendedPrice: benchmarkPrice,
        unit: benchmark.unit,
        headlineBn: '📉 দাম কমানোর পরামর্শ',
        headlineEn: '📉 Suggest Price Decrease',
        reasonBn: 'বর্তমান বাজারদর ৳${benchmarkPrice.toStringAsFixed(0)}/${benchmark.unit}। আপনার নির্ধারিত মূল্য ${diffPercent.abs().toStringAsFixed(0)}% বেশি। সরবরাহ আধিক্য বা বাজার ধসে দ্রুত বিক্রির জন্য দর কমানোর সুপারিশ করা হচ্ছে।',
        reasonEn: 'Market rate is ৳${benchmarkPrice.toStringAsFixed(0)}/${benchmark.unit}. Your price is ${diffPercent.abs().toStringAsFixed(0)}% above market. Lower your price to clear inventory fast.',
        isFishLot: isFishLot,
      );
    } else if (diffPercent < -5.0) {
      // Underpriced: Suggest increase to protect farmer profit
      return PriceSuggestion(
        itemId: itemId,
        itemName: itemName,
        category: category ?? benchmark.category,
        currentPrice: currentPrice,
        benchmarkPrice: benchmarkPrice,
        diffPercent: diffPercent,
        type: PriceSuggestionType.increase,
        recommendedPrice: benchmarkPrice,
        unit: benchmark.unit,
        headlineBn: '📈 দাম বাড়ানোর পরামর্শ',
        headlineEn: '📈 Suggest Price Increase',
        reasonBn: 'বর্তমান বাজারদর বেড়ে ৳${benchmarkPrice.toStringAsFixed(0)}/${benchmark.unit} হয়েছে। আপনি ${diffPercent.abs().toStringAsFixed(0)}% কম দামে বিক্রি করছেন—ন্যায্যমূল্য নিশ্চিত ও লোকসান এড়াতে দর বাড়ানোর সুপারিশ করা হচ্ছে।',
        reasonEn: 'Market rate has rallied to ৳${benchmarkPrice.toStringAsFixed(0)}/${benchmark.unit}. You are selling ${diffPercent.abs().toStringAsFixed(0)}% below market. Raise your price to earn fair profit.',
        isFishLot: isFishLot,
      );
    } else {
      // Optimal price within 5%
      return PriceSuggestion(
        itemId: itemId,
        itemName: itemName,
        category: category ?? benchmark.category,
        currentPrice: currentPrice,
        benchmarkPrice: benchmarkPrice,
        diffPercent: diffPercent,
        type: PriceSuggestionType.optimal,
        recommendedPrice: currentPrice,
        unit: benchmark.unit,
        headlineBn: '✅ বাজারদরের সাথে সামঞ্জস্যপূর্ণ',
        headlineEn: '✅ Optimal Market Price',
        reasonBn: 'আপনার পণ্যের দর বর্তমান সুপার এডমিন বেঞ্চমার্ক হারের সাথে শতভাগ মানানসই।',
        reasonEn: 'Your product is priced in perfect alignment with current market rates.',
        isFishLot: isFishLot,
      );
    }
  }

  /// Stream suggestions for an Agri Farmer's active crops
  Stream<List<PriceSuggestion>> streamFarmerAgriSuggestions(String farmerId) {
    return _firestore
        .collection('products')
        .where('farmerId', isEqualTo: farmerId)
        .snapshots()
        .asyncMap((productSnap) async {
      final benchmarks = await _marketPriceService.fetchCurrentMarketPrices();

      final List<PriceSuggestion> suggestions = [];
      for (final doc in productSnap.docs) {
        final data = doc.data();
        final status = data['status'] as String? ?? '';
        // Skip unavailable or sold out items
        if (status.contains('sold') || status.contains('inactive')) continue;

        final String name = data['cropName'] as String? ?? data['name'] as String? ?? '';
        final double price = (data['price'] as num?)?.toDouble() ?? 0.0;
        final String? cat = data['category'] as String?;
        final String unit = data['unit'] as String? ?? 'কেজি';

        if (price > 0 && name.isNotEmpty) {
          final suggestion = analyzePrice(
            itemId: doc.id,
            itemName: name,
            currentPrice: price,
            benchmarks: benchmarks,
            category: cat,
            unit: unit,
            isFishLot: false,
          );
          suggestions.add(suggestion);
        }
      }
      return suggestions;
    });
  }

  /// Stream suggestions for a Fish Farmer's active lots
  Stream<List<PriceSuggestion>> streamFishFarmerLotSuggestions(String farmerId) {
    return _firestore
        .collection('fish_marketplace_lots')
        .where('farmerId', isEqualTo: farmerId)
        .snapshots()
        .asyncMap((lotSnap) async {
      final benchmarks = await _marketPriceService.fetchCurrentMarketPrices();

      final List<PriceSuggestion> suggestions = [];
      for (final doc in lotSnap.docs) {
        final data = doc.data();
        final status = data['status'] as String? ?? 'active';
        if (status != 'active') continue;

        final String species = data['fishType'] as String? ?? '';
        final double pricePerKg = (data['pricePerKg'] as num?)?.toDouble() ?? 0.0;

        if (pricePerKg > 0 && species.isNotEmpty) {
          final suggestion = analyzePrice(
            itemId: doc.id,
            itemName: species,
            currentPrice: pricePerKg,
            benchmarks: benchmarks,
            category: 'fish',
            unit: 'কেজি',
            isFishLot: true,
          );
          suggestions.add(suggestion);
        }
      }
      return suggestions;
    });
  }

  /// Apply suggested price directly to Firebase Firestore
  Future<bool> applySuggestedPrice({
    required String itemId,
    required double newPrice,
    required bool isFishLot,
  }) async {
    try {
      if (isFishLot) {
        await _firestore.collection('fish_marketplace_lots').doc(itemId).update({
          'pricePerKg': newPrice,
          'lastSuggestedPriceApplied': newPrice,
          'adminPriceSyncAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await _firestore.collection('products').doc(itemId).update({
          'price': newPrice,
          'lastSuggestedPriceApplied': newPrice,
          'adminPriceSyncAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      debugPrint('✅ Suggested price (৳$newPrice) successfully applied to item: $itemId');
      return true;
    } catch (e) {
      debugPrint('❌ Error applying suggested price: $e');
      return false;
    }
  }
}
