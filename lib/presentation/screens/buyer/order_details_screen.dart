import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/models/order_model.dart';
import 'package:agrolinkbd/core/services/order_service.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/core/utils/number_converter.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailsScreen({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late OrderModel _order;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBn = LanguageProvider.isBn(context);

    return StreamBuilder<OrderModel?>(
      stream: OrderService().getOrderByIdStream(_order.id),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          _order = snapshot.data!;
        }

        final statusStep = _order.statusStep;
        final steps = isBn
            ? ['অর্ডার গৃহীত', 'প্রস্তুতি চলছে', 'পাঠানো হয়েছে', 'ডেলিভার্ড']
            : ['Order Accepted', 'Processing', 'Dispatched', 'Delivered'];
        final stepDetails = isBn
            ? [
                'আপনার অর্ডারটি সফলভাবে আমাদের সিস্টেমে গৃহীত হয়েছে।',
                'বিক্রেতা আপনার অর্ডারটি প্রস্তুত করছেন এবং পরিবহনের জন্য প্যাকেজিং করছেন।',
                'পণ্যটি আপনার ঠিকানায় পাঠানোর জন্য ট্রাকে লোড করা হয়েছে।',
                'পণ্যটি সফলভাবে আপনার ঠিকানায় হস্তান্তর করা হয়েছে।'
              ]
            : [
                'Your order was accepted in our system.',
                'The seller is packing and prepping your batch for transit.',
                'Dispatched and loaded into oxygenated transport.',
                'Successfully delivered to your designated address.'
              ];

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            foregroundColor: isDark ? Colors.white : Colors.black87,
            elevation: 0,
            title: Text(
              isBn ? 'অর্ডার ডিটেইলস' : 'Order Details',
              style: isBn
                  ? GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 18)
                  : GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Header Card
                  _buildHeaderCard(isDark, isBn),
                  const SizedBox(height: 16),

                  // Product Details Card
                  _buildProductCard(isDark, isBn),
                  const SizedBox(height: 16),

                  // Order Timeline (Status)
                  _buildTimelineCard(isDark, statusStep, steps, stepDetails, isBn),
                  const SizedBox(height: 24),

                  // Action Buttons
                  _buildActions(context, isDark, isBn),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(bool isDark, bool isBn) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isBn ? 'অর্ডার আইডি:' : 'Order ID:',
                style: isBn
                    ? GoogleFonts.hindSiliguri(color: Colors.grey.shade500, fontSize: 13)
                    : GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 12),
              ),
              Text(
                '#ORD-${_order.id.substring(0, _order.id.length > 8 ? 8 : _order.id.length).toUpperCase()}',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isBn ? 'অর্ডার তারিখ:' : 'Order Date:',
                style: isBn
                    ? GoogleFonts.hindSiliguri(color: Colors.grey.shade500, fontSize: 13)
                    : GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 12),
              ),
              Text(
                '${BanglaEnglishNumberHelper.format(_order.createdAt.day, isBn)}/${BanglaEnglishNumberHelper.format(_order.createdAt.month, isBn)}/${BanglaEnglishNumberHelper.format(_order.createdAt.year, isBn)} ${BanglaEnglishNumberHelper.format(_order.createdAt.hour, isBn)}:${BanglaEnglishNumberHelper.format(_order.createdAt.minute.toString().padLeft(2, '0'), isBn)}',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isBn ? 'পেমেন্ট স্ট্যাটাস:' : 'Payment Status:',
                style: isBn
                    ? GoogleFonts.hindSiliguri(color: Colors.grey.shade500, fontSize: 13)
                    : GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 12),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (_order.paymentStatus == 'paid' ? Colors.green : Colors.orange)
                      .withValues(alpha: isDark ? 0.25 : 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _order.paymentStatus == 'paid'
                      ? (isBn ? 'পরিশোধিত' : 'Paid')
                      : (isBn ? 'বকেয়া' : 'Pending'),
                  style: isBn
                      ? GoogleFonts.hindSiliguri(
                          color: _order.paymentStatus == 'paid' ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        )
                      : GoogleFonts.poppins(
                          color: _order.paymentStatus == 'paid' ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(bool isDark, bool isBn) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isBn ? 'পণ্যের বিবরণ' : 'Product Details',
            style: isBn
                ? GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 15)
                : GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey.shade100,
                  child: _order.productImageUrl.isNotEmpty && _order.productImageUrl.startsWith('http')
                      ? Image.network(
                          _order.productImageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.shopping_basket, color: Colors.grey),
                        )
                      : const Icon(Icons.shopping_basket, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _order.productName,
                      style: isBn
                          ? GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600, fontSize: 14)
                          : GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    Text(
                      '${isBn ? 'বিক্রেতা' : 'Seller'}: ${_order.farmerName}',
                      style: isBn
                          ? GoogleFonts.hindSiliguri(color: Colors.grey.shade500, fontSize: 11)
                          : GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '৳${BanglaEnglishNumberHelper.format(_order.totalAmount.toStringAsFixed(0), isBn)}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1976D2),
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '${BanglaEnglishNumberHelper.format(_order.quantity, isBn)} ${_order.quantity == _order.quantity.toInt() ? (isBn ? 'টি/কেজি' : 'units') : (isBn ? 'কেজি' : 'kg')}',
                    style: isBn
                        ? GoogleFonts.hindSiliguri(color: Colors.grey.shade500, fontSize: 11)
                        : GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(
    bool isDark,
    int statusStep,
    List<String> steps,
    List<String> stepDetails,
    bool isBn,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isBn ? 'অর্ডার ট্র্যাকিং' : 'Order Tracking',
            style: isBn
                ? GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 15)
                : GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 20),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            itemBuilder: (context, index) {
              final isActive = index < statusStep;
              final isCurrent = index == statusStep - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Indicators & Line
                  Column(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive ? const Color(0xFF1976D2) : Colors.grey.shade300,
                          border: isCurrent
                              ? Border.all(color: const Color(0xFF1976D2).withValues(alpha: 0.3), width: 3)
                              : null,
                        ),
                        child: isActive
                            ? const Icon(Icons.check, size: 12, color: Colors.white)
                            : null,
                      ),
                      if (index < 3)
                        Container(
                          width: 2,
                          height: 45,
                          color: index < statusStep - 1 ? const Color(0xFF1976D2) : Colors.grey.shade300,
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  // Texts
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          steps[index],
                          style: isBn
                              ? GoogleFonts.hindSiliguri(
                                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                  fontSize: 13,
                                  color: isActive
                                      ? (isCurrent ? const Color(0xFF1976D2) : (isDark ? Colors.white70 : Colors.black87))
                                      : Colors.grey,
                                )
                              : GoogleFonts.poppins(
                                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                  fontSize: 12,
                                  color: isActive
                                      ? (isCurrent ? const Color(0xFF1976D2) : (isDark ? Colors.white70 : Colors.black87))
                                      : Colors.grey,
                                ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          stepDetails[index],
                          style: isBn
                              ? GoogleFonts.hindSiliguri(
                                  fontSize: 11,
                                  color: isActive
                                      ? (isDark ? Colors.white38 : Colors.grey.shade600)
                                      : Colors.grey.shade400,
                                )
                              : GoogleFonts.poppins(
                                  fontSize: 10.5,
                                  color: isActive
                                      ? (isDark ? Colors.white38 : Colors.grey.shade600)
                                      : Colors.grey.shade400,
                                ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, bool isDark, bool isBn) {
    final canCancel = _order.status == 'pending' || _order.statusStep == 1;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Get.snackbar(
                isBn ? 'যোগাযোগ করুন' : 'Contact Farmer',
                isBn
                    ? 'কৃষক ${_order.farmerName} এর সাথে যোগাযোগের জন্য ফোন করুন: ০১৭০০০০০০০০'
                    : 'Call seller ${_order.farmerName} at 01700000000',
                backgroundColor: Colors.blue.shade100,
                colorText: Colors.blue.shade900,
                duration: const Duration(seconds: 4),
              );
            },
            icon: const Icon(Icons.phone, color: Colors.white),
            label: Text(
              isBn ? 'কৃষকের সাথে যোগাযোগ করুন' : 'Contact Seller',
              style: isBn
                  ? GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold)
                  : GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        if (canCancel) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: _isCancelling
                ? const Center(child: CircularProgressIndicator())
                : OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red.shade400),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _showCancelDialog(context, isBn),
                    icon: Icon(Icons.cancel_outlined, color: Colors.red.shade400),
                    label: Text(
                      isBn ? 'অর্ডার বাতিল করুন' : 'Cancel Order',
                      style: isBn
                          ? GoogleFonts.hindSiliguri(color: Colors.red.shade400, fontWeight: FontWeight.bold)
                          : GoogleFonts.poppins(color: Colors.red.shade400, fontWeight: FontWeight.bold),
                    ),
                  ),
          ),
        ],
      ],
    );
  }

  void _showCancelDialog(BuildContext context, bool isBn) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          isBn ? 'অর্ডার বাতিল করুন?' : 'Cancel Order?',
          style: isBn
              ? GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)
              : GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          isBn
              ? 'আপনি কি নিশ্চিতভাবে এই অর্ডারটি বাতিল করতে চান?'
              : 'Are you sure you want to cancel this order?',
          style: isBn ? GoogleFonts.hindSiliguri() : GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(isBn ? 'না' : 'No', style: isBn ? GoogleFonts.hindSiliguri() : GoogleFonts.poppins()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(dialogContext);
              setState(() {
                _isCancelling = true;
              });
              try {
                await OrderService().updateOrderStatus(_order.id, 'cancelled', 0);
                Get.snackbar(
                  isBn ? 'অর্ডার বাতিল' : 'Order Cancelled',
                  isBn ? 'আপনার অর্ডারটি সফলভাবে বাতিল করা হয়েছে।' : 'Your order has been cancelled successfully.',
                  backgroundColor: Colors.green.shade100,
                  colorText: Colors.green.shade900,
                );
                Navigator.pop(context);
              } catch (e) {
                Get.snackbar(
                  isBn ? 'বাতিল করা যায়নি' : 'Cancellation Failed',
                  isBn ? 'কোনো সমস্যা হয়েছে। আবার চেষ্টা করুন।' : 'Failed to cancel order. Please try again.',
                  backgroundColor: Colors.red.shade100,
                  colorText: Colors.red.shade900,
                );
              } finally {
                if (mounted) {
                  setState(() {
                    _isCancelling = false;
                  });
                }
              }
            },
            child: Text(
              isBn ? 'হ্যাঁ, বাতিল করুন' : 'Yes, Cancel',
              style: isBn
                  ? GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold)
                  : GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
