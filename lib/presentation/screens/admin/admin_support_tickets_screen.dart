import 'package:flutter/material.dart';

/// Support Ticket System
/// Features: Kanban board, ticket management, customer support
class AdminSupportTicketScreen extends StatefulWidget {
  const AdminSupportTicketScreen({super.key});

  @override
  State<AdminSupportTicketScreen> createState() =>
      _AdminSupportTicketScreenState();
}

class _AdminSupportTicketScreenState extends State<AdminSupportTicketScreen> {
  String _selectedFilter = 'All';

  final mockTickets = {
    'new': [
      {
        'id': 'TKT-001',
        'customer': 'Ahmad Khan',
        'subject': 'Order not received',
        'priority': 'High',
        'created': '10 min ago'
      },
      {
        'id': 'TKT-002',
        'customer': 'Fatima Ali',
        'subject': 'Payment failed',
        'priority': 'High',
        'created': '25 min ago'
      },
    ],
    'inProgress': [
      {
        'id': 'TKT-003',
        'customer': 'Hassan Ahmed',
        'subject': 'Refund issue',
        'priority': 'Medium',
        'created': '2 hours ago'
      },
    ],
    'escalated': [
      {
        'id': 'TKT-004',
        'customer': 'Rina Das',
        'subject': 'Account hacked',
        'priority': 'Critical',
        'created': '3 hours ago'
      },
    ],
    'resolved': [
      {
        'id': 'TKT-005',
        'customer': 'Ali Khan',
        'subject': 'Password reset',
        'priority': 'Low',
        'created': '1 day ago'
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('Support Tickets'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard cards
              _buildDashboardCards(),
              const SizedBox(height: 24),

              // Filter
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'High Priority', 'Overdue', 'Unassigned']
                      .map((filter) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(filter),
                              selected: _selectedFilter == filter,
                              onSelected: (selected) =>
                                  setState(() => _selectedFilter = filter),
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Kanban board
              if (!isMobile)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildKanbanColumn('new', 'New', Colors.blue),
                      const SizedBox(width: 16),
                      _buildKanbanColumn(
                          'inProgress', 'In Progress', Colors.orange),
                      const SizedBox(width: 16),
                      _buildKanbanColumn('escalated', 'Escalated', Colors.red),
                      const SizedBox(width: 16),
                      _buildKanbanColumn('resolved', 'Resolved', Colors.green),
                    ],
                  ),
                )
              else
                _buildMobileTicketList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCards() {
    return Row(
      children: [
        Expanded(
          child:
              _buildKpiCard('Open Tickets', '45', Colors.blue, '12 critical'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              _buildKpiCard('Response Time', '2.4h', Colors.green, 'Average'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildKpiCard(
              'Resolution Rate', '78%', Colors.orange, 'This month'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              _buildKpiCard('Satisfaction', '4.2/5', Colors.purple, 'Rating'),
        ),
      ],
    );
  }

  Widget _buildKpiCard(
      String title, String value, Color color, String subtitle) {
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
          const SizedBox(height: 4),
          Text(subtitle,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildKanbanColumn(String status, String title, Color color) {
    final tickets = mockTickets[status] ?? [];

    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              border: Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style:
                        TextStyle(color: color, fontWeight: FontWeight.bold)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10)),
                  child: Text('${tickets.length}',
                      style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tickets.length,
            itemBuilder: (context, index) => _buildTicketCard(tickets[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(Map ticket) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(ticket['id'],
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: ticket['priority'] == 'Critical' ||
                            ticket['priority'] == 'High'
                        ? Colors.red.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    ticket['priority'],
                    style: TextStyle(
                      color: ticket['priority'] == 'Critical' ||
                              ticket['priority'] == 'High'
                          ? Colors.red
                          : Colors.orange,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(ticket['subject'],
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(ticket['customer'],
                style: const TextStyle(color: Colors.white54, fontSize: 10)),
            const SizedBox(height: 8),
            Text(ticket['created'],
                style: const TextStyle(color: Colors.white38, fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileTicketList() {
    final allTickets = [
      ...mockTickets['new']!,
      ...mockTickets['inProgress']!,
      ...mockTickets['escalated']!,
      ...mockTickets['resolved']!,
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: allTickets.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildTicketCard(allTickets[index]),
      ),
    );
  }
}
