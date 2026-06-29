import os

file_path = "lib/presentation/screens/bazaar/product_detail.dart"

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add import
if 'import \'package:agrolinkbd/presentation/widgets/quick_buy_bottom_sheet.dart\';' not in content:
    content = content.replace(
        'import \'package:agrolinkbd/core/services/sslcommerz_service.dart\';',
        'import \'package:agrolinkbd/core/services/sslcommerz_service.dart\';\nimport \'package:agrolinkbd/presentation/widgets/quick_buy_bottom_sheet.dart\';'
    )

# Replace Order button logic
old_logic = """                        SSLCommerzService.initiatePayment(
                          context: context,
                          amount: double.tryParse(price) ?? 0.0,
                          productName: widget.product['name'] ?? 'Unknown',
                          customerName: "Buyer User",
                          customerEmail: "buyer@example.com",
                          customerPhone: "01700000000",
                          customerAddress: "Dhaka, Bangladesh",
                        );"""

new_logic = """                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: QuickBuyBottomSheet(product: widget.product),
                          ),
                        );"""

content = content.replace(old_logic, new_logic)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated product_detail.dart")
