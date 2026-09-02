import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/models/order_model.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
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
      'titleBn': 'কুভোটা কম্বাইন হার্ভেস্টার (Kubota DC-70)',
      'titleEn': 'Kubota Combine Harvester (DC-70)',
      'category': 'harvester',
      'providerNameBn': 'মেসার্স বগুড়া এগ্রো সার্ভিস (ভেরিফাইড পার্টনার ⭐)',
      'providerNameEn': 'M/S Bogura Agro Services (Verified Partner ⭐)',
      'locationBn': 'বগুড়া সদর ও শেরপুর জোন',
      'locationEn': 'Bogura Sadar & Sherpur Zone',
      'pricePerBigha': 1400.0,
      'priceUnitBn': 'বিঘা',
      'priceUnitEn': 'Bigha',
      'rating': 4.9,
      'totalRentals': 142,
      'operatorIncluded': true,
      'fuelIncluded': true,
      'imageUrl': 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=600&auto=format&fit=crop&q=60',
      'descriptionBn': 'ধান ও গম দ্রুত কাটা, মাড়াই ও বস্তাজাতকরণ। প্রতি ঘণ্টায় ২ বিঘা জমি সম্পন্ন।',
      'descriptionEn': 'High-speed paddy & wheat harvesting, threshing & bagging. Covers 2 bigha per hour.',
    },
    {
      'id': 'MCH-02',
      'titleBn': 'মাহিন্দ্রা ৪৭৫ ডিআই ট্রাক্টর (Mahindra 42HP)',
      'titleEn': 'Mahindra 475 DI Tractor (42HP)',
      'category': 'tractor',
      'providerNameBn': 'আলমগীর মেকানাইজড ফার্ম',
      'providerNameEn': 'Alamgir Mechanized Farm',
      'locationBn': 'নাটোর ও ঈশ্বরদী জোন',
      'locationEn': 'Natore & Ishwardi Zone',
      'pricePerBigha': 650.0,
      'priceUnitBn': 'বিঘা চাষ',
      'priceUnitEn': 'Bigha Tillage',
      'rating': 4.8,
      'totalRentals': 89,
      'operatorIncluded': true,
      'fuelIncluded': false,
      'imageUrl': 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=600&auto=format&fit=crop&q=60',
      'descriptionBn': 'গভীর জমি চাষ ও মাটি মসৃণকরণ রোটোভেটর সহ। অভিজ্ঞ ড্রাইভার সহ সরবরাহ।',
      'descriptionEn': 'Deep tillage and soil smoothing with rotavator. Supplied with an experienced driver.',
    },
    {
      'id': 'MCH-03',
      'titleBn': 'ডিজেআই এগ্রাস টি৪০ স্প্রেয়ার ড্রোন (DJI Agras T40)',
      'titleEn': 'DJI Agras T40 Sprayer Drone',
      'category': 'drone',
      'providerNameBn': 'স্মার্ট ড্রোন এগ্রো সল্যুশনস',
      'providerNameEn': 'Smart Drone Agro Solutions',
      'locationBn': 'রংপুর ও দিনাজপুর জোন',
      'locationEn': 'Rangpur & Dinajpur Zone',
      'pricePerBigha': 250.0,
      'priceUnitBn': 'বিঘা স্প্রে',
      'priceUnitEn': 'Bigha Spray',
      'rating': 5.0,
      'totalRentals': 210,
      'operatorIncluded': true,
      'fuelIncluded': true,
      'imageUrl': 'https://images.unsplash.com/photo-1527977966376-1c8408f9f108?w=600&auto=format&fit=crop&q=60',
      'descriptionBn': 'কীটনাশক ও তরল সার সুষম স্প্রে। মাত্র ১০ মিনিটে ৫ বিঘা জমি কভার করে।',
      'descriptionEn': 'Uniform spray of pesticides and liquid fertilizer. Covers 5 bighas in just 10 mins.',
    },
    {
      'id': 'MCH-04',
      'titleBn': 'সোলার ইরিগেশন সেন্ট্রিফিউগাল পাম্প (7.5 HP)',
      'titleEn': 'Solar Centrifugal Irrigation Pump (7.5 HP)',
      'category': 'irrigation',
      'providerNameBn': 'গ্রিন পাওয়ার ইরিগেশন',
      'providerNameEn': 'Green Power Irrigation',
      'locationBn': 'যশোর ও ঝিনাইদহ জোন',
      'locationEn': 'Jashore & Jhenaidah Zone',
      'pricePerBigha': 400.0,
      'priceUnitBn': 'দিন / পানি সেচ',
      'priceUnitEn': 'Day / Irrigation',
      'rating': 4.7,
      'totalRentals': 64,
      'operatorIncluded': false,
      'fuelIncluded': true,
      'imageUrl': 'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?w=600&auto=format&fit=crop&q=60',
      'descriptionBn': 'সৌরবিদ্যুৎ চালিত নিরবচ্ছিন্ন সেচ ব্যবস্থা। জ্বালানি খরচ সাশ্রয়ী।',
      'descriptionEn': 'Solar powered continuous irrigation system. Zero fuel expenses.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2E7D32);
    final bool isBn = LanguageProvider.isBn(context);

    final filteredList = _selectedCategory == 'all'
        ? _machineryList
        : _machineryList.where((m) => m['category'] == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          isBn ? 'কৃষি যন্ত্রপাতি ও হার্ভেস্টার ভাড়া 🚜' : 'Agri Machinery & Rental 🚜',
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
                    isBn 
                        ? '🔒 এগ্রোলিংক মেশিনারি এস্ক্রো: কাজ সন্তোষজনকভাবে সম্পন্ন হওয়ার পর ওটিপি যাচাই সাপেক্ষে মালিকের ভাড়া পরিশোধ হবে।'
                        : '🔒 AgroLink Machinery Escrow: Payment is held safely and released to the owner upon OTP verification.',
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
                _buildFilterChip(isBn ? 'সব যন্ত্রপাতি' : 'All Machinery', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip(isBn ? '🌾 হার্ভেস্টার' : '🌾 Harvester', 'harvester'),
                const SizedBox(width: 8),
                _buildFilterChip(isBn ? '🚜 ট্রাক্টর ও চাষ' : '🚜 Tractor & Tillage', 'tractor'),
                const SizedBox(width: 8),
                _buildFilterChip(isBn ? '🚁 স্প্রেয়ার ড্রোন' : '🚁 Sprayer Drone', 'drone'),
                const SizedBox(width: 8),
                _buildFilterChip(isBn ? '💧 সেচ পাম্প' : '💧 Irrigation Pump', 'irrigation'),
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
                return _buildMachineryCard(item, primaryGreen, isBn);
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

  Widget _buildMachineryCard(Map<String, dynamic> item, Color primaryGreen, bool isBn) {
    final title = isBn ? item['titleBn'] : item['titleEn'];
    final providerName = isBn ? item['providerNameBn'] : item['providerNameEn'];
    final location = isBn ? item['locationBn'] : item['locationEn'];
    final description = isBn ? item['descriptionBn'] : item['descriptionEn'];
    final priceUnit = isBn ? item['priceUnitBn'] : item['priceUnitEn'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        isBn ? '${item['rating']} (${item['totalRentals']} বার ভাড়া)' : '${item['rating']} (${item['totalRentals']} rentals)',
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
                  title,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  providerName,
                  style: GoogleFonts.hindSiliguri(fontSize: 12, color: const Color(0xFF2E7D32), fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(location, style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade700, height: 1.3),
                ),
                const SizedBox(height: 12),

                // Operator & Fuel Tags
                Row(
                  children: [
                    if (item['operatorIncluded'] == true) ...[
                      _featureBadge(isBn ? '👨‍🌾 চালক/অপারেটর সহ' : '👨‍🌾 Operator Included', Colors.blue),
                      const SizedBox(width: 8),
                    ],
                    if (item['fuelIncluded'] == true) ...[
                      _featureBadge(isBn ? '⛽ জ্বালানি সহ' : '⛽ Fuel Included', Colors.orange),
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
                        Text(isBn ? 'ভাড়া মূল্য:' : 'Rate:', style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600)),
                        Text(
                          '৳ ${(item['pricePerBigha'] as double).toStringAsFixed(0)} / $priceUnit',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showBookingModal(item, isBn),
                      icon: const Icon(Icons.calendar_month, color: Colors.white, size: 16),
                      label: Text(
                        isBn ? 'বুকিং করুন ⚡' : 'Book Now ⚡',
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

  void _showBookingModal(Map<String, dynamic> item, bool isBn) {
    int bighaCount = 5;
    final title = isBn ? item['titleBn'] : item['titleEn'];
    final providerName = isBn ? item['providerNameBn'] : item['providerNameEn'];
    final priceUnit = isBn ? item['priceUnitBn'] : item['priceUnitEn'];

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
            final double platformCut = basePrice * 0.05;
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
                    isBn ? 'যন্ত্রপাতি ভাড়া বুকিং' : 'Machinery Rental Booking',
                    style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    title,
                    style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 16),

                  // Bigha Counter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${isBn ? 'জমির পরিমাণ' : 'Land Area'} ($priceUnit):',
                        style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
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
                            Text(
                              '${isBn ? 'মোট ভাড়া' : 'Total Rent'} ($bighaCount $priceUnit):',
                              style: GoogleFonts.hindSiliguri(fontSize: 13),
                            ),
                            Text('৳ ${basePrice.toStringAsFixed(0)}', style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isBn ? 'প্ল্যাটফর্ম সার্ভিস ও বীমা (৫%):' : 'Platform & Insurance (5%):',
                              style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade700),
                            ),
                            Text(
                              '৳ ${platformCut.toStringAsFixed(0)} ${isBn ? '(অন্তর্ভুক্ত)' : '(included)'}',
                              style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.green.shade900),
                            ),
                          ],
                        ),
                        const Divider(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isBn ? 'এস্ক্রোতে জমা হবে:' : 'Held in Escrow:',
                              style: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32)),
                            ),
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
                          farmerName: providerName,
                          productName: '$title ($bighaCount $priceUnit)',
                          productImageUrl: item['imageUrl'],
                          quantity: bighaCount.toDouble(),
                          unit: priceUnit,
                          totalAmount: totalCharge,
                          platformFee: platformCut,
                          farmerPayout: providerNet,
                          deliveryOtp: '7192',
                          batchCode: 'BATCH-MCH-7192',
                          status: 'pending',
                          statusStep: 1,
                          transportStatus: isBn ? 'বুকিং নিশ্চিত' : 'Booking Confirmed',
                          paymentStatus: 'paid',
                          escrowStatus: 'held',
                          createdAt: DateTime.now(),
                        );
                        Get.to(() => OrderQrDeliveryScreen(order: sampleOrder, isDriverView: false));
                        Get.snackbar(
                          isBn ? '✅ বুকিং নিশ্চিত ও টাকা এস্ক্রো লকড!' : '✅ Booking Confirmed & Escrow Funded!',
                          isBn 
                              ? 'কাজ শেষ হলে ওটিপি কোড দিয়ে পেমেন্ট রিলিজ করুন।'
                              : 'Release payment to the operator via OTP code once work is completed.',
                          backgroundColor: const Color(0xFF2E7D32),
                          colorText: Colors.white,
                        );
                      },
                      icon: const Icon(Icons.lock_clock, color: Colors.white),
                      label: Text(
                        isBn ? 'এস্ক্রোতে নিশ্চিত বুক করুন 🔒' : 'Confirm Escrow Booking 🔒',
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
