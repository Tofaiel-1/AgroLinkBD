import 'package:flutter/material.dart';

/// Admin Logs & Audit Screen
/// Features: Real-time log stream, audit trail, compliance reporting
class AdminLogsAuditScreen extends StatefulWidget {
  const AdminLogsAuditScreen({super.key});

  @override
  State<AdminLogsAuditScreen> createState() => _AdminLogsAuditScreenState();
}

class _AdminLogsAuditScreenState extends State<AdminLogsAuditScreen> {
  String _selectedAdmin = 'All';
  String _selectedAction = 'All';
  String _selectedStatus = 'All';

  final mockLogs = [
    {
      'timestamp': '2024-03-19 14:32:15',
      'admin': 'Super Admin',
      'action': 'User Created',
      'target': 'USR-12847',
      'ip': '192.168.1.100',
      'status': 'Success',
    },
    {
      'timestamp': '2024-03-19 14:28:42',
      'admin': 'Content Manager',
      'action': 'Banner Updated',
      'target': 'BNR-003',
      'ip': '192.168.1.101',
      'status': 'Success',
    },
    {
      'timestamp': '2024-03-19 14:20:33',
      'admin': 'Super Admin',
      'action': 'Order Refunded',
      'target': 'ORD-45231',
      'ip': '192.168.1.100',
      'status': 'Success',
    },
    {
      'timestamp': '2024-03-19 14:15:12',
      'admin': 'Support Manager',
      'action': 'User Suspended',
      'target': 'USR-12845',
      'ip': '192.168.1.102',
      'status': 'Failed',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('Logs & Audit'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary cards
              _buildAuditDashboard(),
              const SizedBox(height: 24),

              // Filters
              _buildFiltersRow(),
              const SizedBox(height: 24),

              // Logs table
              _buildLogsTable(),
              const SizedBox(height: 24),

              // Compliance section
              _buildComplianceSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuditDashboard() {
    return Row(
      children: [
        Expanded(
          child: _buildAuditCard('Total Logs', '1,234', Colors.blue),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildAuditCard('Active Admins', '8', Colors.green),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildAuditCard('Failed Actions', '12', Colors.red),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildAuditCard('Suspicious Activity', '3', Colors.orange),
        ),
      ],
    );
  }

  Widget _buildAuditCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
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
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFiltersRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search logs...',
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        PopupMenuButton<String>(
          onSelected: (value) => setState(() => _selectedAdmin = value),
          itemBuilder: (context) => [
            'All',
            'Super Admin',
            'Content Manager',
            'Support Manager'
          ]
              .map((admin) => PopupMenuItem(value: admin, child: Text(admin)))
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
                Text('Admin: $_selectedAdmin',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 11)),
                const Icon(Icons.arrow_drop_down, color: Colors.white54),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        PopupMenuButton<String>(
          onSelected: (value) => setState(() => _selectedStatus = value),
          itemBuilder: (context) => ['All', 'Success', 'Failed']
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
                        const TextStyle(color: Colors.white70, fontSize: 11)),
                const Icon(Icons.arrow_drop_down, color: Colors.white54),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogsTable() {
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
            DataColumn(label: Text('Timestamp')),
            DataColumn(label: Text('Admin')),
            DataColumn(label: Text('Action')),
            DataColumn(label: Text('Target')),
            DataColumn(label: Text('IP Address')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Details')),
          ],
          rows: mockLogs
              .map((log) => DataRow(cells: [
                    DataCell(Text(log['timestamp'] as String,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11))),
                    DataCell(Text(log['admin'] as String,
                        style: const TextStyle(color: Colors.white70))),
                    DataCell(Text(log['action'] as String,
                        style: const TextStyle(color: Colors.white70))),
                    DataCell(Text(log['target'] as String,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold))),
                    DataCell(Text(log['ip'] as String,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 10))),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: log['status'] == 'Success'
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        log['status'] as String,
                        style: TextStyle(
                          color: log['status'] == 'Success'
                              ? Colors.green
                              : Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )),
                    DataCell(IconButton(
                      icon: const Icon(Icons.expand,
                          color: Colors.white54, size: 18),
                      onPressed: () {},
                    )),
                  ]))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildComplianceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Compliance & Alerts',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildAlertItem(
          'Multiple Failed Logins',
          'Same IP (192.168.1.50) detected 5 failed attempts in last 30 minutes',
          Colors.red,
        ),
        const SizedBox(height: 12),
        _buildAlertItem(
          'Bulk User Deletion',
          'Super Admin deleted 15 users on 2024-03-19 13:20',
          Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildAlertItem(
          'SOC2 Report Ready',
          'Generate compliance report for the selected period',
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildAlertItem(String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            color == Colors.red
                ? Icons.error
                : color == Colors.orange
                    ? Icons.warning
                    : Icons.check_circle,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 12)),
                const SizedBox(height: 2),
                Text(description,
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
          if (color == Colors.green)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
              child: const Text('Generate', style: TextStyle(fontSize: 10)),
            ),
        ],
      ),
    );
  }
}
