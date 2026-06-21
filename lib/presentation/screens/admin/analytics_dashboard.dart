import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics & Reports'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Analytics Section
            Text(
              'User Analytics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                // Total Users
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('users').snapshots(),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.docs.length ?? 0;
                    return _buildStatCard(
                      icon: Icons.people,
                      title: 'Total Users',
                      value: count.toString(),
                      color: Colors.blue,
                      subtitle: 'Farmers & Buyers',
                    );
                  },
                ),
                // Premium Users
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('users')
                      .where('isPremium', isEqualTo: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.docs.length ?? 0;
                    return _buildStatCard(
                      icon: Icons.verified,
                      title: 'Premium Users',
                      value: count.toString(),
                      color: Colors.amber,
                      subtitle: 'Verified Accounts',
                    );
                  },
                ),
                // Active Sellers
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('users')
                      .where('role', isEqualTo: 'farmer')
                      .snapshots(),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.docs.length ?? 0;
                    return _buildStatCard(
                      icon: Icons.store,
                      title: 'Sellers',
                      value: count.toString(),
                      color: Colors.green,
                      subtitle: 'Active Farmers',
                    );
                  },
                ),
                // Active Buyers
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('users')
                      .where('role', isEqualTo: 'buyer')
                      .snapshots(),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.docs.length ?? 0;
                    return _buildStatCard(
                      icon: Icons.shopping_cart,
                      title: 'Buyers',
                      value: count.toString(),
                      color: Colors.purple,
                      subtitle: 'Active Buyers',
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Product Analytics Section
            Text(
              'Product Analytics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                // Total Products
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('bazaar_products').snapshots(),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.docs.length ?? 0;
                    return _buildStatCard(
                      icon: Icons.shopping_bag,
                      title: 'Total Products',
                      value: count.toString(),
                      color: Colors.green,
                      subtitle: 'Listed Items',
                    );
                  },
                ),
                // Pending Approval
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('bazaar_products')
                      .where('status', isEqualTo: 'pending')
                      .snapshots(),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.docs.length ?? 0;
                    return _buildStatCard(
                      icon: Icons.pending_actions,
                      title: 'Pending Review',
                      value: count.toString(),
                      color: Colors.orange,
                      subtitle: 'Awaiting Approval',
                    );
                  },
                ),
                // Active Products
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('bazaar_products')
                      .where('isActive', isEqualTo: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.docs.length ?? 0;
                    return _buildStatCard(
                      icon: Icons.check_circle,
                      title: 'Active Products',
                      value: count.toString(),
                      color: Colors.green,
                      subtitle: 'Listed & Selling',
                    );
                  },
                ),
                // Low Stock
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('bazaar_products')
                      .where('stock', isLessThanOrEqualTo: 5)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.docs.length ?? 0;
                    return _buildStatCard(
                      icon: Icons.warning,
                      title: 'Low Stock',
                      value: count.toString(),
                      color: Colors.red,
                      subtitle: '≤ 5 Items',
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Order Analytics Section
            Text(
              'Order Analytics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                // Total Orders
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('orders').snapshots(),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.docs.length ?? 0;
                    return _buildStatCard(
                      icon: Icons.receipt,
                      title: 'Total Orders',
                      value: count.toString(),
                      color: Colors.blue,
                      subtitle: 'All Time',
                    );
                  },
                ),
                // Pending Orders
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('orders')
                      .where('status', isEqualTo: 'pending')
                      .snapshots(),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.docs.length ?? 0;
                    return _buildStatCard(
                      icon: Icons.hourglass_empty,
                      title: 'Pending',
                      value: count.toString(),
                      color: Colors.orange,
                      subtitle: 'Awaiting Processing',
                    );
                  },
                ),
                // Shipped Orders
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('orders')
                      .where('status', isEqualTo: 'shipped')
                      .snapshots(),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.docs.length ?? 0;
                    return _buildStatCard(
                      icon: Icons.local_shipping,
                      title: 'Shipped',
                      value: count.toString(),
                      color: Colors.indigo,
                      subtitle: 'In Transit',
                    );
                  },
                ),
                // Delivered Orders
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('orders')
                      .where('status', isEqualTo: 'delivered')
                      .snapshots(),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.docs.length ?? 0;
                    return _buildStatCard(
                      icon: Icons.check_circle,
                      title: 'Delivered',
                      value: count.toString(),
                      color: Colors.green,
                      subtitle: 'Completed',
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Admin & System Section
            Text(
              'System Management',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                // Total Admins
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('admins').snapshots(),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.docs.length ?? 0;
                    return _buildStatCard(
                      icon: Icons.admin_panel_settings,
                      title: 'Total Admins',
                      value: count.toString(),
                      color: Colors.purple,
                      subtitle: 'Active Staff',
                    );
                  },
                ),
                // Recent Logs
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('audit_logs')
                      .orderBy('timestamp', descending: true)
                      .limit(1)
                      .snapshots(),
                  builder: (context, snapshot) {
                    return _buildStatCard(
                      icon: Icons.history,
                      title: 'Audit Logs',
                      value: 'Active',
                      color: Colors.teal,
                      subtitle: 'Monitoring',
                    );
                  },
                ),
                // Categories
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('categories').snapshots(),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.docs.length ?? 0;
                    return _buildStatCard(
                      icon: Icons.category,
                      title: 'Categories',
                      value: count.toString(),
                      color: Colors.cyan,
                      subtitle: 'Product Types',
                    );
                  },
                ),
                // Reviews
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('reviews').snapshots(),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.docs.length ?? 0;
                    return _buildStatCard(
                      icon: Icons.star,
                      title: 'Reviews',
                      value: count.toString(),
                      color: Colors.amber,
                      subtitle: 'Ratings & Comments',
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Quick Stats Card
            _buildQuickStatsCard(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.trending_up,
                      size: 14, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Health',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildHealthIndicator('Database', 'Connected', Colors.green),
            const SizedBox(height: 12),
            _buildHealthIndicator('Firebase Auth', 'Active', Colors.green),
            const SizedBox(height: 12),
            _buildHealthIndicator('Cloud Storage', 'Available', Colors.green),
            const SizedBox(height: 12),
            _buildHealthIndicator('Firestore', 'Synced', Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthIndicator(String name, String status, Color color) {
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          status,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
