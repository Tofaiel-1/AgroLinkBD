# 🛠️ Development Guide - AgroLinkBD

এই ডকুমেন্ট AgroLinkBD প্রজেক্টে ডেভেলপমেন্ট করার জন্য সম্পূর্ণ গাইড।

---

## 📋 Table of Contents

1. [Setup & Installation](#setup--installation)
2. [Project Structure](#project-structure)
3. [Coding Standards](#coding-standards)
4. [Firebase Configuration](#firebase-configuration)
5. [Adding New Features](#adding-new-features)
6. [Testing](#testing)
7. [Debugging](#debugging)
8. [Git Workflow](#git-workflow)

---

## 🚀 Setup & Installation

### Prerequisites
```bash
- Flutter SDK 3.22.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code with Flutter extension
- Firebase CLI
- Git
```

### Initial Setup

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/agrolinkbd.git
cd agrolinkbd

# 2. Get Flutter dependencies
flutter pub get

# 3. Configure Firebase
flutterfire configure

# 4. Build runner (if using code generation)
flutter pub run build_runner build --delete-conflicting-outputs

# 5. Run the app
flutter run
```

### IDE Setup

#### VS Code
```json
// .vscode/settings.json
{
  "dart.flutterSdkPath": "path/to/flutter",
  "dart.enableSdkFormatter": true,
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "dart-code.dart-code"
}
```

#### Android Studio
- Install Flutter and Dart plugins
- Configure Flutter SDK path in preferences
- Enable Dart formatting on save

---

## 📁 Project Structure

```
lib/
├── core/                          # Business logic layer
│   ├── controllers/               # GetX controllers
│   │   ├── user_controller.dart
│   │   ├── market_controller.dart
│   │   └── admin_controller.dart
│   ├── models/                    # Data models
│   │   ├── user_model.dart
│   │   ├── product_model.dart
│   │   ├── order_model.dart
│   │   ├── admin_model.dart
│   │   ├── audit_log_model.dart
│   │   └── [other_models].dart
│   ├── providers/                 # Provider state management
│   │   ├── admin_provider.dart
│   │   ├── auth_provider.dart
│   │   ├── marketplace_provider.dart
│   │   └── [other_providers].dart
│   ├── services/                  # Backend services
│   │   ├── auth_service.dart
│   │   ├── firestore_service.dart
│   │   ├── storage_service.dart
│   │   ├── payment_service.dart
│   │   ├── audit_service.dart
│   │   ├── notification_service.dart
│   │   └── [other_services].dart
│   └── utils/                     # Utility functions
│       ├── constants.dart
│       ├── validators.dart
│       ├── formatters.dart
│       ├── app_logger.dart
│       └── custom_exceptions.dart
├── presentation/                  # UI layer
│   ├── screens/                   # Full screens
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   └── forgot_password_screen.dart
│   │   ├── admin/
│   │   │   ├── superadmin_management.dart
│   │   │   ├── audit_logs_viewer.dart
│   │   │   ├── analytics_dashboard.dart
│   │   │   └── admin_dashboard.dart
│   │   ├── buyer/
│   │   ├── seller/
│   │   ├── profile/
│   │   ├── marketplace/
│   │   ├── crops/
│   │   ├── wallet/
│   │   ├── ai/
│   │   ├── transport/
│   │   ├── dashboard_screen.dart
│   │   └── [other_screens].dart
│   ├── widgets/                   # Reusable widgets
│   │   ├── custom_app_bar.dart
│   │   ├── product_card.dart
│   │   ├── custom_button.dart
│   │   ├── custom_text_field.dart
│   │   └── [other_widgets].dart
│   └── theme/                     # Theme and styling
│       ├── app_theme.dart
│       ├── app_colors.dart
│       └── app_text_styles.dart
├── config/                        # Configuration
│   ├── routes.dart
│   ├── firebase_options.dart
│   └── app_config.dart
├── main.dart                      # App entry point
└── app.dart                       # App root widget
```

---

## 📝 Coding Standards

### Naming Conventions

```dart
// ✅ GOOD

// Classes: PascalCase
class UserModel {}
class LoginScreen extends StatelessWidget {}

// Variables: camelCase
String userName = "Ahmed";
int totalPrice = 5000;
bool isAdmin = true;

// Constants: camelCase with const
const String apiBaseUrl = "https://api.agrolinkbd.com";
const int pageSize = 20;

// Private variables: _camelCase
String _privateData = "secret";
void _privateMethod() {}

// Enums: PascalCase
enum UserRole { farmer, seller, buyer, admin }

// ❌ BAD

String UserName = "Ahmed";           // Wrong: uses PascalCase
int total_price = 5000;              // Wrong: uses snake_case
final privateData = "secret";        // Wrong: not prefixed with _
class user_model {}                  // Wrong: uses snake_case
```

### Code Organization

```dart
// ✅ GOOD - Follow this order:

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Enums first
enum Status { idle, loading, success, error }

// Model/Data classes
class Product {
  final String id;
  final String name;
  // ...
}

// Main widget class
class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

// State class
class _ProductScreenState extends State<ProductScreen> {
  // 1. Variables and fields
  late ScrollController _scrollController;
  
  // 2. Lifecycle methods (initState, dispose)
  @override
  void initState() {
    super.initState();
    // Initialize
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 3. Main build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  // 4. Helper build methods
  Widget _buildBody() => Container();
  Widget _buildHeader() => Container();
  Widget _buildContent() => Container();

  // 5. Helper methods
  void _loadData() {}
  Future<void> _refreshData() async {}
}
```

### Documentation

```dart
// ✅ Document your code

/// A service class that handles user authentication.
/// 
/// This service provides methods for:
/// - User login
/// - User registration
/// - Password reset
/// - Token management
/// 
/// Example usage:
/// ```dart
/// final authService = AuthService();
/// await authService.login(email, password);
/// ```
class AuthService {
  /// Authenticates a user with email and password.
  /// 
  /// Throws [AuthException] if authentication fails.
  /// Throws [NetworkException] if network is unavailable.
  Future<User> login(String email, String password) async {
    // Implementation
  }
}

// ✅ Document complex logic
void calculateTax() {
  // Calculate tax based on product price
  // Tax rate: 15% for local, 5% for organic
  final taxRate = isOrganic ? 0.05 : 0.15;
  final tax = price * taxRate;
}
```

### Error Handling

```dart
// ✅ GOOD
try {
  final user = await authService.login(email, password);
  // Handle success
} on AuthException catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Authentication failed: ${e.message}')),
  );
} on NetworkException catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Network error. Check your connection.')),
  );
} catch (e) {
  // Log unexpected errors
  logger.error('Unexpected error: $e');
}

// ❌ BAD
try {
  await authService.login(email, password);
} catch (e) {
  print('Error: $e');  // Don't use print in production
}
```

### State Management (Provider + GetX)

```dart
// ✅ Using Provider for complex state
class AdminProvider extends ChangeNotifier {
  bool _isSuperAdmin = false;
  
  bool get isSuperAdmin => _isSuperAdmin;
  
  Future<void> checkAdminStatus(String userId) async {
    try {
      _isSuperAdmin = await _adminService.isSuperAdmin(userId);
      notifyListeners();
    } catch (e) {
      _handleError(e);
    }
  }
  
  void _handleError(Exception e) {
    // Error handling
  }
}

// ✅ Using GetX for simple state
class AdminController extends GetxController {
  final isLoading = false.obs;
  final adminList = <AdminModel>[].obs;
  
  void fetchAdmins() async {
    isLoading.value = true;
    try {
      adminList.value = await adminService.getAdmins();
    } finally {
      isLoading.value = false;
    }
  }
}
```

---

## 🔥 Firebase Configuration

### Setup Steps

```bash
# 1. Install Firebase CLI
npm install -g firebase-tools

# 2. Login to Firebase
firebase login

# 3. Initialize Firebase (already done, but for reference)
firebase init

# 4. Configure for Flutter
flutterfire configure

# 5. Check configuration
flutterfire configure --no-platforms
```

### Firestore Rules (Production)

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - each user can read/write own document
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Products collection - public read, authenticated write
    match /products/{productId} {
      allow read: if true;
      allow create, update: if request.auth != null && 
                              request.auth.uid == resource.data.sellerId;
      allow delete: if request.auth != null &&
                       request.auth.uid == resource.data.sellerId;
    }
    
    // Admin collection - only admins
    match /admins/{adminId} {
      allow read, write: if isAdmin();
    }
    
    // Helper function
    function isAdmin() {
      return request.auth != null &&
             get(/databases/$(database)/documents/admins/$(request.auth.uid)).data.isAdmin == true;
    }
  }
}
```

### Storage Rules (Production)

```storage
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Public read
    match /{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
      allow delete: if request.auth != null && 
                       request.auth.uid == resource.metadata.userId;
    }
  }
}
```

---

## ✨ Adding New Features

### Step-by-step Guide

#### 1. Create Model Class

```dart
// lib/core/models/new_model.dart

class NewModel {
  final String id;
  final String title;
  final DateTime createdAt;

  NewModel({
    required this.id,
    required this.title,
    required this.createdAt,
  });

  factory NewModel.fromJson(Map<String, dynamic> json) {
    return NewModel(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
  };
}
```

#### 2. Create Service/Provider

```dart
// lib/core/services/new_service.dart

class NewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String collectionName = 'new_items';

  Future<List<NewModel>> getItems() async {
    try {
      final snapshot = await _firestore.collection(collectionName).get();
      return snapshot.docs
          .map((doc) => NewModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addItem(NewModel item) async {
    await _firestore
        .collection(collectionName)
        .doc(item.id)
        .set(item.toJson());
  }
}
```

#### 3. Create Screen

```dart
// lib/presentation/screens/new_feature/new_feature_screen.dart

class NewFeatureScreen extends StatefulWidget {
  const NewFeatureScreen({super.key});

  @override
  State<NewFeatureScreen> createState() => _NewFeatureScreenState();
}

class _NewFeatureScreenState extends State<NewFeatureScreen> {
  late Future<List<NewModel>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = NewService().getItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Feature')),
      body: FutureBuilder<List<NewModel>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final items = snapshot.data ?? [];
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(items[index].title),
            ),
          );
        },
      ),
    );
  }
}
```

#### 4. Add Route

```dart
// lib/config/routes.dart

class AppRoutes {
  static const String newFeature = '/new-feature';

  static getPages() => [
    GetPage(
      name: newFeature,
      page: () => const NewFeatureScreen(),
    ),
  ];
}
```

---

## 🧪 Testing

### Unit Tests

```dart
// test/core/models/new_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:agrolinkbd/core/models/new_model.dart';

void main() {
  group('NewModel', () {
    test('creates instance correctly', () {
      final model = NewModel(
        id: '1',
        title: 'Test',
        createdAt: DateTime.now(),
      );
      expect(model.id, '1');
      expect(model.title, 'Test');
    });

    test('converts to JSON correctly', () {
      final model = NewModel(
        id: '1',
        title: 'Test',
        createdAt: DateTime(2026, 4, 19),
      );
      final json = model.toJson();
      expect(json['id'], '1');
      expect(json['title'], 'Test');
    });
  });
}
```

### Widget Tests

```dart
// test/presentation/screens/new_feature_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NewFeatureScreen', () {
    testWidgets('displays loading state', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: NewFeatureScreen(),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
```

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/core/models/new_model_test.dart

# Run with coverage
flutter test --coverage

# Generate coverage report
lcov --list coverage/lcov.info
```

---

## 🐛 Debugging

### Debug Logging

```dart
// lib/core/utils/app_logger.dart

class AppLogger {
  static const String _tag = 'AgroLinkBD';

  static void info(String message) {
    print('[$_tag] INFO: $message');
  }

  static void warning(String message) {
    print('[$_tag] WARNING: $message');
  }

  static void error(String message, [Exception? e]) {
    print('[$_tag] ERROR: $message');
    if (e != null) print('  Exception: $e');
  }

  static void debug(String message) {
    if (kDebugMode) {
      print('[$_tag] DEBUG: $message');
    }
  }
}

// Usage
AppLogger.info('User logged in');
AppLogger.error('Authentication failed', exception);
```

### Dart DevTools

```bash
# Launch DevTools
flutter pub global activate devtools
devtools

# Run app with DevTools enabled
flutter run --start-paused
```

### Common Issues

| Issue | Solution |
|-------|----------|
| "NoSuchMethodError" | Check null safety, ensure objects are initialized |
| "State has been disposed" | Use mounted check before setState |
| "Firebase not initialized" | Ensure Firebase.initializeApp() called in main |
| "Plugin error" | Run `flutter pub get` and `flutter clean` |

---

## 📊 Git Workflow

### Branch Naming

```
feature/add-new-dashboard        # New features
bugfix/fix-login-error           # Bug fixes
hotfix/critical-payment-issue    # Critical fixes
docs/update-readme               # Documentation
refactor/improve-performance     # Code improvements
```

### Commit Messages

```
# ✅ GOOD
git commit -m "feat: add super admin dashboard with analytics"
git commit -m "fix: resolve isSuspended property in AdminModel"
git commit -m "docs: update README with admin features"
git commit -m "refactor: improve dashboard performance"

# ❌ BAD
git commit -m "fixed stuff"
git commit -m "WIP"
git commit -m "asdf"
```

### Pushing Changes

```bash
# Create feature branch
git checkout -b feature/new-dashboard

# Make changes
# ... code here ...

# Commit
git add .
git commit -m "feat: add new dashboard components"

# Push
git push origin feature/new-dashboard

# Create pull request on GitHub
# After approval, merge to main
```

---

## 📚 Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Dart Language Guide](https://dart.dev/guides)
- [GetX Documentation](https://pub.dev/packages/get)
- [Provider Documentation](https://pub.dev/packages/provider)

---

**Version:** 1.0  
**Last Updated:** April 19, 2026  
**Maintainer:** AgroLinkBD Development Team
