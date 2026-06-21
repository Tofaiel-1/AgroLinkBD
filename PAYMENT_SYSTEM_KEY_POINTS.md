# 🎯 AgroLinkBD Payment System - Key Implementation Points

## 🔥 Critical Points to Remember

### 1. **Multi-Party Relationships** (Most Important)

The system handles **cyclic payment flows** where:
- **Buyer** pays **Farmer** for products
- **Farmer** pays **Driver** for transport
- **Buyer** might also pay **Driver** for delivery
- **Farmer** pays **Shop Owner** for inputs
- **Platform** collects commission from all

```
EXAMPLE FLOW:
1. Buyer purchases Tk 1000 crops
   → Farmer receives Tk 950
   → Platform gets Tk 50

2. Farmer buys transport (Tk 200)
   → Driver receives Tk 190
   → Platform gets Tk 10

3. Farmer buys fertilizer (Tk 5000)
   → Shop receives Tk 4850
   → Platform gets Tk 150
```

### 2. **Commission Calculation** (Accuracy is Key)

```dart
// ALWAYS calculate like this:
double calculateCommission(double amount, double rate) {
  final commission = amount * rate;
  // Ensure minimum commission
  return commission < minimumCommission ? minimumCommission : commission;
}

// Rates by category:
- productSale: 5%
- supplySale: 3%
- transport: 5%
- minimum: Tk 10
```

**Never forget**: Commission affects net amount payout!

### 3. **Wallet States**

Your wallet has these distinct states:
```
Total Balance = Balance + Pending + OnHold
  ├─ Balance: Available to spend
  ├─ Pending: Awaiting weekly settlement
  └─ OnHold: Disputed transactions

Available for Withdrawal = Balance (not Pending or OnHold)
```

**Critical**: Users can ONLY withdraw from `balance`, not pending or on-hold!

### 4. **Settlement Process**

```
DAY 1-7: Transactions recorded (PENDING)
MONDAY:  Settlement batch created (APPROVED)
FRIDAY:  Payout processed (COMPLETED)
         Funds transferred to bank account
```

**Key Point**: A transaction must be `completed` BEFORE it appears in settlement!

### 5. **Validation Rules**

Every payment needs these checks:

```dart
❌ REJECT if:
- Amount < Tk 100
- Amount > Tk 10,000,000
- Amount has > 2 decimal places
- User account suspended
- User not KYC verified (for withdrawal)
- Daily/monthly withdrawal limits exceeded
- Insufficient balance

✅ ACCEPT only if all above pass
```

### 6. **Real-time Updates**

Use Riverpod StreamProviders for live updates:

```dart
// Users see balance change INSTANTLY
walletStreamProvider
  .listen((wallet) {
    // Update UI immediately
  });

// Payment status updates in real-time
paymentFlowStreamProvider
  .listen((flow) {
    // Show progress immediately
  });
```

### 7. **Error Handling**

Every function should:

```dart
try {
  // Validate input
  // Process payment
  // Update database
  // Return success
} catch (e) {
  // Log error with context
  // Return user-friendly message
  // Don't expose sensitive details
}
```

### 8. **Transaction Linking**

When payments are related, LINK them:

```dart
// Product purchase generates 3 transactions:
1. Debit from Buyer (Tk 1000)
2. Credit to Farmer (Tk 950)  
3. Commission to Platform (Tk 50)

// All 3 should have linkedTransactionIds: [1, 2, 3]
// This shows they're part of same flow
```

### 9. **Commission Scenarios**

```dart
SCENARIO 1: Buyer → Farmer (Tk 1000)
  Commission: 5% = Tk 50
  Farmer gets: Tk 950
  Platform gets: Tk 50

SCENARIO 2: Farmer → Shop Owner (Tk 5000)
  Commission: 3% = Tk 150 (below minimum: Tk 10, so use minimum)
  Shop gets: Tk 4850
  Platform gets: Tk 150

SCENARIO 3: Transport (Tk 200)
  Commission: 5% = Tk 10 (equals minimum)
  Driver gets: Tk 190
  Platform gets: Tk 10
```

### 10. **Withdrawal Validation**

```dart
// Can withdraw ONLY if:
✓ User is KYC verified
✓ Bank account verified
✓ Amount <= available balance
✓ Amount <= daily limit (Tk 50,000)
✓ Amount + today's withdrawals <= daily limit
✓ Amount + this month's withdrawals <= monthly limit

// Examples:
- If balance = Tk 100,000, can withdraw Tk 50,000 today ✓
- If already withdrew Tk 30,000 today, can only withdraw Tk 20,000 more ✓
- If monthly limit reached, must wait for next month ✗
```

---

## 🎨 UI/UX Best Practices

### 1. **Balance Display**
```
┌─────────────────────────────┐
│ Available Balance           │
│ Tk 125,500.00              │
├─────────────────────────────┤
│ Total Earned: Tk 500,000    │
│ Pending: Tk 50,000          │
└─────────────────────────────┘
```

### 2. **Transaction List**
Show:
- ✓ Transaction type (icon + label)
- ✓ Amount with direction (in/out)
- ✓ Status (completed/pending/failed)
- ✓ Date and time
- ✓ Related person/order

### 3. **Payment Progress**
```
Progress: 75% complete
├─ Buyer: ✓ Paid
├─ Farmer: ✓ Paid
├─ Driver: ◐ Processing
└─ Shop: ◯ Pending
```

### 4. **Error Messages**
Be specific:
- ❌ "Payment failed" (bad)
- ✓ "Daily withdrawal limit exceeded. Remaining: Tk 20,000" (good)

---

## 🔒 Security Checklist

- [ ] Validate every amount before processing
- [ ] Check user authorization
- [ ] Log all transactions
- [ ] Require KYC for withdrawals
- [ ] Implement rate limiting
- [ ] Use HTTPS for APIs
- [ ] Encrypt sensitive data
- [ ] Verify bank accounts
- [ ] Monitor for suspicious patterns
- [ ] Have audit trail for disputes

---

## 📊 Common Queries

### "How much can user withdraw?"
```dart
availableForWithdrawal = wallet.balance 
  - wallet.onHoldBalance 
  - min(dailyLimit, remainingDailyLimit)
  - min(monthlyLimit, remainingMonthlyLimit)
```

### "How much did user earn this month?"
```dart
monthlyEarnings = sum of all completed 
  transactions where isIncome 
  in current month
```

### "What's the commission on Tk 1000?"
```dart
commission = calculateCommission(1000, 0.05) = Tk 50
```

### "Why is withdrawal pending?"
```dart
Because settlement hasn't been processed yet.
Settlement happens weekly on Mondays.
```

---

## 🚨 Common Mistakes to Avoid

### ❌ DON'T:
```dart
// Forget to link related transactions
Transaction.linkedTransactionIds = []; // WRONG!

// Use wrong commission rate
commission = amount * 0.10; // Should be 0.05 for products

// Skip validation
if (amount > 0) { // WRONG! Should also check max
  processPayment();
}

// Forget to update wallet
transaction.save(); // Where's wallet update?

// Use pending balance for withdrawal
if (wallet.pendingBalance > amount) { // WRONG!
  processWithdrawal();
}

// Return sensitive errors to user
catch (e) {
  showError(e.toString()); // WRONG! Might expose DB details
}
```

### ✅ DO:
```dart
// Link all related transactions
transaction.linkedTransactionIds = [txn1, txn2, txn3];

// Use correct commission rates
final rate = CommissionConfig.getCommissionRate(category);

// Validate everything
final validation = PaymentServiceCore.validatePaymentAmount(amount);
if (!validation.isValid) throw validation.error!;

// Always update wallet
await updateWallet(userId, newBalance);

// Use only available balance
if (wallet.availableBalance >= amount) {
  processWithdrawal();
}

// Return user-friendly errors
catch (e) {
  showError('Payment failed. Please try again.');
  logError(e); // Log internally for debugging
}
```

---

## 🎯 Marks Distribution Strategy

### Design (25%): Show your understanding
- ✓ Explain stakeholder relationships clearly
- ✓ Document payment flows with examples
- ✓ Create clear data model diagrams
- ✓ List commission rules explicitly
- ✓ Define validation requirements

### Code (25%): Write error-free code
- ✓ Use proper error handling
- ✓ Validate all inputs
- ✓ Add comments for complex logic
- ✓ Follow Dart conventions
- ✓ Use meaningful variable names

### UI (20%): Create intuitive interfaces
- ✓ Show balance prominently
- ✓ Display payment progress clearly
- ✓ List transactions with details
- ✓ Make actions easy to find
- ✓ Use consistent styling

### Security (15%): Protect user data
- ✓ Validate amounts
- ✓ Check permissions
- ✓ Log transactions
- ✓ Handle errors safely
- ✓ Explain security measures

### Features (15%): Implement everything
- ✓ All payment types work
- ✓ Settlement processes
- ✓ Refunds supported
- ✓ Multi-party works
- ✓ Analytics included

---

## 🚀 Testing Strategy

### Unit Tests
```dart
test('Commission calculation', () {
  expect(
    CommissionConfig.calculateCommission(1000, 0.05),
    equals(50),
  );
});

test('Validation accepts valid amount', () {
  final result = PaymentServiceCore.validatePaymentAmount(1000);
  expect(result.isValid, true);
});

test('Validation rejects invalid amount', () {
  final result = PaymentServiceCore.validatePaymentAmount(50); // Below min
  expect(result.isValid, false);
});
```

### Integration Tests
```dart
test('Complete payment flow', () async {
  // Create payment
  // Verify transaction created
  // Check wallet updated
  // Confirm settlement batch created
});
```

### UI Tests
```dart
test('Wallet displays balance correctly', () {
  // Mount screen
  // Verify balance shown
  // Verify pending balance shown
  // Verify buttons available
});
```

---

## 📱 Screen Flow

```
Main Screen
├─ Payment Method Selection
│  ├─ Enter Amount
│  └─ Confirm Details
├─ Payment Confirmation
│  ├─ Verify parties
│  └─ Process Payment
├─ Payment Status
│  └─ Real-time tracking
├─ Wallet Dashboard
│  ├─ View Balance
│  └─ Recent Transactions
└─ Transaction History
   ├─ Filter & Search
   └─ View Details
```

---

## 💡 Pro Tips

1. **Use Enums** for states - Prevents invalid states
2. **Use Sealed Classes** for results - Type-safe error handling
3. **Cache Frequently** - Reduce database calls
4. **Log Everything** - Helps debugging
5. **Test Edge Cases** - Zero amount, max amount, negative, decimals
6. **Version APIs** - Ready for future changes
7. **Document Assumptions** - Why is commission 5%?
8. **Use Constants** - Don't hardcode rates everywhere
9. **Create Migrations** - Plan for Firestore schema changes
10. **Monitor Performance** - Payment system must be fast

---

**Remember**: A payment system is **TRUST**. Users trust you with their money. Every detail matters!

Good luck with your implementation! 🚀
