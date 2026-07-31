class WeatherModel {
  final double temperature;
  final double feelsLike;
  final String condition;
  final int weatherCode;
  final double rainMm;
  final int rainProbability;
  final int humidity;
  final double windSpeedKmH;
  final String locationName;
  final bool isDay;
  final String agriAdvice;

  WeatherModel({
    required this.temperature,
    required this.feelsLike,
    required this.condition,
    required this.weatherCode,
    required this.rainMm,
    required this.rainProbability,
    required this.humidity,
    required this.windSpeedKmH,
    required this.locationName,
    required this.isDay,
    required this.agriAdvice,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json, String locationName) {
    final current = json['current'] ?? {};
    final hourly = json['hourly'] ?? {};
    
    double temp = (current['temperature_2m'] as num?)?.toDouble() ?? 28.0;
    double apparentTemp = (current['apparent_temperature'] as num?)?.toDouble() ?? temp;
    int code = (current['weather_code'] as num?)?.toInt() ?? 0;
    double rain = (current['rain'] as num?)?.toDouble() ?? (current['precipitation'] as num?)?.toDouble() ?? 0.0;
    int humid = (current['relative_humidity_2m'] as num?)?.toInt() ?? 70;
    double wind = (current['wind_speed_10m'] as num?)?.toDouble() ?? 12.0;
    bool day = (current['is_day'] as num?)?.toInt() == 1;

    // Rain probability from hourly data if available
    int rainProb = 0;
    if (hourly['precipitation_probability'] != null && (hourly['precipitation_probability'] as List).isNotEmpty) {
      rainProb = ((hourly['precipitation_probability'] as List).first as num).toInt();
    }

    String cond = _getConditionText(code);
    String advice = _getAgriAdvice(code, rain, wind, temp);

    return WeatherModel(
      temperature: temp,
      feelsLike: apparentTemp,
      condition: cond,
      weatherCode: code,
      rainMm: rain,
      rainProbability: rainProb,
      humidity: humid,
      windSpeedKmH: wind,
      locationName: locationName,
      isDay: day,
      agriAdvice: advice,
    );
  }

  static String _getConditionText(int code) {
    switch (code) {
      case 0:
        return 'পরিষ্কার আকাশ';
      case 1:
      case 2:
        return 'আংশিক মেঘলা';
      case 3:
        return 'মেঘলা আকাশ';
      case 45:
      case 48:
        return 'ঘন কুয়াশা';
      case 51:
      case 53:
      case 55:
        return 'গুঁড়ি গুঁড়ি বৃষ্টি';
      case 61:
      case 63:
      case 65:
        return 'বৃষ্টিপাত';
      case 80:
      case 81:
      case 82:
        return 'মুষলধারে বৃষ্টি';
      case 95:
      case 96:
      case 99:
        return 'বজ্রবৃষ্টি';
      default:
        return 'স্বাভাবিক আবহাওয়া';
    }
  }

  static String _getAgriAdvice(int code, double rain, double wind, double temp) {
    if (code >= 95) {
      return '⚠️ বজ্রঝড়ের পূর্বাভাস! মাঠের কাজ স্থগিত রাখুন এবং নিরাপদ আশ্রয়ে থাকুন।';
    } else if (rain > 5.0 || code >= 61) {
      return '🌧️ বৃষ্টি হচ্ছে! আজ ফসলে সার প্রয়োগ বা সেচ দেওয়া থেকে বিরত থাকুন।';
    } else if (wind > 25.0) {
      return '💨 বাতাসে উচ্চ গতিবেগ! কীটনাশক ও স্প্রে ছিটানো বন্ধ রাখুন।';
    } else if (temp > 35.0) {
      return '☀️ তীব্র গরম! বিকেলে পর্যাপ্ত সেচ দিন এবং ফসলের আর্দ্রতা ধরে রাখুন।';
    } else if (temp < 15.0) {
      return '❄️ শীতের আমেজ! ধানের চারা ও শাকসবজির রোগবালাই নিয়ন্ত্রণে রাখুন।';
    } else {
      return '🌱 সেচ, সার প্রয়োগ এবং ক্ষেতের পরিচর্যার জন্য আজকের দিনটি উপযুক্ত!';
    }
  }

  factory WeatherModel.defaultFallback(String location) {
    return WeatherModel(
      temperature: 28.5,
      feelsLike: 30.0,
      condition: 'আংশিক মেঘলা',
      weatherCode: 2,
      rainMm: 0.0,
      rainProbability: 20,
      humidity: 68,
      windSpeedKmH: 14.5,
      locationName: location.isNotEmpty ? location : 'গাজীপুর, ঢাকা',
      isDay: true,
      agriAdvice: '🌱 সেচ, সার প্রয়োগ এবং ক্ষেতের পরিচর্যার জন্য আজকের দিনটি উপযুক্ত!',
    );
  }
}
