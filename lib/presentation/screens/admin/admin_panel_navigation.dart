import 'package:flutter/material.dart';
import 'admin_main_dashboard.dart';
import 'admin_user_management_screen.dart';
import 'admin_analytics_screen.dart';
import 'admin_settings_screen.dart';

/// Complete Admin Panel Navigation System
/// Provides unified routing and sidebar navigation for all admin screens
class AdminPanelNavigation extends StatefulWidget {
  final int initialScreenIndex;

  const AdminPanelNavigation({
    super.key,
    this.initialScreenIndex = 0,
  });

  @override
  State<AdminPanelNavigation> createState() => _AdminPanelNavigationState();
}

class _AdminPanelNavigationState extends State<AdminPanelNavigation> {
  late int _selectedScreenIndex;
  bool _sidebarExpanded = true;

  final adminMenuItems = [
    {
      'icon': Icons.dashboard,
      'label': 'Dashboard',
      'screen': const AdminMainDashboard(),
    },
    {
      'icon': Icons.people,
      'label': 'Users',
      'screen': const AdminUserManagementScreen(),
    },
    {
      'icon': Icons.analytics,
      'label': 'Analytics',
      'screen': const AdminAnalyticsScreen(),
    },
    {
      'icon': Icons.settings,
      'label': 'Settings',
      'screen': const AdminSettingsScreen(),
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedScreenIndex = widget.initialScreenIndex;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    if (isMobile) {
      return _buildMobileLayout();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(),

          // Main content
          Expanded(
            child: adminMenuItems[_selectedScreenIndex]['screen'] as Widget,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: adminMenuItems[_selectedScreenIndex]['screen'] as Widget,
      bottomNavigationBar: _buildBottomNavigation(),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: _sidebarExpanded ? 250 : 80,
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Logo section
            Container(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () =>
                    setState(() => _sidebarExpanded = !_sidebarExpanded),
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
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Admin Panel',
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
                          child: Text(
                            'A',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    Icon(
                      _sidebarExpanded
                          ? Icons.chevron_left
                          : Icons.chevron_right,
                      color: Colors.white54,
                    ),
                  ],
                ),
              ),
            ),

            Divider(color: Colors.white.withOpacity(0.1)),

            // Menu items
            ..._buildMenuItems(),

            Divider(color: Colors.white.withOpacity(0.1), height: 32),

            // User profile section
            _buildUserProfileSection(),

            const SizedBox(height: 16),

            // Logout button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showLogoutConfirmation(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.2),
                    foregroundColor: Colors.red,
                  ),
                  icon: const Icon(Icons.logout),
                  label: _sidebarExpanded
                      ? const Text('Logout')
                      : const SizedBox(),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMenuItems() {
    return List.generate(
      adminMenuItems.length,
      (index) => _buildMenuItem(
        icon: adminMenuItems[index]['icon'] as IconData,
        label: adminMenuItems[index]['label'] as String,
        index: index,
        isSelected: _selectedScreenIndex == index,
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedScreenIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF059669).withOpacity(0.2)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? const Color(0xFF059669) : Colors.transparent,
              width: 3,
            ),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF059669) : Colors.white54,
              size: 20,
            ),
            if (_sidebarExpanded) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color:
                        isSelected ? const Color(0xFF059669) : Colors.white70,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelected)
                const Icon(Icons.arrow_forward,
                    color: Color(0xFF059669), size: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
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
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            if (_sidebarExpanded) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Super Admin',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'admin@agrolinkbd.com',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white54,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF1F2937),
      child: Column(
        children: [
          DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF059669), Color(0xFF10B981)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'A',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'AGROLINKBD',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Text(
                  'Admin Panel',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: adminMenuItems.length,
              itemBuilder: (context, index) => ListTile(
                leading: Icon(adminMenuItems[index]['icon'] as IconData,
                    color: _selectedScreenIndex == index
                        ? const Color(0xFF059669)
                        : Colors.white54),
                title: Text(
                  adminMenuItems[index]['label'] as String,
                  style: TextStyle(
                    color: _selectedScreenIndex == index
                        ? const Color(0xFF059669)
                        : Colors.white70,
                  ),
                ),
                onTap: () {
                  setState(() => _selectedScreenIndex = index);
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          const Divider(color: Colors.white10),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutConfirmation(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF1F2937),
      selectedItemColor: const Color(0xFF059669),
      unselectedItemColor: Colors.white54,
      currentIndex: _selectedScreenIndex,
      onTap: (index) => setState(() => _selectedScreenIndex = index),
      items: List.generate(
        adminMenuItems.length,
        (index) => BottomNavigationBarItem(
          icon: Icon(adminMenuItems[index]['icon'] as IconData),
          label: adminMenuItems[index]['label'] as String,
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to login screen
              // Get.offAll(() => const AdminLoginScreen());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
