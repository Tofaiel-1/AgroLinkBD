import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/models/order_model.dart';
import 'package:agrolinkbd/core/models/cart_model.dart';
import 'package:agrolinkbd/core/providers/cart_provider.dart';
import 'package:agrolinkbd/core/services/escrow_service.dart';
import 'package:agrolinkbd/core/services/sslcommerz_service.dart';
import 'package:agrolinkbd/core/services/upazila_hub_service.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/core/utils/masked_identity_helper.dart';
import 'package:agrolinkbd/presentation/screens/buyer/fish_buyer_orders_screen.dart';

class QuickBuyBottomSheet extends StatefulWidget {
  final Map<String, dynamic> product;

  const QuickBuyBottomSheet({Key? key, required this.product}) : super(key: key);

  @override
  State<QuickBuyBottomSheet> createState() => _QuickBuyBottomSheetState();
}

class _QuickBuyBottomSheetState extends State<QuickBuyBottomSheet> {
  double _quantity = 1.0;
  late TextEditingController _quantityController;
  bool _allowFraction = true;
  bool _isProcessing = false;
  final EscrowService _escrowService = EscrowService();
  final UpazilaHubService _hubService = UpazilaHubService();

  @override
  void initState() {
    super.initState();
    final cat = widget.product['category']?.toString().toLowerCase() ?? '';
    final unit = widget.product['unit'] ?? '';
    if (cat.contains('meat') || cat.contains('fish') || unit == 'পিছ' || unit == 'ডজন') {
      _allowFraction = false;
    }
    _quantityController = TextEditingController(text: _allowFraction ? '1.0' : '1');
    _quantityController.addListener(() {
      final val = double.tryParse(_quantityController.text);
      if (val != null && val > 0 && val != _quantity) {
        setState(() => _quantity = val);
      }
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isBn = LanguageProvider.isBn(context);

    // Parse price dynamically
    double price = 0.0;
    if (widget.product['price'] != null) {
      if (widget.product['price'] is String) {
        price = double.tryParse(widget.product['price'].toString()) ?? 0.0;
      } else {
        price = (widget.product['price'] as num).toDouble();
      }
    }

    final productSubtotal = price * _quantity;
    
    // Resolve Origin Upazila Hub & Destination Upazila Hub
    final originHub = _hubService.resolveHubByUpazila(
      widget.product['upazila'],
      districtName: widget.product['district'],
    );
    final destinationHub = _hubService.resolveHubByUpazila('Savar', districtName: 'Dhaka');

    final quote = _hubService.calculateInterHubLogistics(
      originHub,
      destinationHub,
      _quantity * 1.2, // weight factor
      isPerishable: widget.product['category']?.toString().toLowerCase().contains('fish') == true ||
          widget.product['category']?.toString().toLowerCase().contains('veg') == true,
    );

    final estimatedTransport = quote.totalLogisticsCost;
    final breakdown = _escrowService.calculateBreakdown(
      productSubtotal: productSubtotal,
      transportFare: estimatedTransport,
    );
    final totalCharged = breakdown['totalChargedToBuyer'] ?? (productSubtotal + estimatedTransport);

    // Parse image
    String imageUrl = widget.product['image'] ?? widget.product['imageUrl'] ?? 'https://via.placeholder.com/150';

    final maskedFarmerName = widget.product['farmer'] ??
        MaskedIdentityHelper.getMaskedFarmerName(
          userId: widget.product['farmerId'] ?? widget.product['userId'],
          district: widget.product['district'],
          upazila: widget.product['upazila'],
          fallbackName: widget.product['seller'],
        );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Escrow Badge & Hub Tag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isBn ? 'এস্ক্রো ও হাব অর্ডার' : 'Escrow & Hub Order',
                  style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shield_rounded, color: Color(0xFF2E7D32), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        isBn ? '১০০% হাব QC নিশ্চয়তা' : '100% Hub QC Verified',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Upazila Hub QC & Logistics Routing Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.hub, color: Color(0xFF16A34A), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${originHub.getName(isBn)} ➔ ${destinationHub.getName(isBn)}',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                        Text(
                          isBn
                              ? 'পণ্যটি উপজেলা হাবে ওজন পরীক্ষা ও গ্রেডিং সিল দিয়ে প্রেরণ করা হবে'
                              : 'Produce will be QC inspected & sealed at Upazila Hub before dispatch',
                          style: GoogleFonts.hindSiliguri(fontSize: 10, color: Colors.green.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Product Details Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.green.shade100,
                        child: const Icon(Icons.inventory_2, color: Color(0xFF2E7D32)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product['name'] ?? 'Product',
                          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          maskedFarmerName,
                          style: GoogleFonts.hindSiliguri(
                            color: const Color(0xFF1976D2),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '৳$price / ${widget.product['unit'] ?? 'কেজি'} • ${widget.product['qualityGrade'] ?? 'Grade A'}',
                          style: GoogleFonts.hindSiliguri(color: const Color(0xFF2E7D32), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quantity Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'পরিমাণ নির্বাচন করুন:',
                  style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          double step = _allowFraction ? 0.5 : 1.0;
                          if (_quantity > step) {
                            _quantityController.text = (_quantity - step).toStringAsFixed(_allowFraction ? 1 : 0);
                          }
                        },
                        icon: const Icon(Icons.remove, size: 20),
                      ),
                      SizedBox(
                        width: 50,
                        child: TextField(
                          controller: _quantityController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.numberWithOptions(decimal: _allowFraction),
                          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 15),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          double step = _allowFraction ? 0.5 : 1.0;
                          _quantityController.text = (_quantity + step).toStringAsFixed(_allowFraction ? 1 : 0);
                        },
                        icon: const Icon(Icons.add, size: 20),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Pricing Breakdown Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  _buildPriceRow('পণ্যের মূল্য (${_quantity.toStringAsFixed(_allowFraction ? 1 : 0)} ${widget.product['unit'] ?? 'কেজি'})', '৳${productSubtotal.toStringAsFixed(0)}'),
                  const SizedBox(height: 4),
                  _buildPriceRow('উপজেলা হাব লজিস্টিকস ও ডেলিভারি', '৳${estimatedTransport.toStringAsFixed(0)}'),
                  const SizedBox(height: 4),
                  _buildPriceRow('কোয়ালিটি চেক ও এস্ক্রো প্রটেকশন', 'বিনামূল্যে 🔒', valueColor: Colors.green.shade800),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'মোট পরিশোধযোগ্য (এস্ক্রো হোল্ড):',
                        style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        '৳${totalCharged.toStringAsFixed(0)}',
                        style: GoogleFonts.hindSiliguri(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: const Color(0xFF1976D2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF1976D2)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        final cartProvider = Provider.of<CartProvider>(context, listen: false);
                        cartProvider.addToCart(CartItem(
                          id: widget.product['id']?.toString() ?? DateTime.now().toString(),
                          title: widget.product['name'] ?? 'Product',
                          price: price,
                          unit: widget.product['unit'] ?? 'কেজি',
                          quantity: _quantity,
                          imageUrl: imageUrl,
                          itemType: CartItemType.product,
                          sellerId: widget.product['farmerId'] ?? widget.product['userId'] ?? 'unknown_farmer',
                          sellerName: maskedFarmerName,
                          sellerRole: 'farmer',
                        ));
                        Navigator.pop(context);
                        Get.snackbar(
                          'কার্টে যোগ করা হয়েছে',
                          '${widget.product['name']} কার্টে যোগ করা হয়েছে।',
                          backgroundColor: Colors.green.shade100,
                          colorText: Colors.green.shade900,
                        );
                      },
                      child: Text(
                        'কার্টে রাখুন',
                        style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: const Color(0xFF1976D2), fontSize: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _isProcessing
                          ? null
                          : () async {
                              setState(() => _isProcessing = true);

                              final user = FirebaseAuth.instance.currentUser;
                              final buyerId = user?.uid ?? 'guest_buyer';
                              final deliveryOtp = MaskedIdentityHelper.generateDeliveryOtp();
                              final batchCode = MaskedIdentityHelper.generateBatchCode();

                              final success = await SSLCommerzService.initiatePayment(
                                context: context,
                                amount: totalCharged,
                                productName: widget.product['name'] ?? 'Product',
                                customerName: 'AgroLink Buyer',
                                customerEmail: user?.email ?? 'buyer@agrolinkbd.com',
                                customerPhone: user?.phoneNumber ?? '01700000000',
                                customerAddress: 'Dhaka Hub, Bangladesh',
                              );

                              if (success) {
                                final newOrder = OrderModel(
                                  id: '',
                                  buyerId: buyerId,
                                  farmerId: widget.product['farmerId'] ?? widget.product['userId'] ?? 'unknown_farmer',
                                  farmerName: maskedFarmerName,
                                  productName: widget.product['name'] ?? 'Product',
                                  productImageUrl: imageUrl,
                                  quantity: _quantity,
                                  unit: widget.product['unit'] ?? 'কেজি',
                                  totalAmount: totalCharged,
                                  platformFee: breakdown['totalPlatformFee'],
                                  farmerPayout: breakdown['farmerPayout'],
                                  driverFare: breakdown['driverNetFare'],
                                  deliveryOtp: deliveryOtp,
                                  batchCode: batchCode,
                                  status: 'processing',
                                  statusStep: 1,
                                  transportStatus: 'অর্ডার গৃহীত হয়েছে • উপজেলা হাবে কোয়ালিটি পরীক্ষা ও প্যাকেজিং পেন্ডিং',
                                  paymentStatus: 'paid',
                                  escrowStatus: 'held',
                                  qualityGrade: widget.product['qualityGrade'] ?? 'Grade A+ (সুপার প্রিমিয়াম)',
                                  originHubId: originHub.id,
                                  originHubName: originHub.name,
                                  destinationHubId: destinationHub.id,
                                  destinationHubName: destinationHub.name,
                                  qcStatus: 'pending_dropoff',
                                  tamperProofSeal: 'SEAL-AGRO-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                                  qcFreshnessScore: 98.5,
                                  logisticsDistanceKm: quote.distanceKm,
                                  isColdChain: quote.coldChainFee > 0,
                                  createdAt: DateTime.now(),
                                  estimatedDeliveryDate: DateTime.now().add(const Duration(days: 2)),
                                );

                                final orderId = await _escrowService.lockEscrowOrder(newOrder);

                                if (orderId != null) {
                                  final qcReport = _hubService.generateMockQcInspection(
                                    orderId,
                                    widget.product['name'] ?? 'Agro Product',
                                    _quantity,
                                    originHub,
                                  );
                                  await _hubService.saveQcInspection(qcReport);
                                }

                                setState(() => _isProcessing = false);

                                if (orderId != null) {
                                  Navigator.pop(context); // close bottom sheet
                                  _showOrderSuccessModal(context, deliveryOtp, batchCode, totalCharged);
                                }
                              } else {
                                setState(() => _isProcessing = false);
                              }
                            },
                      child: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              'এস্ক্রো অর্ডার করুন',
                              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                            ),
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

  Widget _buildPriceRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade700),
        ),
        Text(
          value,
          style: GoogleFonts.hindSiliguri(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  void _showOrderSuccessModal(BuildContext context, String otp, String batchCode, double amount) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 64),
            const SizedBox(height: 12),
            Text(
              'অর্ডার সফল হয়েছে! 🎉',
              style: GoogleFonts.hindSiliguri(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'আপনার টাকা এগ্রোলিংক এস্ক্রো ওয়ালেটে সুরক্ষিতভাবে জমা রাখা হয়েছে।',
              textAlign: TextAlign.center,
              style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade300),
              ),
              child: Column(
                children: [
                  Text(
                    'আপনার ডেলিভারি ওটিপি (Delivery OTP):',
                    style: GoogleFonts.hindSiliguri(fontSize: 12, color: const Color(0xFF0D47A1), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    otp,
                    style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 8, color: const Color(0xFF1976D2)),
                  ),
                  Text(
                    'ব্যাচ ট্র্যাকিং আইডি: $batchCode',
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '⚠️ পণ্য গ্রহণ ও ওজন যাচাইয়ের পর ড্রাইভারকে এই কোডটি দেবেন। ওটিপি দেওয়ার সাথে সাথে কৃষকের পাওনা টাকা রিলিজ হবে।',
              textAlign: TextAlign.center,
              style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.amber.shade900, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Get.to(() => const FishBuyerOrdersScreen());
                },
                child: Text(
                  'আমার অর্ডার ট্র্যাক করুন',
                  style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
