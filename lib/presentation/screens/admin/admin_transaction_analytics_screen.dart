import 'package:flutter/material.dart';
import 'package:agrolinkbd/core/services/transaction_service.dart';
import 'package:agrolinkbd/core/models/payment_model.dart';
import 'package:intl/intl.dart';

class AdminTransactionAnalyticsScreen extends StatefulWidget {
  const AdminTransactionAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AdminTransactionAnalyticsScreen> createState() => _AdminTransactionAnalyticsScreenState();
}

class _AdminTransactionAnalyticsScreenState extends State<AdminTransactionAnalyticsScreen> with SingleTickerProviderStateMixin {
  final TransactionService _transactionService = TransactionService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getGroupKey(DateTime date, int tabIndex) {
    switch (tabIndex) {
      case 0: // Daily
        return DateFormat('yyyy-MM-dd').format(date);
      case 1: // Weekly
        // Get the start of the week (Monday)
        final int daysToSubtract = date.weekday - 1;
        final DateTime startOfWeek = date.subtract(Duration(days: daysToSubtract));
        return 'Week of ${DateFormat('MMM dd, yyyy').format(startOfWeek)}';
      case 2: // Monthly
        return DateFormat('MMMM yyyy').format(date);
      case 3: // Yearly
        return DateFormat('yyyy').format(date);
      default:
        return DateFormat('yyyy-MM-dd').format(date);
    }
  }

  Map<String, List<Transaction>> _groupTransactions(List<Transaction> transactions, int tabIndex) {
    final Map<String, List<Transaction>> grouped = {};
    for (var tx in transactions) {
      final key = _getGroupKey(tx.createdAt, tabIndex);
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(tx);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Cash Flow Analytics'),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Daily'),
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
            Tab(text: 'Yearly'),
          ],
        ),
      ),
      body: StreamBuilder<List<Transaction>>(
        stream: _transactionService.getAllTransactions(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: SelectableText(
                'Error loading analytics: ${snapshot.error}\\n\\nClick the link above to create Firestore index.',
                style: TextStyle(color: Colors.red.shade400, fontSize: 13),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)));
          }

          final allTransactions = snapshot.data ?? [];
          
          if (allTransactions.isEmpty) {
            return Center(
              child: Text('No transactions found in the system.', style: TextStyle(color: textColor, fontSize: 16)),
            );
          }

          // Calculate total system cash flow
          double totalCredit = 0;
          double totalDebit = 0;
          for (var tx in allTransactions) {
            if (tx.type == TransactionType.credit || tx.type == TransactionType.refund) {
              totalCredit += tx.amount;
            } else if (tx.type == TransactionType.debit) {
              totalDebit += tx.amount;
            }
          }

          return Column(
            children: [
              // Top Overview Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
                child: Column(
                  children: [
                    const Text('Total System Cash Flow', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                      '৳${(totalCredit - totalDebit).toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatColumn('Total In (+)', '৳${totalCredit.toStringAsFixed(2)}', Colors.greenAccent),
                        _buildStatColumn('Total Out (-)', '৳${totalDebit.toStringAsFixed(2)}', Colors.redAccent),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Tabs Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: List.generate(4, (index) {
                    final groupedData = _groupTransactions(allTransactions, index);
                    return _buildGroupedListView(groupedData, cardColor, textColor);
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatColumn(String label, String amount, Color amountColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(amount, style: TextStyle(color: amountColor, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildGroupedListView(Map<String, List<Transaction>> groupedData, Color cardColor, Color textColor) {
    final keys = groupedData.keys.toList();
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final key = keys[index];
        final txList = groupedData[key]!;
        
        double groupCredit = 0;
        double groupDebit = 0;
        for (var tx in txList) {
          if (tx.type == TransactionType.credit || tx.type == TransactionType.refund) {
            groupCredit += tx.amount;
          } else if (tx.type == TransactionType.debit) {
            groupDebit += tx.amount;
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.05),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      key,
                      style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${txList.length} txns',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
              
              // Group Summary Stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMiniStat('Cash In', '৳${groupCredit.toStringAsFixed(2)}', Colors.green),
                    Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.3)),
                    _buildMiniStat('Cash Out', '৳${groupDebit.toStringAsFixed(2)}', Colors.red),
                    Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.3)),
                    _buildMiniStat('Net', '৳${(groupCredit - groupDebit).toStringAsFixed(2)}', 
                        groupCredit >= groupDebit ? Colors.green : Colors.red),
                  ],
                ),
              ),
              
              Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
              
              // Transaction Items
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: txList.length,
                separatorBuilder: (context, i) => Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                itemBuilder: (context, i) {
                  final tx = txList[i];
                  final isCredit = tx.type == TransactionType.credit || tx.type == TransactionType.refund;
                  
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: isCredit ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      child: Icon(
                        isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isCredit ? Colors.green : Colors.red,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      tx.title,
                      style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('hh:mm a').format(tx.createdAt),
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        Text(
                          'User: ${tx.userId.substring(0, 8)}...',
                          style: const TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ],
                    ),
                    trailing: Text(
                      '${isCredit ? '+' : '-'}৳${tx.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: isCredit ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniStat(String label, String amount, Color amountColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(amount, style: TextStyle(color: amountColor, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
