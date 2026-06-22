import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/models/deposit_request_model.dart';
import 'package:agrolinkbd/core/services/deposit_service.dart';

class AdminDepositApprovalScreen extends StatefulWidget {
  const AdminDepositApprovalScreen({Key? key}) : super(key: key);

  @override
  State<AdminDepositApprovalScreen> createState() => _AdminDepositApprovalScreenState();
}

class _AdminDepositApprovalScreenState extends State<AdminDepositApprovalScreen> {
  final DepositService _depositService = DepositService();

  void _approveRequest(DepositRequestModel request) async {
    bool success = await _depositService.approveDeposit(request);
    if (success) {
      Get.snackbar('Success', 'Deposit of ৳${request.amount} approved for user ${request.userId}', backgroundColor: Colors.green.shade100);
    } else {
      Get.snackbar('Error', 'Failed to approve deposit.', backgroundColor: Colors.red.shade100);
    }
  }

  void _rejectRequest(DepositRequestModel request) async {
    bool success = await _depositService.rejectDeposit(request.id);
    if (success) {
      Get.snackbar('Rejected', 'Deposit of ৳${request.amount} was rejected.', backgroundColor: Colors.orange.shade100);
    } else {
      Get.snackbar('Error', 'Failed to reject deposit.', backgroundColor: Colors.red.shade100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deposit Approvals'),
        backgroundColor: const Color(0xFF1E88E5),
      ),
      body: StreamBuilder<List<DepositRequestModel>>(
        stream: _depositService.getPendingDepositRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final requests = snapshot.data ?? [];

          if (requests.isEmpty) {
            return const Center(
              child: Text(
                'No pending deposit requests',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'User ID: ${req.userId}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Pending', style: TextStyle(color: Colors.orange)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Amount: ৳${req.amount}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                      const SizedBox(height: 4),
                      Text('Method: ${req.paymentMethod.toUpperCase()}'),
                      if (req.transactionId != null && req.transactionId!.isNotEmpty)
                        Text('Txn ID: ${req.transactionId}'),
                      const SizedBox(height: 4),
                      Text('Time: ${req.createdAt.toString().split('.')[0]}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => _rejectRequest(req),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Reject'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _approveRequest(req),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            child: const Text('Approve', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
