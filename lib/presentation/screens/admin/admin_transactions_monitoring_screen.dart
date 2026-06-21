import 'package:flutter/material.dart';

/// Transaction Monitoring Screen
/// Features: Financial tracking, wallet management, withdrawal processing
class AdminTransactionMonitoringScreen extends StatefulWidget {
  const AdminTransactionMonitoringScreen({super.key});

  @override
  State<AdminTransactionMonitoringScreen> createState() =>
      _AdminTransactionMonitoringScreenState();
}

class _AdminTransactionMonitoringScreenState
    extends State<AdminTransactionMonitoringScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedType = 'All';
  String _selectedStatus = 'All';

  final mockTransactions = [
    {
      'date': 'Mar 19, 10:30',
      'user': 'Ahmad Khan',
      'role': 'Farmer',
      'type': 'Order Payment',
      'amount': '৳2,450',
      'status': 'Success'
    },
    {
      'date': 'Mar 19, 09:15',
      'user': 'System',
      'role': 'System',
      'type': 'Commission',
      'amount': '৳122.50',
      'status': 'Success'
    },
    {
      'date': 'Mar 18, 14:22',
      'user': 'Fatima Ali',
      'role': 'Buyer',
      'type': 'Wallet Add',
      'amount': '৳10,000',
      'status': 'Pending'
    },
    {
      'date': 'Mar 18, 11:45',
      'user': 'Hassan Ahmed',
      'role': 'Seller',
      'type': 'Withdrawal',
      'amount': '-৳5,000',
      'status': 'Success'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('Transaction Monitoring'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Transactions'),
            Tab(text: 'Wallet Management'),
            Tab(text: 'Withdrawals'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionsTab(),
          _buildWalletManagementTab(),
          _buildWithdrawalsTab(),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Financial overview
            _buildFinancialOverview(),
            const SizedBox(height: 24),

            // Filters
            Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search transactions...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                PopupMenuButton<String>(
                  onSelected: (value) => setState(() => _selectedType = value),
                  itemBuilder: (context) => [
                    'All',
                    'Order Payment',
                    'Wallet Add',
                    'Withdrawal',
                    'Refund',
                    'Commission'
                  ]
                      .map((type) =>
                          PopupMenuItem(value: type, child: Text(type)))
                      .toList(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(_selectedType,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12)),
                        const Icon(Icons.arrow_drop_down,
                            color: Colors.white54),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Transactions table
            _buildTransactionsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialOverview() {
    return Row(
      children: [
        Expanded(
          child: _buildOverviewCard('Total Revenue', '৳3.2M', Colors.blue),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildOverviewCard('Total Withdrawals', '৳1.8M', Colors.green),
        ),
        const SizedBox(width: 16),
        Expanded(
          child:
              _buildOverviewCard('Pending Withdrawals', '৳45K', Colors.orange),
        ),
        const SizedBox(width: 16),
        Expanded(
          child:
              _buildOverviewCard('Platform Balance', '৳1.35M', Colors.purple),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTransactionsTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateColor.resolveWith(
              (states) => Colors.white.withOpacity(0.05)),
          columns: const [
            DataColumn(label: Text('Date & Time')),
            DataColumn(label: Text('User')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Status')),
          ],
          rows: mockTransactions
              .map((txn) => DataRow(cells: [
                    DataCell(Text(txn['date'] as String,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11))),
                    DataCell(Text(txn['user'] as String,
                        style: const TextStyle(color: Colors.white70))),
                    DataCell(Text(txn['type'] as String,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11))),
                    DataCell(Text(
                      txn['amount'] as String,
                      style: TextStyle(
                        color: (txn['amount'] as String).startsWith('-')
                            ? Colors.red
                            : Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (txn['status'] == 'Success'
                                ? Colors.green
                                : Colors.orange)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        txn['status'] as String,
                        style: TextStyle(
                          color: txn['status'] == 'Success'
                              ? Colors.green
                              : Colors.orange,
                          fontSize: 11,
                        ),
                      ),
                    )),
                  ]))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildWalletManagementTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User Wallet Search',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search user by name or email...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 24),

            // Wallet display (example)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ahmad Khan',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Current Balance',
                              style: TextStyle(color: Colors.white54)),
                          SizedBox(height: 4),
                          Text('৳5,240',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        children: [
                          ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                              child: const Text('Add Money')),
                          const SizedBox(height: 8),
                          ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              child: const Text('Deduct')),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text('Adjustment Form',
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: Colors.white70)),
                  const SizedBox(height: 12),
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Amount (positive/negative)',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Reason (required)',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                          value: true,
                          onChanged: (_) {},
                          fillColor: WidgetStateProperty.all(
                              const Color(0xFF059669))),
                      const Expanded(
                          child: Text('Send notification to user',
                              style: TextStyle(color: Colors.white70))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('Submit Adjustment'))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawalsTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pending Withdrawals',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateColor.resolveWith(
                      (states) => Colors.white.withOpacity(0.05)),
                  columns: const [
                    DataColumn(label: Text('User')),
                    DataColumn(label: Text('Amount')),
                    DataColumn(label: Text('Bank Details')),
                    DataColumn(label: Text('Request Date')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: [
                    DataRow(cells: [
                      const DataCell(Text('Fatima Ali',
                          style: TextStyle(color: Colors.white70))),
                      const DataCell(Text('৳10,000',
                          style: TextStyle(color: Colors.white))),
                      DataCell(
                        ElevatedButton(
                          onPressed: () => ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                                  content: Text('Bank details revealed'))),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue),
                          child: const Text('View',
                              style: TextStyle(fontSize: 11)),
                        ),
                      ),
                      const DataCell(Text('Mar 18',
                          style: TextStyle(color: Colors.white70))),
                      DataCell(Row(
                        children: [
                          ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green),
                              child: const Text('Approve',
                                  style: TextStyle(fontSize: 10))),
                          const SizedBox(width: 8),
                          ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              child: const Text('Reject',
                                  style: TextStyle(fontSize: 10))),
                        ],
                      )),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
