import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Advanced Dashboard with Sidebar Navigation
/// Features: Real-time metrics, activity feed, alerts, quick actions
class AdvancedAdminDashboard extends StatefulWidget {
  const AdvancedAdminDashboard({super.key});

  @override
  State<AdvancedAdminDashboard> createState() => _AdvancedAdminDashboardState();
}

class _AdvancedAdminDashboardState extends State<AdvancedAdminDashboard> {
  bool _sidebarExpanded = true;
  String _selectedDateRange = 'Month';
  int _selectedActivityFilter = 0;

  final dateRanges = ['Today', 'Week', 'Month', 'Custom'];
  final activityFilters = ['All', 'Users', 'Orders', 'Payments', 'System'];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildStatCardsGrid(2),
            const SizedBox(height: 24),
            _buildChartsSection(),
            const SizedBox(height: 24),
            _buildActivityFeed(),
            const SizedBox(height: 24),
            _buildAlertsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        _buildSidebar(),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildStatCardsGrid(6),
                  const SizedBox(height: 32),
                  _buildChartsSection(),
                  const SizedBox(height: 32),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildActivityFeed(),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildAlertsSection(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildQuickActionsGrid(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: _sidebarExpanded ? 260 : 80,
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Logo section
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_sidebarExpanded)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AGROLINKBD',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'Admin v2.0',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Colors.white54,
                                ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF059669), Color(0xFF10B981)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text('A',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _sidebarExpanded = !_sidebarExpanded),
                    child: Icon(
                      _sidebarExpanded
                          ? Icons.chevron_left
                          : Icons.chevron_right,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),

            Divider(color: Colors.white.withOpacity(0.1)),

            // Navigation menu
            _buildSidebarMenu(),

            Divider(color: Colors.white.withOpacity(0.1), height: 32),

            // Footer section
            _buildSidebarFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarMenu() {
    final menuItems = [
      {'icon': Icons.dashboard, 'label': 'Dashboard', 'badge': null},
      {'icon': Icons.people, 'label': 'Users', 'badge': '12'},
      {'icon': Icons.shopping_cart, 'label': 'Products', 'badge': null},
      {'icon': Icons.shopping_bag, 'label': 'Orders', 'badge': '23'},
      {'icon': Icons.wallet, 'label': 'Transactions', 'badge': null},
      {'icon': Icons.local_shipping, 'label': 'Drivers', 'badge': '8'},
      {'icon': Icons.build, 'label': 'Services', 'badge': null},
      {'icon': Icons.layers, 'label': 'Content', 'badge': null},
      {'icon': Icons.analytics, 'label': 'Analytics', 'badge': null},
      {'icon': Icons.headset_mic, 'label': 'Support', 'badge': '5'},
      {'icon': Icons.settings, 'label': 'Settings', 'badge': null},
      {'icon': Icons.description, 'label': 'Logs', 'badge': null},
    ];

    return Column(
      children: menuItems.asMap().entries.map((entry) {
        final isActive = entry.key == 0;
        return _buildMenuItem(
          icon: entry.value['icon'] as IconData,
          label: entry.value['label'] as String,
          badge: entry.value['badge'] as String?,
          isActive: isActive,
        );
      }).toList(),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    String? badge,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF059669).withOpacity(0.2)
              : Colors.transparent,
          border: Border(
              left: BorderSide(
                  color:
                      isActive ? const Color(0xFF059669) : Colors.transparent,
                  width: 3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isActive ? const Color(0xFF059669) : Colors.white54,
                size: 20),
            if (_sidebarExpanded) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Text(label,
                    style: TextStyle(
                        color: isActive
                            ? const Color(0xFF059669)
                            : Colors.white70)),
              ),
              if (badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(badge,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          // User card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF059669), Color(0xFF10B981)]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text('SA',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ),
                ),
                if (_sidebarExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Super Admin',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                        Text('admin@agrolinkbd.com',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: Colors.white54),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Storage usage
          if (_sidebarExpanded) ...[
            Text('Storage Usage',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: Colors.white70)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 0.65,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF059669)),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 4),
            Text('6.5 GB / 10 GB used',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: Colors.white54)),
            const SizedBox(height: 12),
          ],

          // System status
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4)),
                ),
                if (_sidebarExpanded) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('All Systems OK',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: Colors.green)),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Logout button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.2),
                  foregroundColor: Colors.red),
              icon: const Icon(Icons.logout),
              label: _sidebarExpanded ? const Text('Logout') : const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Dashboard / Home',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white54),
            ),
          ],
        ),
        Row(
          children: [
            // Date range selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: _selectedDateRange,
                items: dateRanges
                    .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e,
                            style: const TextStyle(color: Colors.white))))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedDateRange = value ?? 'Month'),
                underline: const SizedBox(),
                style: const TextStyle(color: Colors.white),
                dropdownColor: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(width: 16),
            // Notifications
            IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_outlined,
                      color: Colors.white70),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ],
              ),
              onPressed: () {},
            ),
            IconButton(
                icon:
                    const Icon(Icons.settings_outlined, color: Colors.white70),
                onPressed: () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCardsGrid(int crossAxisCount) {
    final stats = [
      {
        'title': 'Total Users',
        'value': '12,847',
        'trend': '+12%',
        'icon': Icons.people,
        'color': Colors.blue
      },
      {
        'title': 'Total Orders',
        'value': '45,231',
        'trend': '+23%',
        'icon': Icons.shopping_cart,
        'color': Colors.green
      },
      {
        'title': 'Total Revenue',
        'value': '৳3.2M',
        'trend': '+18%',
        'icon': Icons.trending_up,
        'color': Colors.amber
      },
      {
        'title': 'Active Users',
        'value': '3,421',
        'trend': '+5%',
        'icon': Icons.person,
        'color': Colors.green
      },
      {
        'title': 'Pending KYC',
        'value': '127',
        'trend': 'Urgent',
        'icon': Icons.schedule,
        'color': Colors.purple
      },
      {
        'title': 'Disputed Orders',
        'value': '23',
        'trend': '-3%',
        'icon': Icons.warning,
        'color': Colors.red
      },
    ];

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: stats.map((stat) => _buildStatCard(stat)).toList(),
    );
  }

  Widget _buildStatCard(Map stat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(stat['title'],
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.white70)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (stat['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(stat['icon'] as IconData,
                    color: stat['color'] as Color, size: 16),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(stat['value'],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(stat['trend'],
                  style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Revenue Trend',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true, drawVerticalLine: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Text(
                                '৳${(value / 1000).toInt()}k',
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 10)),
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(
                            7,
                            (i) =>
                                FlSpot(i.toDouble(), 200 + (i * 50).toDouble()),
                          ),
                          isCurved: true,
                          gradient: const LinearGradient(
                              colors: [Color(0xFF059669), Color(0xFF10B981)]),
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order Status',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                            value: 35,
                            color: const Color(0xFF059669),
                            title: '35%'),
                        PieChartSectionData(
                            value: 30,
                            color: const Color(0xFF3B82F6),
                            title: '30%'),
                        PieChartSectionData(
                            value: 25,
                            color: const Color(0xFFF59E0B),
                            title: '25%'),
                        PieChartSectionData(
                            value: 10,
                            color: const Color(0xFFEF4444),
                            title: '10%'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityFeed() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Real-time Activity Feed',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text('View All')),
            ],
          ),
          const SizedBox(height: 16),
          // Filter chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: activityFilters.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(activityFilters[index]),
                  selected: _selectedActivityFilter == index,
                  onSelected: (selected) =>
                      setState(() => _selectedActivityFilter = index),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Activity items
          ..._buildActivityItems(),
        ],
      ),
    );
  }

  List<Widget> _buildActivityItems() {
    final activities = [
      {
        'user': 'Ahmad Khan',
        'action': 'placed a new order',
        'time': '2 minutes ago',
        'icon': Icons.shopping_cart,
        'color': Colors.blue
      },
      {
        'user': 'Fatima Ali',
        'action': 'completed KYC verification',
        'time': '15 minutes ago',
        'icon': Icons.verified,
        'color': Colors.green
      },
      {
        'user': 'System',
        'action': 'processed withdrawal request',
        'time': '1 hour ago',
        'icon': Icons.wallet,
        'color': Colors.amber
      },
      {
        'user': 'Hassan Ahmed',
        'action': 'disputed an order',
        'time': '2 hours ago',
        'icon': Icons.warning,
        'color': Colors.red
      },
    ];

    return activities
        .map((activity) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: (activity['color'] as Color).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(activity['icon'] as IconData,
                        color: activity['color'] as Color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                  text: activity['user'] as String,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              TextSpan(
                                  text: ' ${activity['action']}',
                                  style:
                                      const TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ),
                        Text(activity['time'] as String,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: Colors.white54)),
                      ],
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }

  Widget _buildAlertsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Alerts & Warnings',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildAlertItem(
            title: 'Server Load',
            message: 'CPU usage at 85%',
            severity: 'warning',
            icon: Icons.warning,
          ),
          const SizedBox(height: 12),
          _buildAlertItem(
            title: 'Pending KYC',
            message: '127 users awaiting verification',
            severity: 'info',
            icon: Icons.schedule,
          ),
          const SizedBox(height: 12),
          _buildAlertItem(
            title: 'Unusual Activity',
            message: 'Multiple failed logins detected',
            severity: 'error',
            icon: Icons.security,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem({
    required String title,
    required String message,
    required String severity,
    required IconData icon,
  }) {
    final severityColor = severity == 'error'
        ? Colors.red
        : severity == 'warning'
            ? Colors.orange
            : Colors.blue;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: severityColor.withOpacity(0.1),
        border: Border.all(color: severityColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: severityColor, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: severityColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12)),
                Text(message,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.close, color: Colors.white54, size: 16),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    final actions = [
      {'icon': Icons.person_add, 'label': 'Create User', 'color': Colors.blue},
      {
        'icon': Icons.notifications,
        'label': 'Send Notification',
        'color': Colors.green
      },
      {
        'icon': Icons.download,
        'label': 'Export Reports',
        'color': Colors.orange
      },
      {
        'icon': Icons.support_agent,
        'label': 'View Tickets',
        'color': Colors.purple
      },
      {
        'icon': Icons.health_and_safety,
        'label': 'Run Diagnostics',
        'color': Colors.red
      },
      {'icon': Icons.storage, 'label': 'Backup DB', 'color': Colors.teal},
      {
        'icon': Icons.cleaning_services,
        'label': 'Clear Cache',
        'color': Colors.pink
      },
      {
        'icon': Icons.settings_backup_restore,
        'label': 'Maintenance',
        'color': Colors.indigo
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: actions
              .map((action) => _buildQuickActionCard(
                    icon: action['icon'] as IconData,
                    label: action['label'] as String,
                    color: action['color'] as Color,
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
