import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transport_model.dart';

class TransportProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<TransportRequestModel> _requests = [];
  List<TransportRequestModel> _myRequests = [];
  bool _isLoading = false;
  String? _error;

  List<TransportRequestModel> get requests => _requests;
  List<TransportRequestModel> get myRequests => _myRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all transport requests (for drivers)
  Future<void> loadRequests({TransportStatus? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Query query = _firestore.collection('transport_requests');

      if (status != null) {
        query = query.where('status', isEqualTo: status.toString());
      } else {
        // Show pending and bidding requests by default
        query = query.where(
          'status',
          whereIn: [
            TransportStatus.pending.toString(),
            TransportStatus.bidding.toString(),
          ],
        );
      }

      QuerySnapshot snapshot = await query
          .orderBy('createdAt', descending: true)
          .get();

      _requests = snapshot.docs
          .map(
            (doc) => TransportRequestModel.fromJson(
              doc.data() as Map<String, dynamic>,
            ),
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

  // Create transport request
  Future<void> createRequest(TransportRequestModel request) async {
    try {
      await _firestore
          .collection('transport_requests')
          .doc(request.id)
          .set(request.toJson());

      _myRequests.insert(0, request);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Load my requests (as farmer)
  Future<void> loadMyRequests(String farmerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('transport_requests')
          .where('farmerId', isEqualTo: farmerId)
          .orderBy('createdAt', descending: true)
          .get();

      _myRequests = snapshot.docs
          .map(
            (doc) => TransportRequestModel.fromJson(
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

  // Place bid on transport request
  Future<void> placeBid({
    required String requestId,
    required TransportBidModel bid,
  }) async {
    try {
      DocumentReference requestRef = _firestore
          .collection('transport_requests')
          .doc(requestId);

      await requestRef.update({
        'bids': FieldValue.arrayUnion([bid.toJson()]),
        'status': TransportStatus.bidding.toString(),
      });

      // Update local state
      int index = _requests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        notifyListeners();
      }

      int myIndex = _myRequests.indexWhere((r) => r.id == requestId);
      if (myIndex != -1) {
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Accept bid
  Future<void> acceptBid({
    required String requestId,
    required String driverId,
    required String driverName,
    required double agreedPrice,
  }) async {
    try {
      await _firestore.collection('transport_requests').doc(requestId).update({
        'status': TransportStatus.accepted.toString(),
        'acceptedDriverId': driverId,
        'acceptedDriverName': driverName,
        'agreedPrice': agreedPrice,
      });

      int index = _myRequests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Update request status
  Future<void> updateRequestStatus(
    String requestId,
    TransportStatus status,
  ) async {
    try {
      Map<String, dynamic> updateData = {'status': status.toString()};

      if (status == TransportStatus.delivered) {
        updateData['completedAt'] = DateTime.now().toIso8601String();
      }

      await _firestore
          .collection('transport_requests')
          .doc(requestId)
          .update(updateData);

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Get my accepted jobs (as driver)
  Future<List<TransportRequestModel>> getMyJobs(String driverId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('transport_requests')
          .where('acceptedDriverId', isEqualTo: driverId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) => TransportRequestModel.fromJson(
              doc.data() as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Get available requests (not yet accepted)
  List<TransportRequestModel> get availableRequests {
    return _requests
        .where(
          (r) =>
              r.status == TransportStatus.pending ||
              r.status == TransportStatus.bidding,
        )
        .toList();
  }
}
