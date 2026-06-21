import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get isPremium => _currentUser?.isPremium ?? false;

  // Load user data
  Future<void> loadUser(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _authService.getUserData(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user
  Future<void> updateUser(UserModel user) async {
    try {
      await _authService.createOrUpdateUser(user);
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.signOut();
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Upgrade to premium
  Future<void> upgradeToPremium(DateTime expiryDate) async {
    if (_currentUser != null) {
      await _authService.updatePremiumStatus(
        userId: _currentUser!.id,
        isPremium: true,
        expiryDate: expiryDate,
      );
      await loadUser(_currentUser!.id);
    }
  }

  // Check premium status
  bool checkPremiumStatus() {
    if (_currentUser?.isPremium == true) {
      if (_currentUser!.premiumExpiryDate != null) {
        return _currentUser!.premiumExpiryDate!.isAfter(DateTime.now());
      }
    }
    return false;
  }
}
