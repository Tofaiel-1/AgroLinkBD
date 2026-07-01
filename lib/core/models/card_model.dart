import 'package:cloud_firestore/cloud_firestore.dart';

class CardModel {
  final String uid;
  final Map<String, dynamic> roleSpecificData;
  final String qrData;
  final double averageRating;
  final bool verificationStatus;
  final int cardVersion;
  final double walletBalance;
  final String? walletPin;

  CardModel({
    required this.uid,
    required this.roleSpecificData,
    required this.qrData,
    this.averageRating = 0.0,
    this.verificationStatus = false,
    this.cardVersion = 1,
    this.walletBalance = 0.0,
    this.walletPin,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'roleSpecificData': roleSpecificData,
      'qrData': qrData,
      'averageRating': averageRating,
      'verificationStatus': verificationStatus,
      'cardVersion': cardVersion,
      'walletBalance': walletBalance,
      'walletPin': walletPin,
    };
  }

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      uid: json['uid'] ?? '',
      roleSpecificData: json['roleSpecificData'] != null 
          ? Map<String, dynamic>.from(json['roleSpecificData'])
          : {},
      qrData: json['qrData'] ?? '',
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      verificationStatus: json['verificationStatus'] ?? false,
      cardVersion: json['cardVersion'] ?? 1,
      walletBalance: (json['walletBalance'] ?? 0.0).toDouble(),
      walletPin: json['walletPin'],
    );
  }

  CardModel copyWith({
    String? uid,
    Map<String, dynamic>? roleSpecificData,
    String? qrData,
    double? averageRating,
    bool? verificationStatus,
    int? cardVersion,
    double? walletBalance,
    String? walletPin,
  }) {
    return CardModel(
      uid: uid ?? this.uid,
      roleSpecificData: roleSpecificData ?? this.roleSpecificData,
      qrData: qrData ?? this.qrData,
      averageRating: averageRating ?? this.averageRating,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      cardVersion: cardVersion ?? this.cardVersion,
      walletBalance: walletBalance ?? this.walletBalance,
      walletPin: walletPin ?? this.walletPin,
    );
  }
}
