import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/machinery_model.dart';

class MachineryProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<MachineryModel> _machineries = [];
  List<MachineryBookingModel> _myBookings = [];
  bool _isLoading = false;
  String? _error;

  List<MachineryModel> get machineries => _machineries;
  List<MachineryBookingModel> get myBookings => _myBookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all machineries
  Future<void> loadMachineries({MachineryType? type, String? district}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Query query = _firestore
          .collection('machineries')
          .where('isAvailable', isEqualTo: true);

      if (type != null) {
        query = query.where('type', isEqualTo: type.toString());
      }

      if (district != null) {
        query = query.where('district', isEqualTo: district);
      }

      QuerySnapshot snapshot = await query.get();

      _machineries = snapshot.docs
          .map(
            (doc) =>
                MachineryModel.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add machinery
  Future<void> addMachinery(MachineryModel machinery) async {
    try {
      await _firestore
          .collection('machineries')
          .doc(machinery.id)
          .set(machinery.toJson());

      _machineries.insert(0, machinery);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Create booking
  Future<void> createBooking(MachineryBookingModel booking) async {
    try {
      await _firestore
          .collection('machinery_bookings')
          .doc(booking.id)
          .set(booking.toJson());

      _myBookings.insert(0, booking);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Load my bookings
  Future<void> loadMyBookings(String userId, {bool asFarmer = true}) async {
    try {
      String field = asFarmer ? 'farmerId' : 'ownerId';

      QuerySnapshot snapshot = await _firestore
          .collection('machinery_bookings')
          .where(field, isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _myBookings = snapshot.docs
          .map(
            (doc) => MachineryBookingModel.fromJson(
              doc.data() as Map<String, dynamic>,
            ),
          )
          .toList();

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update booking status
  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus status,
  ) async {
    try {
      await _firestore.collection('machinery_bookings').doc(bookingId).update({
        'status': status.toString(),
        if (status == BookingStatus.completed)
          'completedAt': DateTime.now().toIso8601String(),
      });

      int index = _myBookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Get nearby machineries (based on location)
  List<MachineryModel> getNearbyMachineries(
    double latitude,
    double longitude,
    double radiusKm,
  ) {
    return _machineries.where((m) {
      if (m.latitude == null || m.longitude == null) return false;

      // Simple distance calculation (not accurate for large distances)
      double latDiff = (m.latitude! - latitude).abs();
      double lonDiff = (m.longitude! - longitude).abs();
      double distance =
          (latDiff * latDiff + lonDiff * lonDiff) * 111; // Rough km

      return distance <= radiusKm;
    }).toList();
  }
}
