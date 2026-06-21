import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/service_model.dart';

class ServiceManagementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  // Get stream of services for the current provider
  Stream<List<ServiceModel>> getProviderServices() {
    if (currentUserId.isEmpty) return Stream.value([]);
    
    return _firestore
        .collection('services')
        .where('providerId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ServiceModel.fromJson(doc.data())).toList();
    });
  }

  // Add a new service
  Future<void> addService(ServiceModel service) async {
    final docRef = _firestore.collection('services').doc();
    final newService = service.copyWith(id: docRef.id, providerId: currentUserId);
    await docRef.set(newService.toJson());
  }

  // Update an existing service
  Future<void> updateService(ServiceModel service) async {
    await _firestore
        .collection('services')
        .doc(service.id)
        .update(service.toJson());
  }

  // Delete a service
  Future<void> deleteService(String serviceId) async {
    await _firestore.collection('services').doc(serviceId).delete();
  }

  // Toggle service status
  Future<void> toggleServiceStatus(String serviceId, ServiceStatus currentStatus) async {
    final newStatus = currentStatus == ServiceStatus.active
        ? ServiceStatus.inactive
        : ServiceStatus.active;
        
    await _firestore.collection('services').doc(serviceId).update({
      'status': newStatus.toString(),
    });
  }
}
