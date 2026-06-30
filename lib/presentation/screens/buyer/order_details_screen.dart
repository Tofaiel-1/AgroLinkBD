import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/models/order_model.dart';
import 'package:agrolinkbd/core/services/order_service.dart';

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

    return StreamBuilder<OrderModel?>(
      stream: OrderService().getOrderByIdStream(_order.id),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          _order = snapshot.data!;
        }

        final statusStep = _order.statusStep;
        final steps = ['অর্ডার গৃহীত', 'প্রস্তুতি চলছে', 'পাঠানো হয়েছে', 'ডেলিভার্ড'];
        final stepDetails = [
          'আপনার অর্ডারটি সফলভাবে আমাদের সিস্টেমে গৃহীত হয়েছে।',
          'বিক্রেতা আপনার অর্ডারটি প্রস্তুত করছেন এবং পরিবহনের জন্য প্যাকেজিং করছেন।',
          'পণ্যটি আপনার ঠিকানায় পাঠানোর জন্য ট্রাকে লোড করা হয়েছে।',
          'পণ্যটি সফলভাবে আপনার ঠিকানায় হস্তান্তর করা হয়েছে।'
        ];

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            foregroundColor: isDark ? Colors.white : Colors.black87,
            elevation: 0,
            title: Text(
              'অর্ডার ডিটেইলস',
              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 18),
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
                  _buildHeaderCard(isDark),
                  const SizedBox(height: 16),

                  // Product Details Card
                  _buildProductCard(isDark),
                  const SizedBox(height: 16),

                  // Order Timeline (Status)
                  _buildTimelineCard(isDark, statusStep, steps, stepDetails),
                  const SizedBox(height: 24),

                  // Action Buttons
                  _buildActions(context, isDark),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(bool isDark) {
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
                'অর্ডার আইডি:',
                style: GoogleFonts.hindSiliguri(color: Colors.grey.shade500, fontSize: 13),
              ),
              Text(
                '#ORD-${_order.id.substring(0, _order.id.length > 8 ? 8 : _order.id.length).toUpperCase()}',
                style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'অর্ডার তারিখ:',
                style: GoogleFonts.hindSiliguri(color: Colors.grey.shade500, fontSize: 13),
              ),
              Text(
                '${_order.createdAt.day}/${_order.createdAt.month}/${_order.createdAt.year} ${_order.createdAt.hour}:${_order.createdAt.minute.toString().padLeft(2, '0')}',
                style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'পেমেন্ট স্ট্যাটাস:',
                style: GoogleFonts.hindSiliguri(color: Colors.grey.shade500, fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _order.paymentStatus == 'paid' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _order.paymentStatus == 'paid' ? 'পরিশোধিত' : 'বকেয়া',
                  style: GoogleFonts.hindSiliguri(
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

  Widget _buildProductCard(bool isDark) {
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
            'পণ্যের বিবরণ',
            style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 15),
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
                      style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    Text(
                      'কৃষক: ${_order.farmerName}',
                      style: GoogleFonts.hindSiliguri(color: Colors.grey.shade500, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '৳${_order.totalAmount.toStringAsFixed(0)}',
                    style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: const Color(0xFF1976D2), fontSize: 15),
                  ),
                  Text(
                    '${_order.quantity} ${_order.quantity == _order.quantity.toInt() ? 'টি/কেজি' : 'কেজি'}',
                    style: GoogleFonts.hindSiliguri(color: Colors.grey.shade500, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(bool isDark, int statusStep, List<String> steps, List<String> stepDetails) {
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
            'অর্ডার ট্র্যাকিং',
            style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 15),
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
                          border: isCurrent ? Border.all(color: const Color(0xFF1976D2).withOpacity(0.3), width: 3) : null,
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
                          style: GoogleFonts.hindSiliguri(
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                            fontSize: 13,
                            color: isActive
                                ? (isCurrent ? const Color(0xFF1976D2) : (isDark ? Colors.white70 : Colors.black87))
                                : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          stepDetails[index],
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 11,
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

  Widget _buildActions(BuildContext context, bool isDark) {
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
                'যোগাযোগ করুন',
                'কৃষক ${_order.farmerName} এর সাথে যোগাযোগের জন্য ফোন করুন: ০১৭০০০০০০০০',
                backgroundColor: Colors.blue.shade100,
                colorText: Colors.blue.shade900,
                duration: const Duration(seconds: 4),
              );
            },
            icon: const Icon(Icons.phone, color: Colors.white),
            label: Text(
              'কৃষকের সাথে যোগাযোগ করুন',
              style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold),
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
                    onPressed: () => _showCancelDialog(context),
                    icon: Icon(Icons.cancel_outlined, color: Colors.red.shade400),
                    label: Text(
                      'অর্ডার বাতিল করুন',
                      style: GoogleFonts.hindSiliguri(color: Colors.red.shade400, fontWeight: FontWeight.bold),
                    ),
                  ),
          ),
        ],
      ],
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'অর্ডার বাতিল করুন?',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'আপনি কি নিশ্চিতভাবে এই অর্ডারটি বাতিল করতে চান?',
          style: GoogleFonts.hindSiliguri(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('না', style: GoogleFonts.hindSiliguri()),
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
                  'অর্ডার বাতিল',
                  'আপনার অর্ডারটি সফলভাবে বাতিল করা হয়েছে।',
                  backgroundColor: Colors.green.shade100,
                  colorText: Colors.green.shade900,
                );
                Navigator.pop(context);
              } catch (e) {
                Get.snackbar(
                  'বাতিল করা যায়নি',
                  'কোনো সমস্যা হয়েছে। আবার চেষ্টা করুন।',
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
            child: Text('হ্যাঁ, বাতিল করুন', style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
