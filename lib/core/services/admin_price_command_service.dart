import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

enum PriceCommandScope {
  all,
  agri,
  fish,
  category,
  division,
  district,
}

enum PriceCommandAction {
  decrease,
  increase,
  syncBenchmark,
  reset,
  rollback,
}

enum PriceAdjustmentUnit {
  percent,
  fixedBdt,
}

class PriceCommandResult {
  final bool success;
  final int affectedProductsCount;
  final int affectedFishLotsCount;
  final String message;
  final String? error;

  PriceCommandResult({
    required this.success,
    this.affectedProductsCount = 0,
    this.affectedFishLotsCount = 0,
    required this.message,
    this.error,
  });

  int get totalAffected => affectedProductsCount + affectedFishLotsCount;
}

class PriceSimulationResult {
  final int productsCount;
  final int fishLotsCount;
  final double averageCurrentPrice;
  final double averageNewPrice;
  final double estimatedTotalValueDelta; // total ৳ changed across inventory

  PriceSimulationResult({
    required this.productsCount,
    required this.fishLotsCount,
    required this.averageCurrentPrice,
    required this.averageNewPrice,
    required this.estimatedTotalValueDelta,
  });

  int get totalListings => productsCount + fishLotsCount;
}

class AdminPriceCommandService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Safety Price Floors (Minimum allowed rate in BDT)
  static const double minCropFloorPrice = 5.0; // ৳5 / kg
  static const double minFishFloorPrice = 40.0; // ৳40 / kg

  /// Comprehensive mapping of Bangladesh Divisions and Districts
  static const Map<String, List<String>> divisionDistricts = {
    'rajshahi': [
      'rajshahi', 'bogura', 'bogra', 'natore', 'naogaon', 'pabna', 'sirajganj', 'joypurhat', 'chapainawabganj',
      'রাজশাহী', 'বগুড়া', 'নাটোর', 'পাবনা', 'সিরাজগঞ্জ', 'নওগাঁ', 'জয়পুরহাট', 'চাঁপাইনবাবগঞ্জ'
    ],
    'dhaka': [
      'dhaka', 'gazipur', 'narayanganj', 'tangail', 'faridpur', 'manikganj', 'munshiganj', 'narsingdi', 'gopalganj', 'kishoreganj', 'madaripur', 'rajbari', 'shariatpur',
      'ঢাকা', 'গাজীপুর', 'নারায়ণগঞ্জ', 'টাঙ্গাইল', 'ফরিদপুর', 'মানিকগঞ্জ', 'মুন্সীগঞ্জ', 'নরসিংদী', 'গোপালগঞ্জ', 'কিশোরগঞ্জ', 'মাদারীপুর', 'রাজবাড়ী', 'শরীয়তপুর'
    ],
    'chittagong': [
      'chattogram', 'chittagong', 'coxsbazar', 'comilla', 'feni', 'brahmanbaria', 'chandpur', 'noakhali', 'lakshmipur', 'khagrachhari', 'rangamati', 'bandarban',
      'চট্টগ্রাম', 'কক্সবাজার', 'কুমিল্লা', 'ফেনী', 'ব্রাহ্মণবাড়িয়া', 'চাঁদপুর', 'নোয়াখালী', 'লক্ষ্মীপুর', 'খাগড়াছড়ি', 'রাঙ্গামাটি', 'বান্দরবান'
    ],
    'khulna': [
      'khulna', 'jashore', 'jessore', 'satkhira', 'bagerhat', 'kushtia', 'chuadanga', 'meherpur', 'jhenaidah', 'magura', 'narail',
      'খুলনা', 'যশোর', 'সাতক্ষীরা', 'বাগেরহাট', 'কুষ্টিয়া', 'চুয়াডাঙ্গা', 'মেহেরপুর', 'ঝিনাইদহ', 'মাগুরা', 'নড়াইল'
    ],
    'barisal': [
      'barisal', 'bhola', 'patuakhali', 'pirojpur', 'barguna', 'jhalokati',
      'বরিশাল', 'ভোলা', 'পটুয়াখালী', 'পিরোজপুর', 'বরগুনা', 'ঝালকাঠি'
    ],
    'sylhet': [
      'sylhet', 'moulvibazar', 'habiganj', 'sunamganj',
      'সিলেট', 'মৌলভীবাজার', 'হবিগঞ্জ', 'সুনামগঞ্জ'
    ],
    'rangpur': [
      'rangpur', 'dinajpur', 'kurigram', 'gaibandha', 'nilphamari', 'panchagarh', 'thakurgaon', 'lalmonirhat',
      'রংপুর', 'দিনাজপুর', 'কুড়িগ্রাম', 'গাইবান্ধা', 'নীলফামারী', 'পঞ্চগড়', 'ঠাকুরগাঁও', 'লালমনিরহাট'
    ],
    'mymensingh': [
      'mymensingh', 'jamalpur', 'netrokona', 'sherpur',
      'ময়মনসিংহ', 'জামালপুর', 'নেত্রকোণা', 'শেরপুর'
    ],
  };

  /// Helper to check if a listing location matches a target district or division
  bool _matchesGeo({
    required Map<String, dynamic> data,
    String? targetDistrict,
    String? targetDivision,
  }) {
    if (targetDistrict != null && targetDistrict.isNotEmpty && targetDistrict != 'all') {
      final district = (data['district'] as String? ?? data['farmerDistrict'] as String? ?? '').toLowerCase();
      final location = (data['location'] as String? ?? '').toLowerCase();
      final target = targetDistrict.toLowerCase();
      return district.contains(target) || location.contains(target);
    }

    if (targetDivision != null && targetDivision.isNotEmpty && targetDivision != 'all') {
      final district = (data['district'] as String? ?? data['farmerDistrict'] as String? ?? '').toLowerCase();
      final location = (data['location'] as String? ?? '').toLowerCase();
      final allowedDistricts = divisionDistricts[targetDivision.toLowerCase()] ?? [];
      for (final d in allowedDistricts) {
        if (district.contains(d) || location.contains(d)) {
          return true;
        }
      }
      return false;
    }

    return true;
  }

  /// Counts the active listings that would be affected by this command
  Future<Map<String, int>> getAffectedCounts({
    required PriceCommandScope scope,
    String? category,
    String? district,
    String? division,
  }) async {
    int productsCount = 0;
    int fishLotsCount = 0;

    try {
      if (scope == PriceCommandScope.all ||
          scope == PriceCommandScope.agri ||
          scope == PriceCommandScope.category ||
          scope == PriceCommandScope.district ||
          scope == PriceCommandScope.division) {
        Query productsQuery = _firestore.collection('products');
        if (scope == PriceCommandScope.category && category != null && category.isNotEmpty && category != 'all') {
          productsQuery = productsQuery.where('category', isEqualTo: category);
        }

        final snapshot = await productsQuery.get();
        productsCount = snapshot.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final cat = (data['category'] as String? ?? '').toLowerCase();
          if (scope == PriceCommandScope.agri && cat == 'fish') return false;
          if (scope == PriceCommandScope.district || scope == PriceCommandScope.division) {
            return _matchesGeo(data: data, targetDistrict: district, targetDivision: division);
          }
          return true;
        }).length;
      }

      if (scope == PriceCommandScope.all ||
          scope == PriceCommandScope.fish ||
          (scope == PriceCommandScope.category && category == 'fish') ||
          scope == PriceCommandScope.district ||
          scope == PriceCommandScope.division) {
        final fishSnap = await _firestore
            .collection('fish_marketplace_lots')
            .where('status', isEqualTo: 'active')
            .get();

        fishLotsCount = fishSnap.docs.where((doc) {
          final data = doc.data();
          if (scope == PriceCommandScope.district || scope == PriceCommandScope.division) {
            return _matchesGeo(data: data, targetDistrict: district, targetDivision: division);
          }
          return true;
        }).length;
      }
    } catch (e) {
      debugPrint('Error getting affected counts: $e');
    }

    return {
      'products': productsCount,
      'fishLots': fishLotsCount,
      'total': productsCount + fishLotsCount,
    };
  }

  /// Calculates pre-execution simulation impact: average price movement and market value delta
  Future<PriceSimulationResult> calculateSimulatedImpact({
    required PriceCommandScope scope,
    required PriceCommandAction action,
    required PriceAdjustmentUnit unit,
    required double deltaValue,
    String? targetCategory,
    String? targetDistrict,
    String? targetDivision,
  }) async {
    int prodCount = 0;
    int fishCount = 0;
    double currentPriceSum = 0.0;
    double newPriceSum = 0.0;
    double totalInventoryValueDelta = 0.0;

    try {
      // 1. Fetch benchmark prices if sync action
      Map<String, double> benchmarkPrices = {};
      if (action == PriceCommandAction.syncBenchmark) {
        final mpSnap = await _firestore.collection('market_prices').get();
        for (var doc in mpSnap.docs) {
          final data = doc.data();
          final name = (data['productName'] as String? ?? '').toLowerCase();
          final price = (data['currentPrice'] as num?)?.toDouble() ?? 0.0;
          if (name.isNotEmpty && price > 0) benchmarkPrices[name] = price;
        }
      }

      // 2. Simulate Agri Products
      if (scope != PriceCommandScope.fish) {
        final snap = await _firestore.collection('products').get();
        for (final doc in snap.docs) {
          final data = doc.data();
          final cat = (data['category'] as String? ?? '').toLowerCase();
          if (scope == PriceCommandScope.agri && cat == 'fish') continue;
          if (scope == PriceCommandScope.category && targetCategory != null && targetCategory != 'all' && cat != targetCategory) {
            continue;
          }
          if ((scope == PriceCommandScope.district || scope == PriceCommandScope.division) &&
              !_matchesGeo(data: data, targetDistrict: targetDistrict, targetDivision: targetDivision)) {
            continue;
          }

          final cur = (data['price'] as num?)?.toDouble() ?? 0.0;
          final orig = (data['originalPrice'] as num?)?.toDouble() ?? cur;
          final qty = (data['quantity'] as num?)?.toDouble() ?? 50.0; // fallback avg 50kg
          if (cur <= 0) continue;

          double nextPrice = cur;
          if (action == PriceCommandAction.reset) {
            nextPrice = orig;
          } else if (action == PriceCommandAction.syncBenchmark) {
            final title = (data['title'] as String? ?? '').toLowerCase();
            for (final entry in benchmarkPrices.entries) {
              if (title.contains(entry.key) || entry.key.contains(title)) {
                nextPrice = entry.value;
                break;
              }
            }
          } else {
            if (unit == PriceAdjustmentUnit.percent) {
              final factor = deltaValue / 100.0;
              nextPrice = action == PriceCommandAction.decrease ? cur * (1.0 - factor) : cur * (1.0 + factor);
            } else {
              nextPrice = action == PriceCommandAction.decrease ? cur - deltaValue : cur + deltaValue;
            }
          }
          if (nextPrice < minCropFloorPrice) nextPrice = minCropFloorPrice;
          nextPrice = double.parse(nextPrice.toStringAsFixed(0));

          prodCount++;
          currentPriceSum += cur;
          newPriceSum += nextPrice;
          totalInventoryValueDelta += ((nextPrice - cur) * qty);
        }
      }

      // 3. Simulate Fish Lots
      if (scope != PriceCommandScope.agri && (targetCategory == null || targetCategory == 'all' || targetCategory == 'fish')) {
        final fishSnap = await _firestore.collection('fish_marketplace_lots').where('status', isEqualTo: 'active').get();
        for (final doc in fishSnap.docs) {
          final data = doc.data();
          if ((scope == PriceCommandScope.district || scope == PriceCommandScope.division) &&
              !_matchesGeo(data: data, targetDistrict: targetDistrict, targetDivision: targetDivision)) {
            continue;
          }

          final cur = (data['pricePerKg'] as num?)?.toDouble() ?? 0.0;
          final orig = (data['originalPricePerKg'] as num?)?.toDouble() ?? cur;
          final qty = (data['quantityKg'] as num?)?.toDouble() ?? 100.0;
          if (cur <= 0) continue;

          double nextPrice = cur;
          if (action == PriceCommandAction.reset) {
            nextPrice = orig;
          } else if (action == PriceCommandAction.syncBenchmark) {
            final fishType = (data['fishType'] as String? ?? '').toLowerCase();
            for (final entry in benchmarkPrices.entries) {
              if (fishType.contains(entry.key) || entry.key.contains(fishType)) {
                nextPrice = entry.value;
                break;
              }
            }
          } else {
            if (unit == PriceAdjustmentUnit.percent) {
              final factor = deltaValue / 100.0;
              nextPrice = action == PriceCommandAction.decrease ? cur * (1.0 - factor) : cur * (1.0 + factor);
            } else {
              nextPrice = action == PriceCommandAction.decrease ? cur - deltaValue : cur + deltaValue;
            }
          }
          if (nextPrice < minFishFloorPrice) nextPrice = minFishFloorPrice;
          nextPrice = double.parse(nextPrice.toStringAsFixed(0));

          fishCount++;
          currentPriceSum += cur;
          newPriceSum += nextPrice;
          totalInventoryValueDelta += ((nextPrice - cur) * qty);
        }
      }
    } catch (e) {
      debugPrint('Error simulating price impact: $e');
    }

    final total = prodCount + fishCount;
    return PriceSimulationResult(
      productsCount: prodCount,
      fishLotsCount: fishCount,
      averageCurrentPrice: total > 0 ? (currentPriceSum / total) : 0.0,
      averageNewPrice: total > 0 ? (newPriceSum / total) : 0.0,
      estimatedTotalValueDelta: totalInventoryValueDelta,
    );
  }

  /// Executes bulk price command across Firestore collections atomically with rollback snapshot & farmer notifications
  Future<PriceCommandResult> executePriceCommand({
    required PriceCommandScope scope,
    required PriceCommandAction action,
    required PriceAdjustmentUnit unit,
    required double deltaValue,
    required String reason,
    String? targetCategory,
    String? targetDistrict,
    String? targetDivision,
    String durationOption = 'permanent', // 'permanent', '24h', '48h', '7d'
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final adminEmail = currentUser?.email ?? 'super_admin';
    final adminUid = currentUser?.uid ?? 'admin_uid';
    final now = FieldValue.serverTimestamp();

    int updatedProducts = 0;
    int updatedFishLots = 0;
    final List<Map<String, dynamic>> affectedSnapshots = [];
    final Set<String> affectedFarmerIds = {};

    try {
      WriteBatch batch = _firestore.batch();
      int batchOperationCount = 0;

      // 1. Fetch benchmark prices if sync action requested
      Map<String, double> benchmarkPrices = {};
      if (action == PriceCommandAction.syncBenchmark) {
        final mpSnap = await _firestore.collection('market_prices').get();
        for (var doc in mpSnap.docs) {
          final data = doc.data();
          final name = (data['productName'] as String? ?? '').toLowerCase();
          final price = (data['currentPrice'] as num?)?.toDouble() ?? 0.0;
          if (name.isNotEmpty && price > 0) {
            benchmarkPrices[name] = price;
          }
        }
      }

      // 2. Process Agri Products (`products` collection)
      if (scope != PriceCommandScope.fish) {
        Query productsQuery = _firestore.collection('products');
        if (scope == PriceCommandScope.category && targetCategory != null && targetCategory.isNotEmpty && targetCategory != 'all') {
          productsQuery = productsQuery.where('category', isEqualTo: targetCategory);
        }

        final snapshot = await productsQuery.get();
        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final cat = (data['category'] as String? ?? '').toLowerCase();

          if (scope == PriceCommandScope.agri && cat == 'fish') continue;

          if ((scope == PriceCommandScope.district || scope == PriceCommandScope.division) &&
              !_matchesGeo(data: data, targetDistrict: targetDistrict, targetDivision: targetDivision)) {
            continue;
          }

          final currentPrice = (data['price'] as num?)?.toDouble() ?? 0.0;
          final originalPrice = (data['originalPrice'] as num?)?.toDouble() ?? currentPrice;
          final farmerId = (data['farmerId'] as String? ?? data['sellerId'] as String? ?? '');
          if (farmerId.isNotEmpty) affectedFarmerIds.add(farmerId);

          Map<String, dynamic> updates = {};
          double appliedPrice = currentPrice;

          if (action == PriceCommandAction.reset) {
            appliedPrice = originalPrice;
            updates = {
              'price': originalPrice,
              'adminOverridePrice': FieldValue.delete(),
              'adminOverrideDelta': FieldValue.delete(),
              'adminOverrideUnit': FieldValue.delete(),
              'adminOverrideReason': FieldValue.delete(),
              'adminOverrideAt': FieldValue.delete(),
              'adminOverrideBy': FieldValue.delete(),
            };
          } else if (action == PriceCommandAction.syncBenchmark) {
            final title = (data['title'] as String? ?? '').toLowerCase();
            double? matchedBenchPrice;
            for (var entry in benchmarkPrices.entries) {
              if (title.contains(entry.key) || entry.key.contains(title)) {
                matchedBenchPrice = entry.value;
                break;
              }
            }
            appliedPrice = matchedBenchPrice ?? currentPrice;
            if (appliedPrice < minCropFloorPrice) appliedPrice = minCropFloorPrice;
            appliedPrice = double.parse(appliedPrice.toStringAsFixed(0));

            updates = {
              'originalPrice': originalPrice,
              'price': appliedPrice,
              'adminOverridePrice': appliedPrice,
              'adminOverrideReason': reason.isNotEmpty ? reason : 'Synced to market benchmark',
              'adminOverrideAt': now,
              'adminOverrideBy': adminEmail,
            };
          } else {
            // Increase or Decrease
            if (unit == PriceAdjustmentUnit.percent) {
              final factor = deltaValue / 100.0;
              appliedPrice = action == PriceCommandAction.decrease
                  ? currentPrice * (1.0 - factor)
                  : currentPrice * (1.0 + factor);
            } else {
              appliedPrice = action == PriceCommandAction.decrease
                  ? currentPrice - deltaValue
                  : currentPrice + deltaValue;
            }

            if (appliedPrice < minCropFloorPrice) appliedPrice = minCropFloorPrice;
            appliedPrice = double.parse(appliedPrice.toStringAsFixed(0));

            updates = {
              'originalPrice': originalPrice,
              'price': appliedPrice,
              'adminOverridePrice': appliedPrice,
              'adminOverrideDelta': deltaValue,
              'adminOverrideUnit': unit.name,
              'adminOverrideAction': action.name,
              'adminOverrideReason': reason,
              'adminOverrideAt': now,
              'adminOverrideBy': adminEmail,
              'adminOverrideDuration': durationOption,
            };
          }

          affectedSnapshots.add({
            'docId': doc.id,
            'collection': 'products',
            'previousPrice': currentPrice,
            'appliedPrice': appliedPrice,
            'title': data['title'] ?? data['name'] ?? 'Product',
          });

          batch.update(doc.reference, updates);
          batchOperationCount++;
          updatedProducts++;

          if (batchOperationCount >= 450) {
            await batch.commit();
            batch = _firestore.batch();
            batchOperationCount = 0;
          }
        }
      }

      // 3. Process Live Fish Lots (`fish_marketplace_lots` collection)
      if (scope != PriceCommandScope.agri && (targetCategory == null || targetCategory == 'all' || targetCategory == 'fish')) {
        final fishSnap = await _firestore
            .collection('fish_marketplace_lots')
            .where('status', isEqualTo: 'active')
            .get();

        for (var doc in fishSnap.docs) {
          final data = doc.data();

          if ((scope == PriceCommandScope.district || scope == PriceCommandScope.division) &&
              !_matchesGeo(data: data, targetDistrict: targetDistrict, targetDivision: targetDivision)) {
            continue;
          }

          final currentPrice = (data['pricePerKg'] as num?)?.toDouble() ?? 0.0;
          final originalPrice = (data['originalPricePerKg'] as num?)?.toDouble() ?? currentPrice;
          final farmerId = (data['farmerId'] as String? ?? '');
          if (farmerId.isNotEmpty) affectedFarmerIds.add(farmerId);

          Map<String, dynamic> updates = {};
          double appliedPrice = currentPrice;

          if (action == PriceCommandAction.reset) {
            appliedPrice = originalPrice;
            updates = {
              'pricePerKg': originalPrice,
              'adminOverridePrice': FieldValue.delete(),
              'adminOverrideDelta': FieldValue.delete(),
              'adminOverrideReason': FieldValue.delete(),
              'adminOverrideAt': FieldValue.delete(),
              'adminOverrideBy': FieldValue.delete(),
            };
          } else if (action == PriceCommandAction.syncBenchmark) {
            final fishType = (data['fishType'] as String? ?? '').toLowerCase();
            double? matchedBenchPrice;
            for (var entry in benchmarkPrices.entries) {
              if (fishType.contains(entry.key) || entry.key.contains(fishType)) {
                matchedBenchPrice = entry.value;
                break;
              }
            }
            appliedPrice = matchedBenchPrice ?? currentPrice;
            if (appliedPrice < minFishFloorPrice) appliedPrice = minFishFloorPrice;
            appliedPrice = double.parse(appliedPrice.toStringAsFixed(0));

            updates = {
              'originalPricePerKg': originalPrice,
              'pricePerKg': appliedPrice,
              'adminOverridePrice': appliedPrice,
              'adminOverrideReason': reason.isNotEmpty ? reason : 'Synced to fish market benchmark',
              'adminOverrideAt': now,
              'adminOverrideBy': adminEmail,
            };
          } else {
            if (unit == PriceAdjustmentUnit.percent) {
              final factor = deltaValue / 100.0;
              appliedPrice = action == PriceCommandAction.decrease
                  ? currentPrice * (1.0 - factor)
                  : currentPrice * (1.0 + factor);
            } else {
              appliedPrice = action == PriceCommandAction.decrease
                  ? currentPrice - deltaValue
                  : currentPrice + deltaValue;
            }

            if (appliedPrice < minFishFloorPrice) appliedPrice = minFishFloorPrice;
            appliedPrice = double.parse(appliedPrice.toStringAsFixed(0));

            updates = {
              'originalPricePerKg': originalPrice,
              'pricePerKg': appliedPrice,
              'adminOverridePrice': appliedPrice,
              'adminOverrideDelta': deltaValue,
              'adminOverrideUnit': unit.name,
              'adminOverrideAction': action.name,
              'adminOverrideReason': reason,
              'adminOverrideAt': now,
              'adminOverrideBy': adminEmail,
              'adminOverrideDuration': durationOption,
            };
          }

          affectedSnapshots.add({
            'docId': doc.id,
            'collection': 'fish_marketplace_lots',
            'previousPrice': currentPrice,
            'appliedPrice': appliedPrice,
            'title': data['fishType'] ?? 'Fish Lot',
          });

          batch.update(doc.reference, updates);
          batchOperationCount++;
          updatedFishLots++;

          if (batchOperationCount >= 450) {
            await batch.commit();
            batch = _firestore.batch();
            batchOperationCount = 0;
          }
        }
      }

      // 4. Update market_prices benchmarks if relevant
      if (action == PriceCommandAction.decrease || action == PriceCommandAction.increase) {
        final mpSnap = await _firestore.collection('market_prices').get();
        for (var doc in mpSnap.docs) {
          final data = doc.data();
          final cat = (data['category'] as String? ?? '').toLowerCase();

          bool shouldUpdate = false;
          if (scope == PriceCommandScope.all) {
            shouldUpdate = true;
          } else if (scope == PriceCommandScope.fish && cat == 'fish') {
            shouldUpdate = true;
          } else if (scope == PriceCommandScope.agri && cat != 'fish') {
            shouldUpdate = true;
          } else if (scope == PriceCommandScope.category && targetCategory != null && cat == targetCategory) {
            shouldUpdate = true;
          }

          if (shouldUpdate) {
            final oldPrice = (data['currentPrice'] as num?)?.toDouble() ?? 0.0;
            double adjustedPrice = oldPrice;
            if (unit == PriceAdjustmentUnit.percent) {
              adjustedPrice = action == PriceCommandAction.decrease
                  ? oldPrice * (1.0 - deltaValue / 100.0)
                  : oldPrice * (1.0 + deltaValue / 100.0);
            } else {
              adjustedPrice = action == PriceCommandAction.decrease
                  ? oldPrice - deltaValue
                  : oldPrice + deltaValue;
            }
            final floor = cat == 'fish' ? minFishFloorPrice : minCropFloorPrice;
            if (adjustedPrice < floor) adjustedPrice = floor;
            adjustedPrice = double.parse(adjustedPrice.toStringAsFixed(0));

            batch.update(doc.reference, {
              'previousPrice': oldPrice,
              'currentPrice': adjustedPrice,
              'trend': action == PriceCommandAction.decrease ? 'PriceTrend.down' : 'PriceTrend.up',
              'updatedAt': DateTime.now().toIso8601String(),
              'updatedBy': adminEmail,
            });
            batchOperationCount++;
          }
        }
      }

      if (batchOperationCount > 0) {
        await batch.commit();
      }

      // 5. Store rich Audit Trail to `admin_price_logs` with snapshot for 1-tap rollback
      await _firestore.collection('admin_price_logs').add({
        'actionType': 'bulk_command_shortcut',
        'scope': scope.name,
        'targetCategory': targetCategory ?? 'all',
        'targetDistrict': targetDistrict ?? 'all',
        'targetDivision': targetDivision ?? 'all',
        'action': action.name,
        'unit': unit.name,
        'deltaValue': deltaValue,
        'reason': reason,
        'duration': durationOption,
        'affectedProducts': updatedProducts,
        'affectedFishLots': updatedFishLots,
        'affectedSnapshots': affectedSnapshots,
        'adminEmail': adminEmail,
        'adminUid': adminUid,
        'timestamp': now,
        'isRolledBack': false,
      });

      // 6. Dispatch direct push/in-app notifications to affected farmers
      for (final fid in affectedFarmerIds) {
        try {
          await _firestore.collection('users').doc(fid).collection('notifications').add({
            'title': '🏷️ সুপার এডমিন বাজার মূল্য আপডেট',
            'titleEn': '🏷️ Super Admin Price Adjustment',
            'message': 'বাজার পরিস্থিতি ও কৃষক সুরক্ষা নিশ্চিত করতে আপনার পণ্যের মূল্যে সাময়িক সমন্বয় ($reason) করা হয়েছে।',
            'messageEn': 'Your listing price was adjusted by Super Admin: $reason',
            'type': 'market_price',
            'createdAt': now,
            'isRead': false,
          });
        } catch (_) {}
      }

      // 7. Global Announcement Banner
      final String actionBn = action == PriceCommandAction.decrease
          ? 'বাজার ধসের প্রেক্ষিতে সাময়িক মূল্য সমন্বয় (${deltaValue.toStringAsFixed(0)}${unit == PriceAdjustmentUnit.percent ? '%' : '৳'} হ্রাস)'
          : action == PriceCommandAction.increase
              ? 'বাজার ঊর্ধ্বগতির প্রেক্ষিতে কৃষক সুরক্ষায় মূল্য বৃদ্ধি (${deltaValue.toStringAsFixed(0)}${unit == PriceAdjustmentUnit.percent ? '%' : '৳'} বৃদ্ধি)'
              : action == PriceCommandAction.reset
                  ? 'কৃষকের আসল মূল্যে ফেরত নেওয়া হয়েছে'
                  : 'বাজার রেটে স্বয়ংক্রিয় সিঙ্ক সম্পন্ন হয়েছে';

      await _firestore.collection('global_announcements').add({
        'title_bn': '🏷️ সুপার এডমিন প্রাইস কমান্ড আপডেট',
        'title_en': '🏷️ Super Admin Price Adjustment',
        'message_bn': '$actionBn। $reason',
        'message_en': '$actionBn. $reason',
        'type': 'market_price',
        'createdAt': now,
        'isActive': true,
      });

      return PriceCommandResult(
        success: true,
        affectedProductsCount: updatedProducts,
        affectedFishLotsCount: updatedFishLots,
        message: 'সফলভাবে $updatedProducts টি কৃষি পণ্য ও $updatedFishLots টি মাছের লটের দাম সমন্বয় করা হয়েছে।',
      );
    } catch (e) {
      debugPrint('❌ Error executing price command: $e');
      return PriceCommandResult(
        success: false,
        message: 'কমান্ড এক্সিকিউট করতে ত্রুটি হয়েছে: $e',
        error: e.toString(),
      );
    }
  }

  /// 1-Tap Instant Rollback: Restores previous prices recorded in the specific command log
  Future<PriceCommandResult> rollbackCommand(String logId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final adminEmail = currentUser?.email ?? 'super_admin';
    final adminUid = currentUser?.uid ?? 'admin_uid';
    final now = FieldValue.serverTimestamp();

    try {
      final logDoc = await _firestore.collection('admin_price_logs').doc(logId).get();
      if (!logDoc.exists) {
        return PriceCommandResult(success: false, message: 'লগ ডাটা পাওয়া যায়নি।');
      }

      final logData = logDoc.data()!;
      if (logData['isRolledBack'] == true) {
        return PriceCommandResult(success: false, message: 'এই কমান্ডটি ইতিমধ্যে পূর্বাবস্থায় ফিরিয়ে নেওয়া হয়েছে।');
      }

      final snapshots = (logData['affectedSnapshots'] as List<dynamic>?) ?? [];
      int restoredProducts = 0;
      int restoredFishLots = 0;

      WriteBatch batch = _firestore.batch();
      int batchOperationCount = 0;

      for (final item in snapshots) {
        if (item is! Map<String, dynamic>) continue;
        final docId = item['docId'] as String?;
        final collection = item['collection'] as String?;
        final previousPrice = (item['previousPrice'] as num?)?.toDouble();

        if (docId == null || collection == null || previousPrice == null) continue;

        final ref = _firestore.collection(collection).doc(docId);

        if (collection == 'products') {
          batch.update(ref, {
            'price': previousPrice,
            'adminOverridePrice': FieldValue.delete(),
            'adminOverrideDelta': FieldValue.delete(),
            'adminOverrideReason': 'Rolled back to previous price ৳$previousPrice',
            'adminOverrideAt': now,
            'adminOverrideBy': adminEmail,
          });
          restoredProducts++;
        } else if (collection == 'fish_marketplace_lots') {
          batch.update(ref, {
            'pricePerKg': previousPrice,
            'adminOverridePrice': FieldValue.delete(),
            'adminOverrideDelta': FieldValue.delete(),
            'adminOverrideReason': 'Rolled back to previous price ৳$previousPrice',
            'adminOverrideAt': now,
            'adminOverrideBy': adminEmail,
          });
          restoredFishLots++;
        }

        batchOperationCount++;
        if (batchOperationCount >= 450) {
          await batch.commit();
          batch = _firestore.batch();
          batchOperationCount = 0;
        }
      }

      // Mark the original log as rolled back
      batch.update(logDoc.reference, {
        'isRolledBack': true,
        'rolledBackAt': now,
        'rolledBackBy': adminEmail,
      });
      batchOperationCount++;

      if (batchOperationCount > 0) {
        await batch.commit();
      }

      // Record rollback event in audit log
      await _firestore.collection('admin_price_logs').add({
        'actionType': 'rollback',
        'targetLogId': logId,
        'originalAction': logData['action'],
        'restoredProducts': restoredProducts,
        'restoredFishLots': restoredFishLots,
        'adminEmail': adminEmail,
        'adminUid': adminUid,
        'timestamp': now,
        'reason': 'Super Admin rolled back command #$logId to prior pricing state',
      });

      return PriceCommandResult(
        success: true,
        affectedProductsCount: restoredProducts,
        affectedFishLotsCount: restoredFishLots,
        message: 'সফলভাবে $restoredProducts টি কৃষি পণ্য ও $restoredFishLots টি মাছের লট আগের মূল্যে ফিরিয়ে আনা হয়েছে।',
      );
    } catch (e) {
      debugPrint('❌ Error rolling back price command: $e');
      return PriceCommandResult(
        success: false,
        message: 'রোলব্যাক করতে ত্রুটি হয়েছে: $e',
        error: e.toString(),
      );
    }
  }

  /// Real-time stream of all admin price logs for audit and history view
  Stream<List<Map<String, dynamic>>> streamCommandHistory() {
    return _firestore
        .collection('admin_price_logs')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          ...doc.data(),
          'id': doc.id,
        };
      }).toList();
    });
  }
}
