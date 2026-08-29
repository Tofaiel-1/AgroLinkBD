import 'dart:math';

/// MaskedIdentityHelper provides privacy masking for farmers, buyers, fish farmers,
/// and drivers to prevent platform leakage and bypass. It also provides regex filters
/// to sanitize messages from sharing direct phone numbers, WhatsApp, or external links.
class MaskedIdentityHelper {
  /// Generate or format a masked Farmer Name: e.g. "খামারি #AGR-4910 (বগুড়া সদর জোন)"
  static String getMaskedFarmerName({
    String? userId,
    String? district,
    String? upazila,
    String? fallbackName,
    bool isBangla = true,
  }) {
    final code = _getShortCode(userId ?? fallbackName ?? 'farmer', prefix: 'AGR');
    final loc = _formatLocation(district, upazila);
    if (isBangla) {
      return 'খামারি #$code${loc.isNotEmpty ? ' ($loc)' : ''}';
    }
    return 'Farmer #$code${loc.isNotEmpty ? ' ($loc)' : ''}';
  }

  /// Generate or format a masked Fish Farmer Name: e.g. "মৎস্য খামারি #FSH-7120 (ময়মনসিংহ জোন)"
  static String getMaskedFishFarmerName({
    String? userId,
    String? district,
    String? upazila,
    String? fallbackName,
    bool isBangla = true,
  }) {
    final code = _getShortCode(userId ?? fallbackName ?? 'fish_farmer', prefix: 'FSH');
    final loc = _formatLocation(district, upazila);
    if (isBangla) {
      return 'মৎস্য খামারি #$code${loc.isNotEmpty ? ' ($loc)' : ''}';
    }
    return 'Fish Farmer #$code${loc.isNotEmpty ? ' ($loc)' : ''}';
  }

  /// Generate or format a masked Buyer Name: e.g. "ক্রেতা #BYR-2091 (ঢাকা জোন)"
  static String getMaskedBuyerName({
    String? userId,
    String? district,
    String? fallbackName,
    bool isBangla = true,
  }) {
    final code = _getShortCode(userId ?? fallbackName ?? 'buyer', prefix: 'BYR');
    final loc = district != null && district.trim().isNotEmpty ? '$district জোন' : '';
    if (isBangla) {
      return 'ক্রেতা #$code${loc.isNotEmpty ? ' ($loc)' : ''}';
    }
    return 'Buyer #$code${loc.isNotEmpty ? ' ($loc)' : ''}';
  }

  /// Generate or format a masked Driver / Transport Name: e.g. "এগ্রো ড্রাইভার #DRV-6310"
  static String getMaskedDriverName({
    String? userId,
    String? vehicleType,
    String? fallbackName,
    bool isBangla = true,
  }) {
    final code = _getShortCode(userId ?? fallbackName ?? 'driver', prefix: 'DRV');
    final vehicle = vehicleType ?? 'পিকআপ/ট্রাক';
    if (isBangla) {
      return 'এগ্রো ড্রাইভার #$code ($vehicle)';
    }
    return 'Agro Driver #$code ($vehicle)';
  }

  /// Generate or format a masked Service Provider Name: e.g. "সার্ভিস পার্টনার #SRV-1184"
  static String getMaskedServiceProviderName({
    String? userId,
    String? serviceCategory,
    String? fallbackName,
    bool isBangla = true,
  }) {
    final code = _getShortCode(userId ?? fallbackName ?? 'service', prefix: 'SRV');
    final category = serviceCategory ?? 'কৃষি সেবা';
    if (isBangla) {
      return 'সার্ভিস পার্টনার #$code ($category)';
    }
    return 'Service Partner #$code ($category)';
  }

  /// Generates a unique 4-digit numeric Delivery OTP for Escrow release
  static String generateDeliveryOtp() {
    final random = Random();
    final otp = 1000 + random.nextInt(9000);
    return otp.toString();
  }

  /// Generates a unique AgroLink Batch Code for QR scanning: e.g. "BATCH-BD-8921"
  static String generateBatchCode() {
    final random = Random();
    final code = 1000 + random.nextInt(9000);
    return 'BATCH-BD-$code';
  }

  /// Checks whether a text contains potential phone numbers, whatsapp, or bypass keywords
  static bool containsContactOrBypassInfo(String text) {
    if (text.trim().isEmpty) return false;

    // Regex for standard BD numbers: 013-019, +8801..., 8801...
    final bdPhoneRegex = RegExp(
      r'(?:\+?880|0)?1[3-9]\d{1}[-\s]?\d{3}[-\s]?\d{4}',
      caseSensitive: false,
    );

    // Regex for Bengali numbers: ০১৩-০১৯...
    final banglaPhoneRegex = RegExp(
      r'(?:[\+০-৯]{0,4})?[০-৯]{11}',
    );

    // Regex for spelled out numbers / bypass keywords
    final bypassKeywordsRegex = RegExp(
      r'(whatsapp|imo|bkash number|বিকাশ নাম্বার|ফোন নাম্বার|মোবাইল নাম্বার|কল দিন|direct call|contact me on|imo number|আমার নাম্বার|০ ১ ৭|0 1 7|0 1 8|0 1 9|0 1 3|0 1 4|0 1 5|0 1 6)',
      caseSensitive: false,
    );

    // Regex for email
    final emailRegex = RegExp(
      r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
    );

    return bdPhoneRegex.hasMatch(text) ||
        banglaPhoneRegex.hasMatch(text) ||
        bypassKeywordsRegex.hasMatch(text) ||
        emailRegex.hasMatch(text);
  }

  /// Sanitizes message text by masking phone numbers and contact details with an escrow safety badge
  static String sanitizeContent(String text) {
    if (!containsContactOrBypassInfo(text)) {
      return text;
    }

    String result = text;

    // Mask BD phone numbers
    final bdPhoneRegex = RegExp(
      r'(?:\+?880|0)?1[3-9]\d{1}[-\s]?\d{3}[-\s]?\d{4}',
      caseSensitive: false,
    );
    result = result.replaceAll(bdPhoneRegex, '[নম্বর লুকায়িত 🔒]');

    // Mask raw Bengali digits sequences of 7+ digits
    final banglaDigitsRegex = RegExp(r'[০-৯]{7,}');
    result = result.replaceAll(banglaDigitsRegex, '[নম্বর লুকায়িত 🔒]');

    // Mask spaced digits like "0 1 7 1 ..."
    final spacedDigitsRegex = RegExp(
      r'(0\s*1\s*[3-9](?:\s*\d){8})',
      caseSensitive: false,
    );
    result = result.replaceAll(spacedDigitsRegex, '[নম্বর লুকায়িত 🔒]');

    // Append security notice if sanitized
    if (result != text) {
      result += '\n\n⚠️ [নিরাপত্তা সতর্কতা: প্রতারণা রোধ ও টাকা সুরক্ষায় সরাসরি ফোন নম্বর আদান-প্রদান নিষিদ্ধ। এগ্রোলিংক এস্ক্রো আপনার লেনদেন ও পণ্যের মানের ১০০% গ্যারান্টি প্রদান করে।]';
    }

    return result;
  }

  // Internal helper to create clean alphanumeric short codes from string
  static String _getShortCode(String input, {String prefix = 'AGR'}) {
    int hash = 0;
    for (int i = 0; i < input.length; i++) {
      hash = (hash * 31 + input.codeUnitAt(i)) & 0xFFFFFFFF;
    }
    final positiveHash = (hash.abs() % 9000) + 1000;
    return '$prefix-$positiveHash';
  }

  static String _formatLocation(String? district, String? upazila) {
    if (upazila != null && upazila.isNotEmpty) {
      if (district != null && district.isNotEmpty) {
        return '$upazila, $district জোন';
      }
      return '$upazila জোন';
    }
    if (district != null && district.isNotEmpty) {
      return '$district জোন';
    }
    return 'বাংলাদেশ হাব';
  }
}
