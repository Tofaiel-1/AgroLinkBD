import 'package:agrolinkbd/core/models/agri_info_model.dart';

/// Bangladesh Complete Agricultural Data
/// Source: BARC (Bangladesh Agricultural Research Council) — Public Data
/// Covers all 8 Divisions, 64 Districts with crop patterns, soil profile,
/// fertilizer doses, and crop suitability.

class BangladeshAgriData {
  // ========================================================
  // All Divisions
  // ========================================================
  static const List<String> divisions = [
    'ঢাকা', 'চট্টগ্রাম', 'রাজশাহী', 'খুলনা',
    'বরিশাল', 'সিলেট', 'রংপুর', 'ময়মনসিংহ',
  ];

  // ========================================================
  // District → Division mapping
  // ========================================================
  static const Map<String, List<String>> zillasPerDivision = {
    'ঢাকা': ['ঢাকা', 'গাজীপুর', 'মানিকগঞ্জ', 'মুন্সিগঞ্জ', 'নারায়ণগঞ্জ', 'নরসিংদী', 'টাঙ্গাইল', 'কিশোরগঞ্জ', 'ফরিদপুর', 'মাদারীপুর', 'রাজবাড়ী', 'গোপালগঞ্জ', 'শরীয়তপুর'],
    'চট্টগ্রাম': ['চট্টগ্রাম', 'কক্সবাজার', 'ব্রাহ্মণবাড়িয়া', 'চাঁদপুর', 'কুমিল্লা', 'ফেনী', 'লক্ষ্মীপুর', 'নোয়াখালী', 'রাঙ্গামাটি', 'বান্দরবান', 'খাগড়াছড়ি'],
    'রাজশাহী': ['রাজশাহী', 'বগুড়া', 'চাঁপাইনবাবগঞ্জ', 'জয়পুরহাট', 'নওগাঁ', 'নাটোর', 'পাবনা', 'সিরাজগঞ্জ'],
    'খুলনা': ['খুলনা', 'বাগেরহাট', 'চুয়াডাঙ্গা', 'যশোর', 'ঝিনাইদহ', 'কুষ্টিয়া', 'মাগুরা', 'মেহেরপুর', 'নড়াইল', 'সাতক্ষীরা'],
    'বরিশাল': ['বরিশাল', 'বরগুনা', 'ভোলা', 'ঝালকাঠি', 'পটুয়াখালী', 'পিরোজপুর'],
    'সিলেট': ['সিলেট', 'হবিগঞ্জ', 'মৌলভীবাজার', 'সুনামগঞ্জ'],
    'রংপুর': ['রংপুর', 'দিনাজপুর', 'গাইবান্ধা', 'কুড়িগ্রাম', 'লালমনিরহাট', 'নীলফামারী', 'পঞ্চগড়', 'ঠাকুরগাঁও'],
    'ময়মনসিংহ': ['ময়মনসিংহ', 'জামালপুর', 'নেত্রকোনা', 'শেরপুর'],
  };

  // ========================================================
  // Upazila → Zilla mapping (main upazilas)
  // ========================================================
  static const Map<String, List<String>> upazilasPerZilla = {
    // ঢাকা বিভাগ
    'ঢাকা': ['সাভার', 'কেরানীগঞ্জ', 'দোহার', 'নবাবগঞ্জ', 'ধামরাই'],
    'গাজীপুর': ['গাজীপুর সদর', 'কালীগঞ্জ', 'কাপাসিয়া', 'শ্রীপুর', 'টঙ্গী'],
    'মানিকগঞ্জ': ['মানিকগঞ্জ সদর', 'ঘিওর', 'দৌলতপুর', 'হরিরামপুর', 'শিবালয়', 'সাটুরিয়া', 'সিঙ্গাইর'],
    'মুন্সিগঞ্জ': ['মুন্সিগঞ্জ সদর', 'গজারিয়া', 'লৌহজং', 'শ্রীনগর', 'সিরাজদিখান', 'টঙ্গিবাড়ী'],
    'নারায়ণগঞ্জ': ['নারায়ণগঞ্জ সদর', 'আড়াইহাজার', 'বন্দর', 'রূপগঞ্জ', 'সোনারগাঁও'],
    'নরসিংদী': ['নরসিংদী সদর', 'বেলাব', 'মনোহরদী', 'পলাশ', 'রায়পুরা', 'শিবপুর'],
    'টাঙ্গাইল': ['টাঙ্গাইল সদর', 'বাসাইল', 'ভূঞাপুর', 'দেলদুয়ার', 'ঘাটাইল', 'কালিহাতী', 'মধুপুর', 'মির্জাপুর', 'নাগরপুর', 'সখিপুর', 'গোপালপুর'],
    'কিশোরগঞ্জ': ['কিশোরগঞ্জ সদর', 'অষ্টগ্রাম', 'বাজিতপুর', 'ভৈরব', 'হোসেনপুর', 'ইটনা', 'করিমগঞ্জ', 'কটিয়াদী', 'কুলিয়ারচর', 'মিঠামইন', 'নিকলী', 'পাকুন্দিয়া', 'তাড়াইল'],
    'ফরিদপুর': ['ফরিদপুর সদর', 'আলফাডাঙ্গা', 'বোয়ালমারী', 'চরভদ্রাসন', 'ভাঙ্গা', 'মধুখালী', 'নগরকান্দা', 'সালথা'],
    'মাদারীপুর': ['মাদারীপুর সদর', 'কালকিনি', 'রাজৈর', 'শিবচর', 'ডাসার'],
    'রাজবাড়ী': ['রাজবাড়ী সদর', 'বালিয়াকান্দি', 'গোয়ালন্দ', 'কালুখালী', 'পাংশা'],
    'গোপালগঞ্জ': ['গোপালগঞ্জ সদর', 'কাশিয়ানী', 'কোটালীপাড়া', 'মুকসুদপুর', 'টুঙ্গীপাড়া'],
    'শরীয়তপুর': ['শরীয়তপুর সদর', 'ডামুড্যা', 'গোসাইরহাট', 'জাজিরা', 'নড়িয়া', 'ভেদরগঞ্জ'],

    // চট্টগ্রাম বিভাগ
    'চট্টগ্রাম': ['চট্টগ্রাম সদর', 'আনোয়ারা', 'বাঁশখালী', 'বোয়ালখালী', 'চন্দনাইশ', 'ফটিকছড়ি', 'হাটহাজারী', 'লোহাগাড়া', 'মীরসরাই', 'পটিয়া', 'রাঙ্গুনিয়া', 'রাউজান', 'সন্দ্বীপ', 'সাতকানিয়া', 'সীতাকুণ্ড'],
    'কক্সবাজার': ['কক্সবাজার সদর', 'চকরিয়া', 'কুতুবদিয়া', 'মহেশখালী', 'পেকুয়া', 'রামু', 'টেকনাফ', 'উখিয়া'],
    'ব্রাহ্মণবাড়িয়া': ['ব্রাহ্মণবাড়িয়া সদর', 'আখাউড়া', 'বাঞ্ছারামপুর', 'বিজয়নগর', 'কসবা', 'নবীনগর', 'নাসিরনগর', 'সরাইল'],
    'চাঁদপুর': ['চাঁদপুর সদর', 'ফরিদগঞ্জ', 'হাইমচর', 'হাজীগঞ্জ', 'কচুয়া', 'মতলব উত্তর', 'মতলব দক্ষিণ', 'শাহরাস্তি'],
    'কুমিল্লা': ['কুমিল্লা সদর', 'বরুড়া', 'ব্রাহ্মণপাড়া', 'বুড়িচং', 'চান্দিনা', 'চৌদ্দগ্রাম', 'দাউদকান্দি', 'দেবিদ্বার', 'হোমনা', 'লাকসাম', 'লালমাই', 'মেঘনা', 'মনোহরগঞ্জ', 'মুরাদনগর', 'নাঙ্গলকোট', 'তিতাস'],
    'ফেনী': ['ফেনী সদর', 'ছাগলনাইয়া', 'দাগনভূঞা', 'ফুলগাজী', 'পরশুরাম', 'সোনাগাজী'],
    'লক্ষ্মীপুর': ['লক্ষ্মীপুর সদর', 'কমলনগর', 'রামগঞ্জ', 'রামগতি', 'রায়পুর'],
    'নোয়াখালী': ['নোয়াখালী সদর', 'বেগমগঞ্জ', 'চাটখিল', 'কোম্পানীগঞ্জ', 'হাতিয়া', 'সেনবাগ', 'সোনাইমুড়ী', 'সুবর্ণচর', 'কবিরহাট'],
    'রাঙ্গামাটি': ['রাঙ্গামাটি সদর', 'বাঘাইছড়ি', 'বরকল', 'বিলাইছড়ি', 'কাউখালী', 'কাপ্তাই', 'জুরাছড়ি', 'লংগদু', 'নানিয়ারচর', 'রাজস্থলী'],
    'বান্দরবান': ['বান্দরবান সদর', 'আলীকদম', 'লামা', 'নাইক্ষ্যংছড়ি', 'রোয়াংছড়ি', 'রুমা', 'থানচি'],
    'খাগড়াছড়ি': ['খাগড়াছড়ি সদর', 'দিঘীনালা', 'গুইমারা', 'লক্ষ্মীছড়ি', 'মাটিরাঙ্গা', 'মানিকছড়ি', 'মহালছড়ি', 'পানছড়ি', 'রামগড়'],

    // রাজশাহী বিভাগ
    'রাজশাহী': ['রাজশাহী সদর', 'বাঘা', 'বাগমারা', 'চারঘাট', 'দুর্গাপুর', 'গোদাগাড়ী', 'মোহনপুর', 'পবা', 'পুঠিয়া', 'তানোর'],
    'বগুড়া': ['বগুড়া সদর', 'আদমদীঘি', 'ধুনট', 'দুপচাঁচিয়া', 'গাবতলী', 'কাহালু', 'নন্দীগ্রাম', 'সারিয়াকান্দি', 'শাহজাহানপুর', 'শেরপুর', 'শিবগঞ্জ', 'সোনাতলা'],
    'চাঁপাইনবাবগঞ্জ': ['চাঁপাইনবাবগঞ্জ সদর', 'ভোলাহাট', 'গোমস্তাপুর', 'নাচোল', 'শিবগঞ্জ'],
    'জয়পুরহাট': ['জয়পুরহাট সদর', 'আক্কেলপুর', 'কালাই', 'ক্ষেতলাল', 'পাঁচবিবি'],
    'নওগাঁ': ['নওগাঁ সদর', 'আত্রাই', 'বদলগাছী', 'ধামইরহাট', 'মহাদেবপুর', 'মান্দা', 'নিয়ামতপুর', 'পত্নীতলা', 'পোরশা', 'রাণীনগর', 'সাপাহার'],
    'নাটোর': ['নাটোর সদর', 'বড়াইগ্রাম', 'বাগাতিপাড়া', 'গুরুদাসপুর', 'লালপুর', 'সিংড়া'],
    'পাবনা': ['পাবনা সদর', 'আটঘরিয়া', 'বেড়া', 'ভাঙ্গুড়া', 'চাটমোহর', 'ফরিদপুর', 'ঈশ্বরদী', 'সাঁথিয়া', 'সুজানগর'],
    'সিরাজগঞ্জ': ['সিরাজগঞ্জ সদর', 'বেলকুচি', 'চৌহালী', 'কামারখন্দ', 'কাজীপুর', 'রায়গঞ্জ', 'শাহজাদপুর', 'তাড়াশ', 'উল্লাপাড়া'],

    // খুলনা বিভাগ
    'খুলনা': ['খুলনা সদর', 'বটিয়াঘাটা', 'দাকোপ', 'ডুমুরিয়া', 'দিঘলিয়া', 'কয়রা', 'পাইকগাছা', 'ফুলতলা', 'তেরখাদা'],
    'বাগেরহাট': ['বাগেরহাট সদর', 'চিতলমারী', 'ফকিরহাট', 'কচুয়া', 'মংলা', 'মোরেলগঞ্জ', 'মোল্লাহাট', 'রামপাল', 'শরণখোলা'],
    'চুয়াডাঙ্গা': ['চুয়াডাঙ্গা সদর', 'আলমডাঙ্গা', 'দামুড়হুদা', 'জীবননগর'],
    'যশোর': ['যশোর সদর', 'অভয়নগর', 'বাঘারপাড়া', 'চৌগাছা', 'ঝিকরগাছা', 'কেশবপুর', 'মণিরামপুর', 'শার্শা'],
    'ঝিনাইদহ': ['ঝিনাইদহ সদর', 'কালীগঞ্জ', 'কোটচাঁদপুর', 'মহেশপুর', 'শৈলকুপা', 'হরিণাকুণ্ডু'],
    'কুষ্টিয়া': ['কুষ্টিয়া সদর', 'ভেড়ামারা', 'দৌলতপুর', 'খোকসা', 'কুমারখালী', 'মিরপুর'],
    'মাগুরা': ['মাগুরা সদর', 'মহম্মদপুর', 'মোহাম্মদপুর', 'শালিখা', 'শ্রীপুর'],
    'মেহেরপুর': ['মেহেরপুর সদর', 'গাংনী', 'মুজিবনগর'],
    'নড়াইল': ['নড়াইল সদর', 'কালিয়া', 'লোহাগাড়া'],
    'সাতক্ষীরা': ['সাতক্ষীরা সদর', 'আশাশুনি', 'দেবহাটা', 'কলারোয়া', 'কালিগঞ্জ', 'শ্যামনগর', 'তালা'],

    // বরিশাল বিভাগ
    'বরিশাল': ['বরিশাল সদর', 'আগৈলঝাড়া', 'বাবুগঞ্জ', 'বাকেরগঞ্জ', 'বানারীপাড়া', 'গৌরনদী', 'হিজলা', 'মেহেন্দিগঞ্জ', 'মুলাদী', 'উজিরপুর'],
    'বরগুনা': ['বরগুনা সদর', 'আমতলী', 'বামনা', 'বেতাগী', 'পাথরঘাটা', 'তালতলী'],
    'ভোলা': ['ভোলা সদর', 'বোরহানউদ্দিন', 'চরফ্যাশন', 'দৌলতখান', 'লালমোহন', 'মনপুরা', 'তজুমদ্দিন'],
    'ঝালকাঠি': ['ঝালকাঠি সদর', 'কাঁঠালিয়া', 'নলছিটি', 'রাজাপুর'],
    'পটুয়াখালী': ['পটুয়াখালী সদর', 'বাউফল', 'দশমিনা', 'গলাচিপা', 'কলাপাড়া', 'মির্জাগঞ্জ', 'রাঙ্গাবালী'],
    'পিরোজপুর': ['পিরোজপুর সদর', 'ভান্ডারিয়া', 'কাউখালী', 'মঠবাড়িয়া', 'নাজিরপুর', 'নেছারাবাদ', 'জিয়ানগর'],

    // সিলেট বিভাগ
    'সিলেট': ['সিলেট সদর', 'বালাগঞ্জ', 'বিয়ানীবাজার', 'বিশ্বনাথ', 'কোম্পানীগঞ্জ', 'ফেঞ্চুগঞ্জ', 'গোলাপগঞ্জ', 'গোয়াইনঘাট', 'জৈন্তাপুর', 'কানাইঘাট', 'ওসমানীনগর', 'দক্ষিণ সুরমা', 'জকিগঞ্জ'],
    'হবিগঞ্জ': ['হবিগঞ্জ সদর', 'আজমিরীগঞ্জ', 'বাহুবল', 'বানিয়াচং', 'চুনারুঘাট', 'লাখাই', 'মাধবপুর', 'নবীগঞ্জ', 'শায়েস্তাগঞ্জ'],
    'মৌলভীবাজার': ['মৌলভীবাজার সদর', 'বড়লেখা', 'জুড়ী', 'কমলগঞ্জ', 'কুলাউড়া', 'রাজনগর', 'শ্রীমঙ্গল'],
    'সুনামগঞ্জ': ['সুনামগঞ্জ সদর', 'বিশ্বম্ভরপুর', 'ছাতক', 'দিরাই', 'দোয়ারাবাজার', 'জগন্নাথপুর', 'জামালগঞ্জ', 'শাল্লা', 'তাহিরপুর', 'ধর্মপাশা'],

    // রংপুর বিভাগ
    'রংপুর': ['রংপুর সদর', 'বদরগঞ্জ', 'গঙ্গাচড়া', 'কাউনিয়া', 'মিঠাপুকুর', 'পীরগাছা', 'পীরগঞ্জ', 'তারাগঞ্জ'],
    'দিনাজপুর': ['দিনাজপুর সদর', 'বীরগঞ্জ', 'বিরল', 'বোচাগঞ্জ', 'চিরিরবন্দর', 'ফুলবাড়ী', 'ঘোড়াঘাট', 'হাকিমপুর', 'কাহারোল', 'খানসামা', 'নবাবগঞ্জ', 'পার্বতীপুর'],
    'গাইবান্ধা': ['গাইবান্ধা সদর', 'ফুলছড়ি', 'গোবিন্দগঞ্জ', 'পলাশবাড়ী', 'সাঘাটা', 'সাদুল্যাপুর', 'সুন্দরগঞ্জ'],
    'কুড়িগ্রাম': ['কুড়িগ্রাম সদর', 'ভুরুঙ্গামারী', 'চিলমারী', 'ফুলবাড়ী', 'নাগেশ্বরী', 'রাজারহাট', 'রৌমারী', 'উলিপুর'],
    'লালমনিরহাট': ['লালমনিরহাট সদর', 'আদিতমারী', 'কালীগঞ্জ', 'হাতীবান্ধা', 'পাটগ্রাম'],
    'নীলফামারী': ['নীলফামারী সদর', 'ডিমলা', 'ডোমার', 'জলঢাকা', 'কিশোরগঞ্জ', 'সৈয়দপুর'],
    'পঞ্চগড়': ['পঞ্চগড় সদর', 'আটোয়ারী', 'বোদা', 'দেবীগঞ্জ', 'তেঁতুলিয়া'],
    'ঠাকুরগাঁও': ['ঠাকুরগাঁও সদর', 'বালিয়াডাঙ্গী', 'হরিপুর', 'পীরগঞ্জ', 'রাণীশংকৈল'],

    // ময়মনসিংহ বিভাগ
    'ময়মনসিংহ': ['ময়মনসিংহ সদর', 'ভালুকা', 'ধোবাউড়া', 'ফুলবাড়িয়া', 'গফরগাঁও', 'গৌরীপুর', 'হালুয়াঘাট', 'ঈশ্বরগঞ্জ', 'মুক্তাগাছা', 'নান্দাইল', 'ফুলপুর', 'তারাকান্দা', 'ত্রিশাল'],
    'জামালপুর': ['জামালপুর সদর', 'বকশীগঞ্জ', 'দেওয়ানগঞ্জ', 'ইসলামপুর', 'মাদারগঞ্জ', 'মেলান্দহ', 'সরিষাবাড়ী'],
    'নেত্রকোনা': ['নেত্রকোনা সদর', 'আটপাড়া', 'বারহাট্টা', 'দুর্গাপুর', 'খালিয়াজুরী', 'কলমাকান্দা', 'কেন্দুয়া', 'মদন', 'মোহনগঞ্জ', 'পূর্বধলা'],
    'শেরপুর': ['শেরপুর সদর', 'ঝিনাইগাতী', 'নকলা', 'নালিতাবাড়ী', 'শ্রীবরদী'],
  };

  // ========================================================
  // Full crop data per upazila (sample set — key districts)
  // ========================================================
  static final List<UpazilaCropData> allData = [

    // ================================================================
    // RAJSHAHI DIVISION — রাজশাহী বিভাগ
    // ================================================================

    // নাটোর — গুরুদাসপুর
    UpazilaCropData(
      division: 'রাজশাহী', zilla: 'নাটোর', upazila: 'গুরুদাসপুর',
      latitude: 24.17, longitude: 89.05,
      cropZone: 'AEZ-11', cropZoneBn: 'পাবনা-নাটোর অঞ্চল',
      soilProfile: SoilProfile(
        type: 'loam', typeBn: 'দোআঁশ মাটি',
        phMin: 6.0, phMax: 7.0,
        organicMatter: 'medium', drainage: 'moderate',
        description: 'উর্বর দোআঁশ মাটি। রবি ফসলে অত্যন্ত উপযুক্ত।',
      ),
      suitableCrops: [
        CropSuitability(cropName: 'রসুন', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'স্থানীয়', yieldTonPerHa: 8.5),
        CropSuitability(cropName: 'পেঁয়াজ', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'তাহেরপুরী', yieldTonPerHa: 12.0),
        CropSuitability(cropName: 'রোপা আমন ধান', season: 'kharif2', seasonBn: 'খরিফ-২', suitability: 'high', variety: 'বিআর-১১', yieldTonPerHa: 4.5),
        CropSuitability(cropName: 'পাট (দেশি)', season: 'kharif1', seasonBn: 'খরিফ-১', suitability: 'medium', variety: 'সিভিই-৩', yieldTonPerHa: 3.2),
        CropSuitability(cropName: 'মুগ', season: 'kharif1', seasonBn: 'খরিফ-১', suitability: 'medium', variety: 'বিনামুগ-৮', yieldTonPerHa: 1.2),
      ],
      cropPatterns: [
        CropPattern(robi: 'রসুন', kharif1: 'পাট (দেশি)', kharif2: 'রোপা আমন', profitIndex: 900, bcRatioVig: 1.51, bcRatioTig: 1.25, isCurrent: true),
        CropPattern(robi: 'পেঁয়াজ', kharif1: 'মুগ', kharif2: 'বোনা আমন', profitIndex: 667, bcRatioVig: 1.76, bcRatioTig: 1.25, isCurrent: true),
        CropPattern(robi: 'রসুন', kharif1: 'মুগ', kharif2: 'রোপা আমন', profitIndex: 905, bcRatioVig: 1.60, bcRatioTig: 1.29),
        CropPattern(robi: 'রসুন', kharif1: 'পাট (দেশি)', kharif2: 'পতিত', profitIndex: 897, bcRatioVig: 1.69, bcRatioTig: 1.42),
        CropPattern(robi: 'পেঁয়াজ', kharif1: 'পাট (দেশি)', kharif2: 'রোপা আমন', profitIndex: 534, bcRatioVig: 1.36, bcRatioTig: 1.19),
        CropPattern(robi: 'রসুন', kharif1: 'বাসী', kharif2: 'মাসকালাই', profitIndex: 1725, bcRatioVig: 2.19, bcRatioTig: 1.75),
        CropPattern(robi: 'রসুন', kharif1: 'ভুট্টা', kharif2: 'রোপা আমন', profitIndex: 1212, bcRatioVig: 1.64, bcRatioTig: 1.38),
      ],
      fertilizerDoses: [
        FertilizerDose(cropName: 'garlic', cropNameBn: 'রসুন', urea: '২৫০', tsp: '১৫০', mop: '১২০', gypsum: '৬০', zinc: '৫', remarks: 'রোপণের ৩০ দিন পর ইউরিয়ার ২য় কিস্তি'),
        FertilizerDose(cropName: 'onion', cropNameBn: 'পেঁয়াজ', urea: '২৩০', tsp: '১৩০', mop: '১১০', gypsum: '৫০', zinc: '৫'),
        FertilizerDose(cropName: 'rice_aman', cropNameBn: 'রোপা আমন', urea: '১৭০', tsp: '৫৫', mop: '৬০'),
        FertilizerDose(cropName: 'jute', cropNameBn: 'পাট (দেশি)', urea: '১৩০', tsp: '৮০', mop: '৬০'),
        FertilizerDose(cropName: 'mung', cropNameBn: 'মুগ', urea: '৩০', tsp: '৮০', mop: '৪০'),
      ],
    ),

    // নাটোর — সিংড়া
    UpazilaCropData(
      division: 'রাজশাহী', zilla: 'নাটোর', upazila: 'সিংড়া',
      latitude: 24.22, longitude: 89.12,
      cropZone: 'AEZ-11', cropZoneBn: 'পাবনা-নাটোর অঞ্চল',
      soilProfile: SoilProfile(
        type: 'loam', typeBn: 'দোআঁশ মাটি',
        phMin: 6.0, phMax: 7.0,
        organicMatter: 'medium', drainage: 'moderate',
        description: 'মাঝারি উর্বর দোআঁশ মাটি। সেচ সুবিধায় উচ্চ ফলন সম্ভব।',
      ),
      suitableCrops: [
        CropSuitability(cropName: 'ধান (বোরো)', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'ব্রি ধান-২৮', yieldTonPerHa: 6.5),
        CropSuitability(cropName: 'গম', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'শতাব্দী', yieldTonPerHa: 3.8),
        CropSuitability(cropName: 'রোপা আমন', season: 'kharif2', seasonBn: 'খরিফ-২', suitability: 'high', variety: 'বিআর-১১', yieldTonPerHa: 4.2),
        CropSuitability(cropName: 'পাট', season: 'kharif1', seasonBn: 'খরিফ-১', suitability: 'medium', variety: 'ভি-১', yieldTonPerHa: 3.0),
      ],
      cropPatterns: [
        CropPattern(robi: 'বোরো ধান', kharif1: 'পতিত', kharif2: 'রোপা আমন', profitIndex: 174, bcRatioVig: 1.30, bcRatioTig: 0.92, isCurrent: true),
        CropPattern(robi: 'বোরো ধান', kharif1: 'পতিত', kharif2: 'পতিত', profitIndex: 36, bcRatioVig: 1.09, bcRatioTig: 0.80, isCurrent: true),
        CropPattern(robi: 'গম', kharif1: 'পাট', kharif2: 'রোপা আমন', profitIndex: 650, bcRatioVig: 1.55, bcRatioTig: 1.30),
        CropPattern(robi: 'সরিষা', kharif1: 'পাট', kharif2: 'রোপা আমন', profitIndex: 480, bcRatioVig: 1.45, bcRatioTig: 1.20),
      ],
      fertilizerDoses: [
        FertilizerDose(cropName: 'boro_rice', cropNameBn: 'বোরো ধান', urea: '২৭০', tsp: '৬৫', mop: '৯০', zinc: '৫'),
        FertilizerDose(cropName: 'wheat', cropNameBn: 'গম', urea: '২০০', tsp: '১০০', mop: '৮০', gypsum: '৬০'),
        FertilizerDose(cropName: 'rice_aman', cropNameBn: 'রোপা আমন', urea: '১৭০', tsp: '৫৫', mop: '৬০'),
      ],
    ),

    // রাজশাহী — রাজশাহী সদর
    UpazilaCropData(
      division: 'রাজশাহী', zilla: 'রাজশাহী', upazila: 'রাজশাহী সদর',
      latitude: 24.37, longitude: 88.60,
      cropZone: 'AEZ-11', cropZoneBn: 'বরেন্দ্র অঞ্চল',
      soilProfile: SoilProfile(
        type: 'clay', typeBn: 'এঁটেল মাটি',
        phMin: 6.5, phMax: 7.5,
        organicMatter: 'low', drainage: 'poor',
        description: 'বরেন্দ্র অঞ্চলের শক্ত এঁটেল মাটি। গভীর নলকূপ সেচে বোরো ধান ভালো হয়।',
      ),
      suitableCrops: [
        CropSuitability(cropName: 'আম', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'ফজলি, হিমসাগর', yieldTonPerHa: 15.0),
        CropSuitability(cropName: 'বোরো ধান', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'ব্রি ধান-২৮', yieldTonPerHa: 6.0),
        CropSuitability(cropName: 'গম', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'বারি গম-৩০', yieldTonPerHa: 3.5),
        CropSuitability(cropName: 'রোপা আমন', season: 'kharif2', seasonBn: 'খরিফ-২', suitability: 'medium', variety: 'বিআর-১১', yieldTonPerHa: 3.8),
      ],
      cropPatterns: [
        CropPattern(robi: 'বোরো ধান', kharif1: 'পতিত', kharif2: 'রোপা আমন', profitIndex: 200, bcRatioVig: 1.35, bcRatioTig: 1.05),
        CropPattern(robi: 'গম', kharif1: 'পতিত', kharif2: 'রোপা আমন', profitIndex: 320, bcRatioVig: 1.48, bcRatioTig: 1.22),
        CropPattern(robi: 'সরিষা', kharif1: 'পতিত', kharif2: 'রোপা আমন', profitIndex: 380, bcRatioVig: 1.52, bcRatioTig: 1.28),
      ],
      fertilizerDoses: [
        FertilizerDose(cropName: 'boro_rice', cropNameBn: 'বোরো ধান', urea: '২৭০', tsp: '৬৫', mop: '৯০', zinc: '৫'),
        FertilizerDose(cropName: 'wheat', cropNameBn: 'গম', urea: '২০০', tsp: '১০০', mop: '৮০'),
        FertilizerDose(cropName: 'mustard', cropNameBn: 'সরিষা', urea: '১৩০', tsp: '৯০', mop: '৬০', gypsum: '৪০'),
      ],
    ),

    // বগুড়া — বগুড়া সদর
    UpazilaCropData(
      division: 'রাজশাহী', zilla: 'বগুড়া', upazila: 'বগুড়া সদর',
      latitude: 24.85, longitude: 89.37,
      cropZone: 'AEZ-9', cropZoneBn: 'বগুড়া-দিনাজপুর অঞ্চল',
      soilProfile: SoilProfile(
        type: 'loam', typeBn: 'দোআঁশ-বেলে দোআঁশ',
        phMin: 5.8, phMax: 6.8,
        organicMatter: 'medium', drainage: 'good',
        description: 'সমতল ভূমি, ভালো নিষ্কাশন। সবজি ও ধান চাষে বিখ্যাত।',
      ),
      suitableCrops: [
        CropSuitability(cropName: 'আলু', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'ডায়মন্ড', yieldTonPerHa: 25.0),
        CropSuitability(cropName: 'ভুট্টা', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'বারি হাইব্রিড ভুট্টা-৯', yieldTonPerHa: 10.5),
        CropSuitability(cropName: 'বোরো ধান', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'ব্রি ধান-২৯', yieldTonPerHa: 7.0),
        CropSuitability(cropName: 'রোপা আমন', season: 'kharif2', seasonBn: 'খরিফ-২', suitability: 'high', variety: 'বিআর-১১', yieldTonPerHa: 4.5),
        CropSuitability(cropName: 'শাকসবজি', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'মিশ্র', yieldTonPerHa: 18.0),
      ],
      cropPatterns: [
        CropPattern(robi: 'আলু', kharif1: 'পাট', kharif2: 'রোপা আমন', profitIndex: 1200, bcRatioVig: 1.85, bcRatioTig: 1.55),
        CropPattern(robi: 'ভুট্টা', kharif1: 'পতিত', kharif2: 'রোপা আমন', profitIndex: 850, bcRatioVig: 1.65, bcRatioTig: 1.40),
        CropPattern(robi: 'বোরো ধান', kharif1: 'পতিত', kharif2: 'রোপা আমন', profitIndex: 280, bcRatioVig: 1.40, bcRatioTig: 1.15),
        CropPattern(robi: 'সবজি (মিশ্র)', kharif1: 'পতিত', kharif2: 'রোপা আমন', profitIndex: 1500, bcRatioVig: 2.10, bcRatioTig: 1.80),
      ],
      fertilizerDoses: [
        FertilizerDose(cropName: 'potato', cropNameBn: 'আলু', urea: '২৫০', tsp: '১৮০', mop: '২০০', gypsum: '৮০', zinc: '৫'),
        FertilizerDose(cropName: 'maize', cropNameBn: 'ভুট্টা', urea: '৩৫০', tsp: '১৫০', mop: '১৩০', gypsum: '৪০'),
        FertilizerDose(cropName: 'boro_rice', cropNameBn: 'বোরো ধান', urea: '২৭০', tsp: '৬৫', mop: '৯০', zinc: '৫'),
      ],
    ),

    // ================================================================
    // DHAKA DIVISION — ঢাকা বিভাগ
    // ================================================================

    // ঢাকা — সাভার
    UpazilaCropData(
      division: 'ঢাকা', zilla: 'ঢাকা', upazila: 'সাভার',
      latitude: 23.85, longitude: 90.27,
      cropZone: 'AEZ-28', cropZoneBn: 'মধুপুর গড় অঞ্চল',
      soilProfile: SoilProfile(
        type: 'loam', typeBn: 'দোআঁশ-লাল মাটি',
        phMin: 5.5, phMax: 6.5,
        organicMatter: 'medium', drainage: 'good',
        description: 'মধুপুর গড়ের উঁচু লালমাটি। আনারস, কলা ও শাকসবজি চাষে উপযুক্ত।',
      ),
      suitableCrops: [
        CropSuitability(cropName: 'আনারস', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'জায়েন্ট কিউ', yieldTonPerHa: 35.0),
        CropSuitability(cropName: 'কলা', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'সবরি', yieldTonPerHa: 25.0),
        CropSuitability(cropName: 'পেঁপে', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'শাহী', yieldTonPerHa: 40.0),
        CropSuitability(cropName: 'রোপা আমন', season: 'kharif2', seasonBn: 'খরিফ-২', suitability: 'medium', variety: 'ব্রি আমন', yieldTonPerHa: 4.0),
        CropSuitability(cropName: 'শাকসবজি', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'মিশ্র', yieldTonPerHa: 20.0),
      ],
      cropPatterns: [
        CropPattern(robi: 'সবজি', kharif1: 'পতিত', kharif2: 'রোপা আমন', profitIndex: 1800, bcRatioVig: 2.20, bcRatioTig: 1.90),
        CropPattern(robi: 'আলু', kharif1: 'পতিত', kharif2: 'রোপা আমন', profitIndex: 1100, bcRatioVig: 1.80, bcRatioTig: 1.50),
        CropPattern(robi: 'বোরো ধান', kharif1: 'পতিত', kharif2: 'রোপা আমন', profitIndex: 250, bcRatioVig: 1.38, bcRatioTig: 1.10),
      ],
      fertilizerDoses: [
        FertilizerDose(cropName: 'vegetable', cropNameBn: 'শাকসবজি (মিশ্র)', urea: '২০০', tsp: '১২০', mop: '১০০', gypsum: '৪০', zinc: '৫'),
        FertilizerDose(cropName: 'potato', cropNameBn: 'আলু', urea: '২৫০', tsp: '১৮০', mop: '২০০'),
        FertilizerDose(cropName: 'boro_rice', cropNameBn: 'বোরো ধান', urea: '২৭০', tsp: '৬৫', mop: '৯০'),
      ],
    ),

    // টাঙ্গাইল — মধুপুর
    UpazilaCropData(
      division: 'ঢাকা', zilla: 'টাঙ্গাইল', upazila: 'মধুপুর',
      latitude: 24.60, longitude: 90.10,
      cropZone: 'AEZ-28', cropZoneBn: 'মধুপুর গড় অঞ্চল',
      soilProfile: SoilProfile(
        type: 'loam', typeBn: 'লাল-বাদামি মাটি',
        phMin: 5.0, phMax: 6.0,
        organicMatter: 'high', drainage: 'good',
        description: 'মধুপুর শালবনের অম্লীয় লাল মাটি। আনারস চাষে বাংলাদেশ-বিখ্যাত।',
      ),
      suitableCrops: [
        CropSuitability(cropName: 'আনারস', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'জায়েন্ট কিউ', yieldTonPerHa: 40.0),
        CropSuitability(cropName: 'কলা', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'বাংলা কলা', yieldTonPerHa: 28.0),
        CropSuitability(cropName: 'হলুদ', season: 'kharif1', seasonBn: 'খরিফ-১', suitability: 'high', variety: 'সিন্দুরী', yieldTonPerHa: 18.0),
        CropSuitability(cropName: 'আদা', season: 'kharif1', seasonBn: 'খরিফ-১', suitability: 'high', variety: 'স্থানীয়', yieldTonPerHa: 12.0),
      ],
      cropPatterns: [
        CropPattern(robi: 'আনারস (বার্ষিক)', kharif1: 'আনারস', kharif2: 'আনারস', profitIndex: 3500, bcRatioVig: 2.80, bcRatioTig: 2.50),
        CropPattern(robi: 'হলুদ/আদা', kharif1: 'হলুদ/আদা', kharif2: 'রোপা আমন', profitIndex: 2200, bcRatioVig: 2.30, bcRatioTig: 2.00),
      ],
      fertilizerDoses: [
        FertilizerDose(cropName: 'pineapple', cropNameBn: 'আনারস', urea: '৩৫০', tsp: '২০০', mop: '২৫০', gypsum: '৫০'),
        FertilizerDose(cropName: 'turmeric', cropNameBn: 'হলুদ', urea: '১৫০', tsp: '১৫০', mop: '১২০'),
        FertilizerDose(cropName: 'ginger', cropNameBn: 'আদা', urea: '১৮০', tsp: '১৮০', mop: '১৫০'),
      ],
    ),

    // কিশোরগঞ্জ — হাওর এলাকা (ভৈরব)
    UpazilaCropData(
      division: 'ঢাকা', zilla: 'কিশোরগঞ্জ', upazila: 'ভৈরব',
      latitude: 24.05, longitude: 90.98,
      cropZone: 'AEZ-21', cropZoneBn: 'হাওর অঞ্চল',
      soilProfile: SoilProfile(
        type: 'clay', typeBn: 'ভারী এঁটেল মাটি',
        phMin: 6.0, phMax: 7.5,
        organicMatter: 'high', drainage: 'poor',
        description: 'হাওর এলাকার জলাভূমি মাটি। বোরো ধান চাষে সর্বোত্তম।',
      ),
      suitableCrops: [
        CropSuitability(cropName: 'বোরো ধান', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'ব্রি ধান-২৮/২৯', yieldTonPerHa: 7.5),
        CropSuitability(cropName: 'মাছ চাষ', season: 'kharif1', seasonBn: 'খরিফ-১', suitability: 'high', variety: 'মিশ্র', yieldTonPerHa: 3.0),
      ],
      cropPatterns: [
        CropPattern(robi: 'বোরো ধান', kharif1: 'মাছ চাষ', kharif2: 'মাছ চাষ', profitIndex: 500, bcRatioVig: 1.55, bcRatioTig: 1.30),
        CropPattern(robi: 'বোরো ধান', kharif1: 'পতিত', kharif2: 'পতিত', profitIndex: 100, bcRatioVig: 1.15, bcRatioTig: 0.90),
      ],
      fertilizerDoses: [
        FertilizerDose(cropName: 'boro_rice', cropNameBn: 'বোরো ধান', urea: '২৮০', tsp: '৭০', mop: '৯৫', zinc: '৫', remarks: 'হাওর এলাকায় ফ্লাড টলারেন্ট জাত ব্যবহার করুন'),
      ],
    ),

    // ================================================================
    // KHULNA DIVISION — খুলনা বিভাগ
    // ================================================================

    // যশোর — যশোর সদর
    UpazilaCropData(
      division: 'খুলনা', zilla: 'যশোর', upazila: 'যশোর সদর',
      latitude: 23.17, longitude: 89.21,
      cropZone: 'AEZ-13', cropZoneBn: 'যশোর-কুষ্টিয়া অঞ্চল',
      soilProfile: SoilProfile(
        type: 'loam', typeBn: 'দোআঁশ মাটি',
        phMin: 6.5, phMax: 7.5,
        organicMatter: 'medium', drainage: 'moderate',
        description: 'ভাটা অঞ্চলের উর্বর দোআঁশ মাটি। ফুল, শাকসবজি ও গলদা চিংড়ি চাষে প্রসিদ্ধ।',
      ),
      suitableCrops: [
        CropSuitability(cropName: 'ফুল (গোলাপ/গ্লাডিওলাস)', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'মিশ্র', yieldTonPerHa: 5.0),
        CropSuitability(cropName: 'পান', season: 'kharif1', seasonBn: 'খরিফ-১', suitability: 'high', variety: 'স্থানীয়', yieldTonPerHa: 8.0),
        CropSuitability(cropName: 'সরিষা', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'বারি সরিষা-১৪', yieldTonPerHa: 1.8),
        CropSuitability(cropName: 'রোপা আমন', season: 'kharif2', seasonBn: 'খরিফ-২', suitability: 'high', variety: 'বিআর-১১', yieldTonPerHa: 4.5),
        CropSuitability(cropName: 'গলদা চিংড়ি', season: 'kharif1', seasonBn: 'খরিফ-১', suitability: 'high', variety: 'স্থানীয়', yieldTonPerHa: 0.5),
      ],
      cropPatterns: [
        CropPattern(robi: 'সরিষা', kharif1: 'পাট', kharif2: 'রোপা আমন', profitIndex: 680, bcRatioVig: 1.62, bcRatioTig: 1.35),
        CropPattern(robi: 'গম', kharif1: 'পাট', kharif2: 'রোপা আমন', profitIndex: 550, bcRatioVig: 1.50, bcRatioTig: 1.25),
        CropPattern(robi: 'সবজি', kharif1: 'পতিত', kharif2: 'রোপা আমন', profitIndex: 1400, bcRatioVig: 2.00, bcRatioTig: 1.70),
      ],
      fertilizerDoses: [
        FertilizerDose(cropName: 'mustard', cropNameBn: 'সরিষা', urea: '১৩০', tsp: '৯০', mop: '৬০', gypsum: '৪০'),
        FertilizerDose(cropName: 'wheat', cropNameBn: 'গম', urea: '২০০', tsp: '১০০', mop: '৮০'),
        FertilizerDose(cropName: 'rice_aman', cropNameBn: 'রোপা আমন', urea: '১৭০', tsp: '৫৫', mop: '৬০'),
      ],
    ),

    // সাতক্ষীরা — শ্যামনগর (সুন্দরবন)
    UpazilaCropData(
      division: 'খুলনা', zilla: 'সাতক্ষীরা', upazila: 'শ্যামনগর',
      latitude: 22.07, longitude: 89.01,
      cropZone: 'AEZ-13', cropZoneBn: 'সুন্দরবন উপকূলীয় অঞ্চল',
      soilProfile: SoilProfile(
        type: 'clay', typeBn: 'লবণাক্ত এঁটেল মাটি',
        phMin: 7.0, phMax: 8.5,
        organicMatter: 'medium', drainage: 'poor',
        description: 'লবণাক্ত উপকূলীয় মাটি। লবণসহিষ্ণু জাতের ধান ও চিংড়ি চাষ উপযুক্ত।',
      ),
      suitableCrops: [
        CropSuitability(cropName: 'বাগদা চিংড়ি', season: 'kharif1', seasonBn: 'খরিফ-১', suitability: 'high', variety: 'স্থানীয়', yieldTonPerHa: 0.8),
        CropSuitability(cropName: 'রোপা আমন (লবণসহিষ্ণু)', season: 'kharif2', seasonBn: 'খরিফ-২', suitability: 'medium', variety: 'বিনা ধান-৮', yieldTonPerHa: 3.0),
        CropSuitability(cropName: 'সূর্যমুখী', season: 'rabi', seasonBn: 'রবি', suitability: 'medium', variety: 'কিরণ', yieldTonPerHa: 2.0),
      ],
      cropPatterns: [
        CropPattern(robi: 'সূর্যমুখী', kharif1: 'চিংড়ি', kharif2: 'রোপা আমন', profitIndex: 800, bcRatioVig: 1.60, bcRatioTig: 1.30),
        CropPattern(robi: 'পতিত', kharif1: 'চিংড়ি', kharif2: 'রোপা আমন', profitIndex: 400, bcRatioVig: 1.40, bcRatioTig: 1.15),
      ],
      fertilizerDoses: [
        FertilizerDose(cropName: 'rice_aman', cropNameBn: 'রোপা আমন (লবণসহিষ্ণু)', urea: '১৫০', tsp: '৫০', mop: '৫৫', remarks: 'লবণাক্ত এলাকায় ডোলোচুন ব্যবহার করুন'),
        FertilizerDose(cropName: 'sunflower', cropNameBn: 'সূর্যমুখী', urea: '১৮০', tsp: '১৫০', mop: '১০০', gypsum: '৬০'),
      ],
    ),

    // কুষ্টিয়া — কুষ্টিয়া সদর
    UpazilaCropData(
      division: 'খুলনা', zilla: 'কুষ্টিয়া', upazila: 'কুষ্টিয়া সদর',
      latitude: 23.90, longitude: 89.13,
      cropZone: 'AEZ-12', cropZoneBn: 'গঙ্গা তীরবর্তী অঞ্চল',
      soilProfile: SoilProfile(
        type: 'loam', typeBn: 'পলি দোআঁশ মাটি',
        phMin: 6.5, phMax: 7.5,
        organicMatter: 'high', drainage: 'good',
        description: 'পদ্মা নদীর পলিমাটি। তামাক, গম ও ইক্ষু চাষে বিখ্যাত।',
      ),
      suitableCrops: [
        CropSuitability(cropName: 'তামাক', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'মটিলাল', yieldTonPerHa: 2.8),
        CropSuitability(cropName: 'গম', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'শতাব্দী', yieldTonPerHa: 4.0),
        CropSuitability(cropName: 'ইক্ষু', season: 'kharif1', seasonBn: 'খরিফ-১', suitability: 'high', variety: 'ঈশ্বরদী-৩৭', yieldTonPerHa: 80.0),
        CropSuitability(cropName: 'পাট', season: 'kharif1', seasonBn: 'খরিফ-১', suitability: 'medium', variety: 'ভি-১', yieldTonPerHa: 3.5),
      ],
      cropPatterns: [
        CropPattern(robi: 'গম', kharif1: 'পাট', kharif2: 'রোপা আমন', profitIndex: 750, bcRatioVig: 1.65, bcRatioTig: 1.38),
        CropPattern(robi: 'সরিষা', kharif1: 'পাট', kharif2: 'রোপা আমন', profitIndex: 620, bcRatioVig: 1.55, bcRatioTig: 1.28),
        CropPattern(robi: 'বোরো ধান', kharif1: 'পতিত', kharif2: 'রোপা আমন', profitIndex: 300, bcRatioVig: 1.42, bcRatioTig: 1.18),
      ],
      fertilizerDoses: [
        FertilizerDose(cropName: 'wheat', cropNameBn: 'গম', urea: '২০০', tsp: '১০০', mop: '৮০', gypsum: '৬০'),
        FertilizerDose(cropName: 'mustard', cropNameBn: 'সরিষা', urea: '১৩০', tsp: '৯০', mop: '৬০', gypsum: '৪০'),
        FertilizerDose(cropName: 'sugarcane', cropNameBn: 'ইক্ষু', urea: '৪০০', tsp: '২০০', mop: '২৫০'),
      ],
    ),

    // ================================================================
    // CHITTAGONG DIVISION — চট্টগ্রাম বিভাগ
    // ================================================================

    // চট্টগ্রাম — হাটহাজারী
    UpazilaCropData(
      division: 'চট্টগ্রাম', zilla: 'চট্টগ্রাম', upazila: 'হাটহাজারী',
      latitude: 22.50, longitude: 91.80,
      cropZone: 'AEZ-2', cropZoneBn: 'চট্টগ্রাম পাহাড়তলী অঞ্চল',
      soilProfile: SoilProfile(
        type: 'clay', typeBn: 'পাহাড়ি লাল মাটি',
        phMin: 4.5, phMax: 6.0,
        organicMatter: 'medium', drainage: 'good',
        description: 'পাহাড়ের ঢালের অম্লীয় মাটি। আনারস, সুপারি ও ধান চাষ হয়।',
      ),
      suitableCrops: [
        CropSuitability(cropName: 'আউশ ধান', season: 'kharif1', seasonBn: 'খরিফ-১', suitability: 'high', variety: 'ব্রি আউশ ৪৮', yieldTonPerHa: 4.0),
        CropSuitability(cropName: 'রোপা আমন', season: 'kharif2', seasonBn: 'খরিফ-২', suitability: 'high', variety: 'বিআর-২২', yieldTonPerHa: 4.2),
        CropSuitability(cropName: 'বোরো ধান', season: 'rabi', seasonBn: 'রবি', suitability: 'medium', variety: 'ব্রি ধান-২৮', yieldTonPerHa: 5.5),
        CropSuitability(cropName: 'সুপারি', season: 'kharif1', seasonBn: 'খরিফ-১', suitability: 'high', variety: 'স্থানীয়', yieldTonPerHa: 2.5),
      ],
      cropPatterns: [
        CropPattern(robi: 'বোরো ধান', kharif1: 'আউশ ধান', kharif2: 'রোপা আমন', profitIndex: 450, bcRatioVig: 1.48, bcRatioTig: 1.22),
        CropPattern(robi: 'সবজি', kharif1: 'আউশ ধান', kharif2: 'রোপা আমন', profitIndex: 1100, bcRatioVig: 1.85, bcRatioTig: 1.58),
      ],
      fertilizerDoses: [
        FertilizerDose(cropName: 'aus_rice', cropNameBn: 'আউশ ধান', urea: '১৮০', tsp: '৫৫', mop: '৫৫'),
        FertilizerDose(cropName: 'aman_rice', cropNameBn: 'রোপা আমন', urea: '১৭০', tsp: '৫৫', mop: '৬০'),
        FertilizerDose(cropName: 'boro_rice', cropNameBn: 'বোরো ধান', urea: '২৬০', tsp: '৬৫', mop: '৮৫'),
      ],
    ),

    // কুমিল্লা — কুমিল্লা সদর
    UpazilaCropData(
      division: 'চট্টগ্রাম', zilla: 'কুমিল্লা', upazila: 'কুমিল্লা সদর',
      latitude: 23.45, longitude: 91.19,
      cropZone: 'AEZ-21', cropZoneBn: 'ত্রিপুরা সীমান্ত সমতল',
      soilProfile: SoilProfile(
        type: 'loam', typeBn: 'পলি দোআঁশ',
        phMin: 6.0, phMax: 7.0,
        organicMatter: 'medium', drainage: 'moderate',
        description: 'সমতল উর্বর পলিমাটি। তিন ফসলি এলাকা।',
      ),
      suitableCrops: [
        CropSuitability(cropName: 'বোরো ধান', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'ব্রি ধান-২৯', yieldTonPerHa: 7.0),
        CropSuitability(cropName: 'আমন ধান', season: 'kharif2', seasonBn: 'খরিফ-২', suitability: 'high', variety: 'বিআর-১১', yieldTonPerHa: 4.5),
        CropSuitability(cropName: 'শর্ষে', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'বারি সরিষা-১৪', yieldTonPerHa: 1.8),
        CropSuitability(cropName: 'গম', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'বারি গম-২৬', yieldTonPerHa: 3.8),
      ],
      cropPatterns: [
        CropPattern(robi: 'বোরো ধান', kharif1: 'পতিত', kharif2: 'রোপা আমন', profitIndex: 350, bcRatioVig: 1.45, bcRatioTig: 1.18),
        CropPattern(robi: 'সরিষা', kharif1: 'পতিত', kharif2: 'রোপা আমন', profitIndex: 520, bcRatioVig: 1.58, bcRatioTig: 1.30),
        CropPattern(robi: 'গম', kharif1: 'পাট', kharif2: 'রোপা আমন', profitIndex: 680, bcRatioVig: 1.65, bcRatioTig: 1.38),
      ],
      fertilizerDoses: [
        FertilizerDose(cropName: 'boro_rice', cropNameBn: 'বোরো ধান', urea: '২৭০', tsp: '৬৫', mop: '৯০', zinc: '৫'),
        FertilizerDose(cropName: 'mustard', cropNameBn: 'সরিষা', urea: '১৩০', tsp: '৯০', mop: '৬০', gypsum: '৪০'),
        FertilizerDose(cropName: 'wheat', cropNameBn: 'গম', urea: '২০০', tsp: '১০০', mop: '৮০'),
      ],
    ),

    // ================================================================
    // RANGPUR DIVISION — রংপুর বিভাগ
    // ================================================================

    // রংপুর — রংপুর সদর
    UpazilaCropData(
      division: 'রংপুর', zilla: 'রংপুর', upazila: 'রংপুর সদর',
      latitude: 25.74, longitude: 89.25,
      cropZone: 'AEZ-1', cropZoneBn: 'তিস্তা সমতল অঞ্চল',
      soilProfile: SoilProfile(
        type: 'sandy_loam', typeBn: 'বেলে দোআঁশ মাটি',
        phMin: 5.5, phMax: 6.5,
        organicMatter: 'low', drainage: 'good',
        description: 'তিস্তা নদীর বেলে দোআঁশ পলিমাটি। আলু, ভুট্টা ও বোরো ধানে বিখ্যাত।',
      ),
      suitableCrops: [
        CropSuitability(cropName: 'আলু', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'কার্ডিনাল', yieldTonPerHa: 28.0),
        CropSuitability(cropName: 'ভুট্টা', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'বারি হাইব্রিড-৭', yieldTonPerHa: 11.0),
        CropSuitability(cropName: 'বোরো ধান', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'ব্রি ধান-৫৮', yieldTonPerHa: 7.0),
        CropSuitability(cropName: 'রোপা আমন', season: 'kharif2', seasonBn: 'খরিফ-২', suitability: 'high', variety: 'বিআর-১১', yieldTonPerHa: 4.0),
        CropSuitability(cropName: 'গম', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'বারি গম-৩০', yieldTonPerHa: 4.2),
      ],
      cropPatterns: [
        CropPattern(robi: 'আলু', kharif1: 'পতিত', kharif2: 'রোপা আমন', profitIndex: 1400, bcRatioVig: 1.95, bcRatioTig: 1.65),
        CropPattern(robi: 'ভুট্টা', kharif1: 'পতিত', kharif2: 'রোপা আমন', profitIndex: 950, bcRatioVig: 1.72, bcRatioTig: 1.45),
        CropPattern(robi: 'গম', kharif1: 'পাট', kharif2: 'রোপা আমন', profitIndex: 720, bcRatioVig: 1.62, bcRatioTig: 1.35),
        CropPattern(robi: 'বোরো ধান', kharif1: 'পতিত', kharif2: 'রোপা আমন', profitIndex: 280, bcRatioVig: 1.40, bcRatioTig: 1.15),
      ],
      fertilizerDoses: [
        FertilizerDose(cropName: 'potato', cropNameBn: 'আলু', urea: '২৫০', tsp: '১৮০', mop: '২০০', gypsum: '৮০', zinc: '৫'),
        FertilizerDose(cropName: 'maize', cropNameBn: 'ভুট্টা', urea: '৩৫০', tsp: '১৫০', mop: '১৩০'),
        FertilizerDose(cropName: 'wheat', cropNameBn: 'গম', urea: '২০০', tsp: '১০০', mop: '৮০'),
        FertilizerDose(cropName: 'boro_rice', cropNameBn: 'বোরো ধান', urea: '২৭০', tsp: '৬৫', mop: '৯০', zinc: '৫'),
      ],
    ),

    // দিনাজপুর — দিনাজপুর সদর
    UpazilaCropData(
      division: 'রংপুর', zilla: 'দিনাজপুর', upazila: 'দিনাজপুর সদর',
      latitude: 25.63, longitude: 88.64,
      cropZone: 'AEZ-1', cropZoneBn: 'উত্তর-পশ্চিম সমতল অঞ্চল',
      soilProfile: SoilProfile(
        type: 'loam', typeBn: 'দোআঁশ মাটি',
        phMin: 5.8, phMax: 6.8,
        organicMatter: 'medium', drainage: 'good',
        description: 'উর্বর সমতল মাটি। ধান, গম ও সবজি চাষের জন্য বিখ্যাত।',
      ),
      suitableCrops: [
        CropSuitability(cropName: 'লিচু', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'বোম্বাই', yieldTonPerHa: 12.0),
        CropSuitability(cropName: 'বোরো ধান', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'ব্রি ধান-২৮', yieldTonPerHa: 6.8),
        CropSuitability(cropName: 'গম', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'বারি গম-২৮', yieldTonPerHa: 4.0),
        CropSuitability(cropName: 'রোপা আমন', season: 'kharif2', seasonBn: 'খরিফ-২', suitability: 'high', variety: 'বিআর-১১', yieldTonPerHa: 4.5),
        CropSuitability(cropName: 'আখ', season: 'kharif1', seasonBn: 'খরিফ-১', suitability: 'medium', variety: 'ঈশ্বরদী-৩৭', yieldTonPerHa: 75.0),
      ],
      cropPatterns: [
        CropPattern(robi: 'গম', kharif1: 'পাট', kharif2: 'রোপা আমন', profitIndex: 750, bcRatioVig: 1.68, bcRatioTig: 1.40),
        CropPattern(robi: 'বোরো ধান', kharif1: 'পতিত', kharif2: 'রোপা আমন', profitIndex: 310, bcRatioVig: 1.42, bcRatioTig: 1.18),
        CropPattern(robi: 'সবজি', kharif1: 'পতিত', kharif2: 'রোপা আমন', profitIndex: 1600, bcRatioVig: 2.15, bcRatioTig: 1.85),
      ],
      fertilizerDoses: [
        FertilizerDose(cropName: 'wheat', cropNameBn: 'গম', urea: '২০০', tsp: '১০০', mop: '৮০', gypsum: '৬০'),
        FertilizerDose(cropName: 'boro_rice', cropNameBn: 'বোরো ধান', urea: '২৭০', tsp: '৬৫', mop: '৯০', zinc: '৫'),
        FertilizerDose(cropName: 'vegetable', cropNameBn: 'শাকসবজি', urea: '২০০', tsp: '১২০', mop: '১০০'),
      ],
    ),

    // ================================================================
    // SYLHET DIVISION — সিলেট বিভাগ
    // ================================================================

    // সিলেট — সিলেট সদর
    UpazilaCropData(
      division: 'সিলেট', zilla: 'সিলেট', upazila: 'সিলেট সদর',
      latitude: 24.90, longitude: 91.87,
      cropZone: 'AEZ-20', cropZoneBn: 'সিলেট সমতল অঞ্চল',
      soilProfile: SoilProfile(
        type: 'clay', typeBn: 'ভারী এঁটেল মাটি',
        phMin: 5.0, phMax: 6.5,
        organicMatter: 'high', drainage: 'poor',
        description: 'উচ্চ বৃষ্টিপাতযুক্ত অম্লীয় মাটি। চা, রবার ও ধান চাষ উপযুক্ত।',
      ),
      suitableCrops: [
        CropSuitability(cropName: 'চা', season: 'kharif1', seasonBn: 'খরিফ-১', suitability: 'high', variety: 'BT-2/BT-3', yieldTonPerHa: 3.5),
        CropSuitability(cropName: 'রবার', season: 'kharif1', seasonBn: 'খরিফ-১', suitability: 'high', variety: 'RRIM-600', yieldTonPerHa: 2.5),
        CropSuitability(cropName: 'বোরো ধান', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'ব্রি ধান-২৯', yieldTonPerHa: 6.5),
        CropSuitability(cropName: 'রোপা আমন', season: 'kharif2', seasonBn: 'খরিফ-২', suitability: 'high', variety: 'বিআর-২২', yieldTonPerHa: 4.0),
        CropSuitability(cropName: 'শাকসবজি', season: 'rabi', seasonBn: 'রবি', suitability: 'medium', variety: 'মিশ্র', yieldTonPerHa: 15.0),
      ],
      cropPatterns: [
        CropPattern(robi: 'বোরো ধান', kharif1: 'পতিত', kharif2: 'রোপা আমন', profitIndex: 380, bcRatioVig: 1.48, bcRatioTig: 1.20),
        CropPattern(robi: 'সবজি', kharif1: 'পতিত', kharif2: 'রোপা আমন', profitIndex: 1300, bcRatioVig: 1.95, bcRatioTig: 1.68),
      ],
      fertilizerDoses: [
        FertilizerDose(cropName: 'boro_rice', cropNameBn: 'বোরো ধান', urea: '২৬০', tsp: '৬০', mop: '৮৫', zinc: '৫', remarks: 'অম্লীয় মাটিতে চুন প্রয়োগ করুন'),
        FertilizerDose(cropName: 'rice_aman', cropNameBn: 'রোপা আমন', urea: '১৬৫', tsp: '৫০', mop: '৫৫'),
      ],
    ),

    // মৌলভীবাজার — শ্রীমঙ্গল
    UpazilaCropData(
      division: 'সিলেট', zilla: 'মৌলভীবাজার', upazila: 'শ্রীমঙ্গল',
      latitude: 24.31, longitude: 91.73,
      cropZone: 'AEZ-20', cropZoneBn: 'চা বাগান অঞ্চল',
      soilProfile: SoilProfile(
        type: 'clay', typeBn: 'অম্লীয় চা বাগান মাটি',
        phMin: 4.5, phMax: 5.5,
        organicMatter: 'high', drainage: 'good',
        description: 'চা চাষের জন্য আদর্শ অম্লীয় মাটি। বাংলাদেশের চা রাজধানী।',
      ),
      suitableCrops: [
        CropSuitability(cropName: 'চা', season: 'kharif1', seasonBn: 'খরিফ-১', suitability: 'high', variety: 'TV-1, BT-2', yieldTonPerHa: 4.0),
        CropSuitability(cropName: 'লেবু', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'বারি লেবু-২', yieldTonPerHa: 10.0),
        CropSuitability(cropName: 'আনারস', season: 'kharif1', seasonBn: 'খরিফ-১', suitability: 'high', variety: 'জায়েন্ট কিউ', yieldTonPerHa: 35.0),
      ],
      cropPatterns: [
        CropPattern(robi: 'লেবু (বার্ষিক)', kharif1: 'লেবু', kharif2: 'লেবু', profitIndex: 2800, bcRatioVig: 2.60, bcRatioTig: 2.30),
        CropPattern(robi: 'সবজি', kharif1: 'আনারস', kharif2: 'রোপা আমন', profitIndex: 2200, bcRatioVig: 2.35, bcRatioTig: 2.05),
      ],
      fertilizerDoses: [
        FertilizerDose(cropName: 'tea', cropNameBn: 'চা', urea: '৪০০', tsp: '১৮০', mop: '৩০০', remarks: 'চা গাছে অ্যামোনিয়াম সালফেট ব্যবহার বেশি উপকারী'),
        FertilizerDose(cropName: 'pineapple', cropNameBn: 'আনারস', urea: '৩৫০', tsp: '২০০', mop: '২৫০'),
      ],
    ),

    // ================================================================
    // MYMENSINGH DIVISION — ময়মনসিংহ বিভাগ
    // ================================================================

    // ময়মনসিংহ — ময়মনসিংহ সদর
    UpazilaCropData(
      division: 'ময়মনসিংহ', zilla: 'ময়মনসিংহ', upazila: 'ময়মনসিংহ সদর',
      latitude: 24.75, longitude: 90.41,
      cropZone: 'AEZ-9', cropZoneBn: 'ব্রহ্মপুত্র-যমুনা পলিসমতল',
      soilProfile: SoilProfile(
        type: 'loam', typeBn: 'পলি দোআঁশ',
        phMin: 6.0, phMax: 7.0,
        organicMatter: 'high', drainage: 'moderate',
        description: 'ব্রহ্মপুত্র নদীর উর্বর পলিমাটি। কৃষি বিশ্ববিদ্যালয় অবস্থিত।',
      ),
      suitableCrops: [
        CropSuitability(cropName: 'বোরো ধান', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'ব্রি ধান-২৯', yieldTonPerHa: 7.5),
        CropSuitability(cropName: 'রোপা আমন', season: 'kharif2', seasonBn: 'খরিফ-২', suitability: 'high', variety: 'বিআর-১১', yieldTonPerHa: 4.8),
        CropSuitability(cropName: 'পাট', season: 'kharif1', seasonBn: 'খরিফ-১', suitability: 'high', variety: 'বিজেআরআই দেশী পাট-৮', yieldTonPerHa: 3.8),
        CropSuitability(cropName: 'সরিষা', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'বারি সরিষা-১৪', yieldTonPerHa: 2.0),
        CropSuitability(cropName: 'শাকসবজি', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'মিশ্র', yieldTonPerHa: 20.0),
      ],
      cropPatterns: [
        CropPattern(robi: 'বোরো ধান', kharif1: 'পাট', kharif2: 'রোপা আমন', profitIndex: 520, bcRatioVig: 1.55, bcRatioTig: 1.28),
        CropPattern(robi: 'সরিষা', kharif1: 'পাট', kharif2: 'রোপা আমন', profitIndex: 680, bcRatioVig: 1.62, bcRatioTig: 1.35),
        CropPattern(robi: 'সবজি', kharif1: 'পতিত', kharif2: 'রোপা আমন', profitIndex: 1500, bcRatioVig: 2.05, bcRatioTig: 1.75),
      ],
      fertilizerDoses: [
        FertilizerDose(cropName: 'boro_rice', cropNameBn: 'বোরো ধান', urea: '২৭০', tsp: '৬৫', mop: '৯০', zinc: '৫'),
        FertilizerDose(cropName: 'jute', cropNameBn: 'পাট', urea: '১৩০', tsp: '৮০', mop: '৬০'),
        FertilizerDose(cropName: 'mustard', cropNameBn: 'সরিষা', urea: '১৩০', tsp: '৯০', mop: '৬০', gypsum: '৪০'),
        FertilizerDose(cropName: 'rice_aman', cropNameBn: 'রোপা আমন', urea: '১৭০', tsp: '৫৫', mop: '৬০'),
      ],
    ),

    // ================================================================
    // BARISHAL DIVISION — বরিশাল বিভাগ
    // ================================================================

    // বরিশাল — বরিশাল সদর
    UpazilaCropData(
      division: 'বরিশাল', zilla: 'বরিশাল', upazila: 'বরিশাল সদর',
      latitude: 22.70, longitude: 90.37,
      cropZone: 'AEZ-13', cropZoneBn: 'গঙ্গা-ব্রহ্মপুত্র প্লাবনসমভূমি',
      soilProfile: SoilProfile(
        type: 'clay', typeBn: 'ভারী পলিমাটি',
        phMin: 6.5, phMax: 7.5,
        organicMatter: 'high', drainage: 'poor',
        description: 'ভাটির দেশের নদীবাহিত উর্বর পলিমাটি। বোরো ও আমন ধান প্রধান।',
      ),
      suitableCrops: [
        CropSuitability(cropName: 'বোরো ধান', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'ব্রি ধান-২৮/২৯', yieldTonPerHa: 7.0),
        CropSuitability(cropName: 'রোপা আমন', season: 'kharif2', seasonBn: 'খরিফ-২', suitability: 'high', variety: 'বিআর-১১/বিআর-২২', yieldTonPerHa: 4.5),
        CropSuitability(cropName: 'সরিষা', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'বারি সরিষা-৯', yieldTonPerHa: 1.6),
        CropSuitability(cropName: 'নারকেল', season: 'kharif1', seasonBn: 'খরিফ-১', suitability: 'high', variety: 'স্থানীয়', yieldTonPerHa: 8.0),
      ],
      cropPatterns: [
        CropPattern(robi: 'বোরো ধান', kharif1: 'পতিত', kharif2: 'রোপা আমন', profitIndex: 350, bcRatioVig: 1.45, bcRatioTig: 1.18),
        CropPattern(robi: 'সরিষা', kharif1: 'পতিত', kharif2: 'রোপা আমন', profitIndex: 480, bcRatioVig: 1.52, bcRatioTig: 1.25),
        CropPattern(robi: 'সবজি', kharif1: 'পতিত', kharif2: 'রোপা আমন', profitIndex: 1200, bcRatioVig: 1.88, bcRatioTig: 1.60),
      ],
      fertilizerDoses: [
        FertilizerDose(cropName: 'boro_rice', cropNameBn: 'বোরো ধান', urea: '২৬৫', tsp: '৬৫', mop: '৮৮', zinc: '৫'),
        FertilizerDose(cropName: 'rice_aman', cropNameBn: 'রোপা আমন', urea: '১৬৮', tsp: '৫২', mop: '৫৮'),
        FertilizerDose(cropName: 'mustard', cropNameBn: 'সরিষা', urea: '১২৫', tsp: '৮৫', mop: '৫৮', gypsum: '৪০'),
      ],
    ),

    // পটুয়াখালী — কলাপাড়া (উপকূলীয়)
    UpazilaCropData(
      division: 'বরিশাল', zilla: 'পটুয়াখালী', upazila: 'কলাপাড়া',
      latitude: 21.88, longitude: 90.23,
      cropZone: 'AEZ-13', cropZoneBn: 'উপকূলীয় অঞ্চল',
      soilProfile: SoilProfile(
        type: 'clay', typeBn: 'লবণাক্ত পলিমাটি',
        phMin: 7.0, phMax: 8.0,
        organicMatter: 'medium', drainage: 'poor',
        description: 'সমুদ্র উপকূলের জোয়ারভাটার প্রভাবযুক্ত মাটি।',
      ),
      suitableCrops: [
        CropSuitability(cropName: 'রোপা আমন (ভাসমান)', season: 'kharif2', seasonBn: 'খরিফ-২', suitability: 'high', variety: 'বিনা ধান-১১', yieldTonPerHa: 3.5),
        CropSuitability(cropName: 'মিষ্টি কুমড়া', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'বারি মিষ্টি কুমড়া-১', yieldTonPerHa: 25.0),
        CropSuitability(cropName: 'বাদাম', season: 'rabi', seasonBn: 'রবি', suitability: 'high', variety: 'ঢাকা-১', yieldTonPerHa: 2.2),
      ],
      cropPatterns: [
        CropPattern(robi: 'মিষ্টি কুমড়া', kharif1: 'পতিত', kharif2: 'রোপা আমন', profitIndex: 900, bcRatioVig: 1.72, bcRatioTig: 1.42),
        CropPattern(robi: 'বাদাম', kharif1: 'পতিত', kharif2: 'রোপা আমন', profitIndex: 650, bcRatioVig: 1.58, bcRatioTig: 1.30),
      ],
      fertilizerDoses: [
        FertilizerDose(cropName: 'pumpkin', cropNameBn: 'মিষ্টি কুমড়া', urea: '১৮০', tsp: '১৫০', mop: '১২০', gypsum: '৫০'),
        FertilizerDose(cropName: 'groundnut', cropNameBn: 'বাদাম', urea: '৫০', tsp: '১৩০', mop: '৮০', gypsum: '৭০'),
        FertilizerDose(cropName: 'rice_aman', cropNameBn: 'রোপা আমন', urea: '১৫০', tsp: '৫০', mop: '৫৫'),
      ],
    ),
  ];

  // ================================================================
  // Search helpers
  // ================================================================

  static UpazilaCropData? findByLocation(String division, String zilla, String upazila) {
    try {
      return allData.firstWhere(
        (d) => d.division == division && d.zilla == zilla && d.upazila == upazila,
      );
    } catch (e) {
      // Fallback: find by division and zilla only
      try {
        return allData.firstWhere(
          (d) => d.division == division && d.zilla == zilla,
        );
      } catch (e) {
        // Fallback: find by division only
        try {
          return allData.firstWhere((d) => d.division == division);
        } catch (e) {
          return null;
        }
      }
    }
  }

  static UpazilaCropData? findNearest(double lat, double lng) {
    if (allData.isEmpty) return null;
    UpazilaCropData? nearest;
    double minDist = double.infinity;
    for (final d in allData) {
      final dist = _dist(lat, lng, d.latitude, d.longitude);
      if (dist < minDist) {
        minDist = dist;
        nearest = d;
      }
    }
    return nearest;
  }

  static double _dist(double lat1, double lng1, double lat2, double lng2) {
    final dLat = (lat2 - lat1) * (lat2 - lat1);
    final dLng = (lng2 - lng1) * (lng2 - lng1);
    return dLat + dLng;
  }

  static List<UpazilaCropData> searchByName(String query) {
    final q = query.toLowerCase().trim();
    return allData.where((d) =>
      d.upazila.contains(q) ||
      d.zilla.contains(q) ||
      d.division.contains(q) ||
      d.suitableCrops.any((c) => c.cropName.contains(q))
    ).toList();
  }
}
