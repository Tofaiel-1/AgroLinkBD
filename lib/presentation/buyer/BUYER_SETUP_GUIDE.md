# 🛍️ Buyer Module - Setup & Initialization Guide

## ✅ Status: READY TO USE

After registering a user as a buyer, you need to:
1. Create Firestore collections (one-time setup)
2. Initialize buyer profile after registration
3. Set buyer ID on login

---

## 📋 Step 1: Create Firestore Collections

### Using Firebase Console (Recommended for First Time)

Go to **Firebase Console → Firestore → Collections** and create these collections:

```
buyer_profiles/
├── Field: name (string)
├── Field: email (string)
├── Field: phone (string)
├── Field: walletBalance (number)
├── Field: totalOrdersPlaced (number)
└── Field: createdAt (timestamp)

products/
├── Field: name (string)
├── Field: price (number)
├── Field: farmerId (string)
├── Field: description (string)
└── Field: images (array)

carts/
├── Field: buyerId (string)
├── Field: items (array)
└── Field: total (number)

orders/
├── Field: buyerId (string)
├── Field: items (array)
├── Field: totalAmount (number)
├── Field: orderStatus (string)
└── Field: createdAt (timestamp)

addresses/
├── Field: buyerId (string)
├── Field: recipientName (string)
├── Field: phoneNumber (string)
└── Field: fullAddress (string)

wishlists/
├── Field: buyerId (string)
├── Field: productId (string)
└── Field: addedAt (timestamp)

reviews/
├── Field: buyerId (string)
├── Field: productId (string)
├── Field: rating (number)
└── Field: comment (string)

categories/
├── Field: name (string)
├── Field: icon (string)
└── Field: description (string)
```

---

## 🔌 Step 2: Initialize Buyer After Registration

### In Your Registration Screen/Service:

```dart
import 'package:agrolinkbd/core/services/buyer_initialization_service.dart';

// After successful Firebase Auth registration
Future<void> registerBuyer(String name, String email, String phone, String password) async {
  try {
    // Register with Firebase Auth
    final credential = await _authService.registerWithEmail(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      // Initialize buyer profile
      final success = await BuyerInitializationService.initializeBuyerAfterRegistration(
        userId: credential.user!.uid,
        name: name,
        email: email,
        phone: phone,
      );

      if (success) {
        print('✅ Buyer registered and profile created!');
        // Navigate to buyer dashboard
        Get.toNamed('/buyer/dashboard');
      }
    }
  } catch (e) {
    print('❌ Registration failed: $e');
  }
}
```

---

## 🔐 Step 3: Initialize Buyer on Login

### In Your Login Screen/Service:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agrolinkbd/core/services/buyer_initialization_service.dart';

// After successful Firebase Auth login
Future<void> loginBuyer(String email, String password, WidgetRef ref) async {
  try {
    // Sign in with Firebase Auth
    final credential = await _authService.signInWithEmail(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      // Initialize buyer session
      final success = await BuyerInitializationService.initializeBuyerSession(
        userId: credential.user!.uid,
        ref: ref,  // Pass WidgetRef from ConsumerWidget
      );

      if (success) {
        print('✅ Buyer logged in successfully!');
        // Navigate to buyer dashboard
        Get.toNamed('/buyer/dashboard');
      }
    }
  } catch (e) {
    print('❌ Login failed: $e');
  }
}
```

---

## 🔑 Step 4: Set Buyer ID Provider (Already Done)

The `currentBuyerIdProvider` is automatically set by `BuyerInitializationService.initializeBuyerSession()`.

You can also access buyer data in any screen:

```dart
class BuyerDashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current buyer ID
    final buyerId = ref.watch(currentBuyerIdProvider);
    
    // Watch buyer profile
    final buyerProfile = ref.watch(buyerProfileProvider);
    
    return buyerProfile.when(
      data: (profile) => Text('Welcome ${profile?.name}'),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

---

## 📱 Step 5: Troubleshooting

### Issue: "No buyer profile found"

**Solution:** Make sure:
1. ✅ `buyer_profiles` collection exists in Firestore
2. ✅ `initializeBuyerAfterRegistration()` was called after registration
3. ✅ `initializeBuyerSession()` was called after login

```dart
// Check if profile exists
final exists = await BuyerInitializationService.buyerProfileExists(userId);
if (!exists) {
  print('❌ Profile does not exist, creating...');
  await BuyerInitializationService.initializeBuyerAfterRegistration(
    userId: userId,
    name: 'User',
    email: 'user@example.com',
    phone: '01711111111',
  );
}
```

---

### Issue: "Buyer dashboard shows no data"

**Solution:** Check:
1. ✅ Is `currentBuyerIdProvider` set? (Should be set after login)
2. ✅ Are there products in the `products` collection?
3. ✅ Is the buyer profile document created?

```dart
// Debug: Check current buyer ID
final buyerId = ref.watch(currentBuyerIdProvider);
print('Current Buyer ID: $buyerId');  // Should not be empty

// Debug: Check if profile exists
final profile = ref.watch(buyerProfileProvider);
print('Profile: $profile');  // Should have data
```

---

### Issue: "Can't see products after registration"

**Solution:**
1. Make sure `products` collection has documents
2. Add test products via Firebase Console:

```
Collection: products
Document ID: product_1
{
  name: "Rice",
  price: 50,
  farmerId: "farmer123",
  description: "Premium basmati rice",
  images: ["https://example.com/rice.jpg"],
  category: "rice",
  createdAt: Timestamp.now()
}
```

---

## 🚀 Quick Start Checklist

- [ ] Created Firestore collections (buyer_profiles, products, orders, etc.)
- [ ] Added security rules to Firestore (see below)
- [ ] Integrated `BuyerInitializationService` in registration screen
- [ ] Set up login to call `initializeBuyerSession()`
- [ ] Tested registration as buyer
- [ ] Verified buyer profile appears in Firestore
- [ ] Tested login as buyer
- [ ] Checked that buyer dashboard loads data

---

## 🔒 Firestore Security Rules

Add these rules to your Firestore:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Buyer profiles - only owner can read/write
    match /buyer_profiles/{buyerId} {
      allow read, write: if request.auth.uid == buyerId;
    }
    
    // Products - public read, admin write
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth.token.isAdmin == true;
    }
    
    // Carts - only buyer can access their cart
    match /carts/{cartId} {
      allow read, write: if request.auth.uid == resource.data.buyerId;
    }
    
    // Orders - only buyer can access their orders
    match /orders/{orderId} {
      allow read, write: if request.auth.uid == resource.data.buyerId;
      allow create: if request.auth.uid == request.resource.data.buyerId;
    }
    
    // Addresses - only buyer can access their addresses
    match /addresses/{addressId} {
      allow read, write: if request.auth.uid == resource.data.buyerId;
    }
    
    // Wishlists - only buyer can access their wishlist
    match /wishlists/{wishlistId} {
      allow read, write: if request.auth.uid == resource.data.buyerId;
    }
  }
}
```

---

## 📞 Support

**If buyer data still not showing after following these steps:**

1. Check browser console / Android Studio logcat for error messages
2. Verify Firestore collections are created
3. Check that buyer profile document exists in Firestore
4. Verify `currentBuyerIdProvider` is set to the user's ID
5. Check Firestore security rules allow access

Common error messages:
- ❌ "PERMISSION_DENIED" → Check security rules
- ❌ "NOT_FOUND" → Collection doesn't exist
- ❌ "No buyer profile" → Need to call `initializeBuyerAfterRegistration()`

---

## 🎯 Next Steps

1. **Create sample data**: Add test products and categories to Firestore
2. **Test complete flow**: Register → See dashboard → Browse products
3. **Enable payments**: Integrate payment gateway (stripe/bkash)
4. **Add notifications**: Set up Firebase Cloud Messaging

---

*Buyer Module Setup Guide v1.0*  
*AGROLINKBD - Agricultural Marketplace Platform*
