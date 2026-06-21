enum AuctionStatus { upcoming, active, closed, cancelled }

class AuctionModel {
  final String id;
  final String productId;
  final String sellerId;
  final String productTitle;
  final String description;
  final List<String> images;
  final double basePrice;
  final double? currentBid;
  final String? currentBidderId;
  final String? currentBidderName;
  final DateTime startTime;
  final DateTime endTime;
  final AuctionStatus status;
  final List<BidModel> bids;
  final String unit;
  final double quantity;
  final DateTime createdAt;

  AuctionModel({
    required this.id,
    required this.productId,
    required this.sellerId,
    required this.productTitle,
    required this.description,
    required this.images,
    required this.basePrice,
    this.currentBid,
    this.currentBidderId,
    this.currentBidderName,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.bids = const [],
    required this.unit,
    required this.quantity,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'sellerId': sellerId,
      'productTitle': productTitle,
      'description': description,
      'images': images,
      'basePrice': basePrice,
      'currentBid': currentBid,
      'currentBidderId': currentBidderId,
      'currentBidderName': currentBidderName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status.toString(),
      'bids': bids.map((bid) => bid.toJson()).toList(),
      'unit': unit,
      'quantity': quantity,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AuctionModel.fromJson(Map<String, dynamic> json) {
    return AuctionModel(
      id: json['id'],
      productId: json['productId'],
      sellerId: json['sellerId'],
      productTitle: json['productTitle'],
      description: json['description'],
      images: List<String>.from(json['images']),
      basePrice: json['basePrice'].toDouble(),
      currentBid: json['currentBid']?.toDouble(),
      currentBidderId: json['currentBidderId'],
      currentBidderName: json['currentBidderName'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      status: AuctionStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      bids: json['bids'] != null
          ? (json['bids'] as List).map((bid) => BidModel.fromJson(bid)).toList()
          : [],
      unit: json['unit'],
      quantity: json['quantity'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class BidModel {
  final String id;
  final String bidderId;
  final String bidderName;
  final double amount;
  final DateTime timestamp;

  BidModel({
    required this.id,
    required this.bidderId,
    required this.bidderName,
    required this.amount,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bidderId': bidderId,
      'bidderName': bidderName,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory BidModel.fromJson(Map<String, dynamic> json) {
    return BidModel(
      id: json['id'],
      bidderId: json['bidderId'],
      bidderName: json['bidderName'],
      amount: json['amount'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
