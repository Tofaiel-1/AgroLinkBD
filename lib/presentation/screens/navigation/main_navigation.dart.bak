import 'package:flutter/material.dart';
import 'package:agrolinkbd/presentation/screens/dashboard/enhanced_dashboard.dart';
import 'package:agrolinkbd/presentation/screens/marketplace/enhanced_marketplace.dart';
import 'package:agrolinkbd/presentation/screens/notifications/notification_center.dart';
import 'package:agrolinkbd/presentation/screens/profile/profile_settings.dart';
import 'package:agrolinkbd/presentation/screens/bazaar/bazaar_home.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const EnhancedDashboard(),
    const EnhancedMarketplace(),
    const BazaarHome(),
    const NotificationCenter(),
    const ProfileSettings(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF2E7D32),
          unselectedItemColor: Colors.grey,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.home_outlined, 0),
              activeIcon: _buildNavIcon(Icons.home, 0, isActive: true),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.store_outlined, 1),
              activeIcon: _buildNavIcon(Icons.store, 1, isActive: true),
              label: 'Market',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.shopping_cart_outlined, 2),
              activeIcon: _buildNavIcon(Icons.shopping_cart, 2, isActive: true),
              label: 'Bazaar',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  _buildNavIcon(Icons.notifications_outlined, 3),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: const Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              activeIcon: Stack(
                children: [
                  _buildNavIcon(Icons.notifications, 3, isActive: true),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: const Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              label: 'Notify',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.person_outline, 4),
              activeIcon: _buildNavIcon(Icons.person, 4, isActive: true),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF2E7D32).withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 24,
      ),
    );
  }
}
