import 'package:agrolinkbd/core/models/market_price_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class MarketPriceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Baseline prices when market supply is unknown or normal
  final List<MarketPriceModel> _baselinePrices = [
    MarketPriceModel(id: '1', productName: 'টমেটো', category: 'vegetables', currentPrice: 80.0, previousPrice: 80.0, unit: 'কেজি', trend: PriceTrend.stable, updatedAt: DateTime.now(), location: 'সারা বাংলাদেশ', imageUrl: 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782757091/Tomato_hcjt7o.png'),
    MarketPriceModel(id: '2', productName: 'আলু', category: 'vegetables', currentPrice: 40.0, previousPrice: 40.0, unit: 'কেজি', trend: PriceTrend.stable, updatedAt: DateTime.now(), location: 'সারা বাংলাদেশ', imageUrl: 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782584736/Screenshot_2026-06-28_002524_ziwqmo.png'),
    MarketPriceModel(id: '3', productName: 'পেঁয়াজ', category: 'vegetables', currentPrice: 90.0, previousPrice: 90.0, unit: 'কেজি', trend: PriceTrend.stable, updatedAt: DateTime.now(), location: 'সারা বাংলাদেশ', imageUrl: 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782757375/images_z5w9hg.jpg'),
    MarketPriceModel(id: '4', productName: 'কাঁচা মরিচ', category: 'vegetables', currentPrice: 150.0, previousPrice: 150.0, unit: 'কেজি', trend: PriceTrend.stable, updatedAt: DateTime.now(), location: 'সারা বাংলাদেশ', imageUrl: 'https://images.unsplash.com/photo-1587889115792-c9d300fb2f6b?q=80&w=600&auto=format&fit=crop'),
    MarketPriceModel(id: '5', productName: 'চাল (মিনিকেট)', category: 'grains', currentPrice: 70.0, previousPrice: 70.0, unit: 'কেজি', trend: PriceTrend.stable, updatedAt: DateTime.now(), location: 'সারা বাংলাদেশ', imageUrl: 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782584453/Screenshot_2026-06-28_002037_e5q6ll.png'),
    MarketPriceModel(id: '6', productName: 'আম (হিমসাগর)', category: 'fruits', currentPrice: 100.0, previousPrice: 100.0, unit: 'কেজি', trend: PriceTrend.stable, updatedAt: DateTime.now(), location: 'সারা বাংলাদেশ', imageUrl: 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782583216/image_sxwwpa.png'),
    MarketPriceModel(id: '7', productName: 'রুই মাছ', category: 'fish', currentPrice: 350.0, previousPrice: 350.0, unit: 'কেজি', trend: PriceTrend.stable, updatedAt: DateTime.now(), location: 'সারা বাংলাদেশ', imageUrl: 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782734272/Screenshot_2026-06-29_175728_q4k1bk.png'),
    MarketPriceModel(id: '8', productName: 'গরুর মাংস', category: 'meat', currentPrice: 750.0, previousPrice: 750.0, unit: 'কেজি', trend: PriceTrend.stable, updatedAt: DateTime.now(), location: 'সারা বাংলাদেশ', imageUrl: 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782756123/images_wrgten.webp'),
    MarketPriceModel(id: '9', productName: 'মুরগি (ব্রয়লার)', category: 'meat', currentPrice: 200.0, previousPrice: 200.0, unit: 'কেজি', trend: PriceTrend.stable, updatedAt: DateTime.now(), location: 'সারা বাংলাদেশ', imageUrl: 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782757555/images_xgtcyf.jpg'),
    MarketPriceModel(id: '10', productName: 'ডিম (হালি)', category: 'dairy', currentPrice: 50.0, previousPrice: 50.0, unit: 'হালি', trend: PriceTrend.stable, updatedAt: DateTime.now(), location: 'সারা বাংলাদেশ', imageUrl: 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782756249/download_ezwxls.jpg'),
  ];

  // Fetch dynamic market prices based on supply
  Future<List<MarketPriceModel>> fetchCurrentMarketPrices() async {
    try {
      final snapshot = await _firestore.collection('products')
          .where('status', isEqualTo: 'ProductStatus.available')
          .get();

      // Aggregate supply
      Map<String, double> supplyData = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final title = data['title'] as String? ?? '';
        final qty = (data['quantity'] as num?)?.toDouble() ?? 0.0;
        
        // Very basic matching, in reality you'd use category + standard product IDs
        for (var base in _baselinePrices) {
          if (title.contains(base.productName) || base.productName.contains(title)) {
            supplyData[base.productName] = (supplyData[base.productName] ?? 0.0) + qty;
            break;
          }
        }
      }

      // Calculate dynamic prices
      List<MarketPriceModel> dynamicPrices = [];
      for (var base in _baselinePrices) {
        double supply = supplyData[base.productName] ?? 0.0;
        
        // Simple Surge/Drop Logic
        // Expected average supply = 1000 kg (as a placeholder)
        double currentPrice = base.currentPrice;
        PriceTrend trend = PriceTrend.stable;
        
        if (supply == 0) {
          // No supply - High Demand (Surge 20%)
          currentPrice = currentPrice * 1.20;
          trend = PriceTrend.up;
        } else if (supply < 50) {
          // Low supply - Surge 10%
          currentPrice = currentPrice * 1.10;
          trend = PriceTrend.up;
        } else if (supply > 1000) {
          // Oversupply - Drop 15%
          currentPrice = currentPrice * 0.85;
          trend = PriceTrend.down;
        } else if (supply > 500) {
          // High supply - Drop 5%
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
      debugPrint('Error fetching dynamic market prices: $e');
      return _baselinePrices;
    }
  }

  // Get price for a specific product
  Future<MarketPriceModel?> getPriceForProduct(String productName) async {
    final prices = await fetchCurrentMarketPrices();
    try {
      return prices.firstWhere((p) => p.productName.contains(productName) || productName.contains(p.productName));
    } catch (e) {
      return null;
    }
  }
}
