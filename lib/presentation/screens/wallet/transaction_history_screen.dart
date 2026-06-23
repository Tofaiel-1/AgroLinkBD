import 'package:flutter/material.dart';
import 'package:agrolinkbd/core/services/transaction_service.dart';
import 'package:agrolinkbd/core/models/payment_model.dart';
import 'package:intl/intl.dart';

class TransactionHistoryScreen extends StatelessWidget {
  final String userId;

  const TransactionHistoryScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TransactionService transactionService = TransactionService();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: StreamBuilder<List<Transaction>>(
        stream: transactionService.getUserTransactions(userId, limit: 100),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading transactions',
                style: TextStyle(color: Colors.red.shade400),
              ),
            );
          }

          final transactions = snapshot.data ?? [];

          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions found',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            separatorBuilder: (context, index) => const Divider(height: 16),
            itemBuilder: (context, index) {
              final tx = transactions[index];
              final isCredit = tx.type == TransactionType.credit || tx.type == TransactionType.refund;
              
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
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
                    tx.title,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textColor),
                  ),
                  subtitle: Text(
                    DateFormat('MMM dd, yyyy - hh:mm a').format(tx.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  trailing: Text(
                    '${isCredit ? '+' : '-'}${tx.amount.toStringAsFixed(2)} ৳',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isCredit ? Colors.green.shade700 : Colors.red.shade700,
                    ),
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
