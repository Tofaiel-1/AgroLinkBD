# 🎯 AgroLinkBD Payment System - Implementation Guide

## Quick Start

### Files Created

#### Data Models
1. **`lib/core/models/enhanced_transaction_model.dart`** - Enhanced transaction tracking
2. **`lib/core/models/payment_flow_model.dart`** - Multi-party payment flows
3. **`lib/core/models/settlement_model.dart`** - Settlement and withdrawal management

#### Core Services
4. **`lib/core/services/payment_service_core.dart`** - Payment logic and validation

#### UI Screens
5. **`lib/presentation/screens/payment/payment_flow_tracking_screen.dart`** - Track multi-party payments
6. **`lib/presentation/screens/payment/wallet_dashboard_screen.dart`** - Wallet management

---

## System Architecture Overview

### Payment Cycle

```
1. BUYER INITIATES → Creates PaymentFlow
2. SYSTEM VALIDATES → Checks balances, amounts, eligibility
3. PAYMENT PROCESSED → Multi-party transactions created
4. SPLITS EXECUTED → Each party receives their portion
5. SETTLEMENT PENDING → Amount awaits settlement period
6. SETTLEMENT PROCESSED → Final payout to bank/wallet
```

### Data Flow

```
User Action
    ↓
PaymentService (Validation)
    ↓
PaymentFlow Created
    ↓
Multiple Transactions Generated
    ↓
Wallets Updated
    ↓
Settlement Batch Created
    ↓
Payout Completed
```

---

## Step-by-Step Implementation

### Step 1: Setup Models in Firestore

```dart
// Initialize Firestore collections
final firestore = FirebaseFirestore.instance;

// Create indexes for common queries
// Collections needed:
// - transactions/
// - payments/
// - wallets/
// - settlements/
// - withdrawal_requests/
// - payment_flows/
```

### Step 2: Create Providers (Riverpod)

Create file: `lib/core/providers/payment_providers.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enhanced_transaction_model.dart';
import '../models/payment_flow_model.dart';

// Wallet Provider
final userWalletProvider = FutureProvider.family<Wallet, String>((ref, userId) async {
  // Fetch from Firestore
  final doc = await FirebaseFirestore.instance
      .collection('wallets')
      .doc(userId)
      .get();
  return Wallet.fromJson(doc.data()!);
});

// Transactions Provider
final userTransactionsProvider = FutureProvider.family<List<Transaction>, String>(
  (ref, userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('payerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    return snapshot.docs
        .map((doc) => Transaction.fromJson(doc.data()))
        .toList();
  },
);

// Payment Flow Provider
final paymentFlowProvider = FutureProvider.family<PaymentFlow, String>(
  (ref, flowId) async {
    final doc = await FirebaseFirestore.instance
        .collection('payment_flows')
        .doc(flowId)
        .get();
    return PaymentFlow.fromJson(doc.data()!);
  },
);
```

### Step 3: Implement Payment Scenarios

#### Scenario: Buyer Purchases from Farmer

```dart
Future<void> buyerPurchaseProduct({
  required String buyerId,
  required String farmerId,
  required String productId,
  required double amount,
  required PaymentMethod method,
  String? driverId,
  double? transportCost,
}) async {
  try {
    // 1. Validate payment
    final validation = PaymentServiceCore.validatePaymentAmount(amount);
    if (!validation.isValid) throw validation.error!;
    
    // 2. Create payment flow
    final splits = PaymentServiceCore.calculateBuyerToFarmerSplit(
      totalAmount: amount,
      farmerId: farmerId,
      farmerName: 'Farmer Name', // Get from DB
    );
    
    final flow = PaymentServiceCore.createPaymentFlow(
      flowType: PaymentFlowType.buyerToFarmer,
      initiatorId: buyerId,
      primaryRecipientId: farmerId,
      totalAmount: amount,
      parties: [
        PaymentParty(
          userId: farmerId,
          userType: 'farmer',
          amount: amount - CommissionConfig.calculateCommission(amount, CommissionConfig.productSaleCommission),
          status: TransactionStatus.pending,
        ),
      ],
      splits: splits,
      relatedOrderId: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      relatedProductId: productId,
    );
    
    // 3. Save payment flow
    await FirebaseFirestore.instance
        .collection('payment_flows')
        .doc(flow.id)
        .set(flow.toJson());
    
    // 4. Create transactions
    final debitTxn = PaymentServiceCore.createTransaction(
      payerId: buyerId,
      payeeId: farmerId,
      amount: amount,
      category: TransactionCategory.productSale,
      method: method,
      description: 'Product purchase',
      orderId: flow.id,
      productId: productId,
    );
    
    // 5. Save debit transaction
    await FirebaseFirestore.instance
        .collection('transactions')
        .doc(debitTxn.id)
        .set(debitTxn.toJson());
    
    // 6. Update payment flow with transaction ID
    await FirebaseFirestore.instance
        .collection('payment_flows')
        .doc(flow.id)
        .update({
          'transactionIds': [debitTxn.id],
          'pendingTransactionIds': [debitTxn.id],
        });
    
    // 7. Update wallets
    await _updateWalletBalance(buyerId, -amount);
    await _updateWalletBalance(farmerId, splits[0].amount);
    
  } catch (e) {
    print('Error: $e');
    rethrow;
  }
}
```

### Step 4: Handle Multi-party Transport Payment

```dart
Future<void> createSharedTransportPayment({
  required String buyerId,
  required String farmerId,
  required String driverId,
  required double buyerShare,
  required double farmerShare,
  required String transportId,
}) async {
  final totalAmount = buyerShare + farmerShare;
  
  // Calculate splits
  final splits = PaymentServiceCore.calculateSharedTransportSplit(
    totalAmount: totalAmount,
    driverId: driverId,
    buyerShare: buyerShare,
    farmerShare: farmerShare,
  );
  
  // Create payment flow
  final flow = PaymentServiceCore.createPaymentFlow(
    flowType: PaymentFlowType.multiPartyTransport,
    initiatorId: buyerId,
    primaryRecipientId: driverId,
    totalAmount: totalAmount,
    parties: [
      PaymentParty(
        userId: buyerId,
        userType: 'buyer',
        amount: buyerShare,
        status: TransactionStatus.pending,
      ),
      PaymentParty(
        userId: farmerId,
        userType: 'farmer',
        amount: farmerShare,
        status: TransactionStatus.pending,
      ),
      PaymentParty(
        userId: driverId,
        userType: 'driver',
        amount: totalAmount - CommissionConfig.calculateCommission(totalAmount, CommissionConfig.transportCommission),
        status: TransactionStatus.pending,
      ),
    ],
    splits: splits,
    relatedTransportId: transportId,
  );
  
  // Save and process
  await FirebaseFirestore.instance
      .collection('payment_flows')
      .doc(flow.id)
      .set(flow.toJson());
}
```

### Step 5: Settlement Processing

```dart
Future<void> processWeeklySettlement({required String userId}) async {
  try {
    // 1. Get all completed transactions
    final snapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('payeeId', isEqualTo: userId)
        .where('status', isEqualTo: 'completed')
        .where('createdAt',
            isGreaterThanOrEqualTo: DateTime.now().subtract(Duration(days: 7)))
        .get();
    
    final transactions = snapshot.docs
        .map((doc) => Transaction.fromJson(doc.data()))
        .toList();
    
    // 2. Create settlement
    final settlement = SettlementServiceCore.createSettlement(
      userId: userId,
      transactions: transactions,
      period: SettlementPeriod.weekly,
    );
    
    // 3. Save settlement
    await FirebaseFirestore.instance
        .collection('settlements')
        .doc(settlement.id)
        .set(settlement.toJson());
    
    // 4. Update wallet pending balance
    await FirebaseFirestore.instance
        .collection('wallets')
        .doc(userId)
        .update({
          'pendingBalance': FieldValue.increment(settlement.netAmount),
          'lastSettlementDate': DateTime.now(),
        });
    
    // 5. Mark transactions as settled
    for (final txn in transactions) {
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(txn.id)
          .update({
            'isSettled': true,
            'settledAt': DateTime.now(),
            'settlementBatchId': settlement.id,
          });
    }
  } catch (e) {
    print('Settlement error: $e');
    rethrow;
  }
}
```

### Step 6: Withdrawal Processing

```dart
Future<void> requestWithdrawal({
  required String userId,
  required double amount,
  required String bankAccountId,
}) async {
  try {
    // 1. Validate withdrawal
    final wallet = await _getWallet(userId);
    final validation = WalletServiceCore.canWithdraw(
      availableBalance: wallet.availableBalance,
      amount: amount,
      dailyWithdrawn: wallet.totalWithdrawToday ?? 0,
      monthlyWithdrawn: wallet.totalWithdrawThisMonth ?? 0,
      isKycVerified: wallet.isKycVerified,
    );
    
    if (!validation.isValid) throw validation.error!;
    
    // 2. Create withdrawal request
    final request = WithdrawalRequest(
      id: 'WD-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      amount: amount,
      bankAccountId: bankAccountId,
      status: WithdrawalStatus.pending,
      createdAt: DateTime.now(),
    );
    
    // 3. Save request
    await FirebaseFirestore.instance
        .collection('withdrawal_requests')
        .doc(request.id)
        .set(request.toJson());
    
    // 4. Update wallet
    await FirebaseFirestore.instance
        .collection('wallets')
        .doc(userId)
        .update({
          'balance': FieldValue.increment(-amount),
          'onHoldBalance': FieldValue.increment(amount),
        });
  } catch (e) {
    print('Withdrawal error: $e');
    rethrow;
  }
}
```

---

## Integration Points

### With Order System

```dart
// When order is created
// 1. Create PaymentFlow with orderData
// 2. Store flowId in order document
// 3. Update order status based on payment status

final orderRef = FirebaseFirestore.instance
    .collection('orders')
    .doc(orderId);

await orderRef.update({
  'paymentFlowId': paymentFlow.id,
  'paymentStatus': 'pending',
});
```

### With Transport System

```dart
// When transport request is accepted
// 1. Create payment flow for driver
// 2. Track payment status with transport status

final transportRef = FirebaseFirestore.instance
    .collection('transport_requests')
    .doc(transportId);

await transportRef.update({
  'paymentFlowId': paymentFlow.id,
  'paymentStatus': 'pending',
});
```

---

## Key Features to Implement

### 1. Real-time Balance Updates
```dart
// Stream wallet balance changes
Stream<Wallet> watchWallet(String userId) {
  return FirebaseFirestore.instance
      .collection('wallets')
      .doc(userId)
      .snapshots()
      .map((doc) => Wallet.fromJson(doc.data()!));
}
```

### 2. Payment Status Notifications
```dart
// Send notifications on payment status changes
Future<void> _notifyPaymentStatus(
  String userId,
  PaymentFlow flow,
  String newStatus,
) async {
  // Send FCM notification
  // Update local notification
  // Update UI via Riverpod
}
```

### 3. Dispute Resolution
```dart
// Create dispute
Future<void> createDispute({
  required String transactionId,
  required String reason,
  required List<String> evidenceUrls,
}) async {
  // Save dispute
  // Move funds to on-hold
  // Notify admin
}
```

---

## Testing Checklist

- [ ] Transaction creation with correct commission calculation
- [ ] Multi-party payment splits
- [ ] Wallet balance updates
- [ ] Settlement batch processing
- [ ] Withdrawal request handling
- [ ] Refund processing
- [ ] Dispute creation and resolution
- [ ] Real-time updates via Riverpod
- [ ] Error handling and validation
- [ ] UI screens display correctly
- [ ] Payment history tracking
- [ ] Commission breakdown accuracy

---

## Deployment Checklist

- [ ] All models imported correctly
- [ ] Firestore rules updated
- [ ] Firebase indexes created
- [ ] Test payments processed
- [ ] Settlement cron jobs scheduled
- [ ] Notification system configured
- [ ] Error tracking enabled
- [ ] Performance monitoring active
- [ ] Backup and recovery tested
- [ ] Admin dashboard accessible

---

## Performance Optimization

### Database Queries
```dart
// Create composite indexes for:
// transactions: payerId + status + createdAt
// transactions: payeeId + status + createdAt
// settlements: userId + status + createdAt
// wallets: userId (primary)
```

### Caching
```dart
// Cache frequently accessed data
// Use Riverpod cache invalidation
// Implement offline capability
```

---

## Security Considerations

1. **Validation**: All amounts validated before processing
2. **Authorization**: Ensure user owns wallet
3. **Encryption**: Sensitive data encrypted
4. **Audit Trail**: All transactions logged
5. **Rate Limiting**: Prevent abuse
6. **KYC Verification**: Required for withdrawals

---

## Commission Structure

| Category | Rate | Min | Max |
|----------|------|-----|-----|
| Product Sales | 5% | Tk 10 | Tk 50,000 |
| Supply Sales | 3% | Tk 5 | Tk 30,000 |
| Transport | 5% | Tk 5 | Tk 10,000 |

---

## Next Steps

1. **Implement Providers** - Create all Riverpod providers
2. **Add Firebase Rules** - Secure Firestore access
3. **Setup Notifications** - FCM integration
4. **Create Admin Dashboard** - Settlement management
5. **Add Analytics** - Track payment metrics
6. **Implement Cron Jobs** - Scheduled settlements

---

**Last Updated**: 2024
**Status**: Ready for Implementation
