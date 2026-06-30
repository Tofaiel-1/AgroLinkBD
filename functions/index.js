const functions = require('firebase-functions');
const admin = require('firebase-admin');
const Stripe = require('stripe');

admin.initializeApp();
const db = admin.firestore();

// Initialize Stripe (Mocked secret for now)
const stripe = new Stripe(functions.config().stripe?.secret || 'sk_test_mockedSecretKey123', {
  apiVersion: '2022-11-15',
});

/**
 * 1. processRefund (Callable)
 * Admin uses this to trigger a refund via Stripe and update Firestore.
 */
exports.processRefund = functions.https.onCall(async (data, context) => {
  // Authentication & Authorization
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in.');
  }
  
  // Verify admin status (we assume user document holds role or custom claims)
  const adminDoc = await db.collection('admins').doc(context.auth.uid).get();
  if (!adminDoc.exists || !['super_admin', 'admin'].includes(adminDoc.data().role)) {
    throw new functions.https.HttpsError('permission-denied', 'Only admins can process refunds.');
  }

  const { transactionId } = data;
  if (!transactionId) {
    throw new functions.https.HttpsError('invalid-argument', 'Transaction ID is required.');
  }

  try {
    const transactionRef = db.collection('transactions').doc(transactionId);
    
    // Run inside a Firestore Transaction to ensure consistency
    await db.runTransaction(async (t) => {
      const transactionSnap = await t.get(transactionRef);
      if (!transactionSnap.exists) {
        throw new functions.https.HttpsError('not-found', 'Transaction not found.');
      }
      
      const txData = transactionSnap.data();
      if (txData.status === 'Refunded') {
        throw new functions.https.HttpsError('failed-precondition', 'Already refunded.');
      }

      // Process Stripe Refund
      let stripeRefund;
      if (txData.paymentIntentId) {
        stripeRefund = await stripe.refunds.create({
          payment_intent: txData.paymentIntentId,
        });
      }

      // Update Transaction Status
      t.update(transactionRef, { 
        status: 'Refunded',
        refundedAt: admin.firestore.FieldValue.serverTimestamp(),
        stripeRefundId: stripeRefund ? stripeRefund.id : null,
      });

      // Restore Stock
      if (txData.productId && txData.quantity) {
        const productRef = db.collection('inventory_products').doc(txData.productId);
        t.update(productRef, {
          stockQuantity: admin.firestore.FieldValue.increment(txData.quantity)
        });
      }

      // Update Refund Request Status if exists
      const refundReqs = await db.collection('refund_requests')
        .where('transactionId', '==', transactionId)
        .where('status', '==', 'Pending')
        .get();
      
      refundReqs.forEach(doc => {
        t.update(doc.ref, { status: 'Approved', processedAt: admin.firestore.FieldValue.serverTimestamp() });
      });
    });

    return { success: true, message: 'Refund processed and stock restored.' };
  } catch (error) {
    console.error('Refund Error:', error);
    throw new functions.https.HttpsError('internal', error.message || 'Refund processing failed.');
  }
});

/**
 * 2. handlePaymentWebhook (HTTP)
 * Stripe webhook to catch payment failures or successes.
 */
exports.handlePaymentWebhook = functions.https.onRequest(async (req, res) => {
  const sig = req.headers['stripe-signature'];
  const endpointSecret = functions.config().stripe?.webhook_secret || 'whsec_mock';

  let event;
  try {
    // Note: For actual verification req.rawBody is needed
    // event = stripe.webhooks.constructEvent(req.rawBody, sig, endpointSecret);
    event = req.body; // Mocked for simplicity without rawBody setup
  } catch (err) {
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  try {
    const paymentIntent = event.data.object;
    const transactionId = paymentIntent.metadata?.transactionId;

    if (transactionId) {
      const txRef = db.collection('transactions').doc(transactionId);
      
      if (event.type === 'payment_intent.payment_failed') {
        await txRef.update({
          status: 'Failed',
          errorDetails: paymentIntent.last_payment_error?.message || 'Unknown error',
          updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });
      } else if (event.type === 'payment_intent.succeeded') {
        await txRef.update({
          status: 'Success',
          updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });
      }
    }
    res.json({received: true});
  } catch (err) {
    console.error('Webhook processing error', err);
    res.status(500).send('Internal Server Error');
  }
});

/**
 * 3. purchaseProduct (Callable)
 * Safely decrements stock to avoid race conditions.
 */
exports.purchaseProduct = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in.');
  }

  const { productId, quantity, paymentMethod } = data;
  if (!productId || !quantity) {
    throw new functions.https.HttpsError('invalid-argument', 'Product ID and quantity required.');
  }

  const productRef = db.collection('inventory_products').doc(productId);
  const transactionRef = db.collection('transactions').doc();

  try {
    const transactionResult = await db.runTransaction(async (t) => {
      const productDoc = await t.get(productRef);
      if (!productDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Product not found.');
      }

      const product = productDoc.data();
      if (product.stockQuantity < quantity) {
        throw new functions.https.HttpsError('failed-precondition', 'Out of stock.');
      }

      const amount = product.price * quantity;

      // Decrement stock
      t.update(productRef, {
        stockQuantity: product.stockQuantity - quantity
      });

      // Create Pending Transaction
      const txData = {
        transactionId: transactionRef.id,
        userId: context.auth.uid,
        productId: productId,
        quantity: quantity,
        amount: amount,
        paymentMethod: paymentMethod || 'Unknown',
        status: 'Pending',
        timestamp: admin.firestore.FieldValue.serverTimestamp()
      };
      t.set(transactionRef, txData);

      return txData;
    });

    return { success: true, transaction: transactionResult };
  } catch (error) {
    console.error('Purchase Error:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

/**
 * 4. triggerLowStockAlert (Trigger)
 * Notifies admins if stock drops below threshold.
 */
exports.triggerLowStockAlert = functions.firestore
  .document('inventory_products/{productId}')
  .onUpdate(async (change, context) => {
    const newValue = change.after.data();
    const previousValue = change.before.data();

    // Only alert if stock just crossed the threshold downwards
    if (newValue.stockQuantity <= newValue.lowStockThreshold && 
        previousValue.stockQuantity > previousValue.lowStockThreshold) {
      
      console.log(`Low stock alert for product ${context.params.productId}`);
      
      // Get all admin FCM tokens (assuming stored in admins collection)
      const adminsSnap = await db.collection('admins').get();
      const tokens = [];
      adminsSnap.forEach(doc => {
        const adminData = doc.data();
        if (adminData.fcmToken) {
          tokens.push(adminData.fcmToken);
        }
      });

      if (tokens.length > 0) {
        const payload = {
          notification: {
            title: 'Low Stock Alert ⚠️',
            body: `Product "${newValue.title}" has fallen below the threshold (${newValue.stockQuantity} remaining).`,
          }
        };
        
        await admin.messaging().sendToDevice(tokens, payload);
      }
    }
  });

/**
 * 5. processPayment (Callable)
 * Sokol Card Payment Processing
 */
exports.processPayment = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in.');
  }

  const { receiverUid, amount, paymentMethod } = data;
  const senderUid = context.auth.uid;

  if (!receiverUid || !amount || amount <= 0) {
    throw new functions.https.HttpsError('invalid-argument', 'Valid receiver and amount are required.');
  }

  const senderWalletRef = db.collection('wallets').doc(senderUid);
  const receiverWalletRef = db.collection('wallets').doc(receiverUid);
  const transactionRef = db.collection('transactions').doc();

  try {
    await db.runTransaction(async (t) => {
      const senderWalletSnap = await t.get(senderWalletRef);
      const receiverWalletSnap = await t.get(receiverWalletRef);

      const senderBalance = senderWalletSnap.exists ? (senderWalletSnap.data().balance || 0) : 0;
      const receiverBalance = receiverWalletSnap.exists ? (receiverWalletSnap.data().balance || 0) : 0;

      if (senderBalance < amount) {
        throw new functions.https.HttpsError('failed-precondition', 'Insufficient balance.');
      }

      // Deduct from sender
      t.set(senderWalletRef, { balance: senderBalance - amount }, { merge: true });
      
      // Add to receiver
      t.set(receiverWalletRef, { balance: receiverBalance + amount }, { merge: true });

      // Record transaction
      t.set(transactionRef, {
        senderUid: senderUid,
        receiverUid: receiverUid,
        amount: amount,
        paymentMethod: paymentMethod || 'SokolWallet',
        status: 'success',
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        description: 'Sokol Card QR Payment'
      });
    });

    return { success: true };
  } catch (error) {
    console.error('Payment Error:', error);
    throw new functions.https.HttpsError('internal', error.message || 'Payment failed.');
  }
});
