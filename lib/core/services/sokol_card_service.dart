import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/card_model.dart';
import '../models/sokol_transaction_model.dart';
import 'package:cloud_functions/cloud_functions.dart';

class SokolCardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Collection References
  CollectionReference get _cardsCollection => _firestore.collection('cards');
  CollectionReference get _transactionsCollection => _firestore.collection('transactions');

  // Create or Update Card
  Future<void> saveCard(CardModel card) async {
    await _cardsCollection.doc(card.uid).set(card.toJson(), SetOptions(merge: true));
  }

  // Get Card Stream
  Stream<CardModel?> getCardStream(String uid) {
    return _cardsCollection.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return CardModel.fromJson(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }
  
  // Update QR Data specifically
  Future<void> updateQrData(String uid, String newQrData) async {
    await _cardsCollection.doc(uid).update({
      'qrData': newQrData,
      'cardVersion': FieldValue.increment(1),
    });
  }

  // Generate Payment Token URL
  String generatePaymentToken(String uid) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'sokol://pay?uid=$uid&token=$timestamp';
  }

  // Process Payment via Cloud Functions
  Future<bool> processPayment({
    required String receiverUid,
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      final HttpsCallable callable = _functions.httpsCallable('processPayment');
      final result = await callable.call(<String, dynamic>{
        'receiverUid': receiverUid,
        'amount': amount,
        'paymentMethod': paymentMethod,
      });

      return result.data['success'] == true;
    } catch (e) {
      print('Error processing payment: $e');
      return false;
    }
  }

  // Get Transaction History
  Stream<List<SokolTransactionModel>> getTransactionHistory(String uid) {
    return _transactionsCollection
        .where(Filter.or(
          Filter('senderUid', isEqualTo: uid),
          Filter('receiverUid', isEqualTo: uid),
        ))
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return SokolTransactionModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}
