import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/admin_provider.dart';

class RefundQueueScreen extends StatefulWidget {
  const RefundQueueScreen({super.key});

  @override
  State<RefundQueueScreen> createState() => _RefundQueueScreenState();
}

class _RefundQueueScreenState extends State<RefundQueueScreen> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  late TabController _tabController;
  
  bool _isLightMode = false;
  String _searchQuery = '';

  Color get _bgColor => _isLightMode ? const Color(0xFFF3F4F6) : const Color(0xFF0B0F19);
  Color get _textColor => _isLightMode ? const Color(0xFF1F2937) : Colors.white;
  Color get _cardColor => _isLightMode ? Colors.white.withOpacity(0.7) : Colors.white.withOpacity(0.03);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(top: -100, left: -100, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF8B5CF6).withOpacity(_isLightMode ? 0.2 : 0.15)))),
            Positioned(bottom: -150, right: -50, child: Container(width: 400, height: 400, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFEF4444).withOpacity(_isLightMode ? 0.2 : 0.1)))),
            BackdropFilter(filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60), child: Container(color: Colors.transparent)),
            
            Column(
              children: [
                _buildHeader(),
                TabBar(
                  controller: _tabController,
                  indicatorColor: const Color(0xFF8B5CF6),
                  labelColor: const Color(0xFF8B5CF6),
                  unselectedLabelColor: _textColor.withOpacity(0.5),
                  tabs: const [
                    Tab(text: 'Refund Queue'),
                    Tab(text: 'All Transactions'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRefundQueue(),
                      _buildAllTransactions(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: _textColor), onPressed: () => Get.back()),
                  Text('Reconciliation', style: TextStyle(color: _textColor, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                ],
              ),
              GestureDetector(
                onTap: () => setState(() => _isLightMode = !_isLightMode),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: _cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: _textColor.withOpacity(0.1))),
                  child: Icon(_isLightMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: _textColor, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                style: TextStyle(color: _textColor),
                decoration: InputDecoration(
                  hintText: 'Search by Transaction ID...',
                  hintStyle: TextStyle(color: _textColor.withOpacity(0.5)),
                  prefixIcon: Icon(Icons.search_rounded, color: _textColor.withOpacity(0.7)),
                  filled: true,
                  fillColor: _cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefundQueue() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('refund_requests').where('status', isEqualTo: 'Pending').orderBy('requestDate', descending: false).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6)));
        
        var requests = snapshot.data!.docs;
        if (_searchQuery.isNotEmpty) {
          requests = requests.where((doc) => doc.id.toLowerCase().contains(_searchQuery) || (doc.data() as Map)['transactionId'].toString().toLowerCase().contains(_searchQuery)).toList();
        }

        if (requests.isEmpty) {
          return Center(child: Text('No pending refund requests!', style: TextStyle(color: _textColor.withOpacity(0.5))));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final data = requests[index].data() as Map<String, dynamic>;
            return _buildRefundCard(requests[index].id, data);
          },
        );
      },
    );
  }

  Widget _buildRefundCard(String reqId, Map<String, dynamic> data) {
    final txId = data['transactionId'] ?? 'Unknown';
    final reason = data['reason'] ?? 'No reason provided';
    final userId = data['userId'] ?? 'Unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: _cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.redAccent.withOpacity(0.3))),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TXN: $txId', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: const Text('PENDING', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text('Reason: $reason', style: TextStyle(color: _textColor.withOpacity(0.7), fontSize: 12)),
            Text('User: $userId', style: TextStyle(color: _textColor.withOpacity(0.5), fontSize: 10)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _confirmRefund(reqId, txId),
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: const Text('PROCESS REFUND', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _confirmRefund(String reqId, String txId) {
    Get.defaultDialog(
      title: 'Confirm Refund',
      middleText: 'Are you sure you want to process this refund? This will reverse the transaction and restore stock via Stripe API.',
      backgroundColor: _bgColor,
      titleStyle: TextStyle(color: _textColor, fontWeight: FontWeight.bold),
      middleTextStyle: TextStyle(color: _textColor.withOpacity(0.8)),
      textConfirm: 'Confirm',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        await _processRefundCall(txId);
      },
    );
  }

  Future<void> _processRefundCall(String txId) async {
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    try {
      final HttpsCallable callable = _functions.httpsCallable('processRefund');
      final result = await callable.call({'transactionId': txId});
      
      Get.back(); // close loading
      
      if (result.data['success']) {
        final provider = Provider.of<AdminProvider>(context, listen: false);
        provider.logAdminAction('REFUND_PROCESSED', 'Processed refund for TXN: $txId');
        Get.snackbar('Success', 'Refund processed successfully!', backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.back(); // close loading
      Get.snackbar('Error', 'Refund failed: $e', backgroundColor: Colors.red, colorText: Colors.white, duration: const Duration(seconds: 4));
    }
  }

  Widget _buildAllTransactions() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('transactions').orderBy('timestamp', descending: true).limit(50).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
        
        var txs = snapshot.data!.docs;
        if (_searchQuery.isNotEmpty) {
          txs = txs.where((doc) => doc.id.toLowerCase().contains(_searchQuery)).toList();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: txs.length,
          itemBuilder: (context, index) {
            final data = txs[index].data() as Map<String, dynamic>;
            return _buildTransactionCard(data);
          },
        );
      },
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> data) {
    final status = data['status'] ?? 'Pending';
    final amount = data['amount'] ?? 0;
    final txId = data['transactionId'] ?? 'Unknown';
    
    Color statusColor;
    if (status == 'Success') statusColor = Colors.green;
    else if (status == 'Refunded') statusColor = Colors.orange;
    else if (status == 'Failed') statusColor = Colors.red;
    else statusColor = Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _cardColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(txId, style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 12)),
              Text('৳$amount', style: TextStyle(color: _textColor.withOpacity(0.7), fontSize: 12)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: Text(status.toString().toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}
