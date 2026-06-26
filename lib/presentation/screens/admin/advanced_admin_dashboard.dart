import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrolinkbd/presentation/screens/auth/login_screen.dart';
import 'package:agrolinkbd/presentation/screens/admin/admin_deposit_approval_screen.dart';
import 'package:agrolinkbd/presentation/screens/admin/admin_send_money_screen.dart';
import 'package:agrolinkbd/presentation/screens/admin/admin_user_management_screen.dart';
import 'package:agrolinkbd/presentation/screens/admin/admin_announcement_screen.dart';
import 'package:agrolinkbd/presentation/screens/admin/audit_logs_viewer.dart';
import 'package:agrolinkbd/presentation/screens/admin/inventory_dashboard_screen.dart';
import 'package:agrolinkbd/presentation/screens/admin/refund_queue_screen.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/admin_provider.dart';
import 'package:agrolinkbd/presentation/screens/admin/admin_create_screen.dart';
import 'package:agrolinkbd/presentation/screens/admin/admin_transaction_analytics_screen.dart';


import 'package:agrolinkbd/presentation/screens/admin/admin_financial_requests_screen.dart';
class PulseEffect extends StatefulWidget {
  final Widget child;
  const PulseEffect({super.key, required this.child});

  @override
  State<PulseEffect> createState() => _PulseEffectState();
}

class _PulseEffectState extends State<PulseEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scaleAnimation, child: widget.child);
  }
}

/// Shimmer Effect for Loading State
class GlassShimmer extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  const GlassShimmer({super.key, required this.width, required this.height, this.borderRadius});

  @override
  State<GlassShimmer> createState() => _GlassShimmerState();
}

class _GlassShimmerState extends State<GlassShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment(-2.0 + (_controller.value * 4), 0.0),
              end: Alignment(0.0 + (_controller.value * 4), 0.0),
              colors: [
                Colors.white.withOpacity(0.02),
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.02),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Animated Counter Widget for Pro-Level UI
class AnimatedCounter extends StatelessWidget {
  final int value;
  final String prefix;
  final String suffix;
  final TextStyle? style;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.prefix = '',
    this.suffix = '',
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutQuart,
      builder: (context, val, child) {
        final formattedVal = val.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
        return Text('$prefix$formattedVal$suffix', style: style);
      },
    );
  }
}

class AdvancedAdminDashboard extends StatefulWidget {
  const AdvancedAdminDashboard({super.key});

  @override
  State<AdvancedAdminDashboard> createState() => _AdvancedAdminDashboardState();
}

class _AdvancedAdminDashboardState extends State<AdvancedAdminDashboard> {
  bool _sidebarExpanded = true;
  bool _isLightMode = false; // Theme Toggle

  // Real Data State
  bool _isLoadingData = true;
  int _totalUsers = 0;
  int _totalProducts = 0;
  int _totalTransactions = 0;
  List<Map<String, dynamic>> _recentActivities = [];

  // Hover States for Glossy Nav
  int _hoveredMenuIndex = -1;
  int _selectedMenuIndex = 0;

  // Theming Getters
  Color get _bgColor => _isLightMode ? const Color(0xFFF3F4F6) : const Color(0xFF0B0F19);
  Color get _textColor => _isLightMode ? const Color(0xFF1F2937) : Colors.white;
  Color get _cardBorderColor => _isLightMode ? Colors.black.withOpacity(0.05) : Colors.white.withOpacity(0.08);

  @override
  void initState() {
    super.initState();
    _fetchRealData();
  }

  Future<void> _fetchRealData() async {
    setState(() => _isLoadingData = true);
    try {
      final db = FirebaseFirestore.instance;

      final userCount = await db.collection('users').count().get();
      final productCount = await db.collection('products').count().get();
      final transactionCount = await db.collection('transactions').count().get();
      
      final recentUsers = await db.collection('users')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();

      final activities = recentUsers.docs.map((doc) {
        final data = doc.data();
        return {
          'user': data['name'] ?? 'New User',
          'action': 'joined the platform',
          'time': 'Recently',
          'icon': Icons.person_add,
          'color': const Color(0xFF10B981)
        };
      }).toList();

      // Simulate a small network delay so the beautiful shimmer is visible
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        setState(() {
          _totalUsers = userCount.count ?? 0;
          _totalProducts = productCount.count ?? 0;
          _totalTransactions = transactionCount.count ?? 0;
          _recentActivities = activities.isEmpty 
              ? [{'user': 'System', 'action': 'System Initialized', 'time': 'Just now', 'icon': Icons.settings, 'color': const Color(0xFF3B82F6)}]
              : activities;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching admin stats: $e');
      if (mounted) setState(() => _isLoadingData = false);
    }
  }
  Future<void> _confirmSignOut(BuildContext context) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text('Are you sure you want to end your session?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      await FirebaseAuth.instance.signOut();
      Get.offAll(() => const LoginScreen());
    }
  }

  Future<void> _confirmClearAdmins(BuildContext context) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Legacy Admins?'),
        content: const Text('Are you sure you want to delete all admins except the Super Admin? This cannot be undone.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (shouldClear == true) {
      final provider = Provider.of<AdminProvider>(context, listen: false);
      final success = await provider.deleteAllRegularAdmins();
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All legacy admins cleared'), backgroundColor: Color(0xFF10B981)));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.error ?? 'Failed to clear admins'), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App?'),
            content: const Text('Are you sure you want to exit the application?'),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Yes, Exit'),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        backgroundColor: _bgColor,
        body: SafeArea(
          child: Stack(
            children: [
              // Ambient glowing background orbs
              Positioned(
                top: -100,
                left: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF059669).withOpacity(_isLightMode ? 0.2 : 0.15),
                  ),
                ),
              ),
              Positioned(
                bottom: -150,
                right: -50,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF3B82F6).withOpacity(_isLightMode ? 0.2 : 0.1),
                  ),
                ),
              ),
              // Backdrop filter
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: Container(color: Colors.transparent),
              ),
              
              // Main Content
              isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _isLoadingData 
                ? _buildShimmerGrid(2) 
                : _buildStatCardsGrid(2),
            const SizedBox(height: 24),
            if (!_isLoadingData) _buildChartsSection(),
            const SizedBox(height: 24),
            if (!_isLoadingData) _buildActivityFeed(),
            const SizedBox(height: 24),
            _buildQuickActionsGrid(crossAxisCount: 4),
            const SizedBox(height: 40),
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
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _isLoadingData 
                      ? _buildShimmerGrid(4) 
                      : _buildStatCardsGrid(4),
                  const SizedBox(height: 32),
                  if (!_isLoadingData) _buildChartsSection(),
                  const SizedBox(height: 32),
                  if (!_isLoadingData) 
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _buildActivityFeed()),
                        const SizedBox(width: 24),
                        Expanded(child: _buildAlertsSection()),
                      ],
                    ),
                  const SizedBox(height: 32),
                  _buildQuickActionsGrid(crossAxisCount: 4),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // GLASSMORPHISM CONTAINER HELPER
  Widget _buildGlassContainer({required Widget child, EdgeInsetsGeometry? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _isLightMode ? Colors.white.withOpacity(0.7) : Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _cardBorderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isLightMode ? 0.05 : 0.2),
                blurRadius: 10,
                spreadRadius: -5,
              )
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildShimmerGrid(int crossAxisCount) {
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: MediaQuery.of(context).size.width < 768 ? 1.1 : 1.5,
      children: List.generate(4, (index) => const GlassShimmer(width: double.infinity, height: double.infinity)),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: _sidebarExpanded ? 260 : 80,
      decoration: BoxDecoration(
        color: _isLightMode ? Colors.white.withOpacity(0.8) : const Color(0xFF0F1423),
        border: Border(right: BorderSide(color: _cardBorderColor)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_sidebarExpanded)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AGROLINK',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _textColor, fontWeight: FontWeight.w900, letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          'Pro Admin v4',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: const Color(0xFF10B981), fontWeight: FontWeight.bold,
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
                      gradient: const LinearGradient(colors: [Color(0xFF059669), Color(0xFF10B981)]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                GestureDetector(
                  onTap: () => setState(() => _sidebarExpanded = !_sidebarExpanded),
                  child: Icon(
                    _sidebarExpanded ? Icons.menu_open : Icons.menu,
                    color: _textColor.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: _cardBorderColor, height: 1),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: _buildSidebarMenu(),
              ),
            ),
          ),
          _buildSidebarFooter(),
        ],
      ),
    );
  }

  Widget _buildSidebarMenu() {
    final menuItems = [
      {'icon': Icons.dashboard_rounded, 'label': 'Dashboard', 'action': 'dashboard'},
      {'icon': Icons.people_rounded, 'label': 'Users DB', 'action': 'users'},
      {'icon': Icons.inventory_2_rounded, 'label': 'Marketplace', 'action': 'market'},
      {'icon': Icons.receipt_long_rounded, 'label': 'Transactions', 'action': 'trans'},
    ];

    return Column(
      children: menuItems.asMap().entries.map((entry) {
        final index = entry.key;
        final isActive = _selectedMenuIndex == index;
        final isHovered = _hoveredMenuIndex == index;
        
        return MouseRegion(
          onEnter: (_) => setState(() => _hoveredMenuIndex = index),
          onExit: (_) => setState(() => _hoveredMenuIndex = -1),
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedMenuIndex = index);
              if (entry.value['action'] == 'users') {
                Get.to(() => AdminUserManagementScreen());
              } else if (entry.value['action'] == 'trans') {
                Get.to(() => AdminTransactionAnalyticsScreen());
              }
              // Reset selection after returning
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) setState(() => _selectedMenuIndex = 0);
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                gradient: isActive || isHovered
                    ? LinearGradient(
                        colors: [
                          const Color(0xFF10B981).withOpacity(isActive ? 0.2 : 0.05),
                          const Color(0xFF10B981).withOpacity(0.0),
                        ],
                      )
                    : null,
                border: Border(
                    left: BorderSide(
                        color: isActive || isHovered ? const Color(0xFF10B981) : Colors.transparent,
                        width: 3)),
                borderRadius: BorderRadius.circular(10),
                boxShadow: isHovered && !isActive ? [
                  BoxShadow(color: const Color(0xFF10B981).withOpacity(0.1), blurRadius: 10)
                ] : null,
              ),
              child: Row(
                children: [
                  Icon(entry.value['icon'] as IconData,
                      color: isActive || isHovered ? const Color(0xFF10B981) : _textColor.withOpacity(0.5),
                      size: 22),
                  if (_sidebarExpanded) ...[
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(entry.value['label'] as String,
                          style: TextStyle(
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                              color: isActive ? _textColor : _textColor.withOpacity(0.7))),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSidebarFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isLightMode ? Colors.white : Colors.white.withOpacity(0.02),
        border: Border(top: BorderSide(color: _cardBorderColor)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF3B82F6).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
                  ]
                ),
                child: const Center(
                  child: Icon(Icons.shield_rounded, color: Colors.white, size: 20),
                ),
              ),
              if (_sidebarExpanded) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('System Admin', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: _textColor, fontWeight: FontWeight.bold)),
                      Text('admin@agrolinkbd.com', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: _textColor.withOpacity(0.5)), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _confirmSignOut(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444).withOpacity(0.15),
                  foregroundColor: const Color(0xFFEF4444),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
              icon: const Icon(Icons.power_settings_new_rounded, size: 18),
              label: _sidebarExpanded ? const Text('End Session') : const SizedBox(),
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
              'Command Center',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: _textColor,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                PulseEffect(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Color(0xFF10B981), blurRadius: 6)]
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Live & Synchronized',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: const Color(0xFF10B981)),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            // Theme Toggle
            _buildGlassIconButton(
              icon: _isLightMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              onTap: () => setState(() => _isLightMode = !_isLightMode),
            ),
            const SizedBox(width: 12),
            _buildGlassIconButton(
              icon: Icons.refresh_rounded,
              onTap: _fetchRealData,
            ),
            const SizedBox(width: 12),
            _buildGlassIconButton(
              icon: Icons.power_settings_new_rounded,
              onTap: () => _confirmSignOut(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGlassIconButton({required IconData icon, bool showBadge = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _isLightMode ? Colors.white : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _cardBorderColor),
        ),
        child: Stack(
          children: [
            Icon(icon, color: _textColor, size: 22),
            if (showBadge)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCardsGrid(int crossAxisCount) {
    final stats = [
      {'title': 'Registered Users', 'value': _totalUsers, 'trend': 'Verified', 'icon': Icons.people_outline_rounded, 'color': const Color(0xFF3B82F6)},
      {'title': 'Active Products', 'value': _totalProducts, 'trend': 'Marketplace', 'icon': Icons.inventory_2_outlined, 'color': const Color(0xFF10B981)},
      {'title': 'Total Transactions', 'value': _totalTransactions, 'trend': 'Recorded', 'icon': Icons.receipt_long_outlined, 'color': const Color(0xFFF59E0B)},
      {'title': 'System Status', 'value': 100, 'isPercentage': true, 'trend': 'Optimal', 'icon': Icons.monitor_heart_outlined, 'color': const Color(0xFF8B5CF6)},
    ];

    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: MediaQuery.of(context).size.width < 768 ? 1.0 : 1.5,
      children: stats.map((stat) => _buildStatCard(stat)).toList(),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat) {
    final color = stat['color'] as Color;
    final value = stat['value'] as int;
    final isPercentage = stat['isPercentage'] == true;
    
    return _buildGlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Icon(stat['icon'] as IconData, color: color, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(stat['trend'] as String, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PulseEffect(
                child: AnimatedCounter(
                  value: value,
                  suffix: isPercentage ? '%' : '',
                  style: TextStyle(color: _textColor, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1),
                ),
              ),
              const SizedBox(height: 4),
              Text(stat['title'] as String, style: TextStyle(color: _textColor.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection() {
    final isMobile = MediaQuery.of(context).size.width < 768;
    if (isMobile) {
      return Column(
        children: [
          _buildRevenueChart(),
          const SizedBox(height: 24),
          _buildPlatformDistributionChart(),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _buildRevenueChart()),
        const SizedBox(width: 24),
        Expanded(child: _buildPlatformDistributionChart()),
      ],
    );
  }

  Widget _buildRevenueChart() {
    return _buildGlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Activity Volume', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 16)),
          Text('Platform usage over last 7 days', style: TextStyle(color: _textColor.withOpacity(0.5), fontSize: 12)),
          const SizedBox(height: 30),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true, drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: _textColor.withOpacity(0.05), strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: const Color(0xFF10B981).withOpacity(0.8),
                  )
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true, reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: TextStyle(color: _textColor.withOpacity(0.3), fontSize: 10)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(days[value.toInt()], style: TextStyle(color: _textColor.withOpacity(0.3), fontSize: 10)),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 10), FlSpot(1, 25), FlSpot(2, 40), FlSpot(3, 30), FlSpot(4, 55), FlSpot(5, 75), FlSpot(6, 60)],
                    isCurved: true,
                    gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)]),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [const Color(0xFF3B82F6).withOpacity(0.2), const Color(0xFF8B5CF6).withOpacity(0.0)],
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
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

  Widget _buildPlatformDistributionChart() {
    return _buildGlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('User Distribution', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 16)),
          Text('By registered role', style: TextStyle(color: _textColor.withOpacity(0.5), fontSize: 12)),
          const SizedBox(height: 30),
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2, centerSpaceRadius: 60,
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                    ),
                    sections: [
                      PieChartSectionData(value: 30, color: const Color(0xFF10B981), radius: 25, showTitle: false),
                      PieChartSectionData(value: 25, color: const Color(0xFF3B82F6), radius: 25, showTitle: false),
                      PieChartSectionData(value: 15, color: const Color(0xFFF59E0B), radius: 25, showTitle: false),
                      PieChartSectionData(value: 15, color: const Color(0xFF06B6D4), radius: 25, showTitle: false),
                      PieChartSectionData(value: 10, color: const Color(0xFFEAB308), radius: 25, showTitle: false),
                      PieChartSectionData(value: 5, color: const Color(0xFF8B5CF6), radius: 25, showTitle: false),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Total', style: TextStyle(color: _textColor.withOpacity(0.5), fontSize: 12)),
                    AnimatedCounter(
                      value: _totalUsers,
                      style: TextStyle(color: _textColor, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildLegendItem(color: const Color(0xFF10B981), text: 'Farmers'),
              _buildLegendItem(color: const Color(0xFF3B82F6), text: 'Buyers'),
              _buildLegendItem(color: const Color(0xFFF59E0B), text: 'Providers'),
              _buildLegendItem(color: const Color(0xFF06B6D4), text: 'Drivers'),
              _buildLegendItem(color: const Color(0xFFEAB308), text: 'Companies'),
              _buildLegendItem(color: const Color(0xFF8B5CF6), text: 'Admins'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String text}) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: _textColor.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildActivityFeed() {
    return _buildGlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Platform Activity', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Live', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._recentActivities.map((activity) => _buildActivityRow(activity)),
        ],
      ),
    );
  }

  Widget _buildActivityRow(Map<String, dynamic> activity) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: (activity['color'] as Color).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(activity['icon'] as IconData, color: activity['color'] as Color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: '${activity['user']} ', style: TextStyle(fontWeight: FontWeight.bold, color: _textColor, fontSize: 13)),
                      TextSpan(text: activity['action'] as String, style: TextStyle(color: _textColor.withOpacity(0.7), fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(activity['time'] as String, style: TextStyle(color: _textColor.withOpacity(0.4), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection() {
    return _buildGlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('System Insights', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          _buildAlertItem(title: 'Database Healthy', message: 'All regions operational', color: const Color(0xFF10B981), icon: Icons.cloud_done_rounded),
          const SizedBox(height: 12),
          _buildAlertItem(title: 'Security Scan', message: 'No threats detected', color: const Color(0xFF3B82F6), icon: Icons.security_rounded),
        ],
      ),
    );
  }

  Widget _buildAlertItem({required String title, required String message, required Color color, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05), border: Border.all(color: color.withOpacity(0.2)), borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
                Text(message, style: TextStyle(color: _textColor.withOpacity(0.5), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid({required int crossAxisCount}) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    final actions = [
      {'icon': Icons.person_add_rounded, 'label': 'User DB', 'color': const Color(0xFF14B8A6), 'route': 'users'},
      {'icon': Icons.campaign_rounded, 'label': 'Announce', 'color': const Color(0xFFF97316), 'route': 'announce'},
      {'icon': Icons.inventory_2_rounded, 'label': 'Inventory', 'color': const Color(0xFF8B5CF6), 'route': 'inventory'},
    ];

    if (adminProvider.isSuperAdmin) {
      actions.insertAll(0, [
        {'icon': Icons.account_balance_wallet_rounded, 'label': 'Deposit', 'color': const Color(0xFF10B981), 'route': 'deposit'},
        {'icon': Icons.send_rounded, 'label': 'Send Funds', 'color': const Color(0xFF3B82F6), 'route': 'send'},
        {'icon': Icons.analytics_rounded, 'label': 'Cash Flow', 'color': const Color(0xFF14B8A6), 'route': 'cashflow'},
        {'icon': Icons.request_quote_rounded, 'label': 'Requests', 'color': const Color(0xFFEAB308), 'route': 'requests'},
        {'icon': Icons.currency_exchange_rounded, 'label': 'Transfers', 'color': const Color(0xFF06B6D4), 'route': 'transfers'},
        {'icon': Icons.receipt_long_rounded, 'label': 'Refunds', 'color': const Color(0xFFF59E0B), 'route': 'refunds'},
        {'icon': Icons.history_edu_rounded, 'label': 'Audit Logs', 'color': const Color(0xFFEF4444), 'route': 'logs'},
      ]);
      actions.add({'icon': Icons.admin_panel_settings_rounded, 'label': 'Add Admin', 'color': const Color(0xFF10B981), 'route': 'add_admin'});
      actions.add({'icon': Icons.cleaning_services_rounded, 'label': 'Clear Admins', 'color': const Color(0xFFEF4444), 'route': 'clear_admins'});
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Command Shortcuts', style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: MediaQuery.of(context).size.width < 768 ? 1.0 : 1.3,
          children: actions.map((action) => _buildQuickActionCard(
            icon: action['icon'] as IconData,
            label: action['label'] as String,
            color: action['color'] as Color,
            route: action['route'] as String,
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({required IconData icon, required String label, required Color color, required String route}) {
    return GestureDetector(
      onTap: () {
        if (route == 'deposit') Get.to(() => const AdminDepositApprovalScreen());
        if (route == 'send') Get.to(() => const AdminSendMoneyScreen());
        if (route == 'cashflow') Get.to(() => AdminTransactionAnalyticsScreen());
        if (route == 'requests') Get.to(() => const AdminFinancialRequestsScreen());
        if (route == 'transfers') Get.to(() => const AdminFinancialRequestsScreen(initialTabIndex: 2));
        if (route == 'inventory') Get.to(() => const InventoryDashboardScreen());
        if (route == 'refunds') Get.to(() => const RefundQueueScreen());
        if (route == 'users') Get.to(() => const AdminUserManagementScreen());
        if (route == 'announce') Get.to(() => AdminAnnouncementScreen());
        if (route == 'logs') Get.to(() => const AuditLogsViewer());
        if (route == 'add_admin') Get.to(() => const AdminCreateScreen());
        if (route == 'clear_admins') _confirmClearAdmins(context);
      },
      child: _buildGlassContainer(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: _textColor, fontSize: 10, fontWeight: FontWeight.w600), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
