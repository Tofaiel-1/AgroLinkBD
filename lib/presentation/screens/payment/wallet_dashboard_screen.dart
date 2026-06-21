import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/models/enhanced_transaction_model.dart';
import '../../core/theme/app_theme.dart';

// ============================================================================
// WALLET DASHBOARD SCREEN
// ============================================================================

class WalletDashboardScreen extends ConsumerWidget {
  final String userId;

  const WalletDashboardScreen({
    required this.userId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallet'),
        elevation: 0,
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _openTransactionHistory(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _openWalletSettings(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Cards
            _buildBalanceCards(),
            const SizedBox(height: 24),

            // Quick Stats
            _buildQuickStats(),
            const SizedBox(height: 24),

            // Recent Transactions
            _buildRecentTransactions(),
            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCards() {
    return Column(
      children: [
        // Main Balance Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available Balance',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tk 125,500.00', // Placeholder
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Earned',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tk 500,000',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lock_clock, size: 14, color: Colors.white.withOpacity(0.7)),
                          const SizedBox(width: 4),
                          Text(
                            'Pending (Escrow)',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tk 50,000',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade300,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Secondary Info Cards
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'Total Spent',
                'Tk 30,500',
                Icons.trending_down,
                Colors.red.withOpacity(0.1),
                Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                'Commission Paid',
                'Tk 25,000',
                Icons.percent,
                Colors.orange.withOpacity(0.1),
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStatRow('Total Transactions', '245'),
                const Divider(height: 20),
                _buildStatRow('This Month', 'Tk 85,000'),
                const Divider(height: 20),
                _buildStatRow('This Week', 'Tk 15,000'),
                const Divider(height: 20),
                _buildStatRow('Last Settlement', '5 days ago'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Container(
            padding: const EdgeInsets.all(0),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey.shade200,
              ),
              itemBuilder: (context, index) {
                return _buildTransactionTile(
                  title: [
                    'Product Sale',
                    'Transport Service',
                    'Supply Purchase'
                  ][index],
                  amount: ['-Tk 500', '+Tk 1,200', '-Tk 5,000'][index],
                  status: ['Completed', 'Completed', 'Processing'][index],
                  date: DateFormat('dd MMM, hh:mm a').format(
                    DateTime.now().subtract(Duration(hours: (index + 1) * 2)),
                  ),
                  isIncome: index != 0 && index != 2,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionTile({
    required String title,
    required String amount,
    required String status,
    required String date,
    required bool isIncome,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isIncome
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isIncome ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _requestWithdrawal(context),
            icon: const Icon(Icons.account_balance_wallet),
            label: const Text('Request Withdrawal'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _viewSettlementHistory(context),
            icon: const Icon(Icons.receipt),
            label: const Text('Settlement History'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  void _openTransactionHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TransactionHistoryScreen(),
      ),
    );
  }

  void _openWalletSettings(BuildContext context) {
    // TODO: Open wallet settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening wallet settings...')),
    );
  }

  void _requestWithdrawal(BuildContext context) {
    // TODO: Open withdrawal request dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening withdrawal request...')),
    );
  }

  void _viewSettlementHistory(BuildContext context) {
    // TODO: Navigate to settlement history
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening settlement history...')),
    );
  }
}

// ============================================================================
// TRANSACTION HISTORY SCREEN (Advanced)
// ============================================================================

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends ConsumerState<TransactionHistoryScreen> {
  TransactionCategory? selectedCategory;
  TransactionStatus? selectedStatus;
  DateTimeRange? selectedDateRange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        elevation: 0,
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterPanel,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          if (selectedCategory != null ||
              selectedStatus != null ||
              selectedDateRange != null)
            Container(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                children: [
                  if (selectedCategory != null)
                    Chip(
                      label: Text(selectedCategory!.name),
                      onDeleted: () {
                        setState(() => selectedCategory = null);
                      },
                    ),
                  if (selectedStatus != null)
                    Chip(
                      label: Text(selectedStatus!.name),
                      onDeleted: () {
                        setState(() => selectedStatus = null);
                      },
                    ),
                  if (selectedDateRange != null)
                    Chip(
                      label: Text(
                        '${DateFormat('dd MMM').format(selectedDateRange!.start)} - ${DateFormat('dd MMM').format(selectedDateRange!.end)}',
                      ),
                      onDeleted: () {
                        setState(() => selectedDateRange = null);
                      },
                    ),
                ],
              ),
            ),

          // Transaction List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: 10,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.money, color: Colors.blue),
                    ),
                    title: Text(
                      'Transaction ${index + 1}',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      DateFormat('dd MMM yyyy, hh:mm a').format(
                        DateTime.now().subtract(Duration(hours: index)),
                      ),
                    ),
                    trailing: Text(
                      index % 2 == 0 ? '+Tk 1,200' : '-Tk 500',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: index % 2 == 0 ? Colors.green : Colors.red,
                      ),
                    ),
                    onTap: () => _showTransactionDetails(context, index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterPanel() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter Transactions',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),

            // Category Filter
            Text(
              'Category',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: TransactionCategory.values
                  .map((cat) => FilterChip(
                        label: Text(cat.name),
                        selected: selectedCategory == cat,
                        onSelected: (selected) {
                          setState(() {
                            selectedCategory = selected ? cat : null;
                          });
                          Navigator.pop(context);
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),

            // Status Filter
            Text(
              'Status',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: TransactionStatus.values
                  .map((status) => FilterChip(
                        label: Text(status.name),
                        selected: selectedStatus == status,
                        onSelected: (selected) {
                          setState(() {
                            selectedStatus = selected ? status : null;
                          });
                          Navigator.pop(context);
                        },
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetails(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Transaction Details',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Transaction ID', 'TXN-ABC12345'),
            _buildDetailRow('Amount', 'Tk 1,200.00'),
            _buildDetailRow('Status', 'Completed'),
            _buildDetailRow('Date',
                DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())),
            _buildDetailRow('Type', 'Product Sale'),
            _buildDetailRow('Commission', 'Tk 60.00'),
            _buildDetailRow('Net Amount', 'Tk 1,140.00'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
