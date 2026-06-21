# 📊 AgroLinkBD Payment System - Visual Architecture Guide

## 🏗️ System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         AGROLINKBD APP                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                    PRESENTATION LAYER                        │  │
│  │ ┌────────────────────────────────────────────────────────┐  │  │
│  │ │   Payment Flow Tracking Screen                         │  │  │
│  │ │   - Real-time payment progress                         │  │  │
│  │ │   - Multi-party status tracking                        │  │  │
│  │ │   - Amount breakdown display                           │  │  │
│  │ └────────────────────────────────────────────────────────┘  │  │
│  │ ┌────────────────────────────────────────────────────────┐  │  │
│  │ │   Wallet Dashboard Screen                              │  │  │
│  │ │   - Balance overview                                   │  │  │
│  │ │   - Transaction history                                │  │  │
│  │ │   - Withdrawal requests                                │  │  │
│  │ └────────────────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                            ↑                                        │
│                   RIVERPOD PROVIDERS                                │
│                            ↓                                        │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                   STATE MANAGEMENT                           │  │
│  │  ┌──────────────────────────────────────────────────────┐   │  │
│  │  │  Wallet Providers                                    │   │  │
│  │  │  - userWalletProvider (FutureProvider)              │   │  │
│  │  │  - walletStreamProvider (StreamProvider)            │   │  │
│  │  └──────────────────────────────────────────────────────┘   │  │
│  │  ┌──────────────────────────────────────────────────────┐   │  │
│  │  │  Transaction Providers                               │   │  │
│  │  │  - userTransactionsProvider (FutureProvider)        │   │  │
│  │  │  - transactionStreamProvider (StreamProvider)       │   │  │
│  │  └──────────────────────────────────────────────────────┘   │  │
│  │  ┌──────────────────────────────────────────────────────┐   │  │
│  │  │  Settlement Providers                                │   │  │
│  │  │  - userSettlementsProvider (FutureProvider)         │   │  │
│  │  │  - settlementStreamProvider (StreamProvider)        │   │  │
│  │  └──────────────────────────────────────────────────────┘   │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                            ↑                                        │
│                    BUSINESS LOGIC                                   │
│                            ↓                                        │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │              CORE SERVICES LAYER                             │  │
│  │  ┌──────────────────────────────────────────────────────┐   │  │
│  │  │  PaymentServiceCore                                  │   │  │
│  │  │  - validatePaymentAmount()                           │   │  │
│  │  │  - createTransaction()                               │   │  │
│  │  │  - createPaymentFlow()                               │   │  │
│  │  │  - calculateCommission()                             │   │  │
│  │  └──────────────────────────────────────────────────────┘   │  │
│  │  ┌──────────────────────────────────────────────────────┐   │  │
│  │  │  WalletServiceCore                                   │   │  │
│  │  │  - calculateBalance()                                │   │  │
│  │  │  - canWithdraw()                                     │   │  │
│  │  │  - calculateCategoryBreakdown()                      │   │  │
│  │  └──────────────────────────────────────────────────────┘   │  │
│  │  ┌──────────────────────────────────────────────────────┐   │  │
│  │  │  SettlementServiceCore                               │   │  │
│  │  │  - createSettlement()                                │   │  │
│  │  │  - getSettlementStats()                              │   │  │
│  │  └──────────────────────────────────────────────────────┘   │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                            ↑                                        │
│                        DATA MODELS                                  │
│                            ↓                                        │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │              DATA MODELS LAYER                               │  │
│  │  ┌──────────────────────────────────────────────────────┐   │  │
│  │  │  enhanced_transaction_model.dart                     │   │  │
│  │  │  - Transaction (payment unit)                        │   │  │
│  │  │  - Wallet (user account)                             │   │  │
│  │  │  - BankAccount (withdrawal target)                   │   │  │
│  │  │  - TransactionLog (audit trail)                      │   │  │
│  │  └──────────────────────────────────────────────────────┘   │  │
│  │  ┌──────────────────────────────────────────────────────┐   │  │
│  │  │  payment_flow_model.dart                              │   │  │
│  │  │  - PaymentFlow (multi-party orchestrator)            │   │  │
│  │  │  - PaymentParty (individual participant)             │   │  │
│  │  │  - PaymentSplit (amount distribution)                │   │  │
│  │  └──────────────────────────────────────────────────────┘   │  │
│  │  ┌──────────────────────────────────────────────────────┐   │  │
│  │  │  settlement_model.dart                                │   │  │
│  │  │  - Settlement (batch processing)                     │   │  │
│  │  │  - WithdrawalRequest (payout request)                │   │  │
│  │  └──────────────────────────────────────────────────────┘   │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                            ↑                                        │
│                      FIRESTORE                                      │
│                            ↓                                        │
├─────────────────────────────────────────────────────────────────────┤
│                    FIREBASE FIRESTORE                               │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │  Collections:                                                │  │
│  │  - wallets/          (user financial accounts)              │  │
│  │  - transactions/     (individual payments)                  │  │
│  │  - payment_flows/    (multi-party flows)                    │  │
│  │  - settlements/      (batch settlements)                    │  │
│  │  - withdrawal_requests/ (payout requests)                   │  │
│  │  - bank_accounts/    (withdrawal destinations)              │  │
│  └──────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 💸 Payment Flow Sequence Diagram

### Scenario 1: Buyer → Farmer Purchase

```
Buyer                          System                         Farmer
  │                              │                              │
  ├─────────→ Initiate Payment ──→│                              │
  │         (Amount: Tk 1000)     │                              │
  │                               ├─ Validate Amount            │
  │                               ├─ Check User Eligibility     │
  │                               ├─ Calculate Commission       │
  │                               │  (Tk 50 = 5%)               │
  │                               │                              │
  │                               ├─ Create Debit Transaction   │
  │                               │  (Farmer: Tk 950)           │
  │                               │                              │
  │                               ├─ Create Credit Transaction  │
  │                               ├─ Commission Transaction     │
  │                               │                              │
  │                               ├─ Create PaymentFlow         │
  │                               │                              │
  ←──────── Payment Confirmed ────│                              │
  │                               │                              │
  │                               ├─ Update Wallet Balances     │
  │                               │                              │
  │                               ├─ Link Transactions          │
  │                               │  (linkedTransactionIds)     │
  │                               │                              │
  │                               ├─ Save to Firestore          │
  │                               │                              │
  │                               ├─ Real-time Updates          │
  │                               ├─ Stream to UI               │
  │                               │                              │
  │                               ├─ Queue for Settlement       │
  │                               │                              │
  ←──────────────────────────────────────→ Show Balance ─────→ │
  │                                                              │
  │  (Next Monday: Settlement Batch Created)                    │
  │  (Next Friday: Settlement Approved & Payout)                │
  │
```

---

## 🔄 Multi-Party Transport Payment Flow

```
Buyer                 Farmer                Driver               Platform
  │                    │                     │                      │
  ├─ Tk 200 Transport ─┤                     │                      │
  │                    │                     │                      │
  ├──────────────────────────────────────────→                      │
  │    Amount: Tk 200                        │                      │
  │    Type: multiPartyTransport             │                      │
  │                                          │                      │
  │    + Farmer also pays Tk 200  ──────────→                      │
  │                                          │                      │
  │                         Calculate Split: │                      │
  │                         - Driver: Tk 380│                      │
  │                         - Platform: Tk 20│                      │
  │                                          │                      │
  │                         ←─ Confirm Payment                      │
  │ ←───────────────────────────────────────→                      │
  │                                          │                      │
  │    Create Transactions:                  │                      │
  │    1. Debit Buyer (Tk 200)   ────→ [Tx1]│                      │
  │    2. Debit Farmer (Tk 200)  ────→ [Tx2]│                      │
  │    3. Credit Driver (Tk 380) ────→ [Tx3]│                      │
  │    4. Commission (Tk 20)     ────→ [Tx4]│                      │
  │                                          │                      │
  │    Link All Transactions:                │                      │
  │    linkedTransactionIds: [1,2,3,4]      │                      │
  │                                          │                      │
  │    Save PaymentFlow:                     │                      │
  │    parties: [Buyer, Farmer]              │                      │
  │    recipient: Driver                     │                      │
  │    status: completed                     │                      │
  │                                          │                      │
  │    Real-time Updates:                    │                      │
  │    Stream all balances updated ────────→ │                      │
  │                                          │                      │
```

---

## 💰 Commission Calculation Flow

```
┌─────────────────────────────────────────────────────────────┐
│  INPUT: Transaction Amount & Category                       │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Category Type                                              │
│      ↓                                                      │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  SELECT COMMISSION RATE                             │  │
│  │                                                     │  │
│  │  if (ProductSale)         → Rate = 5%  ✓          │  │
│  │  if (SupplySale)          → Rate = 3%  ✓          │  │
│  │  if (Transport)           → Rate = 5%  ✓          │  │
│  │  if (FarmingService)      → Rate = 5%  ✓          │  │
│  └─────────────────────────────────────────────────────┘  │
│      ↓                                                      │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  CALCULATE COMMISSION                              │  │
│  │                                                     │  │
│  │  commission = amount × rate                         │  │
│  │                                                     │  │
│  │  Example:                                           │  │
│  │  Tk 1000 × 5% = Tk 50                             │  │
│  └─────────────────────────────────────────────────────┘  │
│      ↓                                                      │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  APPLY MINIMUM & MAXIMUM LIMITS                    │  │
│  │                                                     │  │
│  │  if (commission < minimumCommission)                │  │
│  │    → commission = minimumCommission (Tk 10)        │  │
│  │                                                     │  │
│  │  if (commission > maximumCommission)                │  │
│  │    → commission = maximumCommission                │  │
│  └─────────────────────────────────────────────────────┘  │
│      ↓                                                      │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  CALCULATE NET AMOUNT                              │  │
│  │                                                     │  │
│  │  netAmount = amount - commission                   │  │
│  │                                                     │  │
│  │  Example:                                           │  │
│  │  Tk 1000 - Tk 50 = Tk 950 (Farmer receives)       │  │
│  └─────────────────────────────────────────────────────┘  │
│      ↓                                                      │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  OUTPUT: Transaction with Commission                │  │
│  │  - Amount: Tk 1000                                 │  │
│  │  - Commission: Tk 50                               │  │
│  │  - Net: Tk 950                                     │  │
│  │  - Recipient: Farmer                               │  │
│  │  - Platform: Tk 50 (commission)                    │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 💳 Wallet State Diagram

```
                    ┌─────────────────────┐
                    │  User Wallet        │
                    │  at any given time  │
                    └─────────────────────┘
                            ↓
        ┌─────────────────────────────────────────────┐
        │  Total Wallet = Balance + Pending + OnHold  │
        └─────────────────────────────────────────────┘
                            ↓
        ┌─────────────────────────────────────────────┐
        │  BALANCE (Tk 100,000)                      │
        │  ├─ Available to spend/withdraw            │
        │  └─ Real-time updated                      │
        ├─────────────────────────────────────────────┤
        │  PENDING (Tk 50,000)                       │
        │  ├─ Transactions completed                 │
        │  ├─ Awaiting weekly settlement             │
        │  └─ Moves to Balance after settlement      │
        ├─────────────────────────────────────────────┤
        │  ONHOLD (Tk 20,000)                        │
        │  ├─ Disputed/under review                  │
        │  ├─ Cannot be withdrawn                    │
        │  └─ Resolves to Balance after dispute      │
        └─────────────────────────────────────────────┘
                            ↓
        User Transaction                  User Withdrawal
            (Payment Made)                 (Withdrawal Request)
                  ↓                                ↓
         Balance → Pending              Can withdraw ONLY
         Updates Real-time               from Balance
         (Instant UI Update)             (Not Pending/OnHold)
```

---

## 📊 Settlement Process Timeline

```
Day 1                     Day 7                    Monday               Friday
│                         │                         │                    │
└──────────────────────────────────────────────────────────────────────→ │
                                                                          │
Transactions              End of Week          Settlement Week        Payout Week
Created &                 Completed             Approved & Ready      Transferred
Tracked                   Transactions          for Processing
                          Ready for
                          Settlement


Detailed Timeline:

Day 1-7:
├─ User makes transactions
├─ Transactions marked as "completed"
├─ Wallet balance updates immediately
├─ Status: "pending_settlement"

MONDAY (Settlement Day):
├─ Settlement batch created
├─ Commission calculated & deducted
│  ├─ Product Sales Commission: 5%
│  ├─ Supply Sales Commission: 3%
│  └─ Transport Commission: 5%
├─ Total aggregated: sum of all completed txns
├─ Status: "approved"
├─ Amount ready for payout

FRIDAY (Payout Day):
├─ Settlement approved by admin
├─ Payout request created
├─ Funds transferred to bank
├─ Status: "completed"
├─ Settlement proof generated
├─ User notified

Result:
├─ Pending Balance → Available Balance
├─ User can withdraw immediately
└─ Cycle repeats
```

---

## 🔐 Validation Flow

```
Payment Initiated
        │
        ↓
┌──────────────────────────────────────┐
│  VALIDATE AMOUNT                     │
├──────────────────────────────────────┤
│  ├─ Min: Tk 100?                    │
│  ├─ Max: Tk 10,000,000?             │
│  ├─ Decimal: Max 2 places?          │
│  └─ Positive?                       │
└──────────────────────────────────────┘
        │
        ├─ INVALID → Show Error → ❌ REJECT
        │
        ↓
┌──────────────────────────────────────┐
│  VALIDATE USER ELIGIBILITY           │
├──────────────────────────────────────┤
│  ├─ Account active?                 │
│  ├─ Not suspended?                  │
│  ├─ Balance sufficient?              │
│  └─ Withdrawal: KYC verified?        │
└──────────────────────────────────────┘
        │
        ├─ INVALID → Show Error → ❌ REJECT
        │
        ↓
┌──────────────────────────────────────┐
│  VALIDATE WITHDRAWAL (if applicable) │
├──────────────────────────────────────┤
│  ├─ Daily limit: Tk 50,000?         │
│  ├─ Monthly limit: Tk 500,000?       │
│  ├─ Bank account verified?           │
│  └─ KYC verified?                    │
└──────────────────────────────────────┘
        │
        ├─ INVALID → Show Error → ❌ REJECT
        │
        ↓
✅ ALL VALID → PROCESS PAYMENT
```

---

## 📱 UI Component Hierarchy

```
WalletDashboardScreen (Main)
├── WalletHeader (Gradient Card)
│   ├── BalanceText (Large)
│   ├── EarnedBadge
│   ├── PendingBadge
│   └── OnHoldBadge
├── QuickStatsRow
│   ├── StatCard (Last Settlement)
│   ├── StatCard (This Month)
│   └── StatCard (Monthly Avg)
├── RecentTransactionsList
│   └── TransactionTile (3 items max)
│       ├── Icon (Direction)
│       ├── Title (Type)
│       ├── Amount
│       ├── Date
│       └── Status Badge
├── ActionButtonRow
│   ├── WithdrawButton
│   ├── SettlementButton
│   └── HistoryButton
└── TransactionHistoryScreen
    ├── FilterBar
    │   ├── CategoryDropdown
    │   ├── StatusChips
    │   └── DateRangePicker
    ├── TransactionList
    │   └── TransactionTile (with tap)
    │       └── DetailModal on tap
    │           ├── TransactionID
    │           ├── Amount Details
    │           ├── Status
    │           ├── Commission
    │           ├── Date/Time
    │           └── Close Button
    └── EmptyState (if no transactions)
```

---

## 🎯 User Journey Map

```
User Opens App
        ↓
[1] VIEW BALANCE
    ├─ See available balance
    ├─ See pending balance
    ├─ See recent transactions
    └─ See quick stats
        ↓
[2] INITIATE PAYMENT
    ├─ Select recipient
    ├─ Enter amount
    ├─ Select payment method
    ├─ Review details
    └─ Confirm payment
        ↓
[3] TRACK PAYMENT
    ├─ See payment progress
    ├─ See all parties
    ├─ See amount breakdown
    ├─ See commission
    └─ See status updates (real-time)
        ↓
[4] MANAGE WALLET
    ├─ View transaction history
    ├─ Filter transactions
    ├─ View transaction details
    ├─ See commission breakdown
    └─ View monthly earnings
        ↓
[5] WITHDRAW FUNDS
    ├─ Request withdrawal
    ├─ Select bank account
    ├─ Confirm amount
    ├─ Track request status
    └─ Receive confirmation
        ↓
[6] VIEW SETTLEMENTS
    ├─ See settlement history
    ├─ View settlement details
    ├─ See commission breakdown
    └─ Download settlement proof
```

---

## 📈 Data Flow Example

```
Step 1: Payment Initiated
┌────────────────────────┐
│ Buyer: Tk 1000 Payment │
│ To: Farmer             │
└────────────────────────┘
        ↓

Step 2: Validation
┌──────────────────────────┐
│ ✓ Amount valid (1000 ok) │
│ ✓ User eligible (active) │
│ ✓ Balance sufficient     │
└──────────────────────────┘
        ↓

Step 3: Commission Calculation
┌──────────────────────────┐
│ Commission: 1000 × 5% = 50 │
│ Net: 1000 - 50 = 950     │
└──────────────────────────┘
        ↓

Step 4: Transaction Creation
┌──────────────────────────────────────────┐
│ Transaction 1: Buyer Debit (Tk 1000)    │
│ Transaction 2: Farmer Credit (Tk 950)   │
│ Transaction 3: Platform Commission (50) │
│ Link All: linkedTransactionIds=[1,2,3]  │
└──────────────────────────────────────────┘
        ↓

Step 5: Wallet Updates
┌──────────────────────────┐
│ Buyer: -Tk 1000          │
│ Farmer: +Tk 950 (pending)│
│ Platform: +Tk 50         │
└──────────────────────────┘
        ↓

Step 6: Firestore Save
┌──────────────────────────────────────┐
│ Save to:                              │
│ - wallets/{buyerId} (updated balance) │
│ - wallets/{farmerId} (updated balance)│
│ - transactions/{tx1,tx2,tx3}         │
│ - payment_flows/{flowId}              │
└──────────────────────────────────────┘
        ↓

Step 7: Real-time Updates
┌──────────────────────────┐
│ StreamProvider triggers  │
│ UI updates automatically │
│ Show new balance         │
│ Show in recent txns      │
└──────────────────────────┘
        ↓

Step 8: Settlement Queue
┌──────────────────────────┐
│ Next Monday:             │
│ Create settlement batch  │
│ Aggregate: Tk 950       │
│ Status: APPROVED        │
└──────────────────────────┘
        ↓

Step 9: Weekly Payout
┌──────────────────────────┐
│ Next Friday:             │
│ Transfer to bank         │
│ Status: COMPLETED       │
│ Pending → Balance       │
└──────────────────────────┘
```

---

## ✨ Final Architecture Summary

```
LAYERS:
┌─────────────────────────────────────────────────────────────┐
│ Presentation (UI) - User sees buttons, screens, data       │
├─────────────────────────────────────────────────────────────┤
│ State Mgmt (Riverpod) - Manages reactive UI updates        │
├─────────────────────────────────────────────────────────────┤
│ Business Logic (Services) - Calculates, validates, decides │
├─────────────────────────────────────────────────────────────┤
│ Data Models - Defines data structure                        │
├─────────────────────────────────────────────────────────────┤
│ Database (Firestore) - Persists data                        │
└─────────────────────────────────────────────────────────────┘

KEY FEATURES:
✓ Type-safe Dart with null safety
✓ Real-time updates with Riverpod
✓ Comprehensive validation
✓ Accurate commission calculation
✓ Multi-party payment support
✓ Settlement automation
✓ Withdrawal management
✓ Audit trail logging
✓ Enterprise-grade architecture
✓ Production-ready code
```

---

**Created**: 2024  
**Status**: ✅ Complete  
**Quality**: Enterprise-Grade

This visual guide provides a complete understanding of the system architecture and data flows!
