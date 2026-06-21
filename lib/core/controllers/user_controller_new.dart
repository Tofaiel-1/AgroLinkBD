enum UserRole {
  farmer, // কৃষক
  buyer, // ক্রেতা/ব্যবসায়ী
  expert, // বিশেষজ্ঞ
  guest, // অতিথি
}

class UserData {
  final String id;
  final String name;
  final String phone;
  final String location;
  final UserRole role;
  final double walletBalance;
  final bool isAuthenticated;

  UserData({
    required this.id,
    required this.name,
    required this.phone,
    required this.location,
    required this.role,
    this.walletBalance = 0.0,
    this.isAuthenticated = false,
  });

  UserData copyWith({
    String? id,
    String? name,
    String? phone,
    String? location,
    UserRole? role,
    double? walletBalance,
    bool? isAuthenticated,
  }) {
    return UserData(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      role: role ?? this.role,
      walletBalance: walletBalance ?? this.walletBalance,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class UserController {
  UserData _userData = UserData(
    id: '',
    name: '',
    phone: '',
    location: '',
    role: UserRole.guest,
  );

  // Get current user data
  UserData get userData => _userData;
  UserRole get userRole => _userData.role;
  String get userName => _userData.name;
  String get userId => _userData.id;
  String get userPhone => _userData.phone;
  String get userLocation => _userData.location;
  double get walletBalance => _userData.walletBalance;
  bool get isAuthenticated => _userData.isAuthenticated;

  // Set user role
  void setUserRole(UserRole role) {
    _userData = _userData.copyWith(role: role);
  }

  // Set user data
  void setUserData({
    required String id,
    required String name,
    required String phone,
    required String location,
    required UserRole role,
    double balance = 0.0,
  }) {
    _userData = UserData(
      id: id,
      name: name,
      phone: phone,
      location: location,
      role: role,
      walletBalance: balance,
      isAuthenticated: true,
    );
  }

  // Update wallet balance
  void updateWalletBalance(double amount) {
    _userData = _userData.copyWith(walletBalance: amount);
  }

  // Clear user data (logout)
  void clearUserData() {
    _userData = UserData(
      id: '',
      name: '',
      phone: '',
      location: '',
      role: UserRole.guest,
    );
  }

  // Get role-specific features
  List<Map<String, dynamic>> getQuickActions() {
    switch (_userData.role) {
      case UserRole.farmer:
        return [
          {'title': 'My Crops', 'icon': 'agriculture', 'route': 'crops'},
          {'title': 'Sell Products', 'icon': 'store', 'route': 'marketplace'},
          {
            'title': 'Machinery Rental',
            'icon': 'agriculture',
            'route': 'machinery'
          },
          {
            'title': 'Transport',
            'icon': 'local_shipping',
            'route': 'transport'
          },
          {
            'title': 'Disease Detection',
            'icon': 'camera_alt',
            'route': 'disease'
          },
          {'title': 'Soil Testing', 'icon': 'science', 'route': 'soil'},
          {'title': 'AI Assistant', 'icon': 'smart_toy', 'route': 'ai'},
          {'title': 'Weather', 'icon': 'cloud', 'route': 'weather'},
        ];
      case UserRole.buyer:
        return [
          {
            'title': 'Buy Products',
            'icon': 'shopping_cart',
            'route': 'marketplace'
          },
          {'title': 'Auction', 'icon': 'gavel', 'route': 'auction'},
          {
            'title': 'Transport',
            'icon': 'local_shipping',
            'route': 'transport'
          },
          {'title': 'My Orders', 'icon': 'receipt', 'route': 'orders'},
          {'title': 'Investment', 'icon': 'trending_up', 'route': 'investment'},
          {
            'title': 'Market Price',
            'icon': 'show_chart',
            'route': 'market_price'
          },
        ];
      case UserRole.expert:
        return [
          {
            'title': 'Give Consultation',
            'icon': 'support_agent',
            'route': 'consultation'
          },
          {
            'title': 'Disease Analysis',
            'icon': 'health_and_safety',
            'route': 'disease'
          },
          {'title': 'Soil Analysis', 'icon': 'science', 'route': 'soil'},
          {'title': 'Training', 'icon': 'school', 'route': 'training'},
          {
            'title': 'Earnings',
            'icon': 'account_balance_wallet',
            'route': 'wallet'
          },
        ];
      default:
        return [];
    }
  }

  // Get dashboard title based on role
  String getDashboardTitle() {
    switch (_userData.role) {
      case UserRole.farmer:
        return 'Farmer Dashboard';
      case UserRole.buyer:
        return 'Buyer Dashboard';
      case UserRole.expert:
        return 'Expert Dashboard';
      default:
        return 'Dashboard';
    }
  }

  // Check if feature is available for current role
  bool hasFeature(String feature) {
    switch (_userData.role) {
      case UserRole.farmer:
        return [
          'crops',
          'sell',
          'machinery',
          'transport',
          'disease',
          'soil',
          'ai',
          'weather'
        ].contains(feature);
      case UserRole.buyer:
        return [
          'buy',
          'auction',
          'transport',
          'orders',
          'investment',
          'market_price'
        ].contains(feature);
      case UserRole.expert:
        return ['consultation', 'disease', 'soil', 'training', 'wallet']
            .contains(feature);
      default:
        return false;
    }
  }

  // Get role-specific features count
  int getFeatureCount() {
    return getQuickActions().length;
  }
}

// Global user controller instance
final userController = UserController();
