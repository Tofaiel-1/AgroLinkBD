import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/soil_test_model.dart';

class SoilAnalysisService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Analyze soil from image
  Future<SoilTestModel> analyzeSoil({
    required File imageFile,
    required String farmerId,
    required String location,
    double? latitude,
    double? longitude,
  }) async {
    // Upload image to Firebase Storage
    String imageUrl = await _uploadImage(imageFile, farmerId);

    // Analyze image
    img.Image? image = img.decodeImage(imageFile.readAsBytesSync());
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Get dominant color
    Map<String, int> dominantColor = _getDominantColor(image);

    // Determine soil type based on color
    SoilType soilType = _determineSoilType(dominantColor);

    // Analyze soil health
    SoilHealthStatus healthStatus = _analyzeSoilHealth(dominantColor);

    // Estimate nutrients
    Map<String, dynamic> nutrients = _estimateNutrients(
      dominantColor,
      soilType,
    );

    // Generate recommendations
    List<String> recommendations = _generateRecommendations(
      soilType,
      healthStatus,
      nutrients,
    );

    // Create soil test model
    SoilTestModel soilTest = SoilTestModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      farmerId: farmerId,
      location: location,
      latitude: latitude,
      longitude: longitude,
      imageUrl: imageUrl,
      soilType: soilType,
      healthStatus: healthStatus,
      nutrients: nutrients,
      recommendations: recommendations,
      testedAt: DateTime.now(),
    );

    // Save to Firestore
    await _firestore
        .collection('soil_tests')
        .doc(soilTest.id)
        .set(soilTest.toJson());

    return soilTest;
  }

  // Upload image to Firebase Storage
  Future<String> _uploadImage(File imageFile, String farmerId) async {
    String fileName =
        'soil_tests/$farmerId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    Reference ref = _storage.ref().child(fileName);
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  // Get dominant color from image
  Map<String, int> _getDominantColor(img.Image image) {
    int redSum = 0, greenSum = 0, blueSum = 0;
    int pixelCount = 0;

    // Sample pixels from center region (more representative of soil)
    int startX = image.width ~/ 4;
    int endX = (image.width * 3) ~/ 4;
    int startY = image.height ~/ 4;
    int endY = (image.height * 3) ~/ 4;

    for (int y = startY; y < endY; y += 5) {
      for (int x = startX; x < endX; x += 5) {
        final pixel = image.getPixel(x, y);
        redSum += pixel.r.toInt();
        greenSum += pixel.g.toInt();
        blueSum += pixel.b.toInt();
        pixelCount++;
      }
    }

    return {
      'r': redSum ~/ pixelCount,
      'g': greenSum ~/ pixelCount,
      'b': blueSum ~/ pixelCount,
    };
  }

  // Determine soil type based on color
  SoilType _determineSoilType(Map<String, int> color) {
    int r = color['r']!;
    int g = color['g']!;
    int b = color['b']!;

    // Brown/dark colors - clay or loam
    if (r > 100 && r < 150 && g > 80 && g < 130 && b > 60 && b < 110) {
      return SoilType.loam;
    }
    // Dark brown/black - rich in organic matter
    else if (r < 80 && g < 80 && b < 80) {
      return SoilType.peat;
    }
    // Light brown/tan - sandy
    else if (r > 150 && g > 130 && b > 100) {
      return SoilType.sandy;
    }
    // Reddish brown - clay
    else if (r > g + 20) {
      return SoilType.clay;
    }
    // Grayish - silt
    else if (r > 120 && g > 120 && b > 120) {
      return SoilType.silt;
    }

    return SoilType.loam; // Default
  }

  // Analyze soil health
  SoilHealthStatus _analyzeSoilHealth(Map<String, int> color) {
    int r = color['r']!;
    int g = color['g']!;
    int b = color['b']!;

    // Dark, rich colors indicate good health
    int brightness = (r + g + b) ~/ 3;

    if (brightness < 80) {
      return SoilHealthStatus.excellent;
    } else if (brightness < 120) {
      return SoilHealthStatus.good;
    } else if (brightness < 160) {
      return SoilHealthStatus.average;
    } else {
      return SoilHealthStatus.poor;
    }
  }

  // Estimate nutrient levels (simplified)
  Map<String, dynamic> _estimateNutrients(
    Map<String, int> color,
    SoilType soilType,
  ) {
    // This is a simplified estimation
    // In a real app, you'd use ML models trained on soil data

    double nitrogen = 0.0, phosphorus = 0.0, potassium = 0.0;

    switch (soilType) {
      case SoilType.loam:
        nitrogen = 0.7;
        phosphorus = 0.6;
        potassium = 0.7;
        break;
      case SoilType.clay:
        nitrogen = 0.6;
        phosphorus = 0.5;
        potassium = 0.8;
        break;
      case SoilType.sandy:
        nitrogen = 0.3;
        phosphorus = 0.4;
        potassium = 0.3;
        break;
      case SoilType.peat:
        nitrogen = 0.9;
        phosphorus = 0.7;
        potassium = 0.6;
        break;
      default:
        nitrogen = 0.5;
        phosphorus = 0.5;
        potassium = 0.5;
    }

    return {
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'ph': 6.5, // Default neutral pH
    };
  }

  // Generate recommendations
  List<String> _generateRecommendations(
    SoilType soilType,
    SoilHealthStatus healthStatus,
    Map<String, dynamic> nutrients,
  ) {
    List<String> recommendations = [];

    // Nitrogen recommendations
    if (nutrients['nitrogen'] < 0.5) {
      recommendations.add(
        'মাটিতে নাইট্রোজেনের ঘাটতি রয়েছে। ইউরিয়া সার প্রয়োগ করুন।',
      );
    }

    // Phosphorus recommendations
    if (nutrients['phosphorus'] < 0.5) {
      recommendations.add('ফসফরাসের ঘাটতি রয়েছে। টিএসপি সার ব্যবহার করুন।');
    }

    // Potassium recommendations
    if (nutrients['potassium'] < 0.5) {
      recommendations.add('পটাশিয়ামের ঘাটতি রয়েছে। এমওপি সার প্রয়োগ করুন।');
    }

    // Soil type specific recommendations
    switch (soilType) {
      case SoilType.sandy:
        recommendations.add(
          'বালুময় মাটি। নিয়মিত জৈব সার প্রয়োগ করুন এবং ঘন ঘন সেচ দিন।',
        );
        break;
      case SoilType.clay:
        recommendations.add(
          'এঁটেল মাটি। জল নিকাশের ব্যবস্থা করুন এবং জৈব পদার্থ যোগ করুন।',
        );
        break;
      case SoilType.loam:
        recommendations.add(
          'দোআঁশ মাটি। এটি চাষের জন্য উত্তম। নিয়মিত যত্ন নিন।',
        );
        break;
      default:
        break;
    }

    // Health status recommendations
    if (healthStatus == SoilHealthStatus.poor) {
      recommendations.add(
        'মাটির স্বাস্থ্য খারাপ। কম্পোস্ট এবং জৈব সার ব্যবহার করুন।',
      );
    }

    if (recommendations.isEmpty) {
      recommendations.add('মাটির অবস্থা ভালো। বর্তমান চাষ পদ্ধতি চালিয়ে যান।');
    }

    return recommendations;
  }

  // Get soil test history
  Future<List<SoilTestModel>> getSoilTestHistory(String farmerId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('soil_tests')
        .where('farmerId', isEqualTo: farmerId)
        .orderBy('testedAt', descending: true)
        .limit(10)
        .get();

    return snapshot.docs
        .map(
          (doc) => SoilTestModel.fromJson(doc.data() as Map<String, dynamic>),
        )
        .toList();
  }
}
