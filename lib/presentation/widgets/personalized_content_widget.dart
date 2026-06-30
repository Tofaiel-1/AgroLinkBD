import 'package:flutter/material.dart';
import 'package:agrolinkbd/core/models/user_model.dart';
import 'package:agrolinkbd/core/services/role_service.dart';
import 'package:agrolinkbd/core/services/role_permissions.dart';

/// Personalized Content Widget - Shows role-specific content
class PersonalizedContentWidget extends StatelessWidget {
  final UserModel? user;
  final VoidCallback? onFeatureTap;

  const PersonalizedContentWidget({
    super.key,
    required this.user,
    this.onFeatureTap,
  });

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return _buildEmptyState();
    }

    final features = RoleService.getFeaturesByRole(user!.userType);
    final permissions = RolePermissions.getPermissionsByRole(user!.userType);

    // Filter features based on permissions
    final availableFeatures = features.where((f) {
      if (f.requiredPermission == null) return true;
      return permissions.contains(f.requiredPermission);
    }).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Role-specific greeting
          _buildRoleGreeting(context),
          const SizedBox(height: 24),

          // Quick stats
          _buildQuickStats(context),
          const SizedBox(height: 24),

          // Available features grid
          _buildFeaturesGrid(context, availableFeatures),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text('Loading your personalized dashboard...'),
        ],
      ),
    );
  }

  Widget _buildRoleGreeting(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, ${user!.name}! 👋',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Role: ${RoleService.getRoleNameBN(user!.userType)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const SizedBox(width: 16),
          _buildStatCard(
            context,
            icon: Icons.star_rate,
            label: 'Rating',
            value: '${user!.rating.toStringAsFixed(1)}',
            color: Colors.amber,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            context,
            icon: Icons.star,
            label: 'Reviews',
            value: '${user!.totalRatings}',
            color: Colors.blue,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            context,
            icon: Icons.verified,
            label: 'Status',
            value: user!.status.toString().split('.').last,
            color: Colors.green,
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid(BuildContext context, List<dynamic> features) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Features',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final feature = features[index];
              return _buildFeatureCard(context, feature);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, dynamic feature) {
    return GestureDetector(
      onTap: onFeatureTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: feature.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                feature.icon,
                color: feature.color,
                size: 32,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              feature.titleBN,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              feature.description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: 10,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Role-Specific Data Provider
class RoleDataProvider extends ChangeNotifier {
  UserModel? _user;
  List<dynamic> _features = [];
  Map<String, dynamic> _roleData = {};
  bool _isLoading = false;

  UserModel? get user => _user;
  List<dynamic> get features => _features;
  Map<String, dynamic> get roleData => _roleData;
  bool get isLoading => _isLoading;

  /// Load role-specific data
  Future<void> loadRoleData(UserModel user) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = user;
      _features = RoleService.getFeaturesByRole(user.userType);

      // Load role-specific data based on user type
      _roleData = _loadRoleSpecificData(user);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading role data: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get role-specific dashboard data
  Map<String, dynamic> _loadRoleSpecificData(UserModel user) {
    switch (user.userType) {
      case UserType.farmer:
        return {
          'totalProducts': 15,
          'totalSales': 125000,
          'pendingOrders': 3,
          'landArea': user.totalLand ?? 0,
          'crops': user.cropTypes ?? [],
        };
      case UserType.buyer:
        return {
          'cartItems': 5,
          'totalOrders': 12,
          'savedFarmers': 8,
          'walletBalance': 5000,
          'loyaltyPoints': 250,
        };
      case UserType.driver:
        return {
          'activeTrips': 2,
          'totalTrips': 156,
          'monthlyEarnings': 45000,
          'vehicle': user.vehicleType,
          'capacity': user.loadCapacity,
        };
      case UserType.serviceProvider:
        return {
          'activeServices': 3,
          'totalBookings': 48,
          'monthlyEarnings': 32000,
          'machinery': user.machineryTypes,
          'hourlyRate': user.hourlyRate,
        };
      case UserType.company:
        return {
          'totalProducts': 234,
          'monthlyRevenue': 5650000,
          'activeOrders': 127,
          'companyName': user.companyName,
          'license': user.tradeLicense,
        };
      case UserType.seller:
        return {
          'totalProducts': 234,
          'monthlyRevenue': 5650000,
          'activeOrders': 127,
          'companyName': user.companyName,
          'license': user.tradeLicense,
        };
    }
  }

  /// Clear role data on logout
  void clearRoleData() {
    _user = null;
    _features = [];
    _roleData = {};
    notifyListeners();
  }
}
