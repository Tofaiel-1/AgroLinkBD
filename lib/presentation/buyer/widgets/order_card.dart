import 'package:flutter/material.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';

class OrderCard extends StatelessWidget {
  final String orderId;
  final String status;
  final String statusBN;
  final DateTime orderDate;
  final String farmerName;
  final double totalAmount;
  final int itemCount;
  final List<String>? productImages;
  final VoidCallback onTap;
  final VoidCallback? onTrackOrder;
  final VoidCallback? onCancel;

  const OrderCard({
    Key? key,
    required this.orderId,
    required this.status,
    required this.statusBN,
    required this.orderDate,
    required this.farmerName,
    required this.totalAmount,
    required this.itemCount,
    this.productImages,
    required this.onTap,
    this.onTrackOrder,
    this.onCancel,
  }) : super(key: key);

  Color getStatusColor() {
    switch (status) {
      case 'pending':
        return Colors.amber;
      case 'confirmed':
        return Colors.blue;
      case 'packed':
        return Colors.purple;
      case 'shipped':
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBn = LanguageProvider.isBn(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBn
                          ? 'অর্ডার #${orderId.length > 8 ? orderId.substring(0, 8) : orderId}'
                          : 'Order #${orderId.length > 8 ? orderId.substring(0, 8) : orderId}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${orderDate.day}/${orderDate.month}/${orderDate.year}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: getStatusColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isBn ? statusBN : status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: getStatusColor(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Product images
            if (productImages != null && productImages!.isNotEmpty)
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: productImages!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: isDark
                              ? const Color(0xFF334155)
                              : Colors.grey.shade200,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            productImages![index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.image_not_supported);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (productImages != null && productImages!.isNotEmpty)
              const SizedBox(height: 12),
            // Info row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      farmerName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isBn ? '$itemCount আইটেম' : '$itemCount items',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '৳${totalAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action buttons
            Row(
              children: [
                if (['pending', 'confirmed'].contains(status))
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: Text(
                        isBn ? 'বাতিল করুন' : 'Cancel',
                        style: const TextStyle(fontSize: 11, color: Colors.red),
                      ),
                    ),
                  ),
                if (['shipped', 'out_for_delivery'].contains(status))
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onTrackOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                      ),
                      child: Text(
                        isBn ? 'ট্র্যাক করুন' : 'Track Order',
                        style: const TextStyle(fontSize: 11, color: Colors.white),
                      ),
                    ),
                  ),
                if (!['shipped', 'delivered', 'cancelled', 'out_for_delivery']
                    .contains(status))
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                      ),
                      child: Text(
                        isBn ? 'বিস্তারিত' : 'Details',
                        style: const TextStyle(fontSize: 11, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
