class FishFcrSimulationResult {
  final double fcr;                  // Feed Conversion Ratio (যেমন ১.৩)
  final String fcrRating;            // 'চমৎকার', 'ভালো', 'উদ্বেগজনক'
  final double totalBiomassKg;       // পুকুরে মোট মাছের ওজন (কেজি)
  final double totalWeightGainKg;    // নিট ওজন বৃদ্ধি (কেজি)
  final double totalFeedCost;        // মোট ফিড খরচ (৳)
  final double feedCostPerKgFish;    // প্রতি কেজি মাছ উৎপাদনে ফিড খরচ (৳)
  final double estimatedGrossRevenue;// আনুমানিক বাজারমূল্য (৳)
  final double estimatedNetProfit;   // নিট আনুমানিক মুনাফা (৳)
  final double profitMarginPercent;  // লাভের হার (%)
  final String harvestAdvice;        // হারভেস্ট পরামর্শ

  FishFcrSimulationResult({
    required this.fcr,
    required this.fcrRating,
    required this.totalBiomassKg,
    required this.totalWeightGainKg,
    required this.totalFeedCost,
    required this.feedCostPerKgFish,
    required this.estimatedGrossRevenue,
    required this.estimatedNetProfit,
    required this.profitMarginPercent,
    required this.harvestAdvice,
  });
}

class FishFcrCalculatorService {
  /// Calculate FCR and Project Profit
  /// Formula: FCR = Total Feed Consumed (kg) / Net Biomass Weight Gain (kg)
  static FishFcrSimulationResult calculateFcr({
    required int totalFishCount,
    required double survivalRatePercent, // e.g. 90%
    required double initialAvgWeightGram,// e.g. 20g fingerling
    required double currentAvgWeightGram,// e.g. 1200g (1.2kg)
    required double totalFeedGivenKg,    // e.g. 6500 kg
    required double feedPricePerKg,      // e.g. 68 Tk/kg
    required double expectedMarketPricePerKg, // e.g. 280 Tk/kg
    required double otherExpenses,       // Fingerling + medicine + electricity
  }) {
    final activeFishCount = (totalFishCount * survivalRatePercent) / 100.0;
    final initialBiomassKg = (activeFishCount * initialAvgWeightGram) / 1000.0;
    final currentBiomassKg = (activeFishCount * currentAvgWeightGram) / 1000.0;
    final netWeightGainKg = currentBiomassKg - initialBiomassKg;

    double fcr = 0.0;
    if (netWeightGainKg > 0) {
      fcr = totalFeedGivenKg / netWeightGainKg;
    }

    String fcrRating;
    if (fcr <= 1.25) {
      fcrRating = 'চমৎকার (Excellent - খুব কম খরচে সর্বোচ্চ বৃদ্ধি)';
    } else if (fcr <= 1.55) {
      fcrRating = 'সন্তোষজনক (Good - স্বাভাবিক লাভজনক মান)';
    } else if (fcr <= 1.85) {
      fcrRating = 'মাঝারি (Average - খাদ্য অপচয় কমানো প্রয়োজন)';
    } else {
      fcrRating = 'উদ্বেগজনক (High FCR - অতিরিক্ত খাবার নষ্ট হচ্ছে)';
    }

    final totalFeedCost = totalFeedGivenKg * feedPricePerKg;
    final totalProductionCost = totalFeedCost + otherExpenses;
    final feedCostPerKg = netWeightGainKg > 0 ? (totalFeedCost / currentBiomassKg) : 0.0;

    final grossRevenue = currentBiomassKg * expectedMarketPricePerKg;
    final netProfit = grossRevenue - totalProductionCost;
    final profitMargin = grossRevenue > 0 ? (netProfit / grossRevenue) * 100.0 : 0.0;

    // Harvest Advice Logic
    String harvestAdvice;
    if (currentAvgWeightGram >= 1500 && fcr > 1.6) {
      harvestAdvice = 'মাছের সাইজ উপযুক্ত এবং FCR বাড়ছে। অবিলম্বে হারভেস্ট করে বিক্রি করলে সর্বোচ্চ মুনাফা পাবেন।';
    } else if (currentAvgWeightGram >= 1000 && profitMargin > 30) {
      harvestAdvice = 'খামারে সুস্থ বৃদ্ধির ধারা রয়েছে। চাইলে আগাম চুক্তিতে ২০-৩০% অগ্রিম নিয়ে বিক্রি বুকিং দিতে পারেন।';
    } else {
      harvestAdvice = 'নিয়মিত ফিডিং ও পানির অক্সিজেন ঠিক রাখুন। আগামী ২০-৩০ দিনের মধ্যে কাঙ্ক্ষিত ওজনে পৌঁছাবে।';
    }

    return FishFcrSimulationResult(
      fcr: double.parse(fcr.toStringAsFixed(2)),
      fcrRating: fcrRating,
      totalBiomassKg: double.parse(currentBiomassKg.toStringAsFixed(1)),
      totalWeightGainKg: double.parse(netWeightGainKg.toStringAsFixed(1)),
      totalFeedCost: double.parse(totalFeedCost.toStringAsFixed(0)),
      feedCostPerKgFish: double.parse(feedCostPerKg.toStringAsFixed(1)),
      estimatedGrossRevenue: double.parse(grossRevenue.toStringAsFixed(0)),
      estimatedNetProfit: double.parse(netProfit.toStringAsFixed(0)),
      profitMarginPercent: double.parse(profitMargin.toStringAsFixed(1)),
      harvestAdvice: harvestAdvice,
    );
  }
}
