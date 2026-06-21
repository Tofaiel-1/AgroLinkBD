import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiDiseaseService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? dotenv.env['API_KEY'] ?? '';

  static const String _systemPrompt = """
You are an expert Agricultural Scientist and Plant Pathologist working for the 'AgroLinkBD' platform in Bangladesh. I will provide you with an image of a diseased plant leaf. Your task is to carefully analyze the leaf, identify the disease, and provide a highly accurate, actionable solution tailored for Bangladeshi farmers.

Please provide the output strictly in the following JSON format, using simple and clear Bengali language (except for the English ID):

{
  "disease_id_en": "[English scientific or common name of the disease]",
  "plant_and_disease_bn": "[Plant and disease name in Bengali, e.g., আলুর লেট ব্লাইট (Late Blight)]",
  "cause_bn": "[Root cause - Fungi, Bacteria, or Pests]",
  "symptoms_bn": "[2-3 lines of primary symptoms for the farmer to verify visually]",
  "organic_remedy_bn": "[Home remedies or organic control methods]",
  "chemical_medicine_bn": "[Specific chemical medicines available in the Bangladesh market with dosage, e.g., প্রতি লিটার পানিতে ২ গ্রাম ম্যানকোজেব মিশিয়ে স্প্রে করুন]"
}
""";

  /// Analyzes an image and returns a Map containing the structured JSON response.
  static Future<Map<String, dynamic>?> analyzeImage(String imagePath) async {
    final apiKey = _apiKey;
    if (apiKey.isEmpty || apiKey == "YOUR_API_KEY_HERE") {
      debugPrint("AI Disease Service: API Key is not set. Falling back to mock data.");
      return null;
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
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
      final text = response.text;

      if (text != null && text.isNotEmpty) {
        // Parse the strictly formatted JSON
        return jsonDecode(text) as Map<String, dynamic>;
      } else {
        debugPrint("AI Disease Service: Empty response from Gemini API.");
        return null;
      }
    } catch (e) {
      debugPrint("AI Disease Service Error: $e");
      return null;
    }
  }
}
