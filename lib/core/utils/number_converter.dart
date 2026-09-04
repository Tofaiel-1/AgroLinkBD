class BanglaEnglishNumberHelper {
  static const Map<String, String> _bnToEn = {
    '০': '0',
    '১': '1',
    '২': '2',
    '৩': '3',
    '৪': '4',
    '৫': '5',
    '৬': '6',
    '৭': '7',
    '৮': '8',
    '৯': '9',
  };

  static const Map<String, String> _enToBn = {
    '0': '০',
    '1': '১',
    '2': '২',
    '3': '৩',
    '4': '৪',
    '5': '৫',
    '6': '৬',
    '7': '৭',
    '8': '৮',
    '9': '৯',
  };

  /// Converts any string containing Bengali digits to English digits
  static String toEnglishDigits(String input) {
    if (input.isEmpty) return input;
    String result = input;
    _bnToEn.forEach((bn, en) {
      result = result.replaceAll(bn, en);
    });
    return result;
  }

  /// Converts any string containing English digits to Bengali digits
  static String toBanglaDigits(dynamic input) {
    if (input == null) return '';
    String result = input.toString();
    _enToBn.forEach((en, bn) {
      result = result.replaceAll(en, bn);
    });
    return result;
  }

  /// Safely parse a double from either English or Bengali digits (e.g. "১.৫", "1.5", "২,৫০০.০০")
  static double toDouble(dynamic input, [double defaultValue = 0.0]) {
    if (input == null) return defaultValue;
    if (input is num) return input.toDouble();
    
    final str = input.toString().trim();
    if (str.isEmpty) return defaultValue;

    final cleaned = toEnglishDigits(str).replaceAll(',', '').replaceAll(' ', '');
    return double.tryParse(cleaned) ?? defaultValue;
  }

  /// Safely parse an int from either English or Bengali digits (e.g. "৮৫০০", "8500", "১,২০০")
  static int toInt(dynamic input, [int defaultValue = 0]) {
    if (input == null) return defaultValue;
    if (input is num) return input.toInt();

    final str = input.toString().trim();
    if (str.isEmpty) return defaultValue;

    final cleaned = toEnglishDigits(str).replaceAll(',', '').replaceAll(' ', '');
    // In case user entered floating point string like "10.0"
    final parsedDouble = double.tryParse(cleaned);
    if (parsedDouble != null) {
      return parsedDouble.toInt();
    }
    return int.tryParse(cleaned) ?? defaultValue;
  }

  /// Format number according to current locale (Bangla or English)
  static String format(dynamic number, bool isBn, {int? fractionDigits}) {
    if (number == null) return isBn ? '০' : '0';
    String formatted;
    if (number is num && fractionDigits != null) {
      formatted = number.toStringAsFixed(fractionDigits);
    } else {
      formatted = number.toString();
    }
    return isBn ? toBanglaDigits(formatted) : toEnglishDigits(formatted);
  }
}
