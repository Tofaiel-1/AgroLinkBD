import 'package:flutter/material.dart';
import 'package:agrolinkbd/core/models/withdraw_request_model.dart';
import 'package:agrolinkbd/core/models/deposit_request_model.dart';
import 'package:agrolinkbd/core/models/transfer_request_model.dart';
import 'package:agrolinkbd/core/services/withdraw_service.dart';
import 'package:agrolinkbd/core/services/deposit_service.dart';
import 'package:agrolinkbd/core/services/transaction_service.dart';
import 'package:intl/intl.dart';

class AdminFinancialRequestsScreen extends StatefulWidget {
  final int initialTabIndex;
  const AdminFinancialRequestsScreen({Key? key, this.initialTabIndex = 0}) : super(key: key);

  @override
  State<AdminFinancialRequestsScreen> createState() => _AdminFinancialRequestsScreenState();
}

class _AdminFinancialRequestsScreenState extends State<AdminFinancialRequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final WithdrawService _withdrawService = WithdrawService();
  final DepositService _depositService = DepositService();
  final TransactionService _transactionService = TransactionService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Requests'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Withdrawals'),
            Tab(text: 'Deposits'),
            Tab(text: 'Direct Transfers'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWithdrawalsTab(),
          _buildDepositsTab(),
          _buildTransfersTab(),
        ],
      ),
    );
  }

  Widget _buildWithdrawalsTab() {
    return StreamBuilder<List<WithdrawRequestModel>>(
      stream: _withdrawService.getPendingWithdrawRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final requests = snapshot.data ?? [];
        if (requests.isEmpty) {
          return const Center(child: Text('No pending withdraw requests.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('User ID: ${req.userId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(DateFormat('MMM dd, hh:mm a').format(req.createdAt), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Amount: ৳${req.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
                    Text('Method: ${req.method.toUpperCase()}'),
                    Text('Details: ${req.accountDetails}'),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => _handleRejectWithdraw(req),
                          child: const Text('Reject & Refund', style: TextStyle(color: Colors.red)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _handleApproveWithdraw(req),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('Approve (Paid)'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDepositsTab() {
    return StreamBuilder<List<DepositRequestModel>>(
      stream: _depositService.getPendingDepositRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final requests = snapshot.data ?? [];
        if (requests.isEmpty) {
          return const Center(child: Text('No pending deposit requests.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('User ID: ${req.userId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(DateFormat('MMM dd, hh:mm a').format(req.createdAt), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Amount: ৳${req.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                    Text('Method: ${req.paymentMethod.toUpperCase()}'),
                    if (req.transactionId != null) Text('Txn ID: ${req.transactionId}'),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => _handleRejectDeposit(req),
                          child: const Text('Reject', style: TextStyle(color: Colors.red)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _handleApproveDeposit(req),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('Approve & Credit'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _handleApproveWithdraw(WithdrawRequestModel req) async {
    try {
      await _withdrawService.approveWithdraw(req.id);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Withdrawal approved successfully.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _handleRejectWithdraw(WithdrawRequestModel req) async {
    try {
      await _withdrawService.rejectWithdraw(req);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Withdrawal rejected and refunded.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _handleApproveDeposit(DepositRequestModel req) async {
    try {
      await _depositService.approveDeposit(req);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deposit approved successfully.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _handleRejectDeposit(DepositRequestModel req) async {
    try {
      await _depositService.rejectDeposit(req.id);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deposit rejected.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _buildTransfersTab() {
    return StreamBuilder<List<TransferRequestModel>>(
      stream: _transactionService.getPendingTransferRequests(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: SelectableText(
              'Error loading transfers: ${snapshot.error}\\n\\nClick the link above to create Firestore index.',
              style: TextStyle(color: Colors.red.shade400, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final requests = snapshot.data ?? [];
        if (requests.isEmpty) {
          return const Center(child: Text('No pending transfer requests.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Sender: ${req.senderId.length > 8 ? req.senderId.substring(0, 8) : req.senderId}...', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(DateFormat('MMM dd, hh:mm a').format(req.createdAt), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Receiver: ${req.receiverId.length > 8 ? req.receiverId.substring(0, 8) : req.receiverId}...', style: const TextStyle(fontSize: 12)),
                    Text('Amount: ৳${req.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                    Text('Reason: ${req.reason}'),
                    Text('Method: ${req.paymentMethod} - ${req.accountNumber}'),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => _handleRejectTransfer(req),
                          child: const Text('Reject (Refund)', style: TextStyle(color: Colors.red)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _handleApproveTransfer(req),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('Approve (Credit)'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _handleApproveTransfer(TransferRequestModel req) async {
    try {
      await _transactionService.approveTransferRequest(req);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transfer approved and receiver credited.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _handleRejectTransfer(TransferRequestModel req) async {
    try {
      await _transactionService.rejectTransferRequest(req);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transfer rejected and sender refunded.')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
