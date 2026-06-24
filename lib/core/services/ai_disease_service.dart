import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiDiseaseService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? dotenv.env['API_KEY'] ?? '';

  static const String _systemPrompt = """
You are an expert Agricultural AI Plant Doctor designed for real-world farming use in Bangladesh.

Your primary objective is NOT to predict a disease immediately.
Your first responsibility is to verify whether the uploaded image is suitable for diagnosis.
You must follow the workflow strictly and never skip any step.

STEP 1: IMAGE QUALITY VALIDATION
Check blur level, brightness, contrast, resolution, visibility, occlusion, and distance.
If blurry, dark, overexposed, low resolution, partially visible, or heavily obstructed, DO NOT diagnose. Mark quality as "Poor".

STEP 2: PLANT PART VERIFICATION
Determine whether the image contains a Leaf, Fruit, Flower, Stem, Root, or Whole Plant.
If no plant part is detected, Mark plant_detected as false and DO NOT attempt disease prediction.

STEP 3: LEAF VALIDATION
If diagnosis is intended from leaf analysis, verify a leaf is actually present, occupies sufficient area, and texture/venation are visible.

STEP 4: PLANT SPECIES IDENTIFICATION
Identify plant species first (e.g., Rice, Tomato, Potato, Mango, etc.). Provide confidence percentage.
If confidence is below 70%, Mark diagnosis_status as "Uncertain" and do not diagnose disease.

STEP 5: DISEASE ANALYSIS
Only after successful plant identification. Analyze spots, lesions, color changes, wilting, mold, necrosis, etc.
Predict disease only if visual evidence exists.

STEP 6: UNKNOWN CONDITION DETECTION
Never force a prediction. If symptoms do not match known conditions, mark diagnosis_status as "Unknown". Never label unknown conditions as healthy.

STEP 7: HEALTHY PLANT VERIFICATION
Before declaring healthy, verify no lesions, discoloration, fungal growth, pest damage, or abnormal morphology. If image quality is insufficient, do not declare healthy.

STEP 8: CONFIDENCE-BASED DECISION
If confidence is below 70%, do not provide a definitive diagnosis.

STEP 9: EXPLANATION REQUIREMENT
For every diagnosis explain what symptoms were observed, why the disease was predicted, and which visual patterns support the conclusion.

STEP 10: SEVERITY ASSESSMENT
Estimate severity: Mild, Moderate, Severe.

STEP 11: RECOMMENDATIONS
Provide cultural control, preventive measures, monitoring advice, and safe treatment suggestions.

FINAL RESPONSE FORMAT
You must return your entire final assessment as a single valid JSON object in the following format. All text content must be in clear Bengali language for the farmers (except the keys).

{
  "image_quality": "Good" | "Poor",
  "quality_reason": "Explanation of image quality",
  "action_required": "What the user should do if quality is poor",
  "plant_detected": true | false,
  "plant_part": "Leaf" | "Fruit" | "Flower" | "Stem" | "Root" | "Whole Plant" | "None",
  "plant_identified": "Name of the plant species in Bengali",
  "plant_confidence": 95,
  "diagnosis_status": "Success" | "Healthy" | "Unknown" | "Uncertain" | "Failed",
  "disease_name": "Name of disease in Bengali (if applicable)",
  "disease_confidence": 90,
  "observed_symptoms": ["symptom 1", "symptom 2"],
  "severity": "Mild" | "Moderate" | "Severe" | "N/A",
  "reasoning": "Detailed reasoning based on visible symptoms",
  "recommendations": ["recommendation 1", "recommendation 2"],
  "reliability": "Very High" | "High" | "Moderate" | "Uncertain"
}

CRITICAL RULES:
Never diagnose a non-plant object (human, animal, building, etc.).
Never force a prediction.
Always identify the plant before identifying disease.
""";

  /// Analyzes an image and returns a Map containing the structured JSON response.
  static Future<Map<String, dynamic>?> analyzeImage(String imagePath) async {
    final apiKey = _apiKey;
    if (apiKey.isEmpty || apiKey == "YOUR_API_KEY_HERE") {
      debugPrint("AI Disease Service: API Key is not set.");
      return {'error': 'API Key is missing'};
    }

    final modelsToTry = [
      'gemini-2.5-flash',
      'gemini-flash-latest',
      'gemini-3.5-flash',
      'gemini-2.0-flash',
      'gemini-1.5-flash-latest',
    ];

    String lastError = '';

    for (final modelName in modelsToTry) {
      try {
        debugPrint("AI Disease Service: Trying model \$modelName...");
        final model = GenerativeModel(
          model: modelName,
          apiKey: apiKey,
          generationConfig: GenerationConfig(
            responseMimeType: 'application/json',
          ),
        );

        final imageFile = File(imagePath);
        final imageBytes = await imageFile.readAsBytes();
        
        final content = [
          Content.multi([
            TextPart(_systemPrompt),
            DataPart('image/jpeg', imageBytes),
          ])
        ];

        final response = await model.generateContent(content);
        String text = response.text ?? '';

        if (text.isNotEmpty) {
          debugPrint("AI Disease Service: SUCCESS with model \$modelName!");
          
          text = text.trim();
          if (text.startsWith('```json')) {
            text = text.substring(7);
          } else if (text.startsWith('```')) {
            text = text.substring(3);
          }
          if (text.endsWith('```')) {
            text = text.substring(0, text.length - 3);
          }
          text = text.trim();
          
          return jsonDecode(text) as Map<String, dynamic>;
        }
      } catch (e) {
        lastError = e.toString();
        debugPrint("AI Disease Service Error for \$modelName: \$lastError");
        
        // If the error is about model not found, continue to next model.
        if (lastError.contains("is not found") || lastError.contains("is not supported")) {
          continue;
        } else {
          // If it's a different error (like rate limit or network), break and return it.
          return {'error': lastError};
        }
      }
    }

    // If all models failed
    return {'error': "কোনো সমর্থিত এআই মডেল পাওয়া যায়নি। সর্বশেষ এরর: $lastError"};
  }
}
