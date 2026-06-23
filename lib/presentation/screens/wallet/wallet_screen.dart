import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/services/transaction_service.dart';
import 'package:agrolinkbd/core/models/payment_model.dart';
import 'package:agrolinkbd/presentation/screens/wallet/add_money_screen.dart';
import 'package:agrolinkbd/presentation/screens/wallet/withdraw_money_screen.dart';
import 'package:agrolinkbd/presentation/screens/wallet/transaction_history_screen.dart';
import 'package:intl/intl.dart';

class WalletScreen extends StatefulWidget {
  final String userId;
  
  const WalletScreen({super.key, this.userId = 'demo_user'});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final TransactionService _transactionService = TransactionService();
  double _balance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final balance = await _transactionService.getWalletBalance(widget.userId);
    setState(() {
      _balance = balance;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Wallet',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Get.to(() => TransactionHistoryScreen(userId: widget.userId));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Balance Card
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade700, Colors.green.shade500],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Balance',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$_balance Taka',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.to(() => AddMoneyScreen(userId: widget.userId))?.then((_) => _loadBalance());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.green.shade700,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text(
                            'Add Money',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.to(() => WithdrawMoneyScreen(
                                userId: widget.userId,
                                currentBalance: _balance,
                            ))?.then((_) => _loadBalance());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.green.shade700,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.arrow_upward, size: 18),
                          label: const Text(
                            'Withdraw',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Payment Methods
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Methods',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentMethod(
                      'bKash', 'assets/images/bkash.png', Icons.phone_android),
                  const Divider(height: 12),
                  _buildPaymentMethod('Nagad', 'assets/images/nagad.png',
                      Icons.account_balance_wallet),
                  const Divider(height: 12),
                  _buildPaymentMethod('Rocket', 'assets/images/rocket.png',
                      Icons.rocket_launch),
                  const Divider(height: 12),
                  _buildPaymentMethod('Bank Transfer', 'assets/images/bank.png',
                      Icons.account_balance),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Recent Transactions
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.to(() => TransactionHistoryScreen(userId: widget.userId));
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<List<Transaction>>(
                    stream: _transactionService.getUserTransactions(widget.userId, limit: 5),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)));
                      }
                      
                      final transactions = snapshot.data ?? [];
                      if (transactions.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              'No recent transactions',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ),
                        );
                      }
                      
                      return Column(
                        children: transactions.map((tx) {
                          final isCredit = tx.type == TransactionType.credit || tx.type == TransactionType.refund;
                          final formattedTime = DateFormat('MMM dd - hh:mm a').format(tx.createdAt);
                          
                          return Column(
                            children: [
                              _buildTransaction(
                                tx.title,
                                '${isCredit ? '+' : '-'}${tx.amount.toStringAsFixed(2)} Taka',
                                formattedTime,
                                isCredit,
                              ),
                              if (tx != transactions.last) const Divider(height: 12),
                            ],
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(String name, String imagePath, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    return SizedBox(
      height: 48,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        minLeadingWidth: 40,
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.green.shade50,
          child: Icon(icon, color: Colors.green.shade700, size: 20),
        ),
        title: Text(
          name,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: textColor),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: textColor),
        onTap: () {},
      ),
    );
  }

  Widget _buildTransaction(
      String title, String amount, String time, bool isCredit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    return SizedBox(
      height: 56,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        minLeadingWidth: 40,
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: isCredit ? Colors.green.shade50 : Colors.red.shade50,
          child: Icon(
            isCredit ? Icons.arrow_downward : Icons.arrow_upward,
            color: isCredit ? Colors.green.shade700 : Colors.red.shade700,
            size: 18,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: textColor),
        ),
        subtitle: Text(time, style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
        trailing: Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: isCredit ? Colors.green.shade700 : Colors.red.shade700,
          ),
        ),
      ),
    );
  }
}
