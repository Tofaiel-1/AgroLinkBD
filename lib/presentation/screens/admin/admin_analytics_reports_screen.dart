import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Analytics & Reports Screen
/// Features: Business intelligence, KPI tracking, custom reports
class AdminAnalyticsReportsScreen extends StatefulWidget {
  const AdminAnalyticsReportsScreen({super.key});

  @override
  State<AdminAnalyticsReportsScreen> createState() =>
      _AdminAnalyticsReportsScreenState();
}

class _AdminAnalyticsReportsScreenState
    extends State<AdminAnalyticsReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'Last 30 days';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
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
        title: const Text('Analytics & Reports'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Users'),
            Tab(text: 'Financial'),
            Tab(text: 'Products'),
            Tab(text: 'Performance'),
            Tab(text: 'Reports'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildUsersTab(),
          _buildFinancialTab(),
          _buildProductsTab(),
          _buildPerformanceTab(),
          _buildReportsTab(),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        PopupMenuButton<String>(
          onSelected: (value) => setState(() => _selectedPeriod = value),
          itemBuilder: (context) => [
            'Today',
            'Yesterday',
            'Last 7 days',
            'Last 30 days',
            'Last Quarter',
            'Custom'
          ]
              .map(
                  (period) => PopupMenuItem(value: period, child: Text(period)))
              .toList(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today,
                    color: Colors.white54, size: 16),
                const SizedBox(width: 8),
                Text(_selectedPeriod,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.download, color: Colors.white54),
              onPressed: () {},
              tooltip: 'Export as PDF',
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white54),
              onPressed: () {},
              tooltip: 'Refresh data',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateRangeSelector(),
            const SizedBox(height: 24),

            // KPI Cards
            Row(
              children: [
                Expanded(
                    child:
                        _buildKpiCard('Revenue', '৳3.2M', '+18%', Colors.blue)),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildKpiCard(
                        'Orders', '45,231', '+23%', Colors.green)),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildKpiCard(
                        'Users', '12,847', '+12%', Colors.purple)),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildKpiCard(
                        'Conversion', '3.2%', '+0.5%', Colors.orange)),
              ],
            ),
            const SizedBox(height: 24),

            // Revenue trend chart
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
                  const Text('Revenue Trend',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 250,
                    child: LineChart(LineChartData(
                      gridData: const FlGridData(show: true, drawVerticalLine: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) => Text(
                                    '৳${(value / 1000).toInt()}k',
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 10)))),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(
                              7,
                              (i) => FlSpot(
                                  i.toDouble(), 200 + (i * 50).toDouble())),
                          isCurved: true,
                          gradient: const LinearGradient(
                              colors: [Color(0xFF059669), Color(0xFF10B981)]),
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                        ),
                      ],
                    )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateRangeSelector(),
            const SizedBox(height: 24),
            const Text('User Growth by Role',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SizedBox(
                height: 250,
                child: BarChart(BarChartData(
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Text(
                                '${(value / 1000).toInt()}k',
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 10)))),
                  ),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [
                      BarChartRodData(toY: 8, color: const Color(0xFF059669))
                    ]),
                    BarChartGroupData(
                        x: 1,
                        barRods: [BarChartRodData(toY: 5, color: Colors.blue)]),
                    BarChartGroupData(x: 2, barRods: [
                      BarChartRodData(toY: 3, color: Colors.orange)
                    ]),
                    BarChartGroupData(x: 3, barRods: [
                      BarChartRodData(toY: 4, color: Colors.purple)
                    ]),
                  ],
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateRangeSelector(),
            const SizedBox(height: 24),
            const Text('Revenue Breakdown',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SizedBox(
                height: 250,
                child: PieChart(PieChartData(sections: [
                  PieChartSectionData(
                      value: 40, color: const Color(0xFF059669), title: '40%'),
                  PieChartSectionData(
                      value: 30, color: Colors.blue, title: '30%'),
                  PieChartSectionData(
                      value: 20, color: Colors.orange, title: '20%'),
                  PieChartSectionData(
                      value: 10, color: Colors.red, title: '10%'),
                ])),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Payment Methods',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...[
              {'method': 'Cash on Delivery', 'percentage': 45},
              {'method': 'Wallet', 'percentage': 30},
              {'method': 'Card', 'percentage': 15},
              {'method': 'bKash', 'percentage': 10},
            ].map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(item['method'] as String,
                            style: const TextStyle(color: Colors.white70)),
                      ),
                      Expanded(
                        flex: 2,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (item['percentage'] as int) / 100,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            valueColor:
                                const AlwaysStoppedAnimation(Color(0xFF059669)),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${item['percentage']}%',
                          style: const TextStyle(color: Colors.white54)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateRangeSelector(),
            const SizedBox(height: 24),
            const Text('Top Selling Products',
                style: TextStyle(
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
                    DataColumn(label: Text('Product')),
                    DataColumn(label: Text('Qty Sold')),
                    DataColumn(label: Text('Revenue')),
                    DataColumn(label: Text('Rating')),
                  ],
                  rows: const [
                    DataRow(cells: [
                      DataCell(Text('Fresh Tomatoes',
                          style: TextStyle(color: Colors.white70))),
                      DataCell(Text('1,234',
                          style: TextStyle(color: Colors.white70))),
                      DataCell(Text('৳45,690',
                          style: TextStyle(color: Colors.green))),
                      DataCell(Row(children: [
                        Icon(Icons.star, color: Colors.amber, size: 12),
                        SizedBox(width: 2),
                        Text('4.8',
                            style: TextStyle(color: Colors.white70))
                      ])),
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

  Widget _buildPerformanceTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateRangeSelector(),
            const SizedBox(height: 24),
            const Text('Farmer Performance Leaderboard',
                style: TextStyle(
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
                    DataColumn(label: Text('Rank')),
                    DataColumn(label: Text('Farmer')),
                    DataColumn(label: Text('Sales')),
                    DataColumn(label: Text('Rating')),
                    DataColumn(label: Text('Response Time')),
                  ],
                  rows: List.generate(
                    5,
                    (index) => DataRow(cells: [
                      DataCell(Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: index == 0
                              ? Colors.amber.withOpacity(0.2)
                              : index == 1
                                  ? Colors.grey.withOpacity(0.2)
                                  : index == 2
                                      ? Colors.orange.withOpacity(0.2)
                                      : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text('${index + 1}',
                              style: TextStyle(
                                  color: index == 0
                                      ? Colors.amber
                                      : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10)),
                        ),
                      )),
                      DataCell(Text('Farm ${index + 1}',
                          style: const TextStyle(color: Colors.white70))),
                      DataCell(Text('৳${(50000 - index * 5000)}',
                          style: const TextStyle(color: Colors.white70))),
                      DataCell(Row(children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 2),
                        Text('${4.8 - (index * 0.1)}',
                            style: const TextStyle(color: Colors.white70))
                      ])),
                      DataCell(Text('${2 + index}h',
                          style: const TextStyle(color: Colors.white70))),
                    ]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('New Report'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669)),
            ),
            const SizedBox(height: 24),
            const Text('Saved Reports',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.description, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                [
                                  'Monthly Revenue Report',
                                  'User Activity Report',
                                  'Compliance Report'
                                ][index],
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                            const Text('Generated: Mar 19, 2024',
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 11)),
                          ],
                        ),
                      ),
                      IconButton(
                          icon: const Icon(Icons.download,
                              color: Colors.white54, size: 18),
                          onPressed: () {}),
                      IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.red, size: 18),
                          onPressed: () {}),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, String trend, Color color) {
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
                  color: color, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(trend,
              style: const TextStyle(
                  color: Colors.green,
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
