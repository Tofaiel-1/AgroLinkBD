import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItemModel {
  final String productId;
  final String productName;
  final String productNamebn;
  final double pricePerUnit;
  final int quantity;
  final String unit;
  final double totalPrice;
  final List<String> images;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.productNamebn,
    required this.pricePerUnit,
    required this.quantity,
    required this.unit,
    required this.totalPrice,
    required this.images,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productNamebn': productNamebn,
      'pricePerUnit': pricePerUnit,
      'quantity': quantity,
      'unit': unit,
      'totalPrice': totalPrice,
      'images': images,
    };
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: map['productId'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      productNamebn: map['productNamebn'] as String? ?? '',
      pricePerUnit: (map['pricePerUnit'] as num?)?.toDouble() ?? 0,
      quantity: map['quantity'] as int? ?? 1,
      unit: map['unit'] as String? ?? 'kg',
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0,
      images: List<String>.from(map['images'] as List? ?? []),
    );
  }
}

class BuyerOrderModel {
  final String id;
  final String buyerId;
  final String buyerName;
  final String buyerPhone;
  final String farmerId;
  final String farmerName;
  final String? driverId;
  final String? driverName;
  final String? driverPhone;
  final List<OrderItemModel> items;
  final double subtotal;
  final double deliveryFee;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final String
      orderStatus; // pending, confirmed, packed, shipped, delivered, cancelled
  final String paymentMethod;
  final bool paymentReceived;
  final String deliveryAddressId;
  final String deliveryAddress;
  final String? deliveryPhoneNumber;
  final String? specialInstructions;
  final DateTime? estimatedDeliveryDate;
  final DateTime? actualDeliveryDate;
  final DateTime? pickedUpDate;
  final DateTime? shippedDate;
  final String? deliveryProofImage;
  final bool isReturned;
  final DateTime createdAt;
  final DateTime updatedAt;

  BuyerOrderModel({
    required this.id,
    required this.buyerId,
    required this.buyerName,
    required this.buyerPhone,
    required this.farmerId,
    required this.farmerName,
    this.driverId,
    this.driverName,
    this.driverPhone,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.orderStatus,
    required this.paymentMethod,
    required this.paymentReceived,
    required this.deliveryAddressId,
    required this.deliveryAddress,
    this.deliveryPhoneNumber,
    this.specialInstructions,
    this.estimatedDeliveryDate,
    this.actualDeliveryDate,
    this.pickedUpDate,
    this.shippedDate,
    this.deliveryProofImage,
    this.isReturned = false,
    required this.createdAt,
    required this.updatedAt,
  });

  String getStatusBN() {
    switch (orderStatus) {
      case 'pending':
        return 'পেন্ডিং';
      case 'confirmed':
        return 'নিশ্চিত';
      case 'packed':
        return 'প্যাক করা';
      case 'shipped':
        return 'পাঠানো হয়েছে';
      case 'delivered':
        return 'ডেলিভার করা হয়েছে';
      case 'cancelled':
        return 'বাতিল করা হয়েছে';
      default:
        return orderStatus;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'buyerPhone': buyerPhone,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'driverId': driverId,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'orderStatus': orderStatus,
      'paymentMethod': paymentMethod,
      'paymentReceived': paymentReceived,
      'deliveryAddressId': deliveryAddressId,
      'deliveryAddress': deliveryAddress,
      'deliveryPhoneNumber': deliveryPhoneNumber,
      'specialInstructions': specialInstructions,
      'estimatedDeliveryDate': estimatedDeliveryDate,
      'actualDeliveryDate': actualDeliveryDate,
      'pickedUpDate': pickedUpDate,
      'shippedDate': shippedDate,
      'deliveryProofImage': deliveryProofImage,
      'isReturned': isReturned,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory BuyerOrderModel.fromMap(Map<String, dynamic> map) {
    return BuyerOrderModel(
      id: map['id'] as String? ?? '',
      buyerId: map['buyerId'] as String? ?? '',
      buyerName: map['buyerName'] as String? ?? '',
      buyerPhone: map['buyerPhone'] as String? ?? '',
      farmerId: map['farmerId'] as String? ?? '',
      farmerName: map['farmerName'] as String? ?? '',
      driverId: map['driverId'] as String?,
      driverName: map['driverName'] as String?,
      driverPhone: map['driverPhone'] as String?,
      items: (map['items'] as List?)
              ?.map((item) =>
                  OrderItemModel.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0,
      deliveryFee: (map['deliveryFee'] as num?)?.toDouble() ?? 0,
      taxAmount: (map['taxAmount'] as num?)?.toDouble() ?? 0,
      discountAmount: (map['discountAmount'] as num?)?.toDouble() ?? 0,
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0,
      orderStatus: map['orderStatus'] as String? ?? 'pending',
      paymentMethod: map['paymentMethod'] as String? ?? 'COD',
      paymentReceived: map['paymentReceived'] as bool? ?? false,
      deliveryAddressId: map['deliveryAddressId'] as String? ?? '',
      deliveryAddress: map['deliveryAddress'] as String? ?? '',
      deliveryPhoneNumber: map['deliveryPhoneNumber'] as String?,
      specialInstructions: map['specialInstructions'] as String?,
      estimatedDeliveryDate:
          (map['estimatedDeliveryDate'] as Timestamp?)?.toDate(),
      actualDeliveryDate: (map['actualDeliveryDate'] as Timestamp?)?.toDate(),
      pickedUpDate: (map['pickedUpDate'] as Timestamp?)?.toDate(),
      shippedDate: (map['shippedDate'] as Timestamp?)?.toDate(),
      deliveryProofImage: map['deliveryProofImage'] as String?,
      isReturned: map['isReturned'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
