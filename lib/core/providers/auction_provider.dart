import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart' as rtdb;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/auction_model.dart';

class AuctionProvider with ChangeNotifier {
  final rtdb.FirebaseDatabase _realtimeDb = rtdb.FirebaseDatabase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<AuctionModel> _auctions = [];
  AuctionModel? _currentAuction;
  bool _isLoading = false;
  String? _error;

  List<AuctionModel> get auctions => _auctions;
  AuctionModel? get currentAuction => _currentAuction;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all auctions
  Future<void> loadAuctions({AuctionStatus? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      QuerySnapshot snapshot;

      if (status != null) {
        snapshot = await _firestore
            .collection('auctions')
            .where('status', isEqualTo: status.toString())
            .orderBy('startTime', descending: false)
            .get();
      } else {
        snapshot = await _firestore
            .collection('auctions')
            .orderBy('startTime', descending: false)
            .get();
      }

      _auctions = snapshot.docs
          .map(
            (doc) => AuctionModel.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();

      _isLoading = false;
      notifyListeners();

      // Listen to active auctions in realtime
      _listenToActiveAuctions();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create auction
  Future<void> createAuction(AuctionModel auction) async {
    try {
      await _firestore
          .collection('auctions')
          .doc(auction.id)
          .set(auction.toJson());

      // Also store in Realtime Database for live bidding
      await _realtimeDb.ref('auctions/${auction.id}').set(auction.toJson());

      _auctions.insert(0, auction);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Place bid
  Future<void> placeBid({
    required String auctionId,
    required String bidderId,
    required String bidderName,
    required double amount,
  }) async {
    try {
      BidModel bid = BidModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        bidderId: bidderId,
        bidderName: bidderName,
        amount: amount,
        timestamp: DateTime.now(),
      );

      // Update in Realtime Database for immediate reflection
      rtdb.DatabaseReference auctionRef =
          _realtimeDb.ref('auctions/$auctionId');

      await auctionRef.update({
        'currentBid': amount,
        'currentBidderId': bidderId,
        'currentBidderName': bidderName,
      });

      // Add bid to bids list
      await auctionRef.child('bids').push().set(bid.toJson());

      // Also update Firestore
      await _firestore.collection('auctions').doc(auctionId).update({
        'currentBid': amount,
        'currentBidderId': bidderId,
        'currentBidderName': bidderName,
      });

      // Update local state
      int index = _auctions.indexWhere((a) => a.id == auctionId);
      if (index != -1) {
        // Create updated auction
        AuctionModel updated = AuctionModel(
          id: _auctions[index].id,
          productId: _auctions[index].productId,
          sellerId: _auctions[index].sellerId,
          productTitle: _auctions[index].productTitle,
          description: _auctions[index].description,
          images: _auctions[index].images,
          basePrice: _auctions[index].basePrice,
          currentBid: amount,
          currentBidderId: bidderId,
          currentBidderName: bidderName,
          startTime: _auctions[index].startTime,
          endTime: _auctions[index].endTime,
          status: _auctions[index].status,
          bids: [..._auctions[index].bids, bid],
          unit: _auctions[index].unit,
          quantity: _auctions[index].quantity,
          createdAt: _auctions[index].createdAt,
        );
        _auctions[index] = updated;

        if (_currentAuction?.id == auctionId) {
          _currentAuction = updated;
        }

        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Listen to auction updates in realtime
  void listenToAuction(String auctionId) {
    _realtimeDb.ref('auctions/$auctionId').onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map<String, dynamic> data = Map<String, dynamic>.from(
          event.snapshot.value as Map,
        );
        AuctionModel auction = AuctionModel.fromJson(data);

        _currentAuction = auction;

        // Update in list
        int index = _auctions.indexWhere((a) => a.id == auctionId);
        if (index != -1) {
          _auctions[index] = auction;
        }

        notifyListeners();
      }
    });
  }

  // Listen to all active auctions
  void _listenToActiveAuctions() {
    for (var auction in _auctions) {
      if (auction.status == AuctionStatus.active) {
        listenToAuction(auction.id);
      }
    }
  }

  // End auction
  Future<void> endAuction(String auctionId) async {
    try {
      await _firestore.collection('auctions').doc(auctionId).update({
        'status': AuctionStatus.closed.toString(),
      });

      await _realtimeDb.ref('auctions/$auctionId').update({
        'status': AuctionStatus.closed.toString(),
      });

      int index = _auctions.indexWhere((a) => a.id == auctionId);
      if (index != -1) {
        // Update status
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Get active auctions
  List<AuctionModel> get activeAuctions {
    return _auctions.where((a) => a.status == AuctionStatus.active).toList();
  }

  // Get upcoming auctions
  List<AuctionModel> get upcomingAuctions {
    return _auctions.where((a) => a.status == AuctionStatus.upcoming).toList();
  }
}
