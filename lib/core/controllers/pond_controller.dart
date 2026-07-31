import 'package:get/get.dart';
import '../models/pond_model.dart';
import 'dart:math';

class PondController extends GetxController {
  // Observable list of ponds
  var ponds = <PondModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Load initial mock data
    _loadInitialData();
  }

  void _loadInitialData() {
    ponds.add(
      PondModel(
        id: 'POND_1',
        name: 'পুকুর ১',
        area: '১.২ একর',
        fishSpecies: 'রুই, কাতলা ও মৃগেল',
        stockedDate: DateTime.now().subtract(const Duration(days: 120)),
        totalFishCount: 5000,
        ph: 7.2,
        ammonia: 0.1,
        activities: [
          PondActivityModel(
            id: 'ACT_1',
            title: 'পোনা ক্রয়',
            description: '৫০০০ রুই ও কাতলার পোনা',
            amount: 15000,
            date: DateTime.now().subtract(const Duration(days: 120)),
            type: 'Stock',
            isIncome: false,
          ),
          PondActivityModel(
            id: 'ACT_2',
            title: 'ফিড ক্রয়',
            description: 'ভাসমান ফিড (১০ বস্তা)',
            amount: 16000,
            date: DateTime.now().subtract(const Duration(days: 80)),
            type: 'Feed',
            isIncome: false,
          ),
          PondActivityModel(
            id: 'ACT_3',
            title: 'ওষুধ ও চুন',
            description: 'পুকুর প্রস্তুতি ও জীবাণুমুক্তকরণ',
            amount: 4500,
            date: DateTime.now().subtract(const Duration(days: 60)),
            type: 'Medicine',
            isIncome: false,
          ),
          PondActivityModel(
            id: 'ACT_4',
            title: 'মাছ বিক্রি (আংশিক)',
            description: '৫০০ কেজি রুই মাছ বিক্রি',
            amount: 175000,
            date: DateTime.now().subtract(const Duration(days: 2)),
            type: 'Sale',
            isIncome: true,
          ),
        ],
      )
    );

    ponds.add(
      PondModel(
        id: 'POND_2',
        name: 'পুকুর ২',
        area: '০.৮ একর',
        fishSpecies: 'তেলাপিয়া',
        stockedDate: DateTime.now().subtract(const Duration(days: 20)),
        totalFishCount: 10000,
        ph: 6.5,
        ammonia: 0.5,
        status: 'সতর্কতা',
        activities: [
          PondActivityModel(
            id: 'ACT_5',
            title: 'পোনা ক্রয়',
            description: 'তেলাপিয়ার পোনা',
            amount: 8000,
            date: DateTime.now().subtract(const Duration(days: 20)),
            type: 'Stock',
            isIncome: false,
          ),
          PondActivityModel(
            id: 'ACT_6',
            title: 'শ্রমিক মজুরি',
            description: 'পুকুর পরিষ্কার',
            amount: 2500,
            date: DateTime.now().subtract(const Duration(days: 15)),
            type: 'Maintenance',
            isIncome: false,
          ),
        ],
      )
    );

    ponds.add(
      PondModel(
        id: 'POND_3',
        name: 'হ্যাচারি প্রজেক্ট',
        area: '২.০ একর',
        fishSpecies: 'পাঙ্গাস ও শিং',
        stockedDate: DateTime.now().subtract(const Duration(days: 200)),
        totalFishCount: 25000,
        ph: 7.0,
        ammonia: 0.0,
        status: 'স্বাভাবিক',
        activities: [
          PondActivityModel(
            id: 'ACT_7',
            title: 'পোনা ও পরিবহন',
            description: 'শিং মাছের পোনা ক্রয়',
            amount: 35000,
            date: DateTime.now().subtract(const Duration(days: 200)),
            type: 'Stock',
            isIncome: false,
          ),
          PondActivityModel(
            id: 'ACT_8',
            title: 'খাদ্য খরচ',
            description: '৫০ বস্তা ফিড',
            amount: 80000,
            date: DateTime.now().subtract(const Duration(days: 100)),
            type: 'Feed',
            isIncome: false,
          ),
          PondActivityModel(
            id: 'ACT_9',
            title: 'চূড়ান্ত মাছ বিক্রি',
            description: 'সম্পূর্ণ পুকুর হারভেস্ট',
            amount: 420000,
            date: DateTime.now().subtract(const Duration(days: 1)),
            type: 'Sale',
            isIncome: true,
          ),
        ],
      )
    );
  }

  // Add a new pond
  void addPond(String name, String area, String species, int fishCount, double initialCost) {
    final newPond = PondModel(
      id: 'POND_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      area: area,
      fishSpecies: species,
      stockedDate: DateTime.now(),
      totalFishCount: fishCount,
    );

    if (initialCost > 0) {
      newPond.activities.add(
        PondActivityModel(
          id: 'ACT_${DateTime.now().millisecondsSinceEpoch}',
          title: 'পোনা ক্রয়',
          description: '$fishCount টি $species পোনা',
          amount: initialCost,
          date: DateTime.now(),
          type: 'Stock',
        )
      );
    }

    ponds.add(newPond);
  }

  // Add an activity (cost/income) to a specific pond
  void addActivity(String pondId, String title, String description, double amount, String type, {bool isIncome = false}) {
    final pondIndex = ponds.indexWhere((p) => p.id == pondId);
    if (pondIndex != -1) {
      final pond = ponds[pondIndex];
      pond.activities.add(
        PondActivityModel(
          id: 'ACT_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}',
          title: title,
          description: description,
          amount: amount,
          date: DateTime.now(),
          type: type,
          isIncome: isIncome,
        )
      );
      // Trigger UI update
      ponds[pondIndex] = pond; 
    }
  }

  // Get total farm cost
  double get totalFarmCost {
    return ponds.fold(0.0, (sum, pond) => sum + pond.totalCost);
  }

  // Get total farm income
  double get totalFarmIncome {
    return ponds.fold(0.0, (sum, pond) => sum + pond.totalIncome);
  }
}
