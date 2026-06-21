# 🚀 IMPLEMENTATION GUIDE - Remaining 20+ Screens

**Purpose**: Step-by-step instructions to complete AgroLinkBD from B+ to A+ grade  
**Estimated Time**: 3-4 weeks with focused effort  
**Difficulty**: Medium (patterns already established)

---

## PHASE 1: BUYER FEATURES (Week 1)

### 1. Cart Screen
**File**: `lib/presentation/screens/buyer/cart_screen.dart`  
**Pattern**:
```dart
class CartScreen extends StatefulWidget {
  // Use CartProvider to manage items
  // Display each item in a Card
  // Show subtotal, tax, delivery fee, total
  // Quantity adjustment with +/- buttons
  // Remove item button
  // Proceed to checkout button
}
```

**Key Components**:
- Cartprovider (already has items list)
- AppCard for each item
- AppElevatedButton for checkout
- Price calculation (subtotal + tax + delivery)

### 2. Checkout Screen
**File**: `lib/presentation/screens/buyer/checkout_screen.dart`  
**Pattern**:
```dart
class CheckoutScreen extends StatefulWidget {
  // Shipping address (use AddressService)
  // Payment method selector (Flutterwave, bKash, etc)
  // Order summary
  // Place order button
  // Order confirmation
}
```

**Key Components**:
- AddressService for saved addresses
- PaymentService for processing
- OrderModel for order creation
- FirestoreService to save order

### 3. Orders Screen
**File**: `lib/presentation/screens/buyer/orders_screen.dart`  
**Pattern**:
```dart
class OrdersScreen extends StatelessWidget {
  // List of orders from Firestore
  // Filter by status (Pending, Processing, Shipped, Delivered)
  // Order card with product images
  // Track order button
  // Cancel/Return button
}
```

**Key Components**:
- OrderProvider to manage orders
- StreamBuilder for real-time orders
- OrderCard widget
- OrderDetailsScreen for details

---

## PHASE 2: FARMER FEATURES (Week 2)

### 4. Add Product Screen
**File**: `lib/presentation/screens/farmer/add_product_screen.dart`  
**Pattern**:
```dart
class AddProductScreen extends StatefulWidget {
  // Product name, category, price fields
  // Image picker (multiple images)
  // Description rich text editor
  // Stock quantity
  // Organic certification toggle
  // Save button
}
```

**Key Components**:
- AppTextField for inputs (use validators)
- ImagePickerService for photos
- CloudStorageService to upload
- ProductService to save to Firestore

### 5. My Products Screen
**File**: `lib/presentation/screens/farmer/my_products_screen.dart`  
**Pattern**:
```dart
class MyProductsScreen extends StatelessWidget {
  // List farmer's products from Firestore
  // Show sales count, rating for each
  // Edit/Delete buttons
  // Add new product button (FAB)
}
```

**Key Components**:
- ProductProvider with farmer filter
- ProductCard widget
- Edit/delete dialogs
- FloatingActionButton for add

### 6. Sales Analytics Screen
**File**: `lib/presentation/screens/farmer/sales_analytics_screen.dart`  
**Pattern**:
```dart
class SalesAnalyticsScreen extends StatelessWidget {
  // Revenue chart (line graph)
  // Top selling products
  // Monthly revenue card
  // Total orders card
  // Customer ratings
}
```

**Key Components**:
- fl_chart for graphs
- AnalyticsService to query Firestore
- Card widgets for stats
- Date range picker

---

## PHASE 3: COMMON FEATURES (Week 2-3)

### 7. Product Review System
**File**: `lib/presentation/screens/common/product_reviews_screen.dart`  
**Pattern**:
```dart
class ProductReviewsScreen extends StatefulWidget {
  // List of reviews for a product
  // Star rating display
  // Filter by rating
  // Add review form
  // Review cards with user info
}
```

**Key Components**:
- ReviewModel (id, userId, rating, comment, date)
- ReviewProvider for state
- ReviewCard widget
- Rating bar widget

### 8. User Profile Screen
**File**: `lib/presentation/screens/common/profile_screen.dart`  
**Pattern**:
```dart
class ProfileScreen extends StatefulWidget {
  // User profile picture, name, bio
  // Role-specific stats
  // Saved addresses section
  // Bank accounts section
  // Settings button
  // Logout button
}
```

**Key Components**:
- UserProvider for profile
- ImagePicker for avatar
- Address list
- Bank account list

---

## PATTERN TO FOLLOW FOR ALL SCREENS

### 1. Structure Template
```dart
import 'package:agrolinkbd/core/theme/app_colors.dart';
import 'package:agrolinkbd/core/theme/app_typography.dart';
import 'package:agrolinkbd/core/theme/app_widgets.dart';

class MyFeatureScreen extends StatelessWidget {
  // Key imports above
  // Use consistent naming
  // Follow Material Design 3
}
```

### 2. Always Use
- ✅ AppColors for colors (never hardcode)
- ✅ AppTypography for text (never use TextStyle directly)
- ✅ AppTextField for inputs
- ✅ AppElevatedButton for primary actions
- ✅ AppOutlinedButton for secondary actions
- ✅ AppCard for content containers
- ✅ AppValidators for form validation

### 3. Firebase Operations
```dart
// Get data from Firestore
Stream<List<Product>> getProducts() {
  return FirestoreService.instance
    .listenToCollection('products')
    .map((docs) => docs.map(Product.fromMap).toList());
}

// Save to Firestore
try {
  await FirestoreService.instance.createDocument(
    collection: 'products',
    data: product.toMap(),
  );
} on FirestoreException catch (e) {
  ExceptionHandler.handle(e);
}
```

### 4. Error Handling
```dart
// Always wrap in try-catch
try {
  // operation
} on ValidationException catch (e) {
  // Show validation error
} on NetworkException catch (e) {
  // Show network error
} on Exception catch (e) {
  ExceptionHandler.handle(e);
}
```

---

## PRIORITY ORDER (COMPLETE IN THIS ORDER)

### 🔴 CRITICAL (Must complete for MVP)
1. ✅ Cart Screen (Buyer)
2. ✅ Checkout Screen (Buyer)
3. ✅ Orders Screen (All roles)
4. ✅ Add Product (Farmer)
5. ✅ Product Reviews (Common)

### 🟠 HIGH PRIORITY
6. My Products (Farmer)
7. Job Board (Driver)
8. Bookings (Service Provider)
9. Profile Screen (Common)
10. Analytics (Farmer)

### 🟡 MEDIUM PRIORITY
11. Wishlist (Buyer)
12. Advanced Search (Buyer)
13. Order Tracking (Buyer/Farmer)
14. Invoice System (Billing)
15. Support Tickets (Common)

### 🟢 NICE TO HAVE
16. Video Calling (Chat)
17. Push Notifications (FCM)
18. Offline Mode
19. Admin Dashboard
20. Analytics Dashboard

---

## QUICK CHECKLIST FOR EACH SCREEN

- [ ] Created file in correct folder
- [ ] Imported app_colors, app_typography, app_widgets
- [ ] Used AppColors for all colors
- [ ] Used AppTypography for all text
- [ ] Used AppTextField for inputs
- [ ] Used AppElevatedButton for actions
- [ ] Added validation using AppValidators
- [ ] Error handling with ExceptionHandler
- [ ] Connected to Provider for state
- [ ] Connected to Firestore for data
- [ ] Tested on mobile and web
- [ ] No console errors/warnings
- [ ] No code duplication

---

## EXAMPLE: Complete Cart Screen

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/theme/app_colors.dart';
import 'package:agrolinkbd/core/theme/app_typography.dart';
import 'package:agrolinkbd/core/theme/app_widgets.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'কার্ট',
          style: AppTypography.h4(color: AppColors.textPrimary),
        ),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return AppEmptyState(
              title: 'আপনার কার্ট খালি',
              subtitle: 'কিছু পণ্য যোগ করুন',
              onAction: () => Navigator.pop(context),
              actionLabel: 'কেনাকাটা চালিয়ে যান',
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Items list
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    return _CartItemCard(
                      item: cart.items[index],
                      onRemove: () => cart.removeItem(index),
                      onQuantityChange: (qty) =>
                          cart.updateQuantity(index, qty),
                    );
                  },
                ),
                // Price summary
                _PriceSummary(cart: cart),
                // Checkout button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: AppElevatedButton(
                    label: 'চেকআউটে যান',
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/buyer/checkout',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final Function(int) onQuantityChange;

  const _CartItemCard({
    required this.item,
    required this.onRemove,
    required this.onQuantityChange,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.all(8),
      child: Row(
        children: [
          // Product image
          Image.network(
            item.imageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 12),
          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTypography.labelLarge(),
                ),
                Text(
                  '৳${item.price}',
                  style: AppTypography.bodyLarge(
                    color: AppColors.buyerPrimary,
                  ),
                ),
                // Quantity control
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: item.quantity > 1
                          ? () => onQuantityChange(item.quantity - 1)
                          : null,
                    ),
                    Text(item.quantity.toString()),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () =>
                          onQuantityChange(item.quantity + 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Remove button
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onRemove,
            color: AppColors.error,
          ),
        ],
      ),
    );
  }
}

class _PriceSummary extends StatelessWidget {
  final CartProvider cart;

  const _PriceSummary({required this.cart});

  @override
  Widget build(BuildContext context) {
    final subtotal = cart.subtotal;
    final tax = subtotal * 0.05; // 5% tax
    final delivery = 100; // Fixed delivery
    final total = subtotal + tax + delivery;

    return AppCard(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPriceRow('সাবটোটাল', subtotal),
          _buildPriceRow('কর (৫%)', tax),
          _buildPriceRow('ডেলিভারি', delivery),
          const Divider(),
          _buildPriceRow('মোট', total, bold: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.labelMedium(),
          ),
          Text(
            '৳${amount.toStringAsFixed(2)}',
            style: bold
                ? AppTypography.h4(color: AppColors.buyerPrimary)
                : AppTypography.bodyMedium(),
          ),
        ],
      ),
    );
  }
}
```

---

## GETTING HELP

1. **Design Questions**: Check `lib/core/theme/app_colors.dart`
2. **Widget Questions**: Check `lib/core/theme/app_widgets.dart`
3. **Validation**: Check `lib/core/utils/validators.dart`
4. **Firebase**: Check `lib/core/services/firestore_service.dart`
5. **Chat/Wallet Examples**: Check existing screens in chat/ and wallet/

---

## 🎯 SUCCESS CRITERIA

When all 20+ screens are complete:
- ✅ All roles (Farmer, Buyer, Driver, ServiceProvider) fully functional
- ✅ All CRUD operations working (Create, Read, Update, Delete)
- ✅ Real-time updates from Firestore
- ✅ Payment system integrated (Flutterwave)
- ✅ Chat system fully functional
- ✅ Wallet system operational
- ✅ Zero crashes on production
- ✅ All features tested
- ✅ **Grade**: A+ 🏆

---

**You've got this! Build fast, iterate, test thoroughly. The architecture is solid — just fill in the screens! 🚀**
