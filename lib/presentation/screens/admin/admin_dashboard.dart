import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:agrolinkbd/core/providers/admin_provider.dart';
import 'package:agrolinkbd/presentation/widgets/admin_search_filter_widget.dart';
import 'admin_edit_user.dart';
import 'admin_edit_product.dart';
import 'admin_financial_requests_screen.dart';
import 'admin_transaction_analytics_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  String _userSearchQuery = '';
  String _productSearchQuery = '';
  String? _productCategoryFilter;

  @override
  void initState() {
    super.initState();
    // Load all admins on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).loadAllAdmins();
      _verifySystemStatus();
    });
  }

  /// Verify system status (Firebase, Admin setup, etc.)
  Future<void> _verifySystemStatus() async {
    debugPrint('🔍 Verifying system status...');
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    // Verify admin setup
    final verification = await adminProvider.verifyAdminSetup();
    if (verification['status'] == 'ok') {
      debugPrint('✅ Admin setup verified successfully');
    } else {
      debugPrint(
          '❌ Admin setup verification failed: ${verification['message']}');
    }

    // Get admin info
    final info = adminProvider.getAdminInfo();
    debugPrint('👤 Logged in as: ${info['name']} (${info['role']})');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Admin Dashboard'),
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    '${adminProvider.currentAdmin?.name ?? 'Admin'} (${adminProvider.currentAdmin?.role ?? 'admin'})',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Text('Logout'),
                    onTap: () async {
                      await adminProvider.adminSignOut();
                      if (mounted) {
                        Navigator.of(context)
                            .pushReplacementNamed('/admin-login');
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          body: _buildBody(),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            type: BottomNavigationBarType.shifting,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: 'Users',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag),
                label: 'Bazaar',
              ),
              if (adminProvider.isSuperAdmin) ...[
                const BottomNavigationBarItem(
                  icon: Icon(Icons.admin_panel_settings),
                  label: 'Admins',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: 'Logs',
                ),
              ],
              const BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    final adminProvider = Provider.of<AdminProvider>(context);

    if (!adminProvider.isSuperAdmin) {
      // Regular admin - show limited tabs
      return _buildBodyForRegularAdmin();
    }

    // Super admin - show all tabs
    switch (_selectedIndex) {
      case 0:
        return _buildOverviewDashboard();
      case 1:
        return _buildManageUsers();
      case 2:
        return _buildBazaarManagement();
      case 3:
        return const AdminManagement();
      case 4:
        return _buildActivityLogs();
      case 5:
        return _buildSettings();
      default:
        return _buildOverviewDashboard();
    }
  }

  Widget _buildBodyForRegularAdmin() {
    switch (_selectedIndex) {
      case 0:
        return _buildOverviewDashboard();
      case 1:
        return _buildManageUsers();
      case 2:
        return _buildBazaarManagement();
      case 3:
        return _buildSettings();
      default:
        return _buildOverviewDashboard();
    }
  }

  Widget _buildOverviewDashboard() {
    final adminProvider = Provider.of<AdminProvider>(context);
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  adminProvider.currentAdmin?.name ?? 'Admin',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Role: ${adminProvider.currentAdmin?.role.toUpperCase() ?? 'ADMIN'}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // System Statistics
          Text(
            'System Statistics',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                stream: firestore.collection('users').snapshots(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.docs.length ?? 0;
                  return _buildStatCard(
                    icon: Icons.people,
                    title: 'Total Users',
                    value: count.toString(),
                    color: Colors.blue,
                  );
                },
              ),
              // Total Products
              StreamBuilder<QuerySnapshot>(
                stream: firestore.collection('bazaar_products').snapshots(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.docs.length ?? 0;
                  return _buildStatCard(
                    icon: Icons.shopping_bag,
                    title: 'Total Products',
                    value: count.toString(),
                    color: Colors.green,
                  );
                },
              ),
              // Premium Users
              StreamBuilder<QuerySnapshot>(
                stream: firestore.collection('users').snapshots(),
                builder: (context, snapshot) {
                  final premiumCount = snapshot.data?.docs
                          .where((doc) =>
                              (doc.data()
                                  as Map<String, dynamic>)['isPremium'] ??
                              false)
                          .length ??
                      0;
                  return _buildStatCard(
                    icon: Icons.verified,
                    title: 'Premium Users',
                    value: premiumCount.toString(),
                    color: Colors.amber,
                  );
                },
              ),
              // Total Admins (Super Admin only)
              if (adminProvider.isSuperAdmin)
                _buildStatCard(
                  icon: Icons.admin_panel_settings,
                  title: 'Total Admins',
                  value: adminProvider.allAdmins.length.toString(),
                  color: Colors.purple,
                )
              else
                _buildStatCard(
                  icon: Icons.info,
                  title: 'Role',
                  value: adminProvider.currentAdmin?.role ?? 'admin',
                  color: Colors.indigo,
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
              _buildActionCard(
                icon: Icons.person,
                title: 'Manage Users',
                subtitle: 'View & edit users',
                color: Colors.blue,
                onTap: () => setState(() => _selectedIndex = 1),
              ),
              _buildActionCard(
                icon: Icons.shopping_bag,
                title: 'Bazaar Products',
                subtitle: 'All products',
                color: Colors.green,
                onTap: () => setState(() => _selectedIndex = 2),
              ),
              if (adminProvider.isSuperAdmin) ...[
                _buildActionCard(
                  icon: Icons.admin_panel_settings,
                  title: 'Manage Admins',
                  subtitle: 'View admins',
                  color: Colors.purple,
                  onTap: () => setState(() => _selectedIndex = 3),
                ),
                _buildActionCard(
                  icon: Icons.history,
                  title: 'Activity Logs',
                  subtitle: 'View logs',
                  color: Colors.orange,
                  onTap: () => setState(() => _selectedIndex = 4),
                ),
                _buildActionCard(
                  icon: Icons.account_balance,
                  title: 'Financial Requests',
                  subtitle: 'Deposits & Withdrawals',
                  color: Colors.teal,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminFinancialRequestsScreen()),
                    );
                  },
                ),
                _buildActionCard(
                  icon: Icons.analytics,
                  title: 'Cash Flow',
                  subtitle: 'Transaction Analytics',
                  color: Colors.indigo,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminTransactionAnalyticsScreen()),
                    );
                  },
                ),
              ] else ...[
                _buildActionCard(
                  icon: Icons.settings,
                  title: 'Settings',
                  subtitle: 'System settings',
                  color: Colors.orange,
                  onTap: () => setState(() => _selectedIndex = 3),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),

          // Admin Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Information',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                    'Email', adminProvider.currentAdmin?.email ?? 'N/A'),
                _buildInfoRow('Role',
                    adminProvider.currentAdmin?.role.toUpperCase() ?? 'N/A'),
                _buildInfoRow(
                    'Status',
                    adminProvider.currentAdmin?.isActive ?? false
                        ? '✅ Active'
                        : '❌ Inactive'),
                _buildInfoRow(
                  'Last Login',
                  adminProvider.currentAdmin?.lastLogin
                          ?.toString()
                          .split('.')[0] ??
                      'First login',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Total Admins (Super Admin only)
          if (adminProvider.isSuperAdmin) ...[
            Text(
              'System Stats',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    size: 40,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Admins',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${adminProvider.allAdmins.length}',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          Text(value,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
        ],
      ),
    );
  }

  Widget _buildManageUsers() {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
          title: const Text('Manage Users'),
          elevation: 0,
          automaticallyImplyLeading: false),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: AdminSearchFilterWidget(
              searchHint: 'Search by name or email...',
              onSearch: (query) {
                setState(() => _userSearchQuery = query);
              },
            ),
          ),
          // Users list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var users = snapshot.data?.docs ?? [];

                // Filter users based on search query
                if (_userSearchQuery.isNotEmpty) {
                  users = users.where((userDoc) {
                    final userData = userDoc.data() as Map<String, dynamic>;
                    final userName =
                        (userData['name'] ?? '').toString().toLowerCase();
                    final userEmail =
                        (userData['email'] ?? '').toString().toLowerCase();
                    final query = _userSearchQuery.toLowerCase();
                    return userName.contains(query) ||
                        userEmail.contains(query);
                  }).toList();
                }

                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline,
                            size: 64,
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text(
                          _userSearchQuery.isEmpty
                              ? 'No users found'
                              : 'No results found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final userDoc = users[index];
                    final userData = userDoc.data() as Map<String, dynamic>;
                    final userName = userData['name'] ?? 'Unknown';
                    final userEmail = userData['email'] ?? 'No email';
                    final isPremium = userData['isPremium'] ?? false;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.2)),
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
                                    Row(
                                      children: [
                                        Text(userName,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                        if (isPremium) ...[
                                          const SizedBox(width: 8),
                                          const Icon(Icons.verified,
                                              size: 16, color: Colors.amber),
                                        ],
                                      ],
                                    ),
                                    Text(userEmail,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall),
                                  ],
                                ),
                              ),
                              PopupMenuButton(
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: const Text('View Details'),
                                    onTap: () => _showUserDetailsDialog(
                                        userDoc.id, userData),
                                  ),
                                  PopupMenuItem(
                                    child: const Text('Edit User'),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AdminEditUserScreen(
                                          userId: userDoc.id,
                                          userData: userData,
                                        ),
                                      ),
                                    ).then((result) {
                                      if (result == true) {
                                        setState(() {});
                                      }
                                    }),
                                  ),
                                  PopupMenuItem(
                                    child: const Text('Delete User',
                                        style: TextStyle(color: Colors.red)),
                                    onTap: () =>
                                        _deleteUserDialog(userDoc.id, userName),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBazaarManagement() {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    const productCategories = [
      'Vegetables',
      'Fruits',
      'Grains',
      'Seeds',
      'Fertilizer',
      'Tools',
      'Livestock',
      'Dairy',
      'Other',
    ];

    return Scaffold(
      appBar: AppBar(
          title: const Text('Manage Bazaar Products'),
          elevation: 0,
          automaticallyImplyLeading: false),
      body: Column(
        children: [
          // Search and filter bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: AdminSearchFilterWidget(
              searchHint: 'Search by product name...',
              filterLabel: 'Category',
              filterOptions: productCategories,
              onSearch: (query) {
                setState(() => _productSearchQuery = query);
              },
              onFilterChanged: (category) {
                setState(() => _productCategoryFilter = category);
              },
            ),
          ),
          // Products list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection('bazaar_products')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var products = snapshot.data?.docs ?? [];

                // Filter products based on search query
                if (_productSearchQuery.isNotEmpty) {
                  products = products.where((productDoc) {
                    final productData =
                        productDoc.data() as Map<String, dynamic>;
                    final productName =
                        (productData['name'] ?? '').toString().toLowerCase();
                    final query = _productSearchQuery.toLowerCase();
                    return productName.contains(query);
                  }).toList();
                }

                // Filter products by category
                if (_productCategoryFilter != null &&
                    _productCategoryFilter!.isNotEmpty) {
                  products = products.where((productDoc) {
                    final productData =
                        productDoc.data() as Map<String, dynamic>;
                    final category = (productData['category'] ?? '').toString();
                    return category == _productCategoryFilter;
                  }).toList();
                }

                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined,
                            size: 64,
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text(
                          _productSearchQuery.isEmpty &&
                                  _productCategoryFilter == null
                              ? 'No products found'
                              : 'No results found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final productDoc = products[index];
                    final productData =
                        productDoc.data() as Map<String, dynamic>;
                    final productName = productData['name'] ?? 'Unknown';
                    final price = productData['price'] ?? 0;
                    final category = productData['category'] ?? 'N/A';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.2)),
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
                                    Text(productName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold)),
                                    Text(
                                        '৳${price.toStringAsFixed(2)} • $category',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall),
                                  ],
                                ),
                              ),
                              PopupMenuButton(
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: const Text('Edit Product'),
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AdminEditProductScreen(
                                          productId: productDoc.id,
                                          productData: productData,
                                        ),
                                      ),
                                    ).then((result) {
                                      if (result == true) {
                                        setState(() {});
                                      }
                                    }),
                                  ),
                                  PopupMenuItem(
                                    child: const Text('Delete Product',
                                        style: TextStyle(color: Colors.red)),
                                    onTap: () => _deleteProductDialog(
                                        productDoc.id,
                                        productName,
                                        productData),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLogs() {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
          title: const Text('Activity Logs'),
          elevation: 0,
          automaticallyImplyLeading: false),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('admin_logs')
            .orderBy('timestamp', descending: true)
            .limit(100)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final logs = snapshot.data?.docs ?? [];

          if (logs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history,
                      size: 64,
                      color: Theme.of(context).primaryColor.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text('No activity logs found',
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final logDoc = logs[index];
              final logData = logDoc.data() as Map<String, dynamic>;
              final adminName = logData['adminName'] ?? 'Unknown Admin';
              final actionType = logData['actionType'] ?? 'UNKNOWN';
              final description = logData['description'] ?? 'No description';
              final timestamp =
                  (logData['timestamp'] as Timestamp?)?.toDate() ??
                      DateTime.now();

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.2)),
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
                              Text(
                                actionType,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(adminName,
                                  style:
                                      Theme.of(context).textTheme.labelSmall),
                            ],
                          ),
                        ),
                        Text(
                          '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(description,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showUserDetailsDialog(String userId, Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('User Details',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Name', userData['name'] ?? 'N/A'),
              _buildDetailRow('Email', userData['email'] ?? 'N/A'),
              _buildDetailRow('Phone', userData['phone'] ?? 'N/A'),
              _buildDetailRow('Location', userData['location'] ?? 'N/A'),
              _buildDetailRow(
                  'Premium', userData['isPremium'] == true ? '✅ Yes' : '❌ No'),
              _buildDetailRow('User ID', userId),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
        ],
      ),
    );
  }

  void _deleteUserDialog(String userId, String userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User?'),
        content: Text('Are you sure you want to delete user "$userName"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .delete();
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('User deleted')));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteProductDialog(
      String productId, String productName, Map<String, dynamic> productData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product?'),
        content: Text('Are you sure you want to delete "$productName"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final imageUrl = productData['imageUrl'];
              if (imageUrl != null && imageUrl.isNotEmpty) {
                try {
                  final ref = FirebaseStorage.instance.refFromURL(imageUrl);
                  await ref.delete();
                } catch (e) {
                  debugPrint('Error deleting image: $e');
                }
              }
              await FirebaseFirestore.instance
                  .collection('bazaar_products')
                  .doc(productId)
                  .delete();
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product deleted')));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Admin Settings',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red.shade600),
            title: const Text('Logout'),
            subtitle: const Text('Sign out from admin account'),
            onTap: () async {
              final adminProvider =
                  Provider.of<AdminProvider>(context, listen: false);
              await adminProvider.adminSignOut();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/admin-login');
              }
            },
          ),
        ],
      ),
    );
  }
}

class AdminManagement extends StatelessWidget {
  const AdminManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Manage Admins'), elevation: 0),
          body: adminProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : adminProvider.allAdmins.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.admin_panel_settings,
                            size: 64,
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No admins found',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: adminProvider.allAdmins.length,
                      itemBuilder: (context, index) {
                        final admin = adminProvider.allAdmins[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          admin.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        Text(
                                          admin.email,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Chip(
                                    label: Text(admin.role.toUpperCase()),
                                    backgroundColor: _getRoleColor(admin.role),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    admin.isActive
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color: admin.isActive
                                        ? Colors.green
                                        : Colors.red,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    admin.isActive ? 'Active' : 'Inactive',
                                    style:
                                        Theme.of(context).textTheme.labelSmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const AdminCreateAdminDialog(),
              );
            },
            label: const Text('Create Admin'),
            icon: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'super_admin':
        return Colors.red.withOpacity(0.3);
      case 'admin':
        return Colors.blue.withOpacity(0.3);
      case 'moderator':
        return Colors.orange.withOpacity(0.3);
      default:
        return Colors.grey.withOpacity(0.3);
    }
  }
}

class AdminCreateAdminDialog extends StatefulWidget {
  const AdminCreateAdminDialog({super.key});

  @override
  State<AdminCreateAdminDialog> createState() => _AdminCreateAdminDialogState();
}

class _AdminCreateAdminDialogState extends State<AdminCreateAdminDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedRole = 'admin';
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Text(
        'Create New Admin',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Admin Name',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedRole,
              decoration: InputDecoration(
                labelText: 'Role',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: const [
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
                DropdownMenuItem(value: 'moderator', child: Text('Moderator')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _selectedRole = value);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createAdmin,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _createAdmin() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final success = await adminProvider.createAdmin(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      role: _selectedRole,
    );

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Admin created successfully')),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(adminProvider.error ?? 'Failed to create admin')),
        );
      }
    }
  }
}
