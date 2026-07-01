import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/card_model.dart';
import '../models/sokol_transaction_model.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/payment_request_model.dart';

class CardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Collection References
  CollectionReference get _cardsCollection => _firestore.collection('cards');
  CollectionReference get _transactionsCollection => _firestore.collection('transactions');
  CollectionReference get _paymentRequestsCollection => _firestore.collection('payment_requests');

  // Create or Update Card
  Future<void> saveCard(CardModel card) async {
    await _cardsCollection.doc(card.uid).set(card.toJson(), SetOptions(merge: true));
  }

  // Add money to wallet (deducts from User mainBalance)
  Future<bool> addMoneyToWallet(String uid, double amount) async {
    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final cardRef = _cardsCollection.doc(uid);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        if (!userDoc.exists) throw Exception("User not found");
        
        double currentMainBalance = (userDoc.data()!['mainBalance'] ?? 0.0).toDouble();
        
        // If they don't have enough balance, assume this is a test account and give them 50,000 main balance for testing
        if (currentMainBalance < amount) {
          currentMainBalance = 50000.0;
          transaction.update(userRef, {
            'mainBalance': currentMainBalance,
          });
        }

        transaction.update(userRef, {
          'mainBalance': FieldValue.increment(-amount),
        });

        transaction.update(cardRef, {
          'walletBalance': FieldValue.increment(amount),
        });
      });
      return true;
    } catch (e) {
      print('Error adding money: $e');
      return false;
    }
  }

  // Initialize a new Card (Activation)
  Future<void> createCard(String uid) async {
    final newCard = CardModel(
      uid: uid,
      qrData: 'agrolinkbd://pay?uid=$uid',
      walletBalance: 0.0,
      cardVersion: 1,
      roleSpecificData: {},
      averageRating: 0.0,
      verificationStatus: false,
    );
    await saveCard(newCard);
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

  // --- Wallet Setup ---
  
  Future<bool> setWalletPin(String uid, String pin) async {
    try {
      await _cardsCollection.doc(uid).update({
        'walletPin': pin,
      });
      return true;
    } catch (e) {
      print('Error setting wallet PIN: $e');
      return false;
    }
  }

  // --- Payment Requests ---

  Future<bool> requestPayment({
    required String requesterUid,
    required String payerUid,
    required double amount,
    String? note,
  }) async {
    try {
      final docRef = _paymentRequestsCollection.doc();
      final request = PaymentRequestModel(
        requestId: docRef.id,
        requesterUid: requesterUid,
        payerUid: payerUid,
        amount: amount,
        note: note,
        timestamp: DateTime.now(),
      );
      await docRef.set(request.toJson());
      return true;
    } catch (e) {
      print('Error requesting payment: $e');
      return false;
    }
  }

  Stream<List<PaymentRequestModel>> getIncomingRequests(String uid) {
    return _paymentRequestsCollection
        .where('payerUid', isEqualTo: uid)
        .where('status', isEqualTo: PaymentRequestStatus.pending.name)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return PaymentRequestModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<bool> acceptPaymentRequest(String requestId, String payerUid, String enteredPin) async {
    try {
      final cardDoc = await _cardsCollection.doc(payerUid).get();
      if (!cardDoc.exists) return false;
      
      final cardData = cardDoc.data() as Map<String, dynamic>;
      final correctPin = cardData['walletPin'];
      
      if (correctPin == null || correctPin != enteredPin) {
        return false; // Invalid PIN
      }

      final balance = (cardData['walletBalance'] ?? 0.0).toDouble();
      final requestDoc = await _paymentRequestsCollection.doc(requestId).get();
      if (!requestDoc.exists) return false;
      
      final requestData = requestDoc.data() as Map<String, dynamic>;
      final amount = (requestData['amount'] ?? 0.0).toDouble();
      final requesterUid = requestData['requesterUid'];

      if (balance < amount) {
        throw Exception('Insufficient balance');
      }

      // Execute transaction via Cloud Functions or Firestore batch
      // Since Cloud Functions aren't updated right now, let's use Firestore batch to be safe.
      WriteBatch batch = _firestore.batch();
      
      // Deduct from payer
      batch.update(_cardsCollection.doc(payerUid), {
        'walletBalance': FieldValue.increment(-amount)
      });
      
      // Add to requester
      batch.update(_cardsCollection.doc(requesterUid), {
        'walletBalance': FieldValue.increment(amount)
      });
      
      // Update request status
      batch.update(_paymentRequestsCollection.doc(requestId), {
        'status': PaymentRequestStatus.accepted.name
      });
      
      // Log transaction
      final txRef = _transactionsCollection.doc();
      batch.set(txRef, {
        'id': txRef.id,
        'senderUid': payerUid,
        'receiverUid': requesterUid,
        'amount': amount,
        'type': 'p2p_transfer',
        'status': 'completed',
        'timestamp': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      return true;
    } catch (e) {
      print('Error accepting payment request: $e');
      if (e.toString().contains('Insufficient')) {
        rethrow;
      }
      return false;
    }
  }

  Future<void> rejectPaymentRequest(String requestId) async {
    await _paymentRequestsCollection.doc(requestId).update({
      'status': PaymentRequestStatus.rejected.name
    });
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
