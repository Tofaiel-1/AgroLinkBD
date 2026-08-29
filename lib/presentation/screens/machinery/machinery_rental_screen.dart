import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/models/order_model.dart';
import 'package:agrolinkbd/presentation/screens/transport/order_qr_delivery_screen.dart';

class MachineryRentalScreen extends StatefulWidget {
  const MachineryRentalScreen({super.key});

  @override
  State<MachineryRentalScreen> createState() => _MachineryRentalScreenState();
}

class _MachineryRentalScreenState extends State<MachineryRentalScreen> {
  String _selectedCategory = 'all';

  final List<Map<String, dynamic>> _machineryList = [
    {
      'id': 'MCH-01',
      'title': 'কুভোটা কম্বাইন হার্ভেস্টার (Kubota DC-70)',
      'category': 'harvester',
      'providerName': 'মেসার্স বগুড়া এগ্রো সার্ভিস (ভেরিফাইড পার্টনার ⭐)',
      'location': 'বগুড়া সদর ও শেরপুর জোন',
      'pricePerBigha': 1400.0,
      'priceUnit': 'বিঘা',
      'rating': 4.9,
      'totalRentals': 142,
      'operatorIncluded': true,
      'fuelIncluded': true,
      'imageUrl': 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=600&auto=format&fit=crop&q=60',
      'description': 'ধান ও গম দ্রুত কাটা, মাড়াই ও বস্তাজাতকরণ। প্রতি ঘণ্টায় ২ বিঘা জমি সম্পন্ন।',
    },
    {
      'id': 'MCH-02',
      'title': 'মাহিন্দ্রা ৪৭৫ ডিআই ট্রাক্টর (Mahindra 42HP)',
      'category': 'tractor',
      'providerName': 'আলমগীর মেকানাইজড ফার্ম',
      'location': 'নাটোর ও ঈশ্বরদী জোন',
      'pricePerBigha': 650.0,
      'priceUnit': 'বিঘা চাষ',
      'rating': 4.8,
      'totalRentals': 89,
      'operatorIncluded': true,
      'fuelIncluded': false,
      'imageUrl': 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=600&auto=format&fit=crop&q=60',
      'description': 'গভীর জমি চাষ ও মাটি মসৃণকরণ রোটোভেটর সহ। অভিজ্ঞ ড্রাইভার সহ সরবরাহ।',
    },
    {
      'id': 'MCH-03',
      'title': 'ডিজেআই এগ্রাস টি৪০ স্প্রেয়ার ড্রোন (DJI Agras T40)',
      'category': 'drone',
      'providerName': 'স্মার্ট ড্রোন এগ্রো সল্যুশনস',
      'location': 'রংপুর ও দিনাজপুর জোন',
      'pricePerBigha': 250.0,
      'priceUnit': 'বিঘা স্প্রে',
      'rating': 5.0,
      'totalRentals': 210,
      'operatorIncluded': true,
      'fuelIncluded': true,
      'imageUrl': 'https://images.unsplash.com/photo-1527977966376-1c8408f9f108?w=600&auto=format&fit=crop&q=60',
      'description': 'কীটনাশক ও তরল সার সুষম স্প্রে। মাত্র ১০ মিনিটে ৫ বিঘা জমি কভার করে।',
    },
    {
      'id': 'MCH-04',
      'title': 'সোলার ইরিগেশন সেন্ট্রিফিউগাল পাম্প (7.5 HP)',
      'category': 'irrigation',
      'providerName': 'গ্রিন পাওয়ার ইরিগেশন',
      'location': 'যশোর ও ঝিনাইদহ জোন',
      'pricePerBigha': 400.0,
      'priceUnit': 'দিন / পানি সেচ',
      'rating': 4.7,
      'totalRentals': 64,
      'operatorIncluded': false,
      'fuelIncluded': true,
      'imageUrl': 'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?w=600&auto=format&fit=crop&q=60',
      'description': 'সৌরবিদ্যুৎ চালিত নিরবচ্ছিন্ন সেচ ব্যবস্থা। জ্বালানি খরচ সাশ্রয়ী।',
    },
  ];

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2E7D32);

    final filteredList = _selectedCategory == 'all'
        ? _machineryList
        : _machineryList.where((m) => m['category'] == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'কৃষি যন্ত্রপাতি ও হার্ভেস্টার ভাড়া 🚜',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header Guarantee Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              border: Border(bottom: BorderSide(color: Colors.amber.shade200)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_outlined, color: Color(0xFFE65100), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '🔒 এগ্রোলিংক মেশিনারি এস্ক্রো: কাজ সন্তোষজনকভাবে সম্পন্ন হওয়ার পর ওটিপি যাচাই সাপেক্ষে মালিকের ভাড়া পরিশোধ হবে।',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 12,
                      color: const Color(0xFFE65100),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Category Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip('সব যন্ত্রপাতি', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('🌾 হার্ভেস্টার', 'harvester'),
                const SizedBox(width: 8),
                _buildFilterChip('🚜 ট্রাক্টর ও চাষ', 'tractor'),
                const SizedBox(width: 8),
                _buildFilterChip('🚁 স্প্রেয়ার ড্রোন', 'drone'),
                const SizedBox(width: 8),
                _buildFilterChip('💧 সেচ পাম্প', 'irrigation'),
              ],
            ),
          ),

          // Machine List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final item = filteredList[index];
                return _buildMachineryCard(item, primaryGreen);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String category) {
    final isSelected = _selectedCategory == category;
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.hindSiliguri(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFF2E7D32),
      backgroundColor: Colors.white,
      side: BorderSide(color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade300),
      onSelected: (selected) {
        if (selected) setState(() => _selectedCategory = category);
      },
    );
  }

  Widget _buildMachineryCard(Map<String, dynamic> item, Color primaryGreen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Image & Tags
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: Image.network(
                  item['imageUrl'],
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 140,
                    color: Colors.green.shade50,
                    child: const Icon(Icons.agriculture, size: 50, color: Colors.green),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${item['rating']} (${item['totalRentals']} বার ভাড়া)',
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['providerName'],
                  style: GoogleFonts.hindSiliguri(fontSize: 12, color: const Color(0xFF2E7D32), fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(item['location'], style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item['description'],
                  style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade700, height: 1.3),
                ),
                const SizedBox(height: 12),

                // Operator & Fuel Tags
                Row(
                  children: [
                    if (item['operatorIncluded'] == true) ...[
                      _featureBadge('👨‍🌾 চালক/অপারেটর সহ', Colors.blue),
                      const SizedBox(width: 8),
                    ],
                    if (item['fuelIncluded'] == true) ...[
                      _featureBadge('⛽ জ্বালানি সহ', Colors.orange),
                    ],
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Pricing & Booking Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ভাড়া মূল্য:', style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600)),
                        Text(
                          '৳ ${(item['pricePerBigha'] as double).toStringAsFixed(0)} / ${item['priceUnit']}',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showBookingModal(item),
                      icon: const Icon(Icons.calendar_month, color: Colors.white, size: 16),
                      label: Text(
                        'বুকিং করুন ⚡',
                        style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureBadge(String label, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.shade200),
      ),
      child: Text(
        label,
        style: GoogleFonts.hindSiliguri(fontSize: 11, color: color.shade800, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showBookingModal(Map<String, dynamic> item) {
    int bighaCount = 5;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final double basePrice = (item['pricePerBigha'] as double) * bighaCount;
            final double platformCut = basePrice * 0.05; // 5% Platform Revenue
            final double totalCharge = basePrice;
            final double providerNet = basePrice - platformCut;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'যন্ত্রপাতি ভাড়া বুকিং',
                    style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    item['title'],
                    style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 16),

                  // Bigha Counter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('জমির পরিমাণ (${item['priceUnit']}):', style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (bighaCount > 1) {
                                setModalState(() => bighaCount--);
                              }
                            },
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.green),
                          ),
                          Text('$bighaCount', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                          IconButton(
                            onPressed: () => setModalState(() => bighaCount++),
                            icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Financial Breakdown
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('মোট ভাড়া ($bighaCount বিঘা):', style: GoogleFonts.hindSiliguri(fontSize: 13)),
                            Text('৳ ${basePrice.toStringAsFixed(0)}', style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('প্ল্যাটফর্ম সার্ভিস ও বীমা (৫%):', style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade700)),
                            Text('৳ ${platformCut.toStringAsFixed(0)} (অন্তর্ভুক্ত)', style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.green.shade900)),
                          ],
                        ),
                        const Divider(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('এস্ক্রোতে জমা হবে:', style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32))),
                            Text('৳ ${totalCharge.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        final sampleOrder = OrderModel(
                          id: 'MCH-${DateTime.now().millisecondsSinceEpoch % 10000}',
                          buyerId: 'farmer_user',
                          farmerId: 'provider_user',
                          farmerName: item['providerName'],
                          productName: '${item['title']} ($bighaCount বিঘা)',
                          productImageUrl: item['imageUrl'],
                          quantity: bighaCount.toDouble(),
                          unit: item['priceUnit'],
                          totalAmount: totalCharge,
                          platformFee: platformCut,
                          farmerPayout: providerNet,
                          deliveryOtp: '7192',
                          batchCode: 'BATCH-MCH-7192',
                          status: 'pending',
                          statusStep: 1,
                          transportStatus: 'বুকিং নিশ্চিত',
                          paymentStatus: 'paid',
                          escrowStatus: 'held',
                          createdAt: DateTime.now(),
                        );
                        Get.to(() => OrderQrDeliveryScreen(order: sampleOrder, isDriverView: false));
                        Get.snackbar(
                          '✅ বুকিং নিশ্চিত ও টাকা এস্ক্রো লকড!',
                          'কাজ শেষ হলে ওটিপি কোড দিয়ে পেমেন্ট রিলিজ করুন।',
                          backgroundColor: const Color(0xFF2E7D32),
                          colorText: Colors.white,
                        );
                      },
                      icon: const Icon(Icons.lock_clock, color: Colors.white),
                      label: Text(
                        'এস্ক্রোতে নিশ্চিত বুক করুন 🔒',
                        style: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
