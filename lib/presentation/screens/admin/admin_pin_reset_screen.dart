import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPinResetScreen extends StatelessWidget {
  const AdminPinResetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PIN Reset Requests'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('pin_reset_requests')
            .where('status', isEqualTo: 'pending')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data?.docs ?? [];

          if (requests.isEmpty) {
            return const Center(
              child: Text(
                'No pending PIN reset requests.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final doc = requests[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.lock_reset, color: Colors.white),
                  ),
                  title: Text(data['userName'] ?? 'Unknown User', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Type: ${data['type']}'),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () => _approveRequest(context, doc.id, data['userId'], data['type']),
                    child: const Text('Approve', style: TextStyle(color: Colors.white)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _approveRequest(BuildContext context, String requestId, String userId, String type) async {
    try {
      final db = FirebaseFirestore.instance;
      
      // Update the user's PIN to null
      String pinField = type == 'mainBalance' ? 'mainBalancePin' : 'walletPin';
      
      await db.collection('users').doc(userId).update({
        pinField: null,
      });

      // Update the request status
      await db.collection('pin_reset_requests').doc(requestId).update({
        'status': 'approved',
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN successfully reset for user!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reset PIN: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
