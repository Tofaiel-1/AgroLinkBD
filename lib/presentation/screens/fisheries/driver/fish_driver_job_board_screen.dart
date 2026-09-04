import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';

/// Fish Driver Job Board Screen
/// Real-time load board for fish drivers to find and accept live fish transit and cold-chain cargo trips.
class FishDriverJobBoardScreen extends StatefulWidget {
  const FishDriverJobBoardScreen({super.key});

  @override
  State<FishDriverJobBoardScreen> createState() => _FishDriverJobBoardScreenState();
}

class _FishDriverJobBoardScreenState extends State<FishDriverJobBoardScreen> {
  String _selectedVehicleFilter = 'all';
  String _selectedDistrict = 'সব অঞ্চল';

  final List<Map<String, dynamic>> _jobRequests = [
    {
      'id': 'JOB-FISH-501',
      'farmerName': 'মোঃ আব্দুল কুদ্দুস',
      'farmerPhone': '01711223344',
      'from': 'সিংড়া বাজার, চলনবিল, নাটোর',
      'to': 'যাত্রাবাড়ী মৎস্য আড়ত, ঢাকা',
      'fishSpecies': 'জ্যান্ত রুই ও কাতলা',
      'weightKg': 800.0,
      'isLive': true,
      'vehicleType': 'oxygenPickup',
      'vehicleTypeName': 'লাইভ অক্সিজেন পিকআপ',
      'distanceKm': 210.0,
      'fare': 8500.0,
      'pickupTime': 'আজ রাত ১১:৩০ (ভোরের আড়ত)',
      'status': 'available',
    },
    {
      'id': 'JOB-FISH-502',
      'farmerName': 'হাজী রফিকুল ইসলাম',
      'farmerPhone': '01988776655',
      'from': 'শ্যামনগর বাগদা ঘের, সাতক্ষীরা',
      'to': 'কাওরান বাজার মৎস্য পাইকারি আড়ত, ঢাকা',
      'fishSpecies': 'রপ্তানি গ্রেড বাগদা চিংড়ি (বরফ ঢাকা)',
      'weightKg': 450.0,
      'isLive': false,
      'vehicleType': 'insulatedIceVan',
      'vehicleTypeName': 'ইনসুলেটেড বরফ ভ্যান',
      'distanceKm': 285.0,
      'fare': 12000.0,
      'pickupTime': 'আজ রাত ১০:০০',
      'status': 'available',
    },
    {
      'id': 'JOB-FISH-503',
      'farmerName': 'মেসার্স সততা ফিশারিজ',
      'farmerPhone': '01811445566',
      'from': 'ত্রিশাল পাঙ্গাশ জোন, ময়মনসিংহ',
      'to': 'গাবতলী মাছের বাজার, ঢাকা',
      'fishSpecies': 'তাজা পাঙ্গাশ ও তেলাপিয়া',
      'weightKg': 1200.0,
      'isLive': true,
      'vehicleType': 'oxygenPickup',
      'vehicleTypeName': 'লাইভ অক্সিজেন পিকআপ',
      'distanceKm': 115.0,
      'fare': 6800.0,
      'pickupTime': 'আগামীকাল ভোর ৪:০০',
      'status': 'available',
    },
    {
      'id': 'JOB-FISH-504',
      'farmerName': 'মেঘনা ফিশিং কো-অপারেটিভ',
      'farmerPhone': '01712009988',
      'from': 'চাঁদপুর বড় স্টেশন ঘাট',
      'to': 'যাত্রাবাড়ী ইলিশের আড়ত, ঢাকা',
      'fishSpecies': 'পদ্মা-মেঘনার তাজা রুপালি ইলিশ',
      'weightKg': 600.0,
      'isLive': false,
      'vehicleType': 'insulatedIceVan',
      'vehicleTypeName': 'ইনসুলেটেড বরফ ভ্যান',
      'distanceKm': 108.0,
      'fare': 7500.0,
      'pickupTime': 'আজ রাত ১:০০',
      'status': 'available',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBn = LanguageProvider.isBn(context);

    final filteredJobs = _jobRequests.where((job) {
      if (_selectedVehicleFilter != 'all' && job['vehicleType'] != _selectedVehicleFilter) {
        return false;
      }
      if (_selectedDistrict != 'সব অঞ্চল' && !job['from'].toString().contains(_selectedDistrict)) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF5F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0277BD),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isBn ? 'মৎস্য পরিবহন জব বোর্ড (Load Board)' : 'Fish Transport Job Board',
              style: GoogleFonts.hindSiliguri(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 17,
              ),
            ),
            Text(
              isBn ? 'সরাসরি খামার থেকে ট্রিপ বুকিং' : 'Direct Gher & Arat Trips',
              style: GoogleFonts.hindSiliguri(
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {});
              Get.snackbar(
                isBn ? 'রিফ্রেশ সম্পন্ন' : 'Refreshed',
                isBn ? 'নতুন ট্রিপের তালিকা আপডেট করা হয়েছে।' : 'New load requests updated.',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: isDark ? const Color(0xFF16252F) : Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildFilterChip('all', isBn ? 'সকল ট্রিপ (${_jobRequests.length})' : 'All Loads', isBn),
                  const SizedBox(width: 8),
                  _buildFilterChip('oxygenPickup', isBn ? 'জ্যান্ত মাছ (অক্সিজেন)' : 'Live Fish (O2)', isBn),
                  const SizedBox(width: 8),
                  _buildFilterChip('insulatedIceVan', isBn ? 'বরফযুক্ত ভ্যান' : 'Insulated Ice Van', isBn),
                ],
              ),
            ),
          ),

          // District Quick Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            alignment: Alignment.centerLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: ['সব অঞ্চল', 'নাটোর', 'সাতক্ষীরা', 'ময়মনসিংহ', 'চাঁদপুর'].map((dist) {
                  final isSel = _selectedDistrict == dist;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(dist, style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: FontWeight.w600)),
                      selected: isSel,
                      selectedColor: const Color(0xFF0288D1),
                      labelStyle: TextStyle(color: isSel ? Colors.white : (isDark ? Colors.white70 : Colors.black87)),
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedDistrict = dist);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Job Listings
          Expanded(
            child: filteredJobs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          isBn ? 'এই ক্যাটাগরিতে কোনো ট্রিপ পাওয়া যায়নি' : 'No fish loads found in this category',
                          style: GoogleFonts.hindSiliguri(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredJobs.length,
                    itemBuilder: (context, index) {
                      final job = filteredJobs[index];
                      return _buildJobCard(context, job, isDark, isBn);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label, bool isBn) {
    final isSelected = _selectedVehicleFilter == key;
    return InkWell(
      onTap: () => setState(() => _selectedVehicleFilter = key),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0277BD) : Colors.grey.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0277BD) : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.hindSiliguri(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, Map<String, dynamic> job, bool isDark, bool isBn) {
    final isLive = job['isLive'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16252F) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLive ? const Color(0xFF0288D1).withOpacity(0.5) : Colors.grey.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isLive ? Colors.blue.withOpacity(0.15) : Colors.cyan.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isLive ? Icons.air : Icons.ac_unit,
                      color: isLive ? const Color(0xFF0277BD) : Colors.cyan.shade800,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job['vehicleTypeName'] as String,
                        style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        'লট আইডি: ${job['id']}',
                        style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '৳ ${(job['fare'] as double).toStringAsFixed(0)}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green.shade800,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 18),

          // Fish species and weight
          Text(
            job['fishSpecies'] as String,
            style: GoogleFonts.hindSiliguri(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: const Color(0xFF01579B),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'ওজন: ${job['weightKg']} কেজি',
                  style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'দূরত্ব: ${job['distanceKm']} কিমি',
                  style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.brown),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Pickup and Dropoff
          Row(
            children: [
              const Icon(Icons.circle, size: 12, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'পিকআপ: ${job['from']}',
                  style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.red),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'গন্তব্য: ${job['to']}',
                  style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: Colors.orange),
              const SizedBox(width: 6),
              Text(
                'লোডিং সময়: ${job['pickupTime']}',
                style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.orange.shade800, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.phone, color: Colors.green),
                tooltip: 'খামারির সাথে কথা বলুন',
                onPressed: () {
                  Get.snackbar(
                    'কল ডায়াল হচ্ছে',
                    '${job['farmerName']} (${job['farmerPhone']}) এর সাথে সংযোগ স্থাপন করা হচ্ছে...',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAcceptTripDialog(context, job, isBn),
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                  label: Text(
                    isBn ? 'ট্রিপ গ্রহণ করুন' : 'Accept Load',
                    style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0277BD),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAcceptTripDialog(BuildContext context, Map<String, dynamic> job, bool isBn) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isBn ? 'ট্রিপ কনফার্ম করবেন?' : 'Confirm Trip Booking?',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${job['fishSpecies']} (${job['weightKg']} কেজি)',
              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: const Color(0xFF0277BD)),
            ),
            const SizedBox(height: 8),
            Text('ভাড়া: ৳${job['fare']}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.green)),
            Text('পিকআপ সময়: ${job['pickupTime']}', style: GoogleFonts.hindSiliguri(fontSize: 12)),
            const SizedBox(height: 12),
            Text(
              isBn ? 'ট্রিপ গ্রহণ করলে খামারি ও আড়তদার আপনার গাড়ির লাইভ লোকেশন দেখতে পাবেন।' : 'Farmer and buyer will track your live vehicle GPS.',
              style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isBn ? 'বাতিল' : 'Cancel', style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                job['status'] = 'accepted';
              });
              Get.snackbar(
                isBn ? 'ট্রিপ সফলভাবে গ্রহণ করা হয়েছে! 🚚' : 'Trip Accepted!',
                isBn ? 'খামারে যাত্রা শুরু করতে প্রস্তুত হোন।' : 'Head towards pickup farm location.',
                backgroundColor: const Color(0xFF0277BD),
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0277BD)),
            child: Text(isBn ? 'হ্যাঁ, কনফার্ম' : 'Yes, Confirm', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
