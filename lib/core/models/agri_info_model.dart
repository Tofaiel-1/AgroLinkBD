// Bangladesh Agriculture Information Models
// Based on BARC (Bangladesh Agricultural Research Council) data structure

class UpazilaCropData {
  final String division;
  final String zilla;
  final String upazila;
  final double latitude;
  final double longitude;
  final String cropZone;
  final String cropZoneBn;
  final SoilProfile soilProfile;
  final List<CropSuitability> suitableCrops;
  final List<CropPattern> cropPatterns;
  final List<FertilizerDose> fertilizerDoses;

  const UpazilaCropData({
    required this.division,
    required this.zilla,
    required this.upazila,
    required this.latitude,
    required this.longitude,
    required this.cropZone,
    required this.cropZoneBn,
    required this.soilProfile,
    required this.suitableCrops,
    required this.cropPatterns,
    required this.fertilizerDoses,
  });
}

class SoilProfile {
  final String type;       // loam, clay, sandy, silt
  final String typeBn;
  final double phMin;
  final double phMax;
  final String organicMatter; // low, medium, high
  final String drainage;   // poor, moderate, good
  final String description;

  const SoilProfile({
    required this.type,
    required this.typeBn,
    required this.phMin,
    required this.phMax,
    required this.organicMatter,
    required this.drainage,
    required this.description,
  });
}

class CropSuitability {
  final String cropName;
  final String season;    // rabi, kharif1, kharif2
  final String seasonBn;
  final String suitability; // high, medium, low
  final String variety;
  final double yieldTonPerHa;

  const CropSuitability({
    required this.cropName,
    required this.season,
    required this.seasonBn,
    required this.suitability,
    required this.variety,
    required this.yieldTonPerHa,
  });
}

class CropPattern {
  final String robi;      // রবি ফসল
  final String kharif1;   // খরিফ-১ ফসল
  final String kharif2;   // খরিফ-২ ফসল
  final int profitIndex;  // লাভ সূচক (টাকা প্রতি শতাংশ)
  final double bcRatioVig; // আয়-ব্যয় অনুপাত (ভি.সি.)
  final double bcRatioTig; // আয়-ব্যয় অনুপাত (টি.সি.)
  final bool isCurrent;   // বর্তমান বিন্যাস কিনা

  const CropPattern({
    required this.robi,
    required this.kharif1,
    required this.kharif2,
    required this.profitIndex,
    required this.bcRatioVig,
    required this.bcRatioTig,
    this.isCurrent = false,
  });
}

class FertilizerDose {
  final String cropName;
  final String cropNameBn;
  final String urea;      // kg/হেক্টর
  final String tsp;
  final String mop;
  final String gypsum;
  final String zinc;
  final String remarks;

  const FertilizerDose({
    required this.cropName,
    required this.cropNameBn,
    required this.urea,
    required this.tsp,
    required this.mop,
    this.gypsum = '-',
    this.zinc = '-',
    this.remarks = '',
  });
}

// Saved data model for Firestore
class SavedAgriData {
  final String id;
  final String userId;
  final String division;
  final String zilla;
  final String upazila;
  final DateTime savedAt;
  final String? note;

  const SavedAgriData({
    required this.id,
    required this.userId,
    required this.division,
    required this.zilla,
    required this.upazila,
    required this.savedAt,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'division': division,
    'zilla': zilla,
    'upazila': upazila,
    'savedAt': savedAt.toIso8601String(),
    'note': note,
  };

  factory SavedAgriData.fromJson(Map<String, dynamic> json) => SavedAgriData(
    id: json['id'],
    userId: json['userId'],
    division: json['division'],
    zilla: json['zilla'],
    upazila: json['upazila'],
    savedAt: DateTime.parse(json['savedAt']),
    note: json['note'],
  );
}
