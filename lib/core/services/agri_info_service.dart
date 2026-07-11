import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agrolinkbd/core/data/bangladesh_agri_data.dart';
import 'package:agrolinkbd/core/models/agri_info_model.dart';
import 'package:agrolinkbd/core/services/location_service.dart';

class AgriInfoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocationService _locationService = LocationService();

  /// GPS coordinates → nearest upazila data
  Future<UpazilaCropData?> getDataByGPS() async {
    final position = await _locationService.getCurrentPosition();
    if (position == null) return null;
    return BangladeshAgriData.findNearest(position.latitude, position.longitude);
  }

  /// Division + Zilla + Upazila → data
  UpazilaCropData? getDataBySelection({
    required String division,
    required String zilla,
    required String upazila,
  }) {
    return BangladeshAgriData.findByLocation(division, zilla, upazila);
  }

  /// Search by crop or location name
  List<UpazilaCropData> search(String query) {
    return BangladeshAgriData.searchByName(query);
  }

  /// Save to Firestore for this user
  Future<void> saveData(SavedAgriData data) async {
    await _firestore
        .collection('saved_agri_data')
        .doc(data.id)
        .set(data.toJson());
  }

  /// Load saved data from Firestore
  Future<List<SavedAgriData>> getSavedData(String userId) async {
    final snap = await _firestore
        .collection('saved_agri_data')
        .where('userId', isEqualTo: userId)
        .orderBy('savedAt', descending: true)
        .limit(20)
        .get();
    return snap.docs
        .map((d) => SavedAgriData.fromJson(d.data()))
        .toList();
  }

  /// Delete saved entry
  Future<void> deleteData(String id) async {
    await _firestore.collection('saved_agri_data').doc(id).delete();
  }

  /// All divisions
  List<String> getDivisions() => BangladeshAgriData.divisions;

  /// Zillahs for a division
  List<String> getZillas(String division) =>
      BangladeshAgriData.zillasPerDivision[division] ?? [];

  /// Upazilas for a zilla
  List<String> getUpazilas(String zilla) =>
      BangladeshAgriData.upazilasPerZilla[zilla] ?? [];
}
