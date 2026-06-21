# 🚀 AgroLinkBD Advanced Payment System - Complete Design Guide

## Table of Contents
1. [System Architecture](#system-architecture)
2. [Key Stakeholders & Payment Flows](#key-stakeholders--payment-flows)
3. [Data Models](#data-models)
4. [Payment Flow Scenarios](#payment-flow-scenarios)
5. [Wallet & Settlement System](#wallet--settlement-system)
6. [Error Handling & Validation](#error-handling--validation)
7. [Implementation Checklist](#implementation-checklist)

---

## System Architecture

### Overview
A **multi-party payment ecosystem** where multiple stakeholders (Buyers, Farmers, Drivers, Shop Owners) perform cyclic transactions with proper tracking, settlement, and commission handling.

```
┌─────────────────────────────────────────────────────────────────┐
│                    AgroLinkBD Payment Ecosystem                 │
└─────────────────────────────────────────────────────────────────┘

STAKEHOLDERS:
1. Buyer → Customer purchasing crops/fertilizers
2. Farmer → Producer selling crops
3. Driver → Transportation provider
4. Shop Owner → Retailer selling fertilizers/pesticides
5. Platform → Collects commission (Admin)

PAYMENT FLOWS:
┌──────────────────────────────────────────────────────────┐
│ FLOW 1: Buyer → Farmer (Direct Product Purchase)         │
│                                                           │
│ Buyer sends payment → Farmer receives (minus 5% comm)    │
│ Driver (optional) gets paid by Farmer or Buyer           │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│ FLOW 2: Farmer → Shop Owner (Input Supply)               │
│                                                           │
│ Farmer buys fertilizer → Shop Owner receives payment     │
│ (with 3% commission to platform)                         │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│ FLOW 3: Transport Payment (Multi-party)                  │
│                                                           │
│ Both Buyer & Farmer can pay Driver for transport         │
│ Driver settles with platform (5% commission)             │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│ FLOW 4: Commission & Settlement                          │
│                                                           │
│ All transactions tracked → Daily/Weekly settlement       │
│ Platform retains 3-5% commission                         │
└──────────────────────────────────────────────────────────┘
```

---

## Key Stakeholders & Payment Flows

### 1. **Buyer → Farmer (Product Purchase)**
```
Customer: BUYER
Seller: FARMER
Product: Crops/Agricultural Products
Payment: Direct payment from buyer to farmer

BREAKDOWN:
- Buyer Amount: Tk 1000
  ├─ Farmer receives: Tk 950 (95%)
  └─ Platform commission: Tk 50 (5%)
  
- Optional: Transportation
  - Driver cost: Tk 200
  - Can be paid by Buyer OR split with Farmer
```

### 2. **Farmer → Shop Owner (Input Supply)**
```
Customer: FARMER
Seller: SHOP OWNER
Product: Fertilizers, Seeds, Pesticides
Payment: Farmer purchases inputs for farming

BREAKDOWN:
- Farmer Amount: Tk 5000
  ├─ Shop Owner receives: Tk 4850 (97%)
  └─ Platform commission: Tk 150 (3%)
```

### 3. **Driver - Transportation Payment**
```
Customer: BUYER or FARMER
Service: DRIVER
Service: Transport of goods

PAYMENT MODELS:
a) Driver Hired by Farmer:
   - Farmer pays Driver direct
   - Farmer might get reimbursed by Buyer
   
b) Driver Hired by Buyer:
   - Buyer pays Driver direct
   - Driver handles pickup & delivery
   
c) Split Payment:
   - Buyer pays delivery portion
   - Farmer pays pickup/handling portion

BREAKDOWN:
- Transport Cost: Tk 200
  ├─ Driver receives: Tk 190 (95%)
  └─ Platform commission: Tk 10 (5%)
```

### 4. **Commission & Settlement**
```
All transactions generate commission for platform:
- Product Sales: 5% commission
- Supply Purchases: 3% commission
- Transport Services: 5% commission

SETTLEMENT CYCLE:
├─ Daily: Transactions recorded
├─ Weekly: Commission calculated
├─ Bi-weekly: Payouts to vendors
└─ Real-time: Admin view of pending settlements
```

---

## Data Models

### Core Models

#### 1. **Wallet Model**
```dart
class Wallet {
  final String id;
  final String userId;          // Owner of wallet
  final double balance;          // Current balance
  final double totalEarned;      // Lifetime earnings
  final double totalSpent;       // Lifetime spent
  final double pendingBalance;   // Awaiting settlement
  final bool canWithdraw;        // KYC verified
  final List<String> bankAccounts;
  final DateTime lastSettlementDate;
  final Map<String, double> categoryBreakdown; // By role
}
```

#### 2. **Transaction Model** (Enhanced)
```dart
class Transaction {
  final String id;
  final String payerId;          // Who pays
  final String payeeId;          // Who receives
  final double amount;           // Base amount
  final TransactionType type;    // credit/debit/refund
  final TransactionCategory category; // product/transport/supply/commission
  final TransactionStatus status;
  final PaymentMethod method;
  final String description;
  
  // Payment Flow Tracking
  final String? relatedOrderId;
  final String? relatedTransportId;
  final List<String> linkedTransactionIds; // For cyclic payments
  
  // Commission Breakdown
  final double commissionAmount;
  final double commissionRate;
  final String? commissionPayeeId;
  
  // Settlement Info
  final bool isSettled;
  final DateTime settledAt;
  final String? settlementBatchId;
  
  // Audit Trail
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? failureReason;
  final List<TransactionLog> logs; // For debugging
}
```

#### 3. **Payment Flow Model**
```dart
class PaymentFlow {
  final String id;
  final PaymentFlowType flowType;
  final String initiatorId;      // Who started payment
  final String recipientId;      // Primary recipient
  
  // Multi-party tracking
  final List<PaymentParty> parties;
  
  // Order/Transport reference
  final String? relatedOrderId;
  final String? relatedTransportId;
  
  // Amount breakdown
  final double totalAmount;
  final List<PaymentSplit> splits;
  
  // Status tracking
  final PaymentFlowStatus status;
  final List<String> completedTransactionIds;
  final List<String> pendingTransactionIds;
  
  // Dates
  final DateTime createdAt;
  final DateTime completedAt;
}

enum PaymentFlowType {
  buyerToFarmer,      // Buyer purchases from farmer
  farmerToShopOwner,  // Farmer buys inputs
  buyerToDriver,      // Buyer pays transport
  farmerToDriver,     // Farmer pays transport
  multiPartyTransport, // Both pay driver
  refund,            // Return payment
  commission,        // Platform commission
}

class PaymentParty {
  final String userId;
  final UserType userType;
  final double amount;
  final TransactionStatus status;
  final String? notes;
}

class PaymentSplit {
  final String recipientId;
  final double amount;
  final double percentage;
  final String reason; // 'principal', 'commission', 'refund'
  final TransactionStatus status;
}
```

#### 4. **Settlement Model**
```dart
class Settlement {
  final String id;
  final String userId;
  final double totalAmount;
  final double commissionDeducted;
  final double netAmount;
  
  // Details
  final List<String> transactionIds;
  final DateTime startDate;
  final DateTime endDate;
  final SettlementStatus status;
  
  // Payout
  final String? paymentMethod;
  final String? bankAccount;
  final DateTime? settledAt;
  final String? settlementProofId;
}

enum SettlementStatus {
  pending,
  approved,
  processing,
  completed,
  failed,
  cancelled
}
```

---

## Payment Flow Scenarios

### Scenario 1: Simple Product Purchase (Buyer → Farmer)

**Initial Order:**
- Buyer orders 10kg Rice from Farmer
- Product price: Tk 1000
- Transport needed: Yes (Tk 200)

**Payment Steps:**
```
1. ORDER CREATED
   Order ID: ORD-001
   Buyer: BUYER-001
   Farmer: FARMER-001
   Amount: Tk 1000

2. PAYMENT INITIATED
   Transaction 1: Buyer pays Tk 1200 (product + transport)
   Payment Method: bKash
   Status: Processing

3. PAYMENT CONFIRMED
   ✓ Tk 1200 received from Buyer
   
4. AMOUNT DISTRIBUTION
   Transaction 1.1: FARMER-001 receives Tk 950 (product)
   Transaction 1.2: PLATFORM commission Tk 50
   Transaction 1.3: DRIVER-001 receives Tk 190 (transport)
   Transaction 1.4: PLATFORM commission Tk 10 (transport)

5. WALLET UPDATE
   Buyer: -Tk 1200
   Farmer: +Tk 950
   Driver: +Tk 190
   Platform: +Tk 60
```

### Scenario 2: Multi-party Transport (Buyer + Farmer → Driver)

**Transport Order:**
- Farmer orders transport for delivery
- Pickup: Farmer's location
- Delivery: Buyer's location
- Both want to share payment

**Payment Steps:**
```
1. TRANSPORT REQUEST
   Transport ID: TRN-001
   Farmer initiates: FARMER-001
   Buyer agrees to share: BUYER-001
   Driver: DRIVER-002
   Total cost: Tk 400

2. PAYMENT SPLIT AGREEMENT
   Farmer pays: Tk 200 (60%)
   Buyer pays: Tk 200 (50%)
   Commission: Tk 40 (10%)

3. PAYMENTS EXECUTED
   Transaction 1: Farmer pays Tk 200
   Transaction 2: Buyer pays Tk 200
   
4. DRIVER SETTLEMENT
   Transaction 3: Driver receives Tk 380 (95% of Tk 400)
   Transaction 4: Platform gets Tk 20

5. WALLET UPDATE
   Farmer: -Tk 200
   Buyer: -Tk 200
   Driver: +Tk 380
   Platform: +Tk 40
```

### Scenario 3: Supply Purchase (Farmer → Shop Owner)

**Supply Order:**
- Farmer buys fertilizer
- Farmer account has pending balance

**Payment Steps:**
```
1. ORDER CREATED
   Order ID: SUP-001
   Buyer (Farmer): FARMER-001
   Seller (Shop): SHOP-001
   Amount: Tk 5000

2. PAYMENT INITIATED
   Using Farmer's wallet balance

3. PAYMENT CONFIRMED
   ✓ Tk 5000 from Farmer's wallet
   
4. AMOUNT DISTRIBUTION
   Transaction 1: SHOP-001 receives Tk 4850 (97%)
   Transaction 2: PLATFORM commission Tk 150 (3%)

5. WALLET UPDATE
   Farmer: -Tk 5000
   Shop: +Tk 4850
   Platform: +Tk 150

6. SETTLEMENT
   Shop Owner can request withdrawal
   Platform processes weekly settlement
```

### Scenario 4: Refund & Dispute (Cyclic Payment Reversal)

**Dispute Case:**
- Buyer received damaged goods
- Wants refund from Farmer
- Farmer wants to claim from original seller

**Payment Steps:**
```
1. REFUND INITIATED
   Original Transaction: TXN-001 (Buyer paid Tk 1000)
   Refund Amount: Tk 1000
   Reason: Product damage
   Status: Pending Farmer approval

2. FARMER APPROVES
   Farmer processes refund
   
3. PAYMENT REVERSAL
   Transaction 1: FARMER-001 pays back Tk 950
   Transaction 2: PLATFORM credits refund commission Tk 50
   Transaction 3: Driver refund (if applicable) Tk 190
   
4. BUYER RECEIVES
   Refund: Tk 1000 (to original payment method)
   Timeline: 3-5 business days

5. WALLET UPDATE
   Buyer: +Tk 1000
   Farmer: -Tk 950
   Driver: -Tk 190 (or commission negotiated)
   Platform: -Tk 60
```

---

## Wallet & Settlement System

### Wallet States

```
┌────────────────────────────────────────┐
│         WALLET BALANCE BREAKDOWN        │
├────────────────────────────────────────┤
│ Total Balance       Tk 50,000           │
│ ├─ Available        Tk 30,000 (60%)     │
│ ├─ Pending Settlement Tk 15,000 (30%)   │
│ └─ On Hold          Tk 5,000 (10%)      │
│                                        │
│ Lifetime Earned     Tk 500,000          │
│ ├─ From Sales       Tk 450,000          │
│ ├─ From Transport   Tk 30,000           │
│ └─ From Incentives  Tk 20,000           │
│                                        │
│ Lifetime Spent      Tk 200,000          │
│ ├─ Purchases        Tk 150,000          │
│ ├─ Transport        Tk 30,000           │
│ └─ Refunds          Tk 20,000           │
└────────────────────────────────────────┘
```

### Settlement Process

```
DAILY PROCESS:
├─ All transactions recorded in pending
├─ System calculates commissions
└─ Status: PENDING

WEEKLY PROCESS (Every Monday):
├─ Aggregate user transactions
├─ Deduct platform commission (3-5%)
├─ Verify KYC status
├─ Create settlement batches
└─ Status: APPROVED

BI-WEEKLY PROCESS (Alternate Fridays):
├─ Process bank transfers
├─ Update wallet balances
├─ Send settlement reports
└─ Status: COMPLETED

REAL-TIME DASHBOARD:
├─ Pending amount
├─ Settlement date
├─ Payment method
├─ Settlement history
└─ Withdrawal requests
```

---

## Error Handling & Validation

### Validation Rules

```dart
// Payment amount validation
- Minimum: Tk 100 (platform limit)
- Maximum: Tk 10,000,000 (regulatory limit)
- Precision: 2 decimal places

// User validation
- KYC verified required for withdrawal
- Active account status required
- No suspended/banned accounts

// Transaction validation
- Unique transaction ID
- Matching payer-payee
- Valid payment method
- Sufficient balance

// Settlement validation
- Minimum transaction count: 1
- Maximum pending days: 30
- Commission calculation verified
- KYC status confirmed
```

### Error Handling

```dart
enum PaymentError {
  insufficientBalance,
  invalidAmount,
  paymentMethodNotAvailable,
  userNotVerified,
  dailyLimitExceeded,
  transactionDuplicate,
  paymentGatewayError,
  networkError,
  timeoutError,
  unknownError
}
```

---

## Implementation Checklist

### Phase 1: Data Models (Week 1)
- [ ] Enhanced Transaction Model
- [ ] Wallet Model
- [ ] PaymentFlow Model
- [ ] Settlement Model
- [ ] Payment State Enums
- [ ] Validation utilities

### Phase 2: Core Services (Week 1-2)
- [ ] PaymentService (core logic)
- [ ] WalletService (balance management)
- [ ] SettlementService (commission & payouts)
- [ ] Transaction Logger
- [ ] Error Handler
- [ ] Audit Trail

### Phase 3: Providers & State (Week 2)
- [ ] Payment Providers (Riverpod)
- [ ] Wallet Providers
- [ ] Transaction Providers
- [ ] Settlement Providers
- [ ] User Wallet Provider

### Phase 4: UI Screens (Week 2-3)
- [ ] Enhanced Payment Method Screen
- [ ] Payment Confirmation Screen (multi-party)
- [ ] Transaction History Screen (advanced)
- [ ] Wallet Dashboard Screen
- [ ] Settlement Status Screen
- [ ] Refund/Dispute Screen

### Phase 5: Integration (Week 3-4)
- [ ] Order payment flow
- [ ] Transport payment flow
- [ ] Supply purchase flow
- [ ] Refund flow
- [ ] Settlement cron jobs
- [ ] Webhook handlers

### Phase 6: Testing & Optimization (Week 4)
- [ ] Unit tests
- [ ] Integration tests
- [ ] Edge cases
- [ ] Performance optimization
- [ ] Security review
- [ ] User acceptance testing

---

## Key Features

### ✅ Multi-party Payment Support
- Track payments between multiple stakeholders
- Handle split payments efficiently
- Support cyclic payment flows

### ✅ Wallet Management
- Real-time balance updates
- Pending balance tracking
- Commission deduction
- Withdrawal management

### ✅ Settlement System
- Automated commission calculation
- Scheduled payouts
- Settlement history tracking
- Dispute resolution

### ✅ Security & Compliance
- KYC verification required
- Transaction logging
- Audit trail
- Fraud detection
- PCI DSS compliance

### ✅ Reporting & Analytics
- Transaction analytics
- User payment statistics
- Commission tracking
- Settlement reports
- Dispute tracking

---

## API Endpoints (for backend)

```
POST   /api/payments/initiate
GET    /api/payments/{paymentId}
POST   /api/payments/{paymentId}/confirm
POST   /api/payments/{paymentId}/refund

GET    /api/wallets/{userId}
POST   /api/wallets/{userId}/withdraw
GET    /api/wallets/{userId}/transactions

GET    /api/settlements/{userId}
POST   /api/settlements/{userId}/request
GET    /api/settlements/{settlementId}

GET    /api/transactions/{userId}
GET    /api/transactions/{userId}/analytics
```

---

## Database Schema (Firestore Collections)

```
payments/
  {paymentId}
    - id
    - payerId
    - payeeId
    - amount
    - method
    - status
    - createdAt

transactions/
  {transactionId}
    - id
    - payerId
    - payeeId
    - amount
    - type
    - category
    - status
    - linkedTransactionIds[]
    - createdAt

wallets/
  {userId}
    - userId
    - balance
    - totalEarned
    - totalSpent
    - pendingBalance
    - lastSettled

settlements/
  {settlementId}
    - userId
    - amount
    - status
    - startDate
    - endDate
    - transactionIds[]

transaction_logs/
  {logId}
    - transactionId
    - action
    - timestamp
    - details
```

---

## Commission Structure

```
FARMER SELLING CROPS
├─ Commission Rate: 5%
├─ Min Commission: Tk 10
└─ Max Commission: Tk 50,000

SHOP OWNER SELLING INPUTS
├─ Commission Rate: 3%
├─ Min Commission: Tk 5
└─ Max Commission: Tk 30,000

DRIVER PROVIDING TRANSPORT
├─ Commission Rate: 5%
├─ Min Commission: Tk 5
└─ Max Commission: Tk 10,000

PLATFORM INCENTIVES
├─ Early Settlement: +2% discount
├─ Premium Users: +5% earnings
└─ Referral Bonus: Fixed Tk 100
```

---

## Expected Marks Distribution

```
✨ DESIGN & ARCHITECTURE: 25%
  ├─ Multi-party payment system design
  ├─ Clear stakeholder relationships
  ├─ Comprehensive data models
  └─ Scalable architecture

💻 CODE QUALITY: 25%
  ├─ Clean, error-free code
  ├─ Proper design patterns
  ├─ Unit tests
  └─ Documentation

🎨 UI/UX: 20%
  ├─ Intuitive payment flows
  ├─ Clear transaction history
  ├─ Wallet management interface
  └─ Responsive design

🔒 SECURITY & VALIDATION: 15%
  ├─ Input validation
  ├─ Transaction security
  ├─ Error handling
  └─ Audit trail

📊 FEATURES & COMPLETENESS: 15%
  ├─ All payment types implemented
  ├─ Settlement system working
  ├─ Refund mechanism
  └─ Analytics dashboard
```

---

**End of Design Document**
