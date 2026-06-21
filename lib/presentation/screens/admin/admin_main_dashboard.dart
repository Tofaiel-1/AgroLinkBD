import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Enterprise-grade Main Admin Dashboard
/// Modern SaaS design inspired by Vercel, Stripe, Linear
class AdminMainDashboard extends StatefulWidget {
  const AdminMainDashboard({super.key});

  @override
  State<AdminMainDashboard> createState() => _AdminMainDashboardState();
}

class _AdminMainDashboardState extends State<AdminMainDashboard> {
  int _selectedTimeRange = 0; // 0: 24h, 1: 7d, 2: 30d, 3: 90d
  int _activeTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with time range selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Welcome back, Super Admin',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white54,
                            ),
                      ),
                    ],
                  ),
                  _buildTimeRangeSelector(),
                ],
              ),

              const SizedBox(height: 32),

              // Key metrics grid
              _buildKeyMetricsGrid(isMobile),

              const SizedBox(height: 32),

              // Charts section
              Row(
                children: [
                  Text(
                    'Analytics',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              if (!isMobile)
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildRevenueChart(),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 1,
                      child: _buildUserDistributionChart(),
                    ),
                  ],
                )
              else ...[
                _buildRevenueChart(),
                const SizedBox(height: 24),
                _buildUserDistributionChart(),
              ],

              const SizedBox(height: 32),

              // Tables section
              _buildOrdersTable(isMobile),

              const SizedBox(height: 32),

              _buildUsersTable(isMobile),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      drawer: !isMobile ? null : _buildMobileDrawer(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0F172A),
      elevation: 0,
      title: Text(
        'AGROLINKBD Admin',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white70),
          onPressed: () => _showNotifications(),
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white70),
          onPressed: () => _showSettings(),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF059669), Color(0xFF10B981)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                'SA',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTimeRangeSelector() {
    final ranges = ['24h', '7d', '30d', '90d'];
    return Row(
      children: List.generate(
        ranges.length,
        (index) => Padding(
          padding: const EdgeInsets.only(left: 8),
          child: GestureDetector(
            onTap: () => setState(() => _selectedTimeRange = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _selectedTimeRange == index
                    ? const Color(0xFF059669)
                    : Colors.white.withOpacity(0.05),
                border: Border.all(
                  color: _selectedTimeRange == index
                      ? const Color(0xFF059669)
                      : Colors.white.withOpacity(0.1),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                ranges[index],
                style: TextStyle(
                  color: _selectedTimeRange == index
                      ? Colors.white
                      : Colors.white70,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyMetricsGrid(bool isMobile) {
    final metrics = [
      {
        'title': 'Total Revenue',
        'value': '\$2.5M',
        'change': '+12.5%',
        'icon': Icons.trending_up,
        'color': Colors.green,
      },
      {
        'title': 'Active Users',
        'value': '5.2K',
        'change': '+8.3%',
        'icon': Icons.people,
        'color': Colors.blue,
      },
      {
        'title': 'Orders',
        'value': '12.5K',
        'change': '+23.1%',
        'icon': Icons.shopping_cart,
        'color': Colors.orange,
      },
      {
        'title': 'Conversion Rate',
        'value': '3.2%',
        'change': '+0.5%',
        'icon': Icons.percent,
        'color': Colors.purple,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) => _buildMetricCard(
        title: metrics[index]['title'] as String,
        value: metrics[index]['value'] as String,
        change: metrics[index]['change'] as String,
        icon: metrics[index]['icon'] as IconData,
        color: metrics[index]['color'] as Color,
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String change,
    required IconData icon,
    required Color color,
  }) {
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
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                change,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
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
          Text(
            'Revenue Trend',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Text(
                        '\$${(value / 1000).toInt()}k',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun'
                        ];
                        return Text(
                          days[value.toInt() % 7],
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 250),
                      const FlSpot(1, 320),
                      const FlSpot(2, 280),
                      const FlSpot(3, 450),
                      const FlSpot(4, 380),
                      const FlSpot(5, 520),
                      const FlSpot(6, 480),
                    ],
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF059669), Color(0xFF10B981)],
                    ),
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF059669).withOpacity(0.3),
                          const Color(0xFF059669).withOpacity(0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDistributionChart() {
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
          Text(
            'User Distribution',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: 40,
                    color: const Color(0xFF059669),
                    title: 'Farmers\n40%',
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                  PieChartSectionData(
                    value: 35,
                    color: const Color(0xFF3B82F6),
                    title: 'Buyers\n35%',
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                  PieChartSectionData(
                    value: 25,
                    color: const Color(0xFFF59E0B),
                    title: 'Sellers\n25%',
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTable(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Orders',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.1)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Order ID')),
                DataColumn(label: Text('Customer')),
                DataColumn(label: Text('Amount')),
                DataColumn(label: Text('Status')),
              ],
              rows: [
                _buildDataRow('ORD-001', 'John Farmer', '\$245.00', 'Completed',
                    Colors.green),
                _buildDataRow('ORD-002', 'Ahmed Seller', '\$890.50',
                    'Processing', Colors.orange),
                _buildDataRow('ORD-003', 'Rina Buyer', '\$125.75', 'Pending',
                    Colors.yellow),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTable(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Active Users',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.1)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('User ID')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Role')),
                DataColumn(label: Text('Joined')),
              ],
              rows: [
                _buildDataRow('USR-001', 'Ahmad Khan', 'Farmer', 'Jan 15, 2026',
                    Colors.green),
                _buildDataRow('USR-002', 'Fatima Ali', 'Buyer', 'Feb 20, 2026',
                    Colors.blue),
                _buildDataRow('USR-003', 'Hassan Ahmed', 'Seller',
                    'Mar 10, 2026', Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(
      String col1, String col2, String col3, String col4, Color color) {
    return DataRow(
      cells: [
        DataCell(Text(col1, style: const TextStyle(color: Colors.white70))),
        DataCell(Text(col2, style: const TextStyle(color: Colors.white70))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              col3,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        DataCell(Text(col4, style: const TextStyle(color: Colors.white70))),
      ],
    );
  }

  Widget _buildMobileDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF1F2937),
      child: ListView(
        children: [
          const DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'AGROLINKBD',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Super Admin Panel',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text('Dashboard',
                style: TextStyle(color: Colors.white70)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            title: const Text('Users', style: TextStyle(color: Colors.white70)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            title:
                const Text('Orders', style: TextStyle(color: Colors.white70)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            title:
                const Text('Reports', style: TextStyle(color: Colors.white70)),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You have 3 new notifications')),
    );
  }

  void _showSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings panel coming soon')),
    );
  }
}
