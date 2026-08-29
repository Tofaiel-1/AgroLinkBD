class PondChemicalDosageResult {
  final String chemicalName;
  final String chemicalNameBN;
  final double requiredAmountKg;
  final String applicationMethod;
  final String purpose;
  final String safetyWarning;

  PondChemicalDosageResult({
    required this.chemicalName,
    required this.chemicalNameBN,
    required this.requiredAmountKg,
    required this.applicationMethod,
    required this.purpose,
    required this.safetyWarning,
  });
}

class FishDosageCalculatorService {
  /// Calculate Lime (চুন / ডলোমাইট) requirement
  /// Standard: প্রতি শতকে (প্রতি ফুট পানির গভীরতায়) ২৫০ গ্রাম থেকে ৫০০ গ্রাম
  /// If pH < 6.5 (অতিরিক্ত অম্লীয়): ৫০০ গ্রাম - ১ কেজি / শতক
  static PondChemicalDosageResult calculateLimeDosage({
    required double decimalArea,
    required double waterDepthFeet,
    required double currentPh,
  }) {
    double dosagePerDecimalPerFoot = 0.35; // kg
    if (currentPh < 6.0) {
      dosagePerDecimalPerFoot = 0.8;
    } else if (currentPh < 7.0) {
      dosagePerDecimalPerFoot = 0.45;
    } else if (currentPh >= 8.5) {
      dosagePerDecimalPerFoot = 0.1; // Maintenance only
    }

    final totalKg = decimalArea * waterDepthFeet * dosagePerDecimalPerFoot;

    return PondChemicalDosageResult(
      chemicalName: 'Agricultural Lime / Dolomite',
      chemicalNameBN: 'কৃষি চুন / ডলোমাইট',
      requiredAmountKg: double.parse(totalKg.toStringAsFixed(1)),
      applicationMethod: 'মাটির পাত্রে বা ড্রামে গুলিয়ে ঠান্ডা করে সকালের রোদে পুরো পুকুরে ছিটিয়ে দিন।',
      purpose: 'পানির অম্লত্ব দূর করা, পিএইচ স্বাভাবিক (৭.৫ - ৮.২) রাখা এবং রোগজীবাণু দমন।',
      safetyWarning: 'চুন গরম অবস্থায় সরাসরি পুকুরে ছিটাবেন না, এতে মাছের ক্ষতি হতে পারে।',
    );
  }

  /// Calculate Salt (লবণ) requirement
  /// Standard: প্রতি শতকে (প্রতি ফুট পানির গভীরতায়) ২৫০-৩০০ গ্রাম
  static PondChemicalDosageResult calculateSaltDosage({
    required double decimalArea,
    required double waterDepthFeet,
    bool forDiseaseOutbreak = false,
  }) {
    double dosagePerDecimal = forDiseaseOutbreak ? 0.45 : 0.25;
    final totalKg = decimalArea * waterDepthFeet * dosagePerDecimal;

    return PondChemicalDosageResult(
      chemicalName: 'Raw Salt',
      chemicalNameBN: 'অশোধিত মোটা লবণ',
      requiredAmountKg: double.parse(totalKg.toStringAsFixed(1)),
      applicationMethod: 'পানিতে সম্পূর্ণ গুলিয়ে বিকেলে বা ভোরে পুকুরের চারপাশে সমানভাবে ছিটান।',
      purpose: 'অসমোরেগুলেশন স্বাভাবিক রাখা, ফুলকার ঘা প্রতিরোধ ও বিষাক্ত গ্যাস প্রশমন।',
      safetyWarning: 'আয়োডিনযুক্ত প্যাকেটজাত লবণ ব্যবহার করবেন না, খামারের মোটা লবণ ব্যবহার করুন।',
    );
  }

  /// Calculate Zeolite (জিওলাইট) for Ammonia Removal
  /// Standard: প্রতি শতকে ৫০০ গ্রাম - ১ কেজি
  static PondChemicalDosageResult calculateZeoliteDosage({
    required double decimalArea,
    required double waterDepthFeet,
    required double ammoniaLevelPpm,
  }) {
    double dosagePerDecimal = 0.5;
    if (ammoniaLevelPpm > 1.0) {
      dosagePerDecimal = 1.0;
    } else if (ammoniaLevelPpm > 0.5) {
      dosagePerDecimal = 0.75;
    }

    final totalKg = decimalArea * waterDepthFeet * dosagePerDecimal;

    return PondChemicalDosageResult(
      chemicalName: 'Zeolite Granules / Powder',
      chemicalNameBN: 'জিওলাইট (গ্যাস নাশক)',
      requiredAmountKg: double.parse(totalKg.toStringAsFixed(1)),
      applicationMethod: 'শুকনো দানাদার জিওলাইট বালুর সাথে মিশিয়ে পুরো পুকুরে ছিটিয়ে দিন।',
      purpose: 'পুকুরের তলদেশের বিষাক্ত অ্যামোনিয়া, হাইড্রোজেন সালফাইড গ্যাস শোষণ ও তলদেশ শোধন।',
      safetyWarning: 'প্রয়োগের পর পুকুরে হালকা জাল টেনে দিলে তলদেশের গ্যাস দ্রুত বের হয়ে যায়।',
    );
  }

  /// Calculate Probiotics (অ্যাকোয়া প্রোবায়োটিক)
  /// Standard: প্রতি শতকে ২০-৩০ গ্রাম (পানির গভীরতা ৩-৪ ফুট)
  static PondChemicalDosageResult calculateProbioticDosage({
    required double decimalArea,
  }) {
    final totalGrams = decimalArea * 25.0; // grams
    final totalKg = totalGrams / 1000.0;

    return PondChemicalDosageResult(
      chemicalName: 'Aqua Probiotics',
      chemicalNameBN: 'উপকারী অ্যাকোয়া প্রোবায়োটিক',
      requiredAmountKg: double.parse(totalKg.toStringAsFixed(2)),
      applicationMethod: 'চিটাগুড় (মোলাসেস) ও পানির সাথে ২৪ ঘণ্টা ফার্মেন্টেশন করে সকাল ১০টায় ছিটান।',
      purpose: 'ক্ষতিকারক ব্যাকটেরিয়া দমন, পানির প্রাকৃতিক খাদ্য (প্লাঙ্কটন) বৃদ্ধি ও তলদেশের বর্জ্য পচন।',
      safetyWarning: 'জীবাণুনাশক (যেমন পটাশ বা ব্লিচিং) দেওয়ার অন্তত ৭২ ঘণ্টা পর প্রোবায়োটিক দিন।',
    );
  }

  /// Calculate Potassium Permanganate (পটাশ) for Disinfection
  /// Standard: প্রতি শতকে ১.৫ - ২.০ গ্রাম
  static PondChemicalDosageResult calculatePotashDosage({
    required double decimalArea,
    required double waterDepthFeet,
  }) {
    final totalGrams = decimalArea * waterDepthFeet * 1.8;
    final totalKg = totalGrams / 1000.0;

    return PondChemicalDosageResult(
      chemicalName: 'Potassium Permanganate',
      chemicalNameBN: 'পটাশিয়াম পারম্যাঙ্গানেট (পটাশ)',
      requiredAmountKg: double.parse(totalKg.toStringAsFixed(3)),
      applicationMethod: 'বালতিতে পানি নিয়ে ভালো করে মিশিয়ে লালচে দ্রবণ তৈরি করে সকালের রোদে ছিটান।',
      purpose: 'ক্ষত রোগ (EUS), ফুলকা পচা এবং বহিঃপরজীবী সংক্রমণ দূরীকরণ।',
      safetyWarning: 'অতিরিক্ত মাত্রায় ব্যবহার করবেন না, তীব্র রোদের সময় মাছের ফুলকা পুড়ে যেতে পারে।',
    );
  }
}
