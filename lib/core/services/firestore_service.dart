import 'package:cloud_firestore/cloud_firestore.dart';
import '../exceptions/app_exceptions.dart';

/// Centralized Firestore database service
/// Handles all database operations with proper error handling
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirestoreService._internal();

  factory FirestoreService() {
    return _instance;
  }

  // ========== COLLECTION REFERENCES ==========
  CollectionReference<Map<String, dynamic>> get usersCollection =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get productsCollection =>
      _firestore.collection('products');

  CollectionReference<Map<String, dynamic>> get ordersCollection =>
      _firestore.collection('orders');

  CollectionReference<Map<String, dynamic>> get chatCollection =>
      _firestore.collection('chats');

  CollectionReference<Map<String, dynamic>> get messagesCollection =>
      _firestore.collection('messages');

  CollectionReference<Map<String, dynamic>> get walletsCollection =>
      _firestore.collection('wallets');

  CollectionReference<Map<String, dynamic>> get transactionsCollection =>
      _firestore.collection('transactions');

  // ========== GENERIC CRUD OPERATIONS ==========

  /// Create a document
  Future<void> createDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(documentId).set(data);
    } catch (e) {
      throw FirestoreException.fromFirestore(e);
    }
  }

  /// Read a document
  Future<Map<String, dynamic>?> readDocument(
    String collection,
    String documentId,
  ) async {
    try {
      final doc = await _firestore.collection(collection).doc(documentId).get();
      return doc.data();
    } catch (e) {
      throw FirestoreException.fromFirestore(e);
    }
  }

  /// Update a document
  Future<void> updateDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(documentId).update(data);
    } catch (e) {
      throw FirestoreException.fromFirestore(e);
    }
  }

  /// Delete a document
  Future<void> deleteDocument(
    String collection,
    String documentId,
  ) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
    } catch (e) {
      throw FirestoreException.fromFirestore(e);
    }
  }

  /// Get all documents in collection
  Future<List<Map<String, dynamic>>> getAllDocuments(String collection) async {
    try {
      final snapshot = await _firestore.collection(collection).get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw FirestoreException.fromFirestore(e);
    }
  }

  /// Query documents with filter
  Future<List<Map<String, dynamic>>> queryDocuments(
    String collection,
    String field,
    dynamic value,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(collection)
          .where(field, isEqualTo: value)
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw FirestoreException.fromFirestore(e);
    }
  }

  // ========== REAL-TIME LISTENERS ==========

  /// Listen to a document in real-time
  Stream<Map<String, dynamic>?> listenToDocument(
    String collection,
    String documentId,
  ) {
    return _firestore
        .collection(collection)
        .doc(documentId)
        .snapshots()
        .map((snapshot) => snapshot.data());
  }

  /// Listen to collection with filter
  Stream<List<Map<String, dynamic>>> listenToCollection(
    String collection, {
    String? whereField,
    dynamic whereValue,
    String? orderByField,
    bool descending = false,
    int? limit,
  }) {
    Query query = _firestore.collection(collection);

    if (whereField != null && whereValue != null) {
      query = query.where(whereField, isEqualTo: whereValue);
    }

    if (orderByField != null) {
      query = query.orderBy(orderByField, descending: descending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList());
  }

  // ========== BATCH OPERATIONS ==========

  /// Batch write multiple documents
  Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    try {
      final batch = _firestore.batch();

      for (final op in operations) {
        final ref = _firestore
            .collection(op['collection'] as String)
            .doc(op['documentId'] as String);

        if (op['type'] == 'set') {
          batch.set(ref, op['data'] as Map<String, dynamic>);
        } else if (op['type'] == 'update') {
          batch.update(ref, op['data'] as Map<String, dynamic>);
        } else if (op['type'] == 'delete') {
          batch.delete(ref);
        }
      }

      await batch.commit();
    } catch (e) {
      throw FirestoreException.fromFirestore(e);
    }
  }

  // ========== TRANSACTION OPERATIONS ==========

  /// Execute transaction
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction) updateFunction,
  ) async {
    try {
      return await _firestore.runTransaction(updateFunction);
    } catch (e) {
      throw FirestoreException.fromFirestore(e);
    }
  }

  // ========== AGGREGATION OPERATIONS ==========

  /// Get document count
  Future<int> getDocumentCount(String collection) async {
    try {
      final snapshot = await _firestore.collection(collection).count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw FirestoreException.fromFirestore(e);
    }
  }

  /// Check if document exists
  Future<bool> documentExists(String collection, String documentId) async {
    try {
      final doc = await _firestore.collection(collection).doc(documentId).get();
      return doc.exists;
    } catch (e) {
      throw FirestoreException.fromFirestore(e);
    }
  }

  // ========== HELPER METHODS ==========

  /// Generate auto ID
  String generateDocumentId(String collection) {
    return _firestore.collection(collection).doc().id;
  }

  /// Get server timestamp
  FieldValue getServerTimestamp() {
    return FieldValue.serverTimestamp();
  }

  /// Increment numeric field
  FieldValue incrementField(num value) {
    return FieldValue.increment(value);
  }

  /// Array union (add unique elements)
  FieldValue arrayUnion(List<dynamic> elements) {
    return FieldValue.arrayUnion(elements);
  }

  /// Array remove
  FieldValue arrayRemove(List<dynamic> elements) {
    return FieldValue.arrayRemove(elements);
  }
}
