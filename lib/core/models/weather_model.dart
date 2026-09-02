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

  String getTime(bool isBn) {
    if (time == 'এখন' || time == 'Now') {
      return isBn ? 'এখন' : 'Now';
    }
    return time;
  }
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

  String getDayName(bool isBn) {
    if (dayName == 'আজ' || dayName == 'Today') return isBn ? 'আজ' : 'Today';
    if (dayName == 'রবি' || dayName == 'Sun') return isBn ? 'রবি' : 'Sun';
    if (dayName == 'সোম' || dayName == 'Mon') return isBn ? 'সোম' : 'Mon';
    if (dayName == 'মঙ্গল' || dayName == 'Tue') return isBn ? 'মঙ্গল' : 'Tue';
    if (dayName == 'বুধ' || dayName == 'Wed') return isBn ? 'বুধ' : 'Wed';
    if (dayName == 'বৃহঃ' || dayName == 'Thu') return isBn ? 'বৃহঃ' : 'Thu';
    if (dayName == 'শুক্র' || dayName == 'Fri') return isBn ? 'শুক্র' : 'Fri';
    if (dayName == 'শনি' || dayName == 'Sat') return isBn ? 'শনি' : 'Sat';
    return dayName;
  }
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
  final String? locationNameEn;
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
    this.locationNameEn,
    required this.isDay,
    required this.agriAdvice,
    required this.hourlyForecast,
    required this.dailyForecast,
  });

  String getLocationDisplayName(bool isBn) {
    if (isBn) {
      return _translateLocationToBangla(locationName);
    }
    if (locationNameEn != null && locationNameEn!.isNotEmpty && !RegExp(r'[\u0980-\u09FF]').hasMatch(locationNameEn!)) {
      return locationNameEn!;
    }
    return _translateLocationToEnglish(locationName);
  }

  String getConditionText(bool isBn) {
    return _getConditionTextByCode(weatherCode, isBn);
  }

  String getAgriAdviceText(bool isBn) {
    return _generateAgriAdvice(weatherCode, rainMm, windSpeedKmH, temperature, rainProbability, isBn);
  }

  String getWindDirection(bool isBn) {
    return _getWindDirectionByDegree(windDirectionDegree, isBn);
  }

  factory WeatherModel.fromJson(Map<String, dynamic> json, String locationName, {String? locationNameEn}) {
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

    // Calculate start hour index for now
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

    // Hourly Forecast (24 Hours)
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

    String cond = _getConditionTextByCode(code, true);
    String advice = _generateAgriAdvice(code, rain, wind, temp, rainProb, true);
    String windDirText = _getWindDirectionByDegree(windDirDeg, true);

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
      locationNameEn: locationNameEn ?? _translateLocationToEnglish(locationName),
      isDay: day,
      agriAdvice: advice,
      hourlyForecast: hourlyList,
      dailyForecast: dailyList,
    );
  }

  static String _getWindDirectionByDegree(int degree, bool isBn) {
    if (degree >= 337.5 || degree < 22.5) return isBn ? 'উত্তর' : 'North';
    if (degree >= 22.5 && degree < 67.5) return isBn ? 'উত্তর-পূর্ব' : 'North-East';
    if (degree >= 67.5 && degree < 112.5) return isBn ? 'পূর্ব' : 'East';
    if (degree >= 112.5 && degree < 157.5) return isBn ? 'দক্ষিণ-পূর্ব' : 'South-East';
    if (degree >= 157.5 && degree < 202.5) return isBn ? 'দক্ষিণ' : 'South';
    if (degree >= 202.5 && degree < 247.5) return isBn ? 'দক্ষিণ-পশ্চিম' : 'South-West';
    if (degree >= 247.5 && degree < 292.5) return isBn ? 'পশ্চিম' : 'West';
    return isBn ? 'উত্তর-পশ্চিম' : 'North-West';
  }

  static String _getConditionTextByCode(int code, bool isBn) {
    switch (code) {
      case 0:
        return isBn ? 'পরিষ্কার আকাশ' : 'Clear Sky';
      case 1:
      case 2:
        return isBn ? 'আংশিক মেঘলা' : 'Partly Cloudy';
      case 3:
        return isBn ? 'মেঘলা আকাশ' : 'Overcast / Cloudy';
      case 45:
      case 48:
        return isBn ? 'ঘন কুয়াশা' : 'Dense Fog';
      case 51:
      case 53:
      case 55:
        return isBn ? 'গুঁড়ি গুঁড়ি বৃষ্টি' : 'Light Drizzle';
      case 61:
      case 63:
      case 65:
        return isBn ? 'বৃষ্টিপাত' : 'Moderate Rain';
      case 80:
      case 81:
      case 82:
        return isBn ? 'মুষলধারে বৃষ্টি' : 'Heavy Rain';
      case 95:
      case 96:
      case 99:
        return isBn ? 'বজ্রবৃষ্টি' : 'Thunderstorm';
      default:
        return isBn ? 'স্বাভাবিক আবহাওয়া' : 'Normal Weather';
    }
  }

  static String _generateAgriAdvice(int code, double rain, double wind, double temp, int rainProb, bool isBn) {
    if (code >= 95) {
      return isBn
          ? '⚡ বজ্রঝড়ের সম্ভাবনা ($rainProb%)! মাঠের কাজ স্থগিত রেখে নিরাপদ আশ্রয়ে থাকুন।'
          : '⚡ Thunderstorm Risk ($rainProb%)! Suspend field work and stay indoors.';
    } else if (rain > 5.0 || code >= 61 || rainProb > 70) {
      return isBn
          ? '🌧️ বৃষ্টির সম্ভাবনা $rainProb%! আজ ধানে সার বা কীটনাশক স্প্রে করা বন্ধ রাখুন।'
          : '🌧️ Rain Probability $rainProb%! Avoid spraying fertilizer or pesticides today.';
    } else if (wind > 25.0) {
      return isBn
          ? '💨 বাতাসে উচ্চ গতিবেগ (${wind.toStringAsFixed(1)} km/h)! স্প্রে করা বা হালকা সেচ এড়িয়ে চলুন।'
          : '💨 High Wind Speed (${wind.toStringAsFixed(1)} km/h)! Avoid crop spraying or surface irrigation.';
    } else if (temp > 35.0) {
      return isBn
          ? '☀️ তীব্র তাপপ্রবাহ! ফসল ও মাছের পুকুরে বিকেলে পানি সেচের ব্যবস্থা করুন।'
          : '☀️ Heatwave Alert! Provide extra aeration and irrigation for crops and fish.';
    } else if (temp < 15.0) {
      return isBn
          ? '❄️ ঠাণ্ডা আবহাওয়া! শস্যের রোগবালাই ও চারা গাছের যত্ন নিন।'
          : '❄️ Cold Weather! Protect young seedlings and monitor cold-stress diseases.';
    } else {
      return isBn
          ? '🌱 সেচ, সার প্রয়োগ এবং ক্ষেতের পরিচর্যার জন্য আজকের আবহাওয়া অত্যন্ত অনুকূল!'
          : '🌱 Weather conditions are optimal for irrigation, fertilization, and farm maintenance!';
    }
  }

  static String _translateLocationToBangla(String loc) {
    if (loc.isEmpty) return 'ঢাকা সদর, ঢাকা';
    if (RegExp(r'[\u0980-\u09FF]').hasMatch(loc)) return loc;

    String res = loc;
    final map = {
      'Dumki': 'দুমকি',
      'Bauphal': 'বাউফল',
      'Galachipa': 'গলাচিপা',
      'Kalapara': 'কলাপাড়া',
      'Mirzaganj': 'মির্জাগঞ্জ',
      'Dashmina': 'দশমিনা',
      'Rangabali': 'রাঙ্গাবালী',
      'Patuakhali': 'পটুয়াখালী',
      'Barisal': 'বরিশাল',
      'Barishal': 'বরিশাল',
      'Gurudaspur': 'গুরুদাসপুর',
      'Singra': 'সিংড়া',
      'Baraigram': 'বড়াইগ্রাম',
      'Bagatipara': 'বাগাতিপাড়া',
      'Lalpur': 'লালপুর',
      'Naldanga': 'নলডাঙ্গা',
      'Natore': 'নাটোর',
      'Rajshahi': 'রাজশাহী',
      'Bogura': 'বগুড়া',
      'Bogra': 'বগুড়া',
      'Pabna': 'পাবনা',
      'Sirajganj': 'সিরাজগঞ্জ',
      'Naogaon': 'নওগাঁ',
      'Chapainawabganj': 'চাঁপাইনবাবগঞ্জ',
      'Joypurhat': 'জয়পুরহাট',
      'Dhaka': 'ঢাকা',
      'Gazipur': 'গাজীপুর',
      'Tangail': 'টাঙ্গাইল',
      'Faridpur': 'ফরিদপুর',
      'Gopalganj': 'গোপালগঞ্জ',
      'Kishoreganj': 'কিশোরগঞ্জ',
      'Madaripur': 'মাদারীপুর',
      'Manikganj': 'মানিকগঞ্জ',
      'Munshiganj': 'মুন্সীগঞ্জ',
      'Narayanganj': 'নারায়ণগঞ্জ',
      'Narsingdi': 'নরসিংদী',
      'Rajbari': 'রাজবাড়ী',
      'Shariatpur': 'শরীয়তপুর',
      'Chattogram': 'চট্টগ্রাম',
      'Chittagong': 'চট্টগ্রাম',
      'Comilla': 'কুমিল্লা',
      'Cumilla': 'কুমিল্লা',
      'Coxsbazar': 'কক্সবাজার',
      'Noakhali': 'নোয়াখালী',
      'Brahmanbaria': 'ব্রাহ্মণবাড়িয়া',
      'Chandpur': 'চাঁদপুর',
      'Feni': 'ফেনী',
      'Lakshmipur': 'লক্ষ্মীপুর',
      'Bandarban': 'বান্দরবান',
      'Khagrachhari': 'খাগড়াছড়ি',
      'Rangamati': 'রাঙ্গামাটি',
      'Khulna': 'খুলনা',
      'Jessore': 'যশোর',
      'Jashore': 'যশোর',
      'Kushtia': 'কুষ্টিয়া',
      'Bagerhat': 'বাগেরহাট',
      'Chuadanga': 'চুয়াডাঙ্গা',
      'Jhenaidah': 'ঝিনাইদহ',
      'Magura': 'মাগুরা',
      'Meherpur': 'মেহেরপুর',
      'Narail': 'নড়াইল',
      'Satkhira': 'সাতক্ষীরা',
      'Barguna': 'বরগুনা',
      'Bhola': 'ভোলা',
      'Jhalakathi': 'ঝালকাঠি',
      'Jhalokati': 'ঝালকাঠি',
      'Pirojpur': 'পিরোজপুর',
      'Sylhet': 'সিলেট',
      'Habiganj': 'হবিগঞ্জ',
      'Moulvibazar': 'মৌলভীবাজার',
      'Sunamganj': 'সুনামগঞ্জ',
      'Rangpur': 'রংপুর',
      'Dinajpur': 'দিনাজপুর',
      'Gaibandha': 'গাইবান্ধা',
      'Kurigram': 'কুড়িগ্রাম',
      'Lalmonirhat': 'লালমনিরহাট',
      'Nilphamari': 'নীলফামারী',
      'Panchagarh': 'পঞ্চগড়',
      'Thakurgaon': 'ঠাকুরগাঁও',
      'Mymensingh': 'ময়মনসিংহ',
      'Jamalpur': 'জামালপুর',
      'Netrokona': 'নেত্রকোণা',
      'Sherpur': 'শেরপুর',
      'Sadar': 'সদর',
      'Savar': 'সাভার',
      'Kaliakair': 'কালিয়াকৈর',
      'Kapasia': 'কাপাসিয়া',
      'Sreepur': 'শ্রীপুর',
    };

    map.forEach((en, bn) {
      res = res.replaceAll(en, bn);
    });

    return res;
  }

  static String _translateLocationToEnglish(String loc) {
    if (loc.isEmpty) return 'Dhaka Sadar, Dhaka';
    String res = loc;
    final map = {
      // Patuakhali & Barishal Division
      'দুমকি': 'Dumki',
      'বাউফল': 'Bauphal',
      'গলাচিপা': 'Galachipa',
      'কলাপাড়া': 'Kalapara',
      'মির্জাগঞ্জ': 'Mirzaganj',
      'দশমিনা': 'Dashmina',
      'রাঙ্গাবালী': 'Rangabali',
      'পটুয়াখালী': 'Patuakhali',
      'পটুয়াখালী': 'Patuakhali',
      'বরিশাল': 'Barishal',
      'বরগুনা': 'Barguna',
      'ভোলা': 'Bhola',
      'ঝালকাঠি': 'Jhalokati',
      'পিরোজপুর': 'Pirojpur',

      // Rajshahi Division
      'গুরুদাসপুর': 'Gurudaspur',
      'সিংড়া': 'Singra',
      'সিংড়া': 'Singra',
      'বড়াইগ্রাম': 'Baraigram',
      'বড়াইগ্রাম': 'Baraigram',
      'বাগাতিপাড়া': 'Bagatipara',
      'বাগাতিপাড়া': 'Bagatipara',
      'লালপুর': 'Lalpur',
      'নলডাঙ্গা': 'Naldanga',
      'নাটোর': 'Natore',
      'রাজশাহী': 'Rajshahi',
      'পবা': 'Paba',
      'গোদাগাড়ী': 'Godagari',
      'গোদাগাড়ী': 'Godagari',
      'তানোর': 'Tanore',
      'বাগমারা': 'Bagmara',
      'চারঘাট': 'Charghat',
      'বাঘা': 'Bagha',
      'দুর্গাপুর': 'Durgapur',
      'মোহনপুর': 'Mohonpur',
      'পুঠিয়া': 'Puthia',
      'পুঠিয়া': 'Puthia',
      'বগুড়া': 'Bogura',
      'বগুড়া': 'Bogura',
      'পাবনা': 'Pabna',
      'সিরাজগঞ্জ': 'Sirajganj',
      'নওগাঁ': 'Naogaon',
      'চাঁপাইনবাবগঞ্জ': 'Chapainawabganj',
      'জয়পুরহাট': 'Joypurhat',
      'জয়পুরহাট': 'Joypurhat',

      // Dhaka Division
      'ঢাকা': 'Dhaka',
      'গাজীপুর': 'Gazipur',
      'সাভার': 'Savar',
      'কালিয়াকৈর': 'Kaliakair',
      'কালিয়াকৈর': 'Kaliakair',
      'কাপাসিয়া': 'Kapasia',
      'কাপাসিয়া': 'Kapasia',
      'শ্রীপুর': 'Sreepur',
      'কালীগঞ্জ': 'Kaliganj',
      'টাঙ্গাইল': 'Tangail',
      'ফরিদপুর': 'Faridpur',
      'গোপালগঞ্জ': 'Gopalganj',
      'কিশোরগঞ্জ': 'Kishoreganj',
      'মাদারীপুর': 'Madaripur',
      'মানিকগঞ্জ': 'Manikganj',
      'মুন্সীগঞ্জ': 'Munshiganj',
      'নারায়ণগঞ্জ': 'Narayanganj',
      'নারায়ণগঞ্জ': 'Narayanganj',
      'নরসিংদী': 'Narsingdi',
      'রাজবাড়ী': 'Rajbari',
      'রাজবাড়ী': 'Rajbari',
      'শরীয়তপুর': 'Shariatpur',

      // Chattogram Division
      'চট্টগ্রাম': 'Chattogram',
      'কুমিল্লা': 'Cumilla',
      'কক্সবাজার': 'Cox\'s Bazar',
      'নোয়াখালী': 'Noakhali',
      'নোয়াখালী': 'Noakhali',
      'ব্রাহ্মণবাড়িয়া': 'Brahmanbaria',
      'ব্রাহ্মণবাড়িয়া': 'Brahmanbaria',
      'চাঁদপুর': 'Chandpur',
      'ফেনী': 'Feni',
      'লক্ষ্মীপুর': 'Lakshmipur',
      'বান্দরবান': 'Bandarban',
      'খাগড়াছড়ি': 'Khagrachhari',
      'খাগড়াছড়ি': 'Khagrachhari',
      'রাঙ্গামাটি': 'Rangamati',

      // Khulna Division
      'খুলনা': 'Khulna',
      'যশোর': 'Jashore',
      'কুষ্টিয়া': 'Kushtia',
      'কুষ্টিয়া': 'Kushtia',
      'বাগেরহাট': 'Bagerhat',
      'চুয়াডাঙ্গা': 'Chuadanga',
      'চুয়াডাঙ্গা': 'Chuadanga',
      'ঝিনাইদহ': 'Jhenaidah',
      'মাগুরা': 'Magura',
      'মেহেরপুর': 'Meherpur',
      'নড়াইল': 'Narail',
      'নড়াইল': 'Narail',
      'সাতক্ষীরা': 'Satkhira',

      // Sylhet Division
      'সিলেট': 'Sylhet',
      'হবিগঞ্জ': 'Habiganj',
      'মৌলভীবাজার': 'Moulvibazar',
      'সুনামগঞ্জ': 'Sunamganj',

      // Rangpur Division
      'রংপুর': 'Rangpur',
      'দিনাজপুর': 'Dinajpur',
      'গাইবান্ধা': 'Gaibandha',
      'কুড়িগ্রাম': 'Kurigram',
      'কুড়িগ্রাম': 'Kurigram',
      'লালমনিরহাট': 'Lalmonirhat',
      'নীলফামারী': 'Nilphamari',
      'পঞ্চগড়': 'Panchagarh',
      'পঞ্চগড়': 'Panchagarh',
      'ঠাকুরগাঁও': 'Thakurgaon',

      // Mymensingh Division
      'ময়মনসিংহ': 'Mymensingh',
      'ময়মনসিংহ': 'Mymensingh',
      'জামালপুর': 'Jamalpur',
      'নেত্রকোণা': 'Netrokona',
      'শেরপুর': 'Sherpur',

      // Common Words
      'সদর': 'Sadar',
    };

    map.forEach((bn, en) {
      res = res.replaceAll(bn, en);
    });

    return res;
  }

  factory WeatherModel.defaultFallback(String location, {String? locationEn}) {
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

    String bnLoc = location.isNotEmpty ? _translateLocationToBangla(location) : 'দুমকি, পটুয়াখালী (বরিশাল)';
    String enLoc = locationEn ?? _translateLocationToEnglish(bnLoc);

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
      locationName: bnLoc,
      locationNameEn: enLoc,
      isDay: true,
      agriAdvice: '⚡ এলাকায় বজ্রবৃষ্টির সম্ভাবনা (৮০%)! আজ সেচ ও স্প্রে বন্ধ রাখুন।',
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
