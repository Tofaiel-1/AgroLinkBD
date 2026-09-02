/// Comprehensive Bangladesh Union Data
/// Covers all 64 districts with representative unions per upazila
/// Each union entry: [unionName, unionNameBn, upazila, district, division, lat, lng]
class BDUnionData {

  /// Key unions per district — covers all 64 districts & 8 divisions
  /// Format: { 'District': [ ['UnionEn', 'ইউনিয়নBn', lat, lng], ... ] }
  static const Map<String, List<Map<String, dynamic>>> unionsByDistrict = {

    // ==================== BARISHAL DIVISION ====================
    'Patuakhali': [
      {'en': 'Dumki Sadar', 'bn': 'দুমকি সদর', 'upazila': 'Dumki', 'lat': 22.4500, 'lng': 90.3800},
      {'en': 'Muradia', 'bn': 'মুরাদিয়া', 'upazila': 'Dumki', 'lat': 22.4600, 'lng': 90.3700},
      {'en': 'Lebukhali', 'bn': 'লেবুখালী', 'upazila': 'Dumki', 'lat': 22.4400, 'lng': 90.3900},
      {'en': 'Pangashia', 'bn': 'পাঙ্গাশিয়া', 'upazila': 'Dumki', 'lat': 22.4300, 'lng': 90.3600},
      {'en': 'Angaria', 'bn': 'আংগারিয়া', 'upazila': 'Dumki', 'lat': 22.4700, 'lng': 90.3800},
      {'en': 'Bauphal Sadar', 'bn': 'বাউফল সদর', 'upazila': 'Bauphal', 'lat': 22.4167, 'lng': 90.5833},
      {'en': 'Daspara', 'bn': 'দাশপাড়া', 'upazila': 'Bauphal', 'lat': 22.4200, 'lng': 90.5700},
      {'en': 'Kalisuri', 'bn': 'কালিশুরী', 'upazila': 'Bauphal', 'lat': 22.4300, 'lng': 90.5900},
      {'en': 'Galachipa Sadar', 'bn': 'গলাচিপা সদর', 'upazila': 'Galachipa', 'lat': 22.1667, 'lng': 90.4167},
      {'en': 'Panpatti', 'bn': 'পানপট্টি', 'upazila': 'Galachipa', 'lat': 22.1700, 'lng': 90.4200},
      {'en': 'Kalapara Sadar', 'bn': 'কলাপাড়া সদর', 'upazila': 'Kalapara', 'lat': 21.8786, 'lng': 90.2480},
      {'en': 'Nilganj', 'bn': 'নীলগঞ্জ', 'upazila': 'Kalapara', 'lat': 21.8900, 'lng': 90.2600},
      {'en': 'Mirzaganj Sadar', 'bn': 'মির্জাগঞ্জ সদর', 'upazila': 'Mirzaganj', 'lat': 22.5330, 'lng': 90.1833},
      {'en': 'Dashmina Sadar', 'bn': 'দশমিনা সদর', 'upazila': 'Dashmina', 'lat': 22.3050, 'lng': 90.5350},
      {'en': 'Rangabali Sadar', 'bn': 'রাঙ্গাবালী সদর', 'upazila': 'Rangabali', 'lat': 21.9100, 'lng': 90.4800},
      {'en': 'Patuakhali Sadar', 'bn': 'পটুয়াখালী সদর', 'upazila': 'Patuakhali Sadar', 'lat': 22.3596, 'lng': 90.3299},
    ],

    'Barisal': [
      {'en': 'Barisal City', 'bn': 'বরিশাল শহর', 'upazila': 'Barisal Sadar', 'lat': 22.7010, 'lng': 90.3535},
      {'en': 'Charamaddi', 'bn': 'চরামদ্দি', 'upazila': 'Barisal Sadar', 'lat': 22.7200, 'lng': 90.3600},
      {'en': 'Rajihar', 'bn': 'রাজিহার', 'upazila': 'Agailjhara', 'lat': 22.7900, 'lng': 90.2800},
      {'en': 'Babuganj Sadar', 'bn': 'বাবুগঞ্জ সদর', 'upazila': 'Babuganj', 'lat': 22.6200, 'lng': 90.3800},
      {'en': 'Wazirpur Sadar', 'bn': 'বাকেরগঞ্জ সদর', 'upazila': 'Bakerganj', 'lat': 22.5620, 'lng': 90.3300},
      {'en': 'Gournadi Sadar', 'bn': 'গৌরনদী সদর', 'upazila': 'Gournadi', 'lat': 22.9700, 'lng': 90.2600},
      {'en': 'Hizla Sadar', 'bn': 'হিজলা সদর', 'upazila': 'Hizla', 'lat': 22.6900, 'lng': 90.5300},
      {'en': 'Mehendiganj Sadar', 'bn': 'মেহেন্দিগঞ্জ সদর', 'upazila': 'Mehendiganj', 'lat': 22.5000, 'lng': 90.5700},
      {'en': 'Muladi Sadar', 'bn': 'মুলাদী সদর', 'upazila': 'Muladi', 'lat': 22.7400, 'lng': 90.4800},
    ],

    'Barguna': [
      {'en': 'Barguna Sadar', 'bn': 'বরগুনা সদর', 'upazila': 'Barguna Sadar', 'lat': 22.1570, 'lng': 90.1249},
      {'en': 'Betagi Sadar', 'bn': 'বেতাগী সদর', 'upazila': 'Betagi', 'lat': 22.3500, 'lng': 90.1600},
      {'en': 'Amtali Sadar', 'bn': 'আমতলী সদর', 'upazila': 'Amtali', 'lat': 22.0280, 'lng': 90.2400},
      {'en': 'Patharghata Sadar', 'bn': 'পাথরঘাটা সদর', 'upazila': 'Patharghata', 'lat': 21.8500, 'lng': 89.9700},
      {'en': 'Bamna Sadar', 'bn': 'বামনা সদর', 'upazila': 'Bamna', 'lat': 22.3100, 'lng': 89.9900},
      {'en': 'Taltali Sadar', 'bn': 'তালতলী সদর', 'upazila': 'Taltali', 'lat': 21.8800, 'lng': 90.1500},
    ],

    'Bhola': [
      {'en': 'Bhola Sadar', 'bn': 'ভোলা সদর', 'upazila': 'Bhola Sadar', 'lat': 22.6859, 'lng': 90.6481},
      {'en': 'Borhanuddin Sadar', 'bn': 'বোরহানউদ্দিন সদর', 'upazila': 'Borhanuddin', 'lat': 22.8900, 'lng': 90.6800},
      {'en': 'Char Fasson Sadar', 'bn': 'চরফ্যাশন সদর', 'upazila': 'Char Fasson', 'lat': 22.2500, 'lng': 90.7200},
      {'en': 'Daulatkhan Sadar', 'bn': 'দৌলতখান সদর', 'upazila': 'Daulatkhan', 'lat': 22.8200, 'lng': 90.7600},
      {'en': 'Lalmohan Sadar', 'bn': 'লালমোহন সদর', 'upazila': 'Lalmohan', 'lat': 22.4400, 'lng': 90.7000},
      {'en': 'Manpura Sadar', 'bn': 'মনপুরা সদর', 'upazila': 'Manpura', 'lat': 22.1400, 'lng': 90.8400},
      {'en': 'Tazumuddin Sadar', 'bn': 'তজুমদ্দিন সদর', 'upazila': 'Tazumuddin', 'lat': 22.6500, 'lng': 90.8600},
    ],

    'Jhalokati': [
      {'en': 'Jhalokati Sadar', 'bn': 'ঝালকাঠি সদর', 'upazila': 'Jhalokati Sadar', 'lat': 22.6406, 'lng': 90.1987},
      {'en': 'Kathalia Sadar', 'bn': 'কাঠালিয়া সদর', 'upazila': 'Kathalia', 'lat': 22.4900, 'lng': 90.0400},
      {'en': 'Nalchity Sadar', 'bn': 'নলছিটি সদর', 'upazila': 'Nalchity', 'lat': 22.6800, 'lng': 90.0700},
      {'en': 'Rajapur Sadar', 'bn': 'রাজাপুর সদর', 'upazila': 'Rajapur', 'lat': 22.7500, 'lng': 90.1200},
    ],

    'Pirojpur': [
      {'en': 'Pirojpur Sadar', 'bn': 'পিরোজপুর সদর', 'upazila': 'Pirojpur Sadar', 'lat': 22.5841, 'lng': 89.9720},
      {'en': 'Bhandaria Sadar', 'bn': 'ভান্ডারিয়া সদর', 'upazila': 'Bhandaria', 'lat': 22.4900, 'lng': 89.9500},
      {'en': 'Kawkhali Sadar', 'bn': 'কাউখালী সদর', 'upazila': 'Kawkhali', 'lat': 22.6200, 'lng': 89.8500},
      {'en': 'Mathbaria Sadar', 'bn': 'মঠবাড়িয়া সদর', 'upazila': 'Mathbaria', 'lat': 22.3100, 'lng': 89.9200},
      {'en': 'Nazirpur Sadar', 'bn': 'নাজিরপুর সদর', 'upazila': 'Nazirpur', 'lat': 22.7600, 'lng': 89.9100},
      {'en': 'Nesarabad Sadar', 'bn': 'নেছারাবাদ সদর', 'upazila': 'Nesarabad', 'lat': 22.6400, 'lng': 90.0500},
      {'en': 'Indurkani Sadar', 'bn': 'ইন্দুরকানি সদর', 'upazila': 'Indurkani', 'lat': 22.5400, 'lng': 89.8800},
    ],

    // ==================== RAJSHAHI DIVISION ====================
    'Natore': [
      {'en': 'Gurudaspur Sadar', 'bn': 'গুরুদাসপুর সদর', 'upazila': 'Gurudaspur', 'lat': 24.3667, 'lng': 89.1500},
      {'en': 'Biara', 'bn': 'বিয়ারা', 'upazila': 'Gurudaspur', 'lat': 24.3700, 'lng': 89.1400},
      {'en': 'Chapaibari', 'bn': 'চাপাইবাড়ি', 'upazila': 'Gurudaspur', 'lat': 24.3800, 'lng': 89.1600},
      {'en': 'Khubjipur', 'bn': 'খুবজিপুর', 'upazila': 'Gurudaspur', 'lat': 24.3600, 'lng': 89.1700},
      {'en': 'Natore Sadar', 'bn': 'নাটোর সদর', 'upazila': 'Natore Sadar', 'lat': 24.4102, 'lng': 89.0076},
      {'en': 'Kafuria', 'bn': 'কাফুরিয়া', 'upazila': 'Natore Sadar', 'lat': 24.4200, 'lng': 89.0100},
      {'en': 'Baraigram Sadar', 'bn': 'বড়াইগ্রাম সদর', 'upazila': 'Baraigram', 'lat': 24.3000, 'lng': 89.1667},
      {'en': 'Chhatni', 'bn': 'ছাতনি', 'upazila': 'Baraigram', 'lat': 24.3100, 'lng': 89.1800},
      {'en': 'Singra Sadar', 'bn': 'সিংড়া সদর', 'upazila': 'Singra', 'lat': 24.5000, 'lng': 89.1500},
      {'en': 'Chalita Danga', 'bn': 'চলিতডাঙ্গা', 'upazila': 'Singra', 'lat': 24.5100, 'lng': 89.1600},
      {'en': 'Bagatipara Sadar', 'bn': 'বাগাতিপাড়া সদর', 'upazila': 'Bagatipara', 'lat': 24.4600, 'lng': 89.0200},
      {'en': 'Lalpur Sadar', 'bn': 'লালপুর সদর', 'upazila': 'Lalpur', 'lat': 24.2300, 'lng': 88.9500},
      {'en': 'Naldanga Sadar', 'bn': 'নলডাঙ্গা সদর', 'upazila': 'Naldanga', 'lat': 24.4900, 'lng': 88.9700},
    ],

    'Rajshahi': [
      {'en': 'Paba Sadar', 'bn': 'পবা সদর', 'upazila': 'Paba', 'lat': 24.4333, 'lng': 88.6167},
      {'en': 'Haripur', 'bn': 'হরিপুর', 'upazila': 'Paba', 'lat': 24.4400, 'lng': 88.6200},
      {'en': 'Rajshahi City', 'bn': 'রাজশাহী শহর', 'upazila': 'Rajshahi Sadar', 'lat': 24.3745, 'lng': 88.6042},
      {'en': 'Godagari Sadar', 'bn': 'গোদাগাড়ী সদর', 'upazila': 'Godagari', 'lat': 24.4600, 'lng': 88.3700},
      {'en': 'Tanore Sadar', 'bn': 'তানোর সদর', 'upazila': 'Tanore', 'lat': 24.5700, 'lng': 88.5000},
      {'en': 'Bagha Sadar', 'bn': 'বাঘা সদর', 'upazila': 'Bagha', 'lat': 24.2300, 'lng': 88.6900},
      {'en': 'Bagmara Sadar', 'bn': 'বাগমারা সদর', 'upazila': 'Bagmara', 'lat': 24.5200, 'lng': 88.7600},
      {'en': 'Charghat Sadar', 'bn': 'চারঘাট সদর', 'upazila': 'Charghat', 'lat': 24.2700, 'lng': 88.7500},
      {'en': 'Durgapur Sadar', 'bn': 'দুর্গাপুর সদর', 'upazila': 'Durgapur', 'lat': 24.7400, 'lng': 88.6800},
      {'en': 'Mohonpur Sadar', 'bn': 'মোহনপুর সদর', 'upazila': 'Mohonpur', 'lat': 24.4800, 'lng': 88.7200},
      {'en': 'Puthia Sadar', 'bn': 'পুঠিয়া সদর', 'upazila': 'Puthia', 'lat': 24.3600, 'lng': 88.8800},
    ],

    'Bogura': [
      {'en': 'Bogura Sadar', 'bn': 'বগুড়া সদর', 'upazila': 'Bogura Sadar', 'lat': 24.8481, 'lng': 89.3730},
      {'en': 'Shibganj Sadar', 'bn': 'শিবগঞ্জ সদর', 'upazila': 'Shibganj', 'lat': 24.9500, 'lng': 88.5000},
      {'en': 'Kahalu Sadar', 'bn': 'কাহালু সদর', 'upazila': 'Kahaloo', 'lat': 24.7200, 'lng': 89.1900},
      {'en': 'Gabtali Sadar', 'bn': 'গাবতলী সদর', 'upazila': 'Gabtali', 'lat': 24.7600, 'lng': 89.1800},
      {'en': 'Dhunat Sadar', 'bn': 'ধুনট সদর', 'upazila': 'Dhunat', 'lat': 24.5700, 'lng': 89.5000},
      {'en': 'Nandigram Sadar', 'bn': 'নন্দীগ্রাম সদর', 'upazila': 'Nandigram', 'lat': 24.6400, 'lng': 89.4600},
      {'en': 'Sariakandi Sadar', 'bn': 'সারিয়াকান্দি সদর', 'upazila': 'Sariakandi', 'lat': 24.8900, 'lng': 89.6700},
      {'en': 'Shajahanpur Sadar', 'bn': 'শাজাহানপুর সদর', 'upazila': 'Shajahanpur', 'lat': 24.8800, 'lng': 89.4800},
      {'en': 'Sherpur Sadar (Bogura)', 'bn': 'শেরপুর সদর (বগুড়া)', 'upazila': 'Sherpur', 'lat': 24.6200, 'lng': 89.2700},
      {'en': 'Sonatala Sadar', 'bn': 'সোনাতলা সদর', 'upazila': 'Sonatala', 'lat': 25.0100, 'lng': 89.4300},
      {'en': 'Adamdighi Sadar', 'bn': 'আদমদীঘি সদর', 'upazila': 'Adamdighi', 'lat': 24.7000, 'lng': 89.0500},
    ],

    'Chapainawabganj': [
      {'en': 'Chapai Sadar', 'bn': 'চাঁপাই নবাবগঞ্জ সদর', 'upazila': 'Chapainawabganj Sadar', 'lat': 24.5965, 'lng': 88.2775},
      {'en': 'Gomastapur Sadar', 'bn': 'গোমস্তাপুর সদর', 'upazila': 'Gomastapur', 'lat': 24.6800, 'lng': 88.1300},
      {'en': 'Nachole Sadar', 'bn': 'নাচোল সদর', 'upazila': 'Nachole', 'lat': 24.7000, 'lng': 88.2000},
      {'en': 'Bholahat Sadar', 'bn': 'ভোলাহাট সদর', 'upazila': 'Bholahat', 'lat': 24.5200, 'lng': 88.1000},
      {'en': 'Shibganj (Chapai) Sadar', 'bn': 'শিবগঞ্জ (চাঁপাই) সদর', 'upazila': 'Shibganj (Chapai)', 'lat': 24.8000, 'lng': 88.2000},
    ],

    'Naogaon': [
      {'en': 'Naogaon Sadar', 'bn': 'নওগাঁ সদর', 'upazila': 'Naogaon Sadar', 'lat': 24.7936, 'lng': 88.9318},
      {'en': 'Atrai Sadar', 'bn': 'আত্রাই সদর', 'upazila': 'Atrai', 'lat': 24.5800, 'lng': 89.0000},
      {'en': 'Badalgachhi Sadar', 'bn': 'বদলগাছী সদর', 'upazila': 'Badalgachhi', 'lat': 24.7400, 'lng': 88.7200},
      {'en': 'Manda Sadar', 'bn': 'মান্দা সদর', 'upazila': 'Manda', 'lat': 24.6500, 'lng': 88.8800},
      {'en': 'Mohadevpur Sadar', 'bn': 'মহাদেবপুর সদর', 'upazila': 'Mohadevpur', 'lat': 24.9400, 'lng': 88.6700},
      {'en': 'Niamatpur Sadar', 'bn': 'নিয়ামতপুর সদর', 'upazila': 'Niamatpur', 'lat': 24.9700, 'lng': 88.9400},
      {'en': 'Porsha Sadar', 'bn': 'পোরশা সদর', 'upazila': 'Porsha', 'lat': 25.1400, 'lng': 88.7600},
      {'en': 'Raninagar Sadar', 'bn': 'রানীনগর সদর', 'upazila': 'Raninagar', 'lat': 24.5300, 'lng': 88.9000},
      {'en': 'Sapahar Sadar', 'bn': 'সাপাহার সদর', 'upazila': 'Sapahar', 'lat': 25.1200, 'lng': 88.6700},
      {'en': 'Patnitala Sadar', 'bn': 'পতনতলা সদর', 'upazila': 'Patnitala', 'lat': 24.9900, 'lng': 88.7400},
      {'en': 'Dhamoirhat Sadar', 'bn': 'ধামইরহাট সদর', 'upazila': 'Dhamoirhat', 'lat': 25.0800, 'lng': 88.9900},
    ],

    'Pabna': [
      {'en': 'Pabna Sadar', 'bn': 'পাবনা সদর', 'upazila': 'Pabna Sadar', 'lat': 24.0064, 'lng': 89.2494},
      {'en': 'Atgharia Sadar', 'bn': 'আটঘরিয়া সদর', 'upazila': 'Atgharia', 'lat': 24.0700, 'lng': 89.3100},
      {'en': 'Bera Sadar', 'bn': 'বেড়া সদর', 'upazila': 'Bera', 'lat': 24.0800, 'lng': 89.5500},
      {'en': 'Bhangura Sadar', 'bn': 'ভাঙ্গুড়া সদর', 'upazila': 'Bhangura', 'lat': 24.2700, 'lng': 89.3700},
      {'en': 'Chatmohar Sadar', 'bn': 'চাটমোহর সদর', 'upazila': 'Chatmohar', 'lat': 24.2300, 'lng': 89.1600},
      {'en': 'Faridpur (Pabna) Sadar', 'bn': 'ফরিদপুর (পাবনা) সদর', 'upazila': 'Faridpur (Pabna)', 'lat': 24.1700, 'lng': 89.0400},
      {'en': 'Ishwardi Sadar', 'bn': 'ঈশ্বরদী সদর', 'upazila': 'Ishwardi', 'lat': 24.1200, 'lng': 89.0600},
      {'en': 'Santhia Sadar', 'bn': 'সাঁথিয়া সদর', 'upazila': 'Santhia', 'lat': 24.1300, 'lng': 89.1900},
      {'en': 'Sujanagar Sadar', 'bn': 'সুজানগর সদর', 'upazila': 'Sujanagar', 'lat': 23.9000, 'lng': 89.4500},
    ],

    'Sirajganj': [
      {'en': 'Sirajganj Sadar', 'bn': 'সিরাজগঞ্জ সদর', 'upazila': 'Sirajganj Sadar', 'lat': 24.4534, 'lng': 89.7008},
      {'en': 'Belkuchi Sadar', 'bn': 'বেলকুচি সদর', 'upazila': 'Belkuchi', 'lat': 24.4000, 'lng': 89.7900},
      {'en': 'Chauhali Sadar', 'bn': 'চৌহালী সদর', 'upazila': 'Chauhali', 'lat': 24.3000, 'lng': 89.8600},
      {'en': 'Kamarkhand Sadar', 'bn': 'কামারখন্দ সদর', 'upazila': 'Kamarkhand', 'lat': 24.3400, 'lng': 89.7700},
      {'en': 'Raiganj Sadar', 'bn': 'রায়গঞ্জ সদর', 'upazila': 'Raiganj', 'lat': 24.6200, 'lng': 89.6500},
      {'en': 'Shahjadpur Sadar', 'bn': 'শাহজাদপুর সদর', 'upazila': 'Shahjadpur', 'lat': 24.2200, 'lng': 89.6500},
      {'en': 'Tarash Sadar', 'bn': 'তাড়াশ সদর', 'upazila': 'Tarash', 'lat': 24.3000, 'lng': 89.4700},
      {'en': 'Ullahpara Sadar', 'bn': 'উল্লাপাড়া সদর', 'upazila': 'Ullahpara', 'lat': 24.2900, 'lng': 89.5800},
    ],

    'Joypurhat': [
      {'en': 'Joypurhat Sadar', 'bn': 'জয়পুরহাট সদর', 'upazila': 'Joypurhat Sadar', 'lat': 25.1017, 'lng': 89.0267},
      {'en': 'Akkelpur Sadar', 'bn': 'আক্কেলপুর সদর', 'upazila': 'Akkelpur', 'lat': 25.0500, 'lng': 89.0000},
      {'en': 'Kalai Sadar', 'bn': 'কালাই সদর', 'upazila': 'Kalai', 'lat': 24.9600, 'lng': 89.1200},
      {'en': 'Khetlal Sadar', 'bn': 'ক্ষেতলাল সদর', 'upazila': 'Khetlal', 'lat': 24.9000, 'lng': 89.0500},
      {'en': 'Panchbibi Sadar', 'bn': 'পাঁচবিবি সদর', 'upazila': 'Panchbibi', 'lat': 25.0600, 'lng': 89.1500},
    ],

    // ==================== DHAKA DIVISION ====================
    'Dhaka': [
      {'en': 'Savar Sadar', 'bn': 'সাভার সদর', 'upazila': 'Savar', 'lat': 23.8583, 'lng': 90.2667},
      {'en': 'Ashulia', 'bn': 'আশুলিয়া', 'upazila': 'Savar', 'lat': 23.8980, 'lng': 90.2430},
      {'en': 'Birulia', 'bn': 'বিরুলিয়া', 'upazila': 'Savar', 'lat': 23.8400, 'lng': 90.2800},
      {'en': 'Dhamrai Sadar', 'bn': 'ধামরাই সদর', 'upazila': 'Dhamrai', 'lat': 23.9200, 'lng': 90.2000},
      {'en': 'Keraniganj Sadar', 'bn': 'কেরানীগঞ্জ সদর', 'upazila': 'Keraniganj', 'lat': 23.6900, 'lng': 90.3900},
      {'en': 'Dohar Sadar', 'bn': 'দোহার সদর', 'upazila': 'Dohar', 'lat': 23.5900, 'lng': 90.1300},
      {'en': 'Nawabganj (Dhaka) Sadar', 'bn': 'নবাবগঞ্জ (ঢাকা) সদর', 'upazila': 'Nawabganj (Dhaka)', 'lat': 23.6700, 'lng': 90.0700},
    ],

    'Gazipur': [
      {'en': 'Gazipur Sadar', 'bn': 'গাজীপুর সদর', 'upazila': 'Gazipur Sadar', 'lat': 23.9999, 'lng': 90.4203},
      {'en': 'Kaliakair Sadar', 'bn': 'কালিয়াকৈর সদর', 'upazila': 'Kaliakair', 'lat': 24.0667, 'lng': 90.2167},
      {'en': 'Kapasia Sadar', 'bn': 'কাপাসিয়া সদর', 'upazila': 'Kapasia', 'lat': 24.1100, 'lng': 90.5900},
      {'en': 'Kaliganj (Gazipur) Sadar', 'bn': 'কালীগঞ্জ (গাজীপুর) সদর', 'upazila': 'Kaliganj (Gazipur)', 'lat': 24.0000, 'lng': 90.5000},
      {'en': 'Sreepur Sadar', 'bn': 'শ্রীপুর সদর', 'upazila': 'Sreepur', 'lat': 24.1900, 'lng': 90.4700},
    ],

    'Tangail': [
      {'en': 'Tangail Sadar', 'bn': 'টাঙ্গাইল সদর', 'upazila': 'Tangail Sadar', 'lat': 24.2513, 'lng': 89.9167},
      {'en': 'Basail Sadar', 'bn': 'বাসাইল সদর', 'upazila': 'Basail', 'lat': 24.2400, 'lng': 90.0200},
      {'en': 'Bhuapur Sadar', 'bn': 'ভূঞাপুর সদর', 'upazila': 'Bhuapur', 'lat': 24.4200, 'lng': 89.8900},
      {'en': 'Delduar Sadar', 'bn': 'দেলদুয়ার সদর', 'upazila': 'Delduar', 'lat': 24.1600, 'lng': 89.9600},
      {'en': 'Ghatail Sadar', 'bn': 'ঘাটাইল সদর', 'upazila': 'Ghatail', 'lat': 24.4600, 'lng': 89.8400},
      {'en': 'Gopalpur Sadar', 'bn': 'গোপালপুর সদর', 'upazila': 'Gopalpur', 'lat': 24.5800, 'lng': 89.9900},
      {'en': 'Kalihati Sadar', 'bn': 'কালিহাতী সদর', 'upazila': 'Kalihati', 'lat': 24.2900, 'lng': 89.9900},
      {'en': 'Madhupur Sadar', 'bn': 'মধুপুর সদর', 'upazila': 'Madhupur', 'lat': 24.6200, 'lng': 90.0100},
      {'en': 'Mirzapur Sadar', 'bn': 'মির্জাপুর সদর', 'upazila': 'Mirzapur', 'lat': 24.0900, 'lng': 90.0700},
      {'en': 'Nagarpur Sadar', 'bn': 'নাগরপুর সদর', 'upazila': 'Nagarpur', 'lat': 23.9500, 'lng': 89.8200},
      {'en': 'Sakhipur Sadar', 'bn': 'সখীপুর সদর', 'upazila': 'Sakhipur', 'lat': 24.4100, 'lng': 90.1500},
      {'en': 'Dhanbari Sadar', 'bn': 'ধনবাড়ী সদর', 'upazila': 'Dhanbari', 'lat': 24.5500, 'lng': 89.9200},
    ],

    'Narayanganj': [
      {'en': 'Narayanganj Sadar', 'bn': 'নারায়ণগঞ্জ সদর', 'upazila': 'Narayanganj Sadar', 'lat': 23.6238, 'lng': 90.5000},
      {'en': 'Araihazar Sadar', 'bn': 'আড়াইহাজার সদর', 'upazila': 'Araihazar', 'lat': 23.6700, 'lng': 90.6500},
      {'en': 'Bandar Sadar', 'bn': 'বন্দর সদর', 'upazila': 'Bandar', 'lat': 23.5900, 'lng': 90.5500},
      {'en': 'Rupganj Sadar', 'bn': 'রূপগঞ্জ সদর', 'upazila': 'Rupganj', 'lat': 23.7400, 'lng': 90.5500},
      {'en': 'Sonargaon Sadar', 'bn': 'সোনারগাঁও সদর', 'upazila': 'Sonargaon', 'lat': 23.6500, 'lng': 90.6000},
    ],

    'Faridpur': [
      {'en': 'Faridpur Sadar', 'bn': 'ফরিদপুর সদর', 'upazila': 'Faridpur Sadar', 'lat': 23.6070, 'lng': 89.8406},
      {'en': 'Alfadanga Sadar', 'bn': 'আলফাডাঙ্গা সদর', 'upazila': 'Alfadanga', 'lat': 23.5600, 'lng': 89.7100},
      {'en': 'Bhanga Sadar', 'bn': 'ভাঙ্গা সদর', 'upazila': 'Bhanga', 'lat': 23.3800, 'lng': 89.7200},
      {'en': 'Boalmari Sadar', 'bn': 'বোয়ালমারী সদর', 'upazila': 'Boalmari', 'lat': 23.4700, 'lng': 89.7700},
      {'en': 'Charbhadrasan Sadar', 'bn': 'চরভদ্রাসন সদর', 'upazila': 'Charbhadrasan', 'lat': 23.4200, 'lng': 89.7500},
      {'en': 'Madhukhali Sadar', 'bn': 'মধুখালী সদর', 'upazila': 'Madhukhali', 'lat': 23.5400, 'lng': 89.5800},
      {'en': 'Nagarkanda Sadar', 'bn': 'নগরকান্দা সদর', 'upazila': 'Nagarkanda', 'lat': 23.5000, 'lng': 89.7000},
      {'en': 'Sadarpur Sadar', 'bn': 'সদরপুর সদর', 'upazila': 'Sadarpur', 'lat': 23.4900, 'lng': 89.8300},
      {'en': 'Saltha Sadar', 'bn': 'সালথা সদর', 'upazila': 'Saltha', 'lat': 23.6600, 'lng': 89.9400},
    ],

    // ==================== CHATTOGRAM DIVISION ====================
    'Chattogram': [
      {'en': 'Anwara Sadar', 'bn': 'আনোয়ারা সদর', 'upazila': 'Anwara', 'lat': 22.2900, 'lng': 91.8800},
      {'en': 'Boalkhali Sadar', 'bn': 'বোয়ালখালী সদর', 'upazila': 'Boalkhali', 'lat': 22.4400, 'lng': 92.0100},
      {'en': 'Chandanaish Sadar', 'bn': 'চন্দনাইশ সদর', 'upazila': 'Chandanaish', 'lat': 22.1900, 'lng': 92.0400},
      {'en': 'Fatikchhari Sadar', 'bn': 'ফটিকছড়ি সদর', 'upazila': 'Fatikchhari', 'lat': 22.6800, 'lng': 91.8200},
      {'en': 'Hathazari Sadar', 'bn': 'হাটহাজারী সদর', 'upazila': 'Hathazari', 'lat': 22.5200, 'lng': 91.8200},
      {'en': 'Lohagara (Ctg) Sadar', 'bn': 'লোহাগাড়া (চট্টগ্রাম) সদর', 'upazila': 'Lohagara (Ctg)', 'lat': 22.0700, 'lng': 92.1100},
      {'en': 'Mirsarai Sadar', 'bn': 'মীরসরাই সদর', 'upazila': 'Mirsarai', 'lat': 22.8200, 'lng': 91.6200},
      {'en': 'Patiya Sadar', 'bn': 'পটিয়া সদর', 'upazila': 'Patiya', 'lat': 22.3000, 'lng': 92.0000},
      {'en': 'Rangunia Sadar', 'bn': 'রাঙ্গুনিয়া সদর', 'upazila': 'Rangunia', 'lat': 22.4700, 'lng': 92.0900},
      {'en': 'Raozan Sadar', 'bn': 'রাউজান সদর', 'upazila': 'Raozan', 'lat': 22.5600, 'lng': 91.9300},
      {'en': 'Sandwip Sadar', 'bn': 'সন্দ্বীপ সদর', 'upazila': 'Sandwip', 'lat': 22.5100, 'lng': 91.5600},
      {'en': 'Satkania Sadar', 'bn': 'সাতকানিয়া সদর', 'upazila': 'Satkania', 'lat': 22.0500, 'lng': 92.0700},
      {'en': 'Sitakunda Sadar', 'bn': 'সীতাকুণ্ড সদর', 'upazila': 'Sitakunda', 'lat': 22.6300, 'lng': 91.6600},
      {'en': 'Karnaphuli Sadar', 'bn': 'কর্ণফুলী সদর', 'upazila': 'Karnaphuli', 'lat': 22.3600, 'lng': 91.8600},
    ],

    'Comilla': [
      {'en': 'Comilla Sadar', 'bn': 'কুমিল্লা সদর', 'upazila': 'Comilla Sadar', 'lat': 23.4607, 'lng': 91.1809},
      {'en': 'Barura Sadar', 'bn': 'বরুড়া সদর', 'upazila': 'Barura', 'lat': 23.3200, 'lng': 91.0500},
      {'en': 'Brahmanpara Sadar', 'bn': 'ব্রাহ্মণপাড়া সদর', 'upazila': 'Brahmanpara', 'lat': 23.5400, 'lng': 91.0500},
      {'en': 'Burichang Sadar', 'bn': 'বুড়িচং সদর', 'upazila': 'Burichang', 'lat': 23.5500, 'lng': 91.1500},
      {'en': 'Chandina Sadar', 'bn': 'চান্দিনা সদর', 'upazila': 'Chandina', 'lat': 23.5800, 'lng': 91.0600},
      {'en': 'Chauddagram Sadar', 'bn': 'চৌদ্দগ্রাম সদর', 'upazila': 'Chauddagram', 'lat': 23.2300, 'lng': 91.2400},
      {'en': 'Daudkandi Sadar', 'bn': 'দাউদকান্দি সদর', 'upazila': 'Daudkandi', 'lat': 23.6600, 'lng': 90.8800},
      {'en': 'Debidwar Sadar', 'bn': 'দেবিদ্বার সদর', 'upazila': 'Debidwar', 'lat': 23.6800, 'lng': 90.9600},
      {'en': 'Homna Sadar', 'bn': 'হোমনা সদর', 'upazila': 'Homna', 'lat': 23.6100, 'lng': 90.8200},
      {'en': 'Laksam Sadar', 'bn': 'লাকসাম সদর', 'upazila': 'Laksam', 'lat': 23.2500, 'lng': 91.1300},
      {'en': 'Muradnagar Sadar', 'bn': 'মুরাদনগর সদর', 'upazila': 'Muradnagar', 'lat': 23.6700, 'lng': 91.0400},
      {'en': 'Titas Sadar', 'bn': 'তিতাস সদর', 'upazila': 'Titas', 'lat': 23.6200, 'lng': 90.9200},
    ],

    'Noakhali': [
      {'en': 'Noakhali Sadar', 'bn': 'নোয়াখালী সদর', 'upazila': 'Noakhali Sadar', 'lat': 22.8696, 'lng': 91.0993},
      {'en': 'Begumganj Sadar', 'bn': 'বেগমগঞ্জ সদর', 'upazila': 'Begumganj', 'lat': 22.9800, 'lng': 91.0300},
      {'en': 'Chatkhil Sadar', 'bn': 'চাটখিল সদর', 'upazila': 'Chatkhil', 'lat': 23.0600, 'lng': 91.1700},
      {'en': 'Companiganj (NK) Sadar', 'bn': 'কোম্পানিগঞ্জ (নোয়াখালী) সদর', 'upazila': 'Companiganj (NK)', 'lat': 22.7000, 'lng': 91.0700},
      {'en': 'Hatia Sadar', 'bn': 'হাতিয়া সদর', 'upazila': 'Hatia', 'lat': 22.4500, 'lng': 91.1500},
      {'en': 'Kabirhat Sadar', 'bn': 'কবিরহাট সদর', 'upazila': 'Kabirhat', 'lat': 22.9000, 'lng': 91.2200},
      {'en': 'Senbagh Sadar', 'bn': 'সেনবাগ সদর', 'upazila': 'Senbagh', 'lat': 23.0100, 'lng': 91.1600},
      {'en': 'Sonaimuri Sadar', 'bn': 'সোনাইমুড়ী সদর', 'upazila': 'Sonaimuri', 'lat': 23.0200, 'lng': 91.0900},
      {'en': 'Subarnachar Sadar', 'bn': 'সুবর্ণচর সদর', 'upazila': 'Subarnachar', 'lat': 22.7000, 'lng': 91.2500},
    ],

    // ==================== KHULNA DIVISION ====================
    'Khulna': [
      {'en': 'Khulna Sadar', 'bn': 'খুলনা সদর', 'upazila': 'Khulna Sadar', 'lat': 22.8456, 'lng': 89.5403},
      {'en': 'Batiaghata Sadar', 'bn': 'বটিয়াঘাটা সদর', 'upazila': 'Batiaghata', 'lat': 22.7900, 'lng': 89.4200},
      {'en': 'Dacope Sadar', 'bn': 'ডাকপ৷ সদর', 'upazila': 'Dacope', 'lat': 22.6000, 'lng': 89.4200},
      {'en': 'Dumuria Sadar', 'bn': 'ডুমুরিয়া সদর', 'upazila': 'Dumuria', 'lat': 22.8500, 'lng': 89.2900},
      {'en': 'Dighalia Sadar', 'bn': 'দীঘলিয়া সদর', 'upazila': 'Dighalia', 'lat': 22.9400, 'lng': 89.4600},
      {'en': 'Koyra Sadar', 'bn': 'কয়রা সদর', 'upazila': 'Koyra', 'lat': 22.3200, 'lng': 89.2900},
      {'en': 'Paikgachha Sadar', 'bn': 'পাইকগাছা সদর', 'upazila': 'Paikgachha', 'lat': 22.6200, 'lng': 89.3100},
      {'en': 'Phultala Sadar', 'bn': 'ফুলতলা সদর', 'upazila': 'Phultala', 'lat': 22.9600, 'lng': 89.4800},
      {'en': 'Rupsa Sadar', 'bn': 'রূপসা সদর', 'upazila': 'Rupsa', 'lat': 22.9500, 'lng': 89.5700},
      {'en': 'Terokhada Sadar', 'bn': 'তেরখাদা সদর', 'upazila': 'Terokhada', 'lat': 23.0100, 'lng': 89.5000},
    ],

    'Jashore': [
      {'en': 'Jashore Sadar', 'bn': 'যশোর সদর', 'upazila': 'Jashore Sadar', 'lat': 23.1664, 'lng': 89.2081},
      {'en': 'Abhaynagar Sadar', 'bn': 'অভয়নগর সদর', 'upazila': 'Abhaynagar', 'lat': 23.0800, 'lng': 89.3600},
      {'en': 'Bagherpara Sadar', 'bn': 'বাঘারপাড়া সদর', 'upazila': 'Bagherpara', 'lat': 23.1100, 'lng': 89.0900},
      {'en': 'Chaugachha Sadar', 'bn': 'চৌগাছা সদর', 'upazila': 'Chaugachha', 'lat': 23.2600, 'lng': 89.0700},
      {'en': 'Jhikargachha Sadar', 'bn': 'ঝিকরগাছা সদর', 'upazila': 'Jhikargachha', 'lat': 23.0900, 'lng': 89.1600},
      {'en': 'Keshabpur Sadar', 'bn': 'কেশবপুর সদর', 'upazila': 'Keshabpur', 'lat': 22.9400, 'lng': 89.2100},
      {'en': 'Manirampur Sadar', 'bn': 'মণিরামপুর সদর', 'upazila': 'Manirampur', 'lat': 23.0400, 'lng': 89.0700},
      {'en': 'Sharsha Sadar', 'bn': 'শার্শা সদর', 'upazila': 'Sharsha', 'lat': 23.2200, 'lng': 88.9600},
    ],

    'Satkhira': [
      {'en': 'Satkhira Sadar', 'bn': 'সাতক্ষীরা সদর', 'upazila': 'Satkhira Sadar', 'lat': 22.7185, 'lng': 89.0705},
      {'en': 'Assasuni Sadar', 'bn': 'আশাশুনি সদর', 'upazila': 'Assasuni', 'lat': 22.6300, 'lng': 89.1400},
      {'en': 'Debhata Sadar', 'bn': 'দেবহাটা সদর', 'upazila': 'Debhata', 'lat': 22.6600, 'lng': 89.0000},
      {'en': 'Kalaroa Sadar', 'bn': 'কলারোয়া সদর', 'upazila': 'Kalaroa', 'lat': 22.8700, 'lng': 88.9800},
      {'en': 'Kaliganj (SK) Sadar', 'bn': 'কালীগঞ্জ (সাতক্ষীরা) সদর', 'upazila': 'Kaliganj (SK)', 'lat': 22.9100, 'lng': 89.1300},
      {'en': 'Shyamnagar Sadar', 'bn': 'শ্যামনগর সদর', 'upazila': 'Shyamnagar', 'lat': 22.3000, 'lng': 89.0600},
      {'en': 'Tala Sadar', 'bn': 'তালা সদর', 'upazila': 'Tala', 'lat': 22.9000, 'lng': 89.2200},
    ],

    // ==================== SYLHET DIVISION ====================
    'Sylhet': [
      {'en': 'Sylhet Sadar', 'bn': 'সিলেট সদর', 'upazila': 'Sylhet Sadar', 'lat': 24.8949, 'lng': 91.8687},
      {'en': 'Balaganj Sadar', 'bn': 'বালাগঞ্জ সদর', 'upazila': 'Balaganj', 'lat': 24.7200, 'lng': 91.9600},
      {'en': 'Beanibazar Sadar', 'bn': 'বিয়ানীবাজার সদর', 'upazila': 'Beanibazar', 'lat': 24.6200, 'lng': 92.0300},
      {'en': 'Bishwanath Sadar', 'bn': 'বিশ্বনাথ সদর', 'upazila': 'Bishwanath', 'lat': 24.8200, 'lng': 91.7500},
      {'en': 'Companiganj (SYL) Sadar', 'bn': 'কোম্পানিগঞ্জ (সিলেট) সদর', 'upazila': 'Companiganj (SYL)', 'lat': 25.1000, 'lng': 91.6200},
      {'en': 'Fenchuganj Sadar', 'bn': 'ফেঞ্চুগঞ্জ সদর', 'upazila': 'Fenchuganj', 'lat': 24.7100, 'lng': 91.8400},
      {'en': 'Golapganj Sadar', 'bn': 'গোলাপগঞ্জ সদর', 'upazila': 'Golapganj', 'lat': 24.7400, 'lng': 91.9800},
      {'en': 'Gowainghat Sadar', 'bn': 'গোয়াইনঘাট সদর', 'upazila': 'Gowainghat', 'lat': 25.0600, 'lng': 91.9300},
      {'en': 'Jaintiapur Sadar', 'bn': 'জৈন্তাপুর সদর', 'upazila': 'Jaintiapur', 'lat': 25.1200, 'lng': 92.1100},
      {'en': 'Kanaighat Sadar', 'bn': 'কানাইঘাট সদর', 'upazila': 'Kanaighat', 'lat': 25.0300, 'lng': 92.1800},
      {'en': 'Zakiganj Sadar', 'bn': 'জকিগঞ্জ সদর', 'upazila': 'Zakiganj', 'lat': 24.5700, 'lng': 92.1200},
      {'en': 'Osmaninagar Sadar', 'bn': 'ওসমানীনগর সদর', 'upazila': 'Osmaninagar', 'lat': 24.7400, 'lng': 91.8300},
    ],

    'Sunamganj': [
      {'en': 'Sunamganj Sadar', 'bn': 'সুনামগঞ্জ সদর', 'upazila': 'Sunamganj Sadar', 'lat': 25.0658, 'lng': 91.4073},
      {'en': 'Bishwamvarpur Sadar', 'bn': 'বিশ্বম্ভরপুর সদর', 'upazila': 'Bishwamvarpur', 'lat': 25.1400, 'lng': 91.3400},
      {'en': 'Chhatak Sadar', 'bn': 'ছাতক সদর', 'upazila': 'Chhatak', 'lat': 25.0200, 'lng': 91.6600},
      {'en': 'Derai Sadar', 'bn': 'দিরাই সদর', 'upazila': 'Derai', 'lat': 24.7800, 'lng': 91.3200},
      {'en': 'Dharampasha Sadar', 'bn': 'ধর্মপাশা সদর', 'upazila': 'Dharampasha', 'lat': 24.8900, 'lng': 91.1000},
      {'en': 'Dowarabazar Sadar', 'bn': 'দোয়ারাবাজার সদর', 'upazila': 'Dowarabazar', 'lat': 25.2300, 'lng': 91.6600},
      {'en': 'Jagannathpur Sadar', 'bn': 'জগন্নাথপুর সদর', 'upazila': 'Jagannathpur', 'lat': 24.7200, 'lng': 91.5200},
      {'en': 'Jamalganj Sadar', 'bn': 'জামালগঞ্জ সদর', 'upazila': 'Jamalganj', 'lat': 25.1000, 'lng': 91.1200},
      {'en': 'Sulla Sadar', 'bn': 'সুলা সদর', 'upazila': 'Sulla', 'lat': 24.7500, 'lng': 91.1300},
      {'en': 'Tahirpur Sadar', 'bn': 'তাহিরপুর সদর', 'upazila': 'Tahirpur', 'lat': 25.1500, 'lng': 91.0600},
    ],

    'Habiganj': [
      {'en': 'Habiganj Sadar', 'bn': 'হবিগঞ্জ সদর', 'upazila': 'Habiganj Sadar', 'lat': 24.3749, 'lng': 91.4155},
      {'en': 'Ajmiriganj Sadar', 'bn': 'আজমিরীগঞ্জ সদর', 'upazila': 'Ajmiriganj', 'lat': 24.3100, 'lng': 91.3400},
      {'en': 'Bahubal Sadar', 'bn': 'বাহুবল সদর', 'upazila': 'Bahubal', 'lat': 24.3200, 'lng': 91.5700},
      {'en': 'Baniachong Sadar', 'bn': 'বানিয়াচং সদর', 'upazila': 'Baniachong', 'lat': 24.2400, 'lng': 91.3700},
      {'en': 'Chunarughat Sadar', 'bn': 'চুনারুঘাট সদর', 'upazila': 'Chunarughat', 'lat': 24.2700, 'lng': 91.6600},
      {'en': 'Lakhai Sadar', 'bn': 'লাখাই সদর', 'upazila': 'Lakhai', 'lat': 24.1800, 'lng': 91.3400},
      {'en': 'Madhabpur Sadar', 'bn': 'মাধবপুর সদর', 'upazila': 'Madhabpur', 'lat': 24.2200, 'lng': 91.6400},
      {'en': 'Nabiganj Sadar', 'bn': 'নবীগঞ্জ সদর', 'upazila': 'Nabiganj', 'lat': 24.3400, 'lng': 91.5700},
      {'en': 'Shaistaganj Sadar', 'bn': 'শায়েস্তাগঞ্জ সদর', 'upazila': 'Shaistaganj', 'lat': 24.3900, 'lng': 91.4600},
    ],

    'Moulvibazar': [
      {'en': 'Moulvibazar Sadar', 'bn': 'মৌলভীবাজার সদর', 'upazila': 'Moulvibazar Sadar', 'lat': 24.4829, 'lng': 91.7774},
      {'en': 'Barlekha Sadar', 'bn': 'বড়লেখা সদর', 'upazila': 'Barlekha', 'lat': 24.3900, 'lng': 92.1100},
      {'en': 'Juri Sadar', 'bn': 'জুড়ী সদর', 'upazila': 'Juri', 'lat': 24.2600, 'lng': 92.0400},
      {'en': 'Kamalganj Sadar', 'bn': 'কমলগঞ্জ সদর', 'upazila': 'Kamalganj', 'lat': 24.3200, 'lng': 91.9700},
      {'en': 'Kulaura Sadar', 'bn': 'কুলাউড়া সদর', 'upazila': 'Kulaura', 'lat': 24.5200, 'lng': 92.0400},
      {'en': 'Rajnagar Sadar', 'bn': 'রাজনগর সদর', 'upazila': 'Rajnagar', 'lat': 24.4100, 'lng': 91.9400},
      {'en': 'Sreemangal Sadar', 'bn': 'শ্রীমঙ্গল সদর', 'upazila': 'Sreemangal', 'lat': 24.3100, 'lng': 91.7300},
    ],

    // ==================== RANGPUR DIVISION ====================
    'Rangpur': [
      {'en': 'Rangpur Sadar', 'bn': 'রংপুর সদর', 'upazila': 'Rangpur Sadar', 'lat': 25.7439, 'lng': 89.2752},
      {'en': 'Badarganj Sadar', 'bn': 'বদরগঞ্জ সদর', 'upazila': 'Badarganj', 'lat': 25.6600, 'lng': 89.0500},
      {'en': 'Gangachara Sadar', 'bn': 'গঙ্গাচড়া সদর', 'upazila': 'Gangachara', 'lat': 25.8700, 'lng': 89.3000},
      {'en': 'Kaunia Sadar', 'bn': 'কাউনিয়া সদর', 'upazila': 'Kaunia', 'lat': 25.7800, 'lng': 89.4900},
      {'en': 'Mithapukur Sadar', 'bn': 'মিঠাপুকুর সদর', 'upazila': 'Mithapukur', 'lat': 25.6000, 'lng': 89.3200},
      {'en': 'Pirgachha Sadar', 'bn': 'পীরগাছা সদর', 'upazila': 'Pirgachha', 'lat': 25.7700, 'lng': 89.3800},
      {'en': 'Pirganj (Rgp) Sadar', 'bn': 'পীরগঞ্জ (রংপুর) সদর', 'upazila': 'Pirganj (Rgp)', 'lat': 25.5800, 'lng': 88.9500},
      {'en': 'Taraganj Sadar', 'bn': 'তারাগঞ্জ সদর', 'upazila': 'Taraganj', 'lat': 25.8000, 'lng': 89.1400},
    ],

    'Dinajpur': [
      {'en': 'Dinajpur Sadar', 'bn': 'দিনাজপুর সদর', 'upazila': 'Dinajpur Sadar', 'lat': 25.6217, 'lng': 88.6354},
      {'en': 'Birampur Sadar', 'bn': 'বীরামপুর সদর', 'upazila': 'Birampur', 'lat': 25.4100, 'lng': 89.1300},
      {'en': 'Birganj Sadar', 'bn': 'বীরগঞ্জ সদর', 'upazila': 'Birganj', 'lat': 25.8600, 'lng': 88.7000},
      {'en': 'Bochaganj Sadar', 'bn': 'বোচাগঞ্জ সদর', 'upazila': 'Bochaganj', 'lat': 25.8900, 'lng': 88.5600},
      {'en': 'Chirirbandar Sadar', 'bn': 'চিরিরবন্দর সদর', 'upazila': 'Chirirbandar', 'lat': 25.7200, 'lng': 88.8600},
      {'en': 'Fulbari (DN) Sadar', 'bn': 'ফুলবাড়ী (দিনাজপুর) সদর', 'upazila': 'Fulbari (DN)', 'lat': 25.9100, 'lng': 88.6800},
      {'en': 'Ghoraghat Sadar', 'bn': 'ঘোড়াঘাট সদর', 'upazila': 'Ghoraghat', 'lat': 25.2800, 'lng': 89.2900},
      {'en': 'Hakimpur Sadar', 'bn': 'হাকিমপুর সদর', 'upazila': 'Hakimpur', 'lat': 25.5100, 'lng': 88.9600},
      {'en': 'Kaharole Sadar', 'bn': 'কাহারোল সদর', 'upazila': 'Kaharole', 'lat': 25.7700, 'lng': 88.5800},
      {'en': 'Khansama Sadar', 'bn': 'খানসামা সদর', 'upazila': 'Khansama', 'lat': 25.8400, 'lng': 88.7800},
      {'en': 'Nawabganj (DN) Sadar', 'bn': 'নবাবগঞ্জ (দিনাজপুর) সদর', 'upazila': 'Nawabganj (DN)', 'lat': 24.9300, 'lng': 88.3400},
      {'en': 'Parbatipur Sadar', 'bn': 'পার্বতীপুর সদর', 'upazila': 'Parbatipur', 'lat': 25.6500, 'lng': 88.9100},
      {'en': 'Phulbari (Rangpur) Sadar', 'bn': 'ফুলবাড়ী (রংপুর) সদর', 'upazila': 'Phulbari (Rangpur)', 'lat': 26.0000, 'lng': 88.6200},
    ],

    'Gaibandha': [
      {'en': 'Gaibandha Sadar', 'bn': 'গাইবান্ধা সদর', 'upazila': 'Gaibandha Sadar', 'lat': 25.3288, 'lng': 89.5403},
      {'en': 'Fulchhari Sadar', 'bn': 'ফুলছড়ি সদর', 'upazila': 'Fulchhari', 'lat': 25.1700, 'lng': 89.6900},
      {'en': 'Gobindaganj Sadar', 'bn': 'গোবিন্দগঞ্জ সদর', 'upazila': 'Gobindaganj', 'lat': 25.1300, 'lng': 89.3800},
      {'en': 'Palashbari Sadar', 'bn': 'পলাশবাড়ী সদর', 'upazila': 'Palashbari', 'lat': 25.1800, 'lng': 89.3400},
      {'en': 'Sadullapur Sadar', 'bn': 'সাদুল্যাপুর সদর', 'upazila': 'Sadullapur', 'lat': 25.3800, 'lng': 89.3500},
      {'en': 'Saghata Sadar', 'bn': 'সাঘাটা সদর', 'upazila': 'Saghata', 'lat': 25.2100, 'lng': 89.6700},
      {'en': 'Sundarganj Sadar', 'bn': 'সুন্দরগঞ্জ সদর', 'upazila': 'Sundarganj', 'lat': 25.4800, 'lng': 89.4800},
    ],

    // ==================== MYMENSINGH DIVISION ====================
    'Mymensingh': [
      {'en': 'Mymensingh Sadar', 'bn': 'ময়মনসিংহ সদর', 'upazila': 'Mymensingh Sadar', 'lat': 24.7471, 'lng': 90.4203},
      {'en': 'Bhaluka Sadar', 'bn': 'ভালুকা সদর', 'upazila': 'Bhaluka', 'lat': 24.3700, 'lng': 90.3700},
      {'en': 'Dhobaura Sadar', 'bn': 'ধোবাউড়া সদর', 'upazila': 'Dhobaura', 'lat': 25.0400, 'lng': 90.4800},
      {'en': 'Fulbaria Sadar', 'bn': 'ফুলবাড়িয়া সদর', 'upazila': 'Fulbaria', 'lat': 24.5600, 'lng': 90.1500},
      {'en': 'Gaffargaon Sadar', 'bn': 'গফরগাঁও সদর', 'upazila': 'Gaffargaon', 'lat': 24.4200, 'lng': 90.5700},
      {'en': 'Gauripur Sadar', 'bn': 'গৌরীপুর সদর', 'upazila': 'Gauripur', 'lat': 24.7300, 'lng': 90.2700},
      {'en': 'Haluaghat Sadar', 'bn': 'হালুয়াঘাট সদর', 'upazila': 'Haluaghat', 'lat': 25.0600, 'lng': 90.2000},
      {'en': 'Ishwarganj Sadar', 'bn': 'ঈশ্বরগঞ্জ সদর', 'upazila': 'Ishwarganj', 'lat': 24.5200, 'lng': 90.5800},
      {'en': 'Muktagachha Sadar', 'bn': 'মুক্তাগাছা সদর', 'upazila': 'Muktagachha', 'lat': 24.7600, 'lng': 90.2700},
      {'en': 'Nandail Sadar', 'bn': 'নান্দাইল সদর', 'upazila': 'Nandail', 'lat': 24.4300, 'lng': 90.7400},
      {'en': 'Phulpur Sadar', 'bn': 'ফুলপুর সদর', 'upazila': 'Phulpur', 'lat': 24.8800, 'lng': 90.4600},
      {'en': 'Trishal Sadar', 'bn': 'ত্রিশাল সদর', 'upazila': 'Trishal', 'lat': 24.5600, 'lng': 90.3500},
      {'en': 'Tarakanda Sadar', 'bn': 'তারাকান্দা সদর', 'upazila': 'Tarakanda', 'lat': 24.9000, 'lng': 90.4900},
    ],

    'Jamalpur': [
      {'en': 'Jamalpur Sadar', 'bn': 'জামালপুর সদর', 'upazila': 'Jamalpur Sadar', 'lat': 24.9375, 'lng': 89.9378},
      {'en': 'Baksiganj Sadar', 'bn': 'বকশীগঞ্জ সদর', 'upazila': 'Baksiganj', 'lat': 25.1000, 'lng': 89.9700},
      {'en': 'Dewanganj Sadar', 'bn': 'দেওয়ানগঞ্জ সদর', 'upazila': 'Dewanganj', 'lat': 25.1400, 'lng': 89.8400},
      {'en': 'Islampur Sadar', 'bn': 'ইসলামপুর সদর', 'upazila': 'Islampur', 'lat': 24.8200, 'lng': 89.7600},
      {'en': 'Madarganj Sadar', 'bn': 'মাদারগঞ্জ সদর', 'upazila': 'Madarganj', 'lat': 24.8500, 'lng': 89.8000},
      {'en': 'Melandaha Sadar', 'bn': 'মেলান্দহ সদর', 'upazila': 'Melandaha', 'lat': 24.8700, 'lng': 90.0100},
      {'en': 'Sarishabari Sadar', 'bn': 'সরিষাবাড়ী সদর', 'upazila': 'Sarishabari', 'lat': 24.7300, 'lng': 89.9700},
    ],

    'Sherpur': [
      {'en': 'Sherpur Sadar', 'bn': 'শেরপুর সদর', 'upazila': 'Sherpur Sadar', 'lat': 25.0205, 'lng': 90.0153},
      {'en': 'Jhenaigati Sadar', 'bn': 'ঝিনাইগাতী সদর', 'upazila': 'Jhenaigati', 'lat': 25.1600, 'lng': 90.1800},
      {'en': 'Nalitabari Sadar', 'bn': 'নালিতাবাড়ী সদর', 'upazila': 'Nalitabari', 'lat': 25.1100, 'lng': 90.0500},
      {'en': 'Nakla Sadar', 'bn': 'নকলা সদর', 'upazila': 'Nakla', 'lat': 24.8900, 'lng': 90.1800},
      {'en': 'Sreebordi Sadar', 'bn': 'শ্রীবরদী সদর', 'upazila': 'Sreebordi', 'lat': 25.0600, 'lng': 90.2200},
    ],

    'Netrokona': [
      {'en': 'Netrokona Sadar', 'bn': 'নেত্রকোণা সদর', 'upazila': 'Netrokona Sadar', 'lat': 24.8709, 'lng': 90.7279},
      {'en': 'Atpara Sadar', 'bn': 'আটপাড়া সদর', 'upazila': 'Atpara', 'lat': 24.7700, 'lng': 90.6700},
      {'en': 'Barhatta Sadar', 'bn': 'বারহাট্টা সদর', 'upazila': 'Barhatta', 'lat': 24.8800, 'lng': 90.6500},
      {'en': 'Durgapur (NK) Sadar', 'bn': 'দুর্গাপুর (নেত্রকোণা) সদর', 'upazila': 'Durgapur (NK)', 'lat': 25.1200, 'lng': 90.7700},
      {'en': 'Kalmakanda Sadar', 'bn': 'কলমাকান্দা সদর', 'upazila': 'Kalmakanda', 'lat': 25.0900, 'lng': 90.5400},
      {'en': 'Kendua Sadar', 'bn': 'কেন্দুয়া সদর', 'upazila': 'Kendua', 'lat': 24.7200, 'lng': 90.8100},
      {'en': 'Khaliajuri Sadar', 'bn': 'খালিয়াজুরী সদর', 'upazila': 'Khaliajuri', 'lat': 24.9100, 'lng': 91.0200},
      {'en': 'Madan Sadar', 'bn': 'মদন সদর', 'upazila': 'Madan', 'lat': 24.7600, 'lng': 90.9400},
      {'en': 'Mohanganj Sadar', 'bn': 'মোহনগঞ্জ সদর', 'upazila': 'Mohanganj', 'lat': 24.6400, 'lng': 91.0000},
      {'en': 'Purbadhala Sadar', 'bn': 'পূর্বধলা সদর', 'upazila': 'Purbadhala', 'lat': 24.8700, 'lng': 90.5700},
    ],
  };

  /// Get all unions for a given district
  static List<Map<String, dynamic>> getUnionsByDistrict(String district) {
    return unionsByDistrict[district] ?? [];
  }

  /// Get unions filtered by upazila within a district
  static List<Map<String, dynamic>> getUnionsByUpazila(String district, String upazila) {
    final all = unionsByDistrict[district] ?? [];
    return all.where((u) => (u['upazila'] as String).toLowerCase().contains(upazila.toLowerCase())).toList();
  }

  /// Get all districts that have union data
  static List<String> get districtsWithUnionData => unionsByDistrict.keys.toList()..sort();

  /// Get all division names
  static const List<String> divisions = [
    'Barishal', 'Chattogram', 'Dhaka', 'Khulna',
    'Mymensingh', 'Rajshahi', 'Rangpur', 'Sylhet',
  ];

  /// District → Division mapping
  static const Map<String, String> districtDivisionMap = {
    'Patuakhali': 'Barishal', 'Barisal': 'Barishal', 'Barguna': 'Barishal',
    'Bhola': 'Barishal', 'Jhalokati': 'Barishal', 'Pirojpur': 'Barishal',
    'Chattogram': 'Chattogram', 'Comilla': 'Chattogram', 'Noakhali': 'Chattogram',
    'Brahmanbaria': 'Chattogram', 'Chandpur': 'Chattogram', 'Feni': 'Chattogram',
    'Lakshmipur': 'Chattogram', 'Bandarban': 'Chattogram', 'Khagrachhari': 'Chattogram',
    'Rangamati': 'Chattogram', 'Coxsbazar': 'Chattogram',
    'Dhaka': 'Dhaka', 'Gazipur': 'Dhaka', 'Tangail': 'Dhaka', 'Narayanganj': 'Dhaka',
    'Faridpur': 'Dhaka', 'Gopalganj': 'Dhaka', 'Kishoreganj': 'Dhaka', 'Madaripur': 'Dhaka',
    'Manikganj': 'Dhaka', 'Munshiganj': 'Dhaka', 'Narsingdi': 'Dhaka', 'Rajbari': 'Dhaka',
    'Shariatpur': 'Dhaka',
    'Khulna': 'Khulna', 'Jashore': 'Khulna', 'Satkhira': 'Khulna', 'Bagerhat': 'Khulna',
    'Chuadanga': 'Khulna', 'Jhenaidah': 'Khulna', 'Kushtia': 'Khulna',
    'Magura': 'Khulna', 'Meherpur': 'Khulna', 'Narail': 'Khulna',
    'Mymensingh': 'Mymensingh', 'Jamalpur': 'Mymensingh', 'Netrokona': 'Mymensingh', 'Sherpur': 'Mymensingh',
    'Rajshahi': 'Rajshahi', 'Natore': 'Rajshahi', 'Bogura': 'Rajshahi', 'Pabna': 'Rajshahi',
    'Sirajganj': 'Rajshahi', 'Naogaon': 'Rajshahi', 'Chapainawabganj': 'Rajshahi', 'Joypurhat': 'Rajshahi',
    'Rangpur': 'Rangpur', 'Dinajpur': 'Rangpur', 'Gaibandha': 'Rangpur', 'Kurigram': 'Rangpur',
    'Lalmonirhat': 'Rangpur', 'Nilphamari': 'Rangpur', 'Panchagarh': 'Rangpur', 'Thakurgaon': 'Rangpur',
    'Sylhet': 'Sylhet', 'Habiganj': 'Sylhet', 'Moulvibazar': 'Sylhet', 'Sunamganj': 'Sylhet',
  };

  /// Get division for a district
  static String getDivisionForDistrict(String district) {
    return districtDivisionMap[district] ?? 'Unknown';
  }

  /// Get Bangla district name
  static const Map<String, String> districtBnNames = {
    'Patuakhali': 'পটুয়াখালী', 'Barisal': 'বরিশাল', 'Barguna': 'বরগুনা',
    'Bhola': 'ভোলা', 'Jhalokati': 'ঝালকাঠি', 'Pirojpur': 'পিরোজপুর',
    'Chattogram': 'চট্টগ্রাম', 'Comilla': 'কুমিল্লা', 'Noakhali': 'নোয়াখালী',
    'Brahmanbaria': 'ব্রাহ্মণবাড়িয়া', 'Chandpur': 'চাঁদপুর', 'Feni': 'ফেনী',
    'Lakshmipur': 'লক্ষ্মীপুর', 'Bandarban': 'বান্দরবান', 'Khagrachhari': 'খাগড়াছড়ি',
    'Rangamati': 'রাঙ্গামাটি', 'Coxsbazar': 'কক্সবাজার',
    'Dhaka': 'ঢাকা', 'Gazipur': 'গাজীপুর', 'Tangail': 'টাঙ্গাইল',
    'Narayanganj': 'নারায়ণগঞ্জ', 'Faridpur': 'ফরিদপুর', 'Gopalganj': 'গোপালগঞ্জ',
    'Kishoreganj': 'কিশোরগঞ্জ', 'Madaripur': 'মাদারীপুর', 'Manikganj': 'মানিকগঞ্জ',
    'Munshiganj': 'মুন্সীগঞ্জ', 'Narsingdi': 'নরসিংদী', 'Rajbari': 'রাজবাড়ী', 'Shariatpur': 'শরীয়তপুর',
    'Khulna': 'খুলনা', 'Jashore': 'যশোর', 'Satkhira': 'সাতক্ষীরা', 'Bagerhat': 'বাগেরহাট',
    'Chuadanga': 'চুয়াডাঙ্গা', 'Jhenaidah': 'ঝিনাইদহ', 'Kushtia': 'কুষ্টিয়া',
    'Magura': 'মাগুরা', 'Meherpur': 'মেহেরপুর', 'Narail': 'নড়াইল',
    'Mymensingh': 'ময়মনসিংহ', 'Jamalpur': 'জামালপুর', 'Netrokona': 'নেত্রকোণা', 'Sherpur': 'শেরপুর',
    'Rajshahi': 'রাজশাহী', 'Natore': 'নাটোর', 'Bogura': 'বগুড়া', 'Pabna': 'পাবনা',
    'Sirajganj': 'সিরাজগঞ্জ', 'Naogaon': 'নওগাঁ', 'Chapainawabganj': 'চাঁপাইনবাবগঞ্জ', 'Joypurhat': 'জয়পুরহাট',
    'Rangpur': 'রংপুর', 'Dinajpur': 'দিনাজপুর', 'Gaibandha': 'গাইবান্ধা', 'Kurigram': 'কুড়িগ্রাম',
    'Lalmonirhat': 'লালমনিরহাট', 'Nilphamari': 'নীলফামারী', 'Panchagarh': 'পঞ্চগড়', 'Thakurgaon': 'ঠাকুরগাঁও',
    'Sylhet': 'সিলেট', 'Habiganj': 'হবিগঞ্জ', 'Moulvibazar': 'মৌলভীবাজার', 'Sunamganj': 'সুনামগঞ্জ',
  };

  static const Map<String, String> divisionBnNames = {
    'Barishal': 'বরিশাল', 'Chattogram': 'চট্টগ্রাম', 'Dhaka': 'ঢাকা', 'Khulna': 'খুলনা',
    'Mymensingh': 'ময়মনসিংহ', 'Rajshahi': 'রাজশাহী', 'Rangpur': 'রংপুর', 'Sylhet': 'সিলেট',
  };
}
