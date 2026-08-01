class HourlyWeather {
  final String time;
  final double temperature;
  final int rainProbability;
  final int weatherCode;

  HourlyWeather({
    required this.time,
    required this.temperature,
    required this.rainProbability,
    required this.weatherCode,
  });
}

class DailyWeather {
  final String dayName;
  final double maxTemp;
  final double minTemp;
  final int rainProbability;
  final int weatherCode;

  DailyWeather({
    required this.dayName,
    required this.maxTemp,
    required this.minTemp,
    required this.rainProbability,
    required this.weatherCode,
  });
}

class WeatherModel {
  final double temperature;
  final double feelsLike;
  final String condition;
  final int weatherCode;
  final double rainMm;
  final int rainProbability;
  final int humidity;
  final double windSpeedKmH;
  final int windDirectionDegree;
  final String windDirectionText;
  final double uvIndex;
  final double pressureHpa;
  final int cloudCoverPercent;
  final String locationName;
  final bool isDay;
  final String agriAdvice;
  final List<HourlyWeather> hourlyForecast;
  final List<DailyWeather> dailyForecast;

  WeatherModel({
    required this.temperature,
    required this.feelsLike,
    required this.condition,
    required this.weatherCode,
    required this.rainMm,
    required this.rainProbability,
    required this.humidity,
    required this.windSpeedKmH,
    required this.windDirectionDegree,
    required this.windDirectionText,
    required this.uvIndex,
    required this.pressureHpa,
    required this.cloudCoverPercent,
    required this.locationName,
    required this.isDay,
    required this.agriAdvice,
    required this.hourlyForecast,
    required this.dailyForecast,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json, String locationName) {
    final current = json['current'] ?? {};
    final hourly = json['hourly'] ?? {};
    final daily = json['daily'] ?? {};
    
    double temp = (current['temperature_2m'] as num?)?.toDouble() ?? 28.0;
    double apparentTemp = (current['apparent_temperature'] as num?)?.toDouble() ?? temp;
    int code = (current['weather_code'] as num?)?.toInt() ?? 0;
    double rain = (current['rain'] as num?)?.toDouble() ?? (current['precipitation'] as num?)?.toDouble() ?? 0.0;
    int humid = (current['relative_humidity_2m'] as num?)?.toInt() ?? 70;
    double wind = (current['wind_speed_10m'] as num?)?.toDouble() ?? 12.0;
    int windDirDeg = (current['wind_direction_10m'] as num?)?.toInt() ?? 90;
    double uv = (current['uv_index'] as num?)?.toDouble() ?? 5.5;
    double press = (current['surface_pressure'] as num?)?.toDouble() ?? 1012.0;
    int clouds = (current['cloud_cover'] as num?)?.toInt() ?? 25;
    bool day = (current['is_day'] as num?)?.toInt() == 1;

    // Calculate current hour index to start hourly forecast from Now (current hour)
    int startHourIndex = 0;
    if (hourly['time'] != null && hourly['time'] is List) {
      final times = hourly['time'] as List;
      final now = DateTime.now();
      final nowIsoHour = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}T${now.hour.toString().padLeft(2, '0')}';
      for (int i = 0; i < times.length; i++) {
        if (times[i].toString().startsWith(nowIsoHour)) {
          startHourIndex = i;
          break;
        }
      }
      if (startHourIndex == 0 && now.hour > 0 && times.length > now.hour) {
        startHourIndex = now.hour;
      }
    }

    // Rain probability for current hour
    int rainProb = 0;
    if (hourly['precipitation_probability'] != null && (hourly['precipitation_probability'] as List).isNotEmpty) {
      final probs = hourly['precipitation_probability'] as List;
      if (startHourIndex < probs.length) {
        rainProb = (probs[startHourIndex] as num).toInt();
      } else {
        rainProb = (probs.first as num).toInt();
      }
    }

    // Hourly Forecast (24 Hours starting from Current Hour)
    List<HourlyWeather> hourlyList = [];
    if (hourly['time'] != null && hourly['time'] is List) {
      final times = hourly['time'] as List;
      final temps = (hourly['temperature_2m'] as List?) ?? [];
      final probs = (hourly['precipitation_probability'] as List?) ?? [];
      final codes = (hourly['weather_code'] as List?) ?? [];

      int endIdx = startHourIndex + 24;
      if (endIdx > times.length) endIdx = times.length;

      for (int i = startHourIndex; i < endIdx; i++) {
        String tStr = times[i].toString();
        DateTime? dt = DateTime.tryParse(tStr);
        
        String displayTime;
        if (i == startHourIndex) {
          displayTime = 'এখন';
        } else if (dt != null) {
          int h = dt.hour;
          String ampm = h >= 12 ? 'PM' : 'AM';
          int h12 = h % 12;
          if (h12 == 0) h12 = 12;
          displayTime = '$h12 $ampm';
        } else {
          displayTime = tStr.contains('T') ? tStr.split('T').last : tStr;
        }

        double tVal = i < temps.length ? (temps[i] as num).toDouble() : temp;
        int pVal = i < probs.length ? (probs[i] as num).toInt() : 0;
        int cVal = i < codes.length ? (codes[i] as num).toInt() : code;

        hourlyList.add(HourlyWeather(
          time: displayTime,
          temperature: tVal,
          rainProbability: pVal,
          weatherCode: cVal,
        ));
      }
    }

    // Daily Forecast (7 Days)
    List<DailyWeather> dailyList = [];
    if (daily['time'] != null && daily['time'] is List) {
      final dTimes = daily['time'] as List;
      final maxs = (daily['temperature_2m_max'] as List?) ?? [];
      final mins = (daily['temperature_2m_min'] as List?) ?? [];
      final dProbs = (daily['precipitation_probability_max'] as List?) ?? [];
      final dCodes = (daily['weather_code'] as List?) ?? [];

      final banglaDays = ['রবি', 'সোম', 'মঙ্গল', 'বুধ', 'বৃহঃ', 'শুক্র', 'শনি'];

      for (int i = 0; i < dTimes.length && i < 7; i++) {
        DateTime dt = DateTime.tryParse(dTimes[i].toString()) ?? DateTime.now().add(Duration(days: i));
        String dayLabel = i == 0 ? 'আজ' : banglaDays[dt.weekday % 7];
        double mx = i < maxs.length ? (maxs[i] as num).toDouble() : temp + 3;
        double mn = i < mins.length ? (mins[i] as num).toDouble() : temp - 4;
        int pr = i < dProbs.length ? (dProbs[i] as num).toInt() : 10;
        int cd = i < dCodes.length ? (dCodes[i] as num).toInt() : code;

        dailyList.add(DailyWeather(
          dayName: dayLabel,
          maxTemp: mx,
          minTemp: mn,
          rainProbability: pr,
          weatherCode: cd,
        ));
      }
    }

    String cond = _getConditionText(code);
    String advice = _getAgriAdvice(code, rain, wind, temp, rainProb);
    String windDirText = _getWindDirectionText(windDirDeg);

    return WeatherModel(
      temperature: temp,
      feelsLike: apparentTemp,
      condition: cond,
      weatherCode: code,
      rainMm: rain,
      rainProbability: rainProb,
      humidity: humid,
      windSpeedKmH: wind,
      windDirectionDegree: windDirDeg,
      windDirectionText: windDirText,
      uvIndex: uv,
      pressureHpa: press,
      cloudCoverPercent: clouds,
      locationName: locationName,
      isDay: day,
      agriAdvice: advice,
      hourlyForecast: hourlyList,
      dailyForecast: dailyList,
    );
  }

  static String _getWindDirectionText(int degree) {
    if (degree >= 337.5 || degree < 22.5) return 'উত্তর';
    if (degree >= 22.5 && degree < 67.5) return 'উত্তর-পূর্ব';
    if (degree >= 67.5 && degree < 112.5) return 'পূর্ব';
    if (degree >= 112.5 && degree < 157.5) return 'দক্ষিণ-পূর্ব';
    if (degree >= 157.5 && degree < 202.5) return 'দক্ষিণ';
    if (degree >= 202.5 && degree < 247.5) return 'দক্ষিণ-পশ্চিম';
    if (degree >= 247.5 && degree < 292.5) return 'পশ্চিম';
    return 'উত্তর-পশ্চিম';
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

  static String _getAgriAdvice(int code, double rain, double wind, double temp, int rainProb) {
    if (code >= 95) {
      return '⚡ বজ্রঝড়ের সম্ভাবনা ($rainProb%)! মাঠের কাজ স্থগিত রেখে নিরাপদ আশ্রয়ে থাকুন।';
    } else if (rain > 5.0 || code >= 61 || rainProb > 70) {
      return '🌧️ বৃষ্টির সম্ভাবনা $rainProb%! আজ ধানে সার বা কীটনাশক স্প্রে করা বন্ধ রাখুন।';
    } else if (wind > 25.0) {
      return '💨 বাতাসে উচ্চ গতিবেগ ($wind km/h)! স্প্রে করা বা হালকা সেচ এড়িয়ে চলুন।';
    } else if (temp > 35.0) {
      return '☀️ তীব্র তাপপ্রবাহ! ফসল ও মাছের পুকুরে বিকেলে পানি সেচের ব্যবস্থা করুন।';
    } else if (temp < 15.0) {
      return '❄️ ঠাণ্ডা আবহাওয়া! শস্যের রোগবালাই ও চারা গাছের যত্ন নিন।';
    } else {
      return '🌱 সেচ, সার প্রয়োগ এবং ক্ষেতের পরিচর্যার জন্য আজকের আবহাওয়া অত্যন্ত অনুকূল!';
    }
  }

  factory WeatherModel.defaultFallback(String location) {
    final now = DateTime.now();
    int curH = now.hour;
    List<HourlyWeather> fallbackHourly = [];
    for (int i = 0; i < 6; i++) {
      int h = (curH + i) % 24;
      String ampm = h >= 12 ? 'PM' : 'AM';
      int h12 = h % 12;
      if (h12 == 0) h12 = 12;
      String label = i == 0 ? 'এখন' : '$h12 $ampm';
      fallbackHourly.add(HourlyWeather(
        time: label,
        temperature: 30.0 - (i * 0.4),
        rainProbability: i == 0 ? 80 : (i == 1 ? 60 : (i == 2 ? 40 : 20)),
        weatherCode: i < 3 ? 95 : 3,
      ));
    }

    return WeatherModel(
      temperature: 30.0,
      feelsLike: 35.0,
      condition: 'মেঘলা আকাশ',
      weatherCode: 3,
      rainMm: 0.2,
      rainProbability: 80,
      humidity: 78,
      windSpeedKmH: 12.6,
      windDirectionDegree: 180,
      windDirectionText: 'দক্ষিণ',
      uvIndex: 2.7,
      pressureHpa: 996.0,
      cloudCoverPercent: 95,
      locationName: location.isNotEmpty ? location : 'গুরুদাসপুর, নাটোর (রাজশাহী)',
      isDay: true,
      agriAdvice: '⚡ নাটোর ও উত্তরবঙ্গে বজ্রবৃষ্টির সম্ভাবনা (৮০%)! আজ সেচ ও স্প্রে বন্ধ রাখুন।',
      hourlyForecast: fallbackHourly,
      dailyForecast: [
        DailyWeather(dayName: 'আজ', maxTemp: 32.0, minTemp: 28.0, rainProbability: 80, weatherCode: 95),
        DailyWeather(dayName: 'সোম', maxTemp: 32.0, minTemp: 27.0, rainProbability: 60, weatherCode: 95),
        DailyWeather(dayName: 'মঙ্গল', maxTemp: 32.0, minTemp: 27.0, rainProbability: 60, weatherCode: 95),
        DailyWeather(dayName: 'বুধ', maxTemp: 29.0, minTemp: 26.0, rainProbability: 30, weatherCode: 3),
        DailyWeather(dayName: 'বৃহঃ', maxTemp: 29.0, minTemp: 26.0, rainProbability: 20, weatherCode: 3),
      ],
    );
  }
}
