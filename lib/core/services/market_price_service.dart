import 'package:agrolinkbd/core/models/market_price_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class MarketPriceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Baseline prices — used ONLY when Firestore `market_prices` collection is empty
  final List<MarketPriceModel> _baselinePrices = [
    MarketPriceModel(id: 'tomato', productName: 'টমেটো', category: 'vegetables', currentPrice: 80.0, previousPrice: 80.0, unit: 'কেজি', trend: PriceTrend.stable, updatedAt: DateTime.now(), location: 'সারা বাংলাদেশ', imageUrl: 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782757091/Tomato_hcjt7o.png'),
    MarketPriceModel(id: 'potato', productName: 'আলু', category: 'vegetables', currentPrice: 40.0, previousPrice: 40.0, unit: 'কেজি', trend: PriceTrend.stable, updatedAt: DateTime.now(), location: 'সারা বাংলাদেশ', imageUrl: 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782584736/Screenshot_2026-06-28_002524_ziwqmo.png'),
    MarketPriceModel(id: 'onion', productName: 'পেঁয়াজ', category: 'vegetables', currentPrice: 90.0, previousPrice: 90.0, unit: 'কেজি', trend: PriceTrend.stable, updatedAt: DateTime.now(), location: 'সারা বাংলাদেশ', imageUrl: 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782757375/images_z5w9hg.jpg'),
    MarketPriceModel(id: 'chilli', productName: 'কাঁচা মরিচ', category: 'spices', currentPrice: 150.0, previousPrice: 150.0, unit: 'কেজি', trend: PriceTrend.stable, updatedAt: DateTime.now(), location: 'সারা বাংলাদেশ', imageUrl: 'https://images.unsplash.com/photo-1587889115792-c9d300fb2f6b?q=80&w=600&auto=format&fit=crop'),
    MarketPriceModel(id: 'rice', productName: 'চাল (মিনিকেট)', category: 'grains', currentPrice: 70.0, previousPrice: 70.0, unit: 'কেজি', trend: PriceTrend.stable, updatedAt: DateTime.now(), location: 'সারা বাংলাদেশ', imageUrl: 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782584453/Screenshot_2026-06-28_002037_e5q6ll.png'),
    MarketPriceModel(id: 'mango', productName: 'আম (হিমসাগর)', category: 'fruits', currentPrice: 100.0, previousPrice: 100.0, unit: 'কেজি', trend: PriceTrend.stable, updatedAt: DateTime.now(), location: 'সারা বাংলাদেশ', imageUrl: 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782583216/image_sxwwpa.png'),
    MarketPriceModel(id: 'rui_fish', productName: 'রুই মাছ', category: 'fish', currentPrice: 350.0, previousPrice: 350.0, unit: 'কেজি', trend: PriceTrend.stable, updatedAt: DateTime.now(), location: 'সারা বাংলাদেশ', imageUrl: 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782734272/Screenshot_2026-06-29_175728_q4k1bk.png'),
    MarketPriceModel(id: 'beef', productName: 'গরুর মাংস', category: 'meat', currentPrice: 750.0, previousPrice: 750.0, unit: 'কেজি', trend: PriceTrend.stable, updatedAt: DateTime.now(), location: 'সারা বাংলাদেশ', imageUrl: 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782756123/images_wrgten.webp'),
    MarketPriceModel(id: 'chicken', productName: 'মুরগি (ব্রয়লার)', category: 'meat', currentPrice: 200.0, previousPrice: 200.0, unit: 'কেজি', trend: PriceTrend.stable, updatedAt: DateTime.now(), location: 'সারা বাংলাদেশ', imageUrl: 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782757555/images_xgtcyf.jpg'),
    MarketPriceModel(id: 'egg', productName: 'ডিম (হালি)', category: 'dairy', currentPrice: 50.0, previousPrice: 50.0, unit: 'হালি', trend: PriceTrend.stable, updatedAt: DateTime.now(), location: 'সারা বাংলাদেশ', imageUrl: 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782756249/download_ezwxls.jpg'),
  ];

  // ─── REAL-TIME STREAM (used by buyer dashboard ticker) ───────────────────
  /// Returns a live stream of market prices from `market_prices` Firestore collection.
  /// Falls back to baseline prices if the collection is empty.
  Stream<List<MarketPriceModel>> streamCurrentMarketPrices() {
    return _firestore
        .collection('market_prices')
        .orderBy('productName')
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return _baselinePrices;
      return snapshot.docs.map((doc) {
        final data = doc.data();
        try {
          return MarketPriceModel(
            id: doc.id,
            productName: data['productName'] as String? ?? '',
            category: data['category'] as String? ?? '',
            currentPrice: (data['currentPrice'] as num?)?.toDouble() ?? 0.0,
            previousPrice: (data['previousPrice'] as num?)?.toDouble() ?? 0.0,
            unit: data['unit'] as String? ?? 'কেজি',
            trend: _parseTrend(data['trend'] as String?),
            updatedAt: data['updatedAt'] != null
                ? DateTime.tryParse(data['updatedAt'] as String) ?? DateTime.now()
                : DateTime.now(),
            location: data['location'] as String?,
            imageUrl: data['imageUrl'] as String?,
          );
        } catch (_) {
          return _baselinePrices.firstWhere(
            (b) => b.id == doc.id,
            orElse: () => _baselinePrices.first,
          );
        }
      }).toList();
    });
  }

  PriceTrend _parseTrend(String? trendStr) {
    if (trendStr == null) return PriceTrend.stable;
    if (trendStr.contains('up')) return PriceTrend.up;
    if (trendStr.contains('down')) return PriceTrend.down;
    return PriceTrend.stable;
  }

  // ─── ONE-TIME FETCH (backward compat) ────────────────────────────────────
  /// Fetches market prices. Prefers Firestore `market_prices` collection.
  /// If empty, falls back to supply-based dynamic pricing from `products`.
  Future<List<MarketPriceModel>> fetchCurrentMarketPrices() async {
    try {
      // 1. Try admin-configured market_prices collection first
      final mpSnapshot = await _firestore.collection('market_prices').get();
      if (mpSnapshot.docs.isNotEmpty) {
        return mpSnapshot.docs.map((doc) {
          final data = doc.data();
          return MarketPriceModel(
            id: doc.id,
            productName: data['productName'] as String? ?? '',
            category: data['category'] as String? ?? '',
            currentPrice: (data['currentPrice'] as num?)?.toDouble() ?? 0.0,
            previousPrice: (data['previousPrice'] as num?)?.toDouble() ?? 0.0,
            unit: data['unit'] as String? ?? 'কেজি',
            trend: _parseTrend(data['trend'] as String?),
            updatedAt: data['updatedAt'] != null
                ? DateTime.tryParse(data['updatedAt'] as String) ?? DateTime.now()
                : DateTime.now(),
            location: data['location'] as String?,
            imageUrl: data['imageUrl'] as String?,
          );
        }).toList();
      }

      // 2. Fallback: supply-based dynamic pricing from products
      final snapshot = await _firestore
          .collection('products')
          .where('status', isEqualTo: 'ProductStatus.available')
          .get();

      Map<String, double> supplyData = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final title = data['title'] as String? ?? '';
        final qty = (data['quantity'] as num?)?.toDouble() ?? 0.0;
        for (var base in _baselinePrices) {
          if (title.contains(base.productName) ||
              base.productName.contains(title)) {
            supplyData[base.productName] =
                (supplyData[base.productName] ?? 0.0) + qty;
            break;
          }
        }
      }

      List<MarketPriceModel> dynamicPrices = [];
      for (var base in _baselinePrices) {
        double supply = supplyData[base.productName] ?? 0.0;
        double currentPrice = base.currentPrice;
        PriceTrend trend = PriceTrend.stable;

        if (supply == 0) {
          currentPrice = currentPrice * 1.20;
          trend = PriceTrend.up;
        } else if (supply < 50) {
          currentPrice = currentPrice * 1.10;
          trend = PriceTrend.up;
        } else if (supply > 1000) {
          currentPrice = currentPrice * 0.85;
          trend = PriceTrend.down;
        } else if (supply > 500) {
          currentPrice = currentPrice * 0.95;
          trend = PriceTrend.down;
        }

        dynamicPrices.add(MarketPriceModel(
          id: base.id,
          productName: base.productName,
          category: base.category,
          currentPrice: double.parse(currentPrice.toStringAsFixed(2)),
          previousPrice: base.currentPrice,
          unit: base.unit,
          trend: trend,
          updatedAt: DateTime.now(),
          location: base.location,
          imageUrl: base.imageUrl,
        ));
      }

      return dynamicPrices;
    } catch (e) {
      debugPrint('Error fetching market prices: $e');
      return _baselinePrices;
    }
  }

  /// Get price for a specific product (one-shot)
  Future<MarketPriceModel?> getPriceForProduct(String productName) async {
    final prices = await fetchCurrentMarketPrices();
    try {
      return prices.firstWhere((p) =>
          p.productName.contains(productName) ||
          productName.contains(p.productName));
    } catch (e) {
      return null;
    }
  }

  /// Get the effective display price for a product document.
  /// If admin has set an override price, returns that; otherwise returns seller price.
  static double getEffectivePrice(Map<String, dynamic> productData) {
    final adminOverride = (productData['adminOverridePrice'] as num?)?.toDouble();
    final sellerPrice = (productData['price'] as num?)?.toDouble() ?? 0.0;
    return adminOverride ?? sellerPrice;
  }
}
