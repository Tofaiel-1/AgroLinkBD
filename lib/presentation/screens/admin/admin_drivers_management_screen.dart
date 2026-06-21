import 'package:flutter/material.dart';

/// Drivers & Trip Management Screen
/// Features: Real-time driver map, driver list, performance metrics
class AdminDriversManagementScreen extends StatefulWidget {
  const AdminDriversManagementScreen({super.key});

  @override
  State<AdminDriversManagementScreen> createState() =>
      _AdminDriversManagementScreenState();
}

class _AdminDriversManagementScreenState
    extends State<AdminDriversManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final mockDrivers = [
    {
      'name': 'Karim Ahmed',
      'rating': 4.8,
      'vehicle': 'Pickup Truck',
      'status': 'Online',
      'tripsToday': 12,
      'earnings': '৳3,240',
      'onTimeRate': '95%',
    },
    {
      'name': 'Hassan Khan',
      'rating': 4.5,
      'vehicle': 'Refrigerated Van',
      'status': 'Busy',
      'tripsToday': 8,
      'earnings': '৳2,560',
      'onTimeRate': '89%',
    },
    {
      'name': 'Ali Hossain',
      'rating': 4.2,
      'vehicle': 'Motorcycle',
      'status': 'Online',
      'tripsToday': 15,
      'earnings': '৳2,890',
      'onTimeRate': '92%',
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
        title: const Text('Driver & Trip Management'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Driver Map'),
            Tab(text: 'Drivers List'),
            Tab(text: 'Active Trips'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMapTab(),
          _buildDriversListTab(),
          _buildActiveTripsTab(),
        ],
      ),
    );
  }

  Widget _buildMapTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              height: 400,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Icons.location_on, color: Colors.white38, size: 64),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Live Driver Status',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: Colors.white70)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(4))),
                            const SizedBox(width: 6),
                            const Text('12 Online',
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(width: 16),
                            Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(4))),
                            const SizedBox(width: 6),
                            const Text('5 Busy',
                                style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(width: 16),
                            Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(4))),
                            const SizedBox(width: 6),
                            const Text('3 Offline',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white54),
                      onPressed: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriversListTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mockDrivers.length,
              itemBuilder: (context, index) {
                final driver = mockDrivers[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(driver['name'] as String,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.star,
                                          color: Colors.amber, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                          '${driver['rating']} • ${driver['vehicle']}',
                                          style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: driver['status'] == 'Online'
                                    ? Colors.green.withOpacity(0.2)
                                    : driver['status'] == 'Busy'
                                        ? Colors.orange.withOpacity(0.2)
                                        : Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                driver['status'] as String,
                                style: TextStyle(
                                  color: driver['status'] == 'Online'
                                      ? Colors.green
                                      : driver['status'] == 'Busy'
                                          ? Colors.orange
                                          : Colors.grey,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _buildMetricTile(
                                  'Trips', driver['tripsToday'] as String),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildMetricTile(
                                  'Earnings', driver['earnings'] as String),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildMetricTile(
                                  'On-time', driver['onTimeRate'] as String),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                                child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue),
                                    child: const Text('View Profile'))),
                            const SizedBox(width: 8),
                            Expanded(
                                child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange),
                                    child: const Text('Assign Trip'))),
                            const SizedBox(width: 8),
                            IconButton(
                                icon: const Icon(Icons.more_vert,
                                    color: Colors.white54),
                                onPressed: () {}),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 10)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildActiveTripsTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Active Trips (3)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Trip #${1001 + index}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('In Transit',
                                style: TextStyle(
                                    color: Colors.blue, fontSize: 10)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('Driver: Karim Ahmed • Vehicle: Truck-001',
                          style:
                              TextStyle(color: Colors.white54, fontSize: 11)),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 0.65,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor:
                              const AlwaysStoppedAnimation(Colors.green),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('8 km / 12 km remaining • ETA: 25 min',
                          style:
                              TextStyle(color: Colors.white54, fontSize: 10)),
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
}
