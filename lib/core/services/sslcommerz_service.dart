import 'package:flutter/material.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCCustomerInfoInitializer.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class SSLCommerzService {
  /// Directly initiate payment through the official SSLCommerz gateway
  static Future<bool> initiatePayment({
    required BuildContext context,
    required double amount,
    required String productName,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String customerAddress,
  }) async {
    final storeId = dotenv.env['STORE_ID'] ?? 'agrol6a4232adbe03f';
    final storePassword = dotenv.env['STORE_PASSWORD'] ?? 'agrol6a4232adbe03f@ssl';

    if (storeId.isEmpty || storePassword.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SSLCommerz পেমেন্ট গেটওয়ে কনফিগারেশন পাওয়া যায়নি।'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }

    // On Web or Desktop environment where native SDK is unsupported
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Mock Payment Successful (Web/Desktop Environment)'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      }
      return true;
    }

    final SSLCommerzInitialization sslcInitialization = SSLCommerzInitialization(
      store_id: storeId,
      store_passwd: storePassword,
      total_amount: amount,
      currency: "BDT",
      tran_id: "TXN_${DateTime.now().millisecondsSinceEpoch}",
      product_category: "Agriculture",
      sdkType: SSLCSdkType.TESTBOX,
    );

    final SSLCCustomerInfoInitializer customerInfo = SSLCCustomerInfoInitializer(
      customerName: customerName.isNotEmpty ? customerName : "Customer",
      customerEmail: customerEmail.isNotEmpty ? customerEmail : "customer@agrolinkbd.com",
      customerAddress1: customerAddress.isNotEmpty ? customerAddress : "Dhaka",
      customerCity: "Dhaka",
      customerState: "Dhaka",
      customerPostCode: "1000",
      customerCountry: "Bangladesh",
      customerPhone: customerPhone.isNotEmpty ? customerPhone : "01700000000",
    );

    try {
      final Sslcommerz sslcommerz = Sslcommerz(initializer: sslcInitialization);
      sslcommerz.addCustomerInfoInitializer(customerInfoInitializer: customerInfo);

      final result = await sslcommerz.payNow();

      if (result.status == 'VALID' ||
          result.status == 'VALIDATED' ||
          result.status == 'SUCCESS') {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ SSLCommerz পেমেন্ট সফল হয়েছে! (Payment Successful)'),
              backgroundColor: Color(0xFF2E7D32),
            ),
          );
        }
        return true;
      } else if (result.status == 'CANCELLED') {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ SSLCommerz পেমেন্ট বাতিল করা হয়েছে। (Payment Cancelled)'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return false;
      } else if (result.status == 'FAILED') {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ SSLCommerz পেমেন্ট ব্যর্থ হয়েছে।'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment Status: ${result.status ?? "Incomplete"}'),
              backgroundColor: Colors.grey.shade800,
            ),
          );
        }
        return false;
      }
    } catch (e) {
      debugPrint('SSLCommerz error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SSLCommerz ত্রুটি: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }
}
