import 'package:flutter/material.dart';

/// Order Management Screen
/// Features: Order tracking, status management, dispute handling
class AdminOrderManagementScreen extends StatefulWidget {
  const AdminOrderManagementScreen({super.key});

  @override
  State<AdminOrderManagementScreen> createState() =>
      _AdminOrderManagementScreenState();
}

class _AdminOrderManagementScreenState
    extends State<AdminOrderManagementScreen> {
  String _selectedStatus = 'All';
  String _searchQuery = '';

  final mockOrders = [
    {
      'id': 'ORD-001',
      'customer': 'Ahmad Khan',
      'farmer': 'Farm Fresh Ltd',
      'amount': '৳2,450',
      'status': 'Delivered',
      'paymentStatus': 'Paid',
      'date': 'Mar 18'
    },
    {
      'id': 'ORD-002',
      'customer': 'Fatima Ali',
      'farmer': 'Green Valley',
      'amount': '৳5,680',
      'status': 'Shipped',
      'paymentStatus': 'Paid',
      'date': 'Mar 17'
    },
    {
      'id': 'ORD-003',
      'customer': 'Hassan Ahmed',
      'farmer': 'Organic Farm',
      'amount': '৳1,200',
      'status': 'Pending',
      'paymentStatus': 'Pending',
      'date': 'Mar 19'
    },
    {
      'id': 'ORD-004',
      'customer': 'Rina Das',
      'farmer': 'Urban Garden',
      'amount': '৳3,900',
      'status': 'Disputed',
      'paymentStatus': 'Refunded',
      'date': 'Mar 16'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('Order Management'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary cards
              _buildSummaryRow(),
              const SizedBox(height: 24),

              // Search and filter
              _buildSearchAndFilter(),
              const SizedBox(height: 24),

              // Orders table
              _buildOrdersTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
              'Total Orders', '45,231', Icons.shopping_bag, Colors.blue),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
              "Today's Orders", '234', Icons.today, Colors.green),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
              'Pending Actions', '45', Icons.schedule, Colors.orange),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard('Disputed', '23', Icons.warning, Colors.red),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Colors.white70)),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search by order ID or customer...',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        const SizedBox(width: 12),
        PopupMenuButton<String>(
          onSelected: (value) => setState(() => _selectedStatus = value),
          itemBuilder: (context) => [
            'All',
            'Pending',
            'Confirmed',
            'Shipped',
            'Delivered',
            'Cancelled',
            'Disputed'
          ]
              .map(
                  (status) => PopupMenuItem(value: status, child: Text(status)))
              .toList(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text('Status: $_selectedStatus',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12)),
                const Icon(Icons.arrow_drop_down, color: Colors.white54),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersTable() {
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
            DataColumn(label: Text('Order ID')),
            DataColumn(label: Text('Customer')),
            DataColumn(label: Text('Farmer')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Payment')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Actions')),
          ],
          rows: mockOrders
              .map((order) => DataRow(cells: [
                    DataCell(Text(order['id'] as String,
                        style: const TextStyle(color: Colors.white70))),
                    DataCell(Text(order['customer'] as String,
                        style: const TextStyle(color: Colors.white70))),
                    DataCell(Text(order['farmer'] as String,
                        style: const TextStyle(color: Colors.white70))),
                    DataCell(Text(order['amount'] as String,
                        style: const TextStyle(color: Colors.white))),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order['status'] as String)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        order['status'] as String,
                        style: TextStyle(
                          color: _getStatusColor(order['status'] as String),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (order['paymentStatus'] == 'Paid'
                                ? Colors.green
                                : Colors.orange)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        order['paymentStatus'] as String,
                        style: TextStyle(
                          color: order['paymentStatus'] == 'Paid'
                              ? Colors.green
                              : Colors.orange,
                          fontSize: 11,
                        ),
                      ),
                    )),
                    DataCell(Text(order['date'] as String,
                        style: const TextStyle(color: Colors.white70))),
                    DataCell(PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(child: Text('View Details')),
                        const PopupMenuItem(child: Text('Update Status')),
                        const PopupMenuItem(child: Text('Refund')),
                      ],
                      child: const Icon(Icons.more_vert,
                          color: Colors.white54, size: 18),
                    )),
                  ]))
              .toList(),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivered':
        return Colors.green;
      case 'Shipped':
        return Colors.blue;
      case 'Confirmed':
        return Colors.orange;
      case 'Disputed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
