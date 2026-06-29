import 'package:flutter/material.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCCustomerInfoInitializer.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SSLCommerzService {
  static Future<bool> initiatePayment({
    required BuildContext context,
    required double amount,
    required String productName,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String customerAddress,
  }) async {
    final storeId = dotenv.env['STORE_ID'] ?? '';
    final storePassword = dotenv.env['STORE_PASSWORD'] ?? '';

    if (storeId.isEmpty || storePassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Payment Gateway is not configured properly.')),
      );
      return false;
    }

    SSLCommerzInitialization sslcInitialization = SSLCommerzInitialization(
      store_id: storeId,
      store_passwd: storePassword,
      total_amount: amount,
      currency: "BDT",
      tran_id: "TXN_${DateTime.now().millisecondsSinceEpoch}",
      product_category: "Agriculture",
      sdkType: SSLCSdkType.TESTBOX,
    );

    SSLCCustomerInfoInitializer customerInfo = SSLCCustomerInfoInitializer(
      customerName: customerName.isNotEmpty ? customerName : "Customer",
      customerEmail: customerEmail.isNotEmpty ? customerEmail : "customer@example.com",
      customerAddress1: customerAddress.isNotEmpty ? customerAddress : "Dhaka",
      customerCity: "Dhaka",
      customerState: "Dhaka",
      customerPostCode: "1000",
      customerCountry: "Bangladesh",
      customerPhone: customerPhone.isNotEmpty ? customerPhone : "01700000000",
    );

    Sslcommerz sslcommerz = Sslcommerz(initializer: sslcInitialization);
    sslcommerz.addCustomerInfoInitializer(customerInfoInitializer: customerInfo);

    try {
      final result = await sslcommerz.payNow();

      if (result.status == 'VALID') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('পেমেন্ট সফল হয়েছে! (Payment Successful)'),
            backgroundColor: Colors.green,
          ),
        );
        return true;
      } else if (result.status == 'FAILED') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('পেমেন্ট ব্যর্থ হয়েছে! (Payment Failed)'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      } else if (result.status == 'CANCELLED') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('পেমেন্ট বাতিল করা হয়েছে। (Payment Cancelled)'),
            backgroundColor: Colors.orange,
          ),
        );
        return false;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment Status: ${result.status}'),
          ),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }
}
