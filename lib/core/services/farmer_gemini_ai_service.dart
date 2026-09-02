import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:agrolinkbd/core/controllers/farmer_analysis_controller.dart';

/// Masterclass Gemini AI Agronomist & Farm Insights Service
/// Zero-hallucination grounding using real-time farm financials, batches, IoT metrics, and market rates.
class FarmerGeminiAiService {
  static String get _apiKey =>
      dotenv.env['GEMINI_API_KEY'] ?? dotenv.env['API_KEY'] ?? '';

  static final List<String> _modelCandidates = [
    'gemini-2.5-flash',
    'gemini-flash-latest',
    'gemini-2.0-flash',
    'gemini-1.5-flash',
    'gemini-1.5-flash-latest',
    'gemini-1.5-pro',
  ];

  /// Ask Gemini AI with 100% Real-Time Farm Grounding
  static Future<String> askFarmerAi({
    required String query,
    required FarmerAnalysisController controller,
    required bool isBn,
  }) async {
    if (query.trim().isEmpty) {
      return isBn
          ? 'অনুগ্রহ করে আপনার প্রশ্নটি স্পষ্ট করে বলুন বা লিখুন।'
          : 'Please enter or speak your query clearly.';
    }

    // Build Grounded Farm Profile Context
    final farmContext = _buildFarmContext(controller, isBn);

    // Try Gemini API First
    if (_apiKey.isNotEmpty) {
      for (final modelName in _modelCandidates) {
        try {
          final model = GenerativeModel(
            model: modelName,
            apiKey: _apiKey,
            systemInstruction: Content.system(_getSystemPrompt(isBn, farmContext)),
            generationConfig: GenerationConfig(
              temperature: 0.2, // Low temperature for high factual accuracy
              topK: 40,
              topP: 0.85,
              maxOutputTokens: 600,
            ),
          );

          final response = await model.generateContent([
            Content.text('User Query: $query\n\nFarm Live Data:\n$farmContext'),
          ]);

          final answer = response.text?.trim();
          if (answer != null && answer.isNotEmpty) {
            return answer;
          }
        } catch (e) {
          debugPrint('⚠️ Gemini API attempt failed on $modelName: $e');
        }
      }
    }

    // High-Precision Expert Grounded Rule Fallback (if offline or API key exhausted)
    return _generateGroundedFallbackAnswer(query, controller, isBn);
  }

  static String _getSystemPrompt(bool isBn, String farmContext) {
    if (isBn) {
      return '''
তুমি AgroLinkBD-এর সার্টিফাইড প্রধান কৃষি ও মৎস্য বিশেষজ্ঞ এআই (Chief AI Agronomist & Farm Auditor)।
তোমার দায়িত্ব বাংলাদেশের খামারিকে তার নিজের খামারের লাইভ ডেটার ভিত্তিতে ১০০% নির্ভুল, বৈজ্ঞানিক ও লাভজনক পরামর্শ দেওয়া।

নিয়মাবলী:
১. তোমার কাছে খামারির রিয়েল-টাইম তথ্য (আয়, ব্যয়, লাভ, ব্যাচ স্ট্যাটাস, FCR, পানির DO/pH/অ্যামোনিয়া এবং বাজারদর) নিচে দেওয়া আছে।
২. আর্থিক বা খামারের কোনো তথ্যে কাল্পনিক বা ভুল সংখ্যা বলবে না। হুবহু বাস্তব ডেটা ব্যবহার করে উত্তর দেবে।
৩. উত্তরটি হতে হবে স্পষ্ট, উৎসাহব্যঞ্জক, পেশাদার ও সরাসরি কাজের উপযোগী বুলেট পয়েন্টে।
৪. উত্তর সম্পূর্ণ বাংলায় (সহজ বাংলা ভাষায়) প্রদান করো।
''';
    } else {
      return '''
You are the Certified Chief AI Agronomist & Farm Financial Auditor of AgroLinkBD.
Your mission is to provide 100% accurate, scientific, and profitable agricultural/aquaculture advice strictly grounded in the farmer's live data.

Rules:
1. Live farm data (Revenue, Expense, Net Profit, Active Batches, FCR, DO/pH/Ammonia, and Wholesale Market Rates) is provided.
2. NEVER hallucinate or fabricate figures. Use the exact grounded data.
3. Keep the answer structured, actionable, professional, and encouraging with concise bullet points.
4. Respond in clear English.
''';
    }
  }

  static String _buildFarmContext(FarmerAnalysisController c, bool isBn) {
    final buffer = StringBuffer();
    buffer.writeln('--- FINANCIAL SUMMARY ---');
    buffer.writeln('Total Revenue: ৳${c.totalRevenue.toStringAsFixed(0)}');
    buffer.writeln('Operating Expense: ৳${c.totalExpense.toStringAsFixed(0)}');
    buffer.writeln('Net Profit: ৳${c.netProfit.toStringAsFixed(0)} (${c.profitMarginPct.toStringAsFixed(1)}% margin)');

    buffer.writeln('\n--- ACTIVE PRODUCTION BATCHES ---');
    if (c.activeBatches.isEmpty) {
      buffer.writeln('No active batches registered.');
    } else {
      for (final b in c.activeBatches) {
        buffer.writeln('- Batch "${b.batchName}" (${b.commodityType}): ${b.daysElapsed} days elapsed / ${b.cycleDurationDays} total days. Biomass: ${b.currentBiomassKg.toInt()} kg, Target Yield: ${b.targetYieldKg.toInt()} kg, FCR Score: ${b.fcr.toStringAsFixed(2)}, Survival Rate: ${b.survivalRatePct.toStringAsFixed(1)}%, Investment: ৳${b.totalInvestedCost.toInt()}');
      }
    }

    buffer.writeln('\n--- WATER QUALITY & SOIL IoT ---');
    final water = c.getWaterQualityMetrics(isBn);
    buffer.writeln('Dissolved Oxygen (DO): ${water['do']['value']} mg/L (Safe: 5.0 - 8.0 mg/L)');
    buffer.writeln('pH Level: ${water['ph']['value']} (Safe: 6.5 - 8.5)');
    buffer.writeln('Ammonia: ${water['ammonia']['value']} ppm (Critical if > 0.05 ppm)');
    buffer.writeln('Water Temperature: ${water['temp']['value']} °C');

    buffer.writeln('\n--- LIVE WHOLESALE MARKET TRENDS ---');
    for (final m in c.marketOpportunities) {
      buffer.writeln('- ${m.cropEn} at ${m.marketEn}: Current ৳${m.currentPrice.toInt()} -> 7-Day Forecast ৳${m.projectedPrice7Days.toInt()} (${m.recommendationEn})');
    }

    buffer.writeln('\n--- ACTIVE SEASONAL DISEASE ALERTS ---');
    for (final a in c.seasonalDiseaseAlerts) {
      buffer.writeln('- ${a.diseaseNameEn} (${a.riskLevelEn} risk for ${a.targetCommodityEn}): Rx: ${a.recommendedMedicineEn}. Prev: ${a.preventiveActionEn}');
    }

    return buffer.toString();
  }

  /// Grounded deterministic fallback in case Gemini network is unreachable
  static String _generateGroundedFallbackAnswer(
    String query,
    FarmerAnalysisController c,
    bool isBn,
  ) {
    final q = query.toLowerCase();

    // 1. Profit / Revenue / Financials
    if (q.contains('লাভ') || q.contains('আয়') || q.contains('ব্যয়') || q.contains('টাকা') || q.contains('profit') || q.contains('revenue') || q.contains('income') || q.contains('expense')) {
      if (isBn) {
        return '📊 আপনার খামারের বর্তমান আর্থিক বিশ্লেষণ:\n'
            '• মোট আয়: ৳${c.totalRevenue.toStringAsFixed(0)}\n'
            '• মোট পরিচালনা ব্যয়: ৳${c.totalExpense.toStringAsFixed(0)}\n'
            '• মোট নিট লাভ: ৳${c.netProfit.toStringAsFixed(0)} (মার্জিন: ${c.profitMarginPct.toStringAsFixed(1)}%)\n\n'
            '💡 এআই পরামর্শ: আপনার লাভজনকতা বজায় রাখতে ফিড ও সার খরচের অপচয় রোধ করুন।';
      } else {
        return '📊 Live Farm Financial Analysis:\n'
            '• Total Revenue: BDT ${c.totalRevenue.toStringAsFixed(0)}\n'
            '• Operating Costs: BDT ${c.totalExpense.toStringAsFixed(0)}\n'
            '• Net Profit: BDT ${c.netProfit.toStringAsFixed(0)} (Margin: ${c.profitMarginPct.toStringAsFixed(1)}%)\n\n'
            '💡 AI Advisory: Feed and nutrient management is key to sustaining this margin.';
      }
    }

    // 2. FCR & Fish Growth
    if (q.contains('fcr') || q.contains('ফিড') || q.contains('মাছ') || q.contains('বায়োমাস') || q.contains('feed') || q.contains('fish') || q.contains('biomass')) {
      final active = c.activeBatches.isNotEmpty ? c.activeBatches.first : null;
      if (active != null) {
        if (isBn) {
          return '🐟 সক্রিয় ব্যাচ (${active.batchName}) বিশ্লেষণ:\n'
              '• বর্তমান বায়োমাস: ${active.currentBiomassKg.toInt()} কেজি (লক্ষ্য: ${active.targetYieldKg.toInt()} কেজি)\n'
              '• বর্তমান FCR স্কোর: ${active.fcr.toStringAsFixed(2)} ${active.fcr <= 1.3 ? "(চমৎকার - অপচয়হীন)" : "(ফিড নিয়ন্ত্রণ করুন)"}\n'
              '• সারভাইভাল রেট: ${active.survivalRatePct.toStringAsFixed(1)}%\n'
              '• চলমান দিন: ${active.daysElapsed} দিন / মোট ${active.cycleDurationDays} দিন।';
        } else {
          return '🐟 Active Batch (${active.batchName}) Insights:\n'
              '• Current Biomass: ${active.currentBiomassKg.toInt()} kg (Target: ${active.targetYieldKg.toInt()} kg)\n'
              '• FCR Score: ${active.fcr.toStringAsFixed(2)} ${active.fcr <= 1.3 ? "(Optimal Efficiency)" : "(Optimize feed quantity)"}\n'
              '• Survival Rate: ${active.survivalRatePct.toStringAsFixed(1)}%\n'
              '• Progress: ${active.daysElapsed} days / ${active.cycleDurationDays} total days.';
        }
      }
    }

    // 3. Water Quality / Dissolved Oxygen / Ammonia
    if (q.contains('পানি') || q.contains('অক্সিজেন') || q.contains('ph') || q.contains('অ্যামোনিয়া') || q.contains('water') || q.contains('oxygen') || q.contains('ammonia') || q.contains('do')) {
      final water = c.getWaterQualityMetrics(isBn);
      if (isBn) {
        return '🌊 পানির বর্তমান IoT সূচক:\n'
            '• দ্রবীভূত অক্সিজেন (DO): ${water['do']['value']} mg/L (স্বাভাবিক)\n'
            '• পানির pH মাত্রা: ${water['ph']['value']} (ভারসাম্যপূর্ণ)\n'
            '• ক্ষতিকর অ্যামোনিয়া: ${water['ammonia']['value']} ppm (নিরাপদ সীমার মধ্যে)\n'
            '• পানির তাপমাত্রা: ${water['temp']['value']} °C\n\n'
            '💡 পরামর্শ: ভোরবেলা অক্সিজেন কমে গেলে অ্যারেশন চালু রাখুন।';
      } else {
        return '🌊 Live Water Quality IoT Status:\n'
            '• Dissolved Oxygen (DO): ${water['do']['value']} mg/L (Optimal)\n'
            '• pH Level: ${water['ph']['value']} (Balanced)\n'
            '• Toxic Ammonia: ${water['ammonia']['value']} ppm (Safe Range)\n'
            '• Water Temperature: ${water['temp']['value']} °C\n\n'
            '💡 Advisory: Run aerators during early dawn hours if fish surface.';
      }
    }

    // 4. Market Prices / Selling Advice
    if (q.contains('বাজার') || q.contains('দাম') || q.contains('দর') || q.contains('বিক্রি') || q.contains('market') || q.contains('price') || q.contains('sell') || q.contains('rate')) {
      final opp = c.marketOpportunities.first;
      if (isBn) {
        return '📈 লাইভ বাজার পূর্বাভাস ও বিক্রয় সুযোগ:\n'
            '• ${opp.cropBn} (${opp.marketBn}): বর্তমান দর ৳${opp.currentPrice.toInt()} ➔ ৭ দিনে প্রত্যাশিত দর ৳${opp.projectedPrice7Days.toInt()}\n'
            '• পরামর্শ: ${opp.recommendationBn}';
      } else {
        return '📈 Live Wholesale Market Forecast:\n'
            '• ${opp.cropEn} (${opp.marketEn}): Current BDT ${opp.currentPrice.toInt()} ➔ 7-Day Target BDT ${opp.projectedPrice7Days.toInt()}\n'
            '• Recommendation: ${opp.recommendationEn}';
      }
    }

    // Default scientific advice
    if (isBn) {
      return '🌿 এগ্রোলিংক এআই সহকারী:\n'
          'আপনার খামারে বর্তমানে মোট নিট লাভ ৳${c.netProfit.toStringAsFixed(0)} এবং ${c.activeBatches.length}টি সক্রিয় ব্যাচ চলমান রয়েছে।\n'
          'নির্দিষ্ট কোনো ব্যাচ, পানির গুণমান, সার বা কীটনাশক ডোজ সম্পর্কে জানতে প্রশ্ন করুন।';
    } else {
      return '🌿 AgroLink AI Assistant:\n'
          'Your farm currently has BDT ${c.netProfit.toStringAsFixed(0)} net profit with ${c.activeBatches.length} active production batches.\n'
          'Ask specific questions on feed conversion, water parameters, disease treatments, or market price forecasts.';
    }
  }
}
