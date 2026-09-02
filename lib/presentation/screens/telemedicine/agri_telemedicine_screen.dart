import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';

class AgriTelemedicineScreen extends StatefulWidget {
  const AgriTelemedicineScreen({super.key});

  @override
  State<AgriTelemedicineScreen> createState() => _AgriTelemedicineScreenState();
}

class _AgriTelemedicineScreenState extends State<AgriTelemedicineScreen> {
  String _selectedSpecialty = 'all';

  final List<Map<String, dynamic>> _doctors = [
    {
      'id': 'DOC-01',
      'nameBn': 'কৃষিবিদ ড. মো: আসাদুজ্জামান',
      'nameEn': 'Dr. Md. Asaduzzaman (Agriculturist)',
      'titleBn': 'বিসিএস (কৃষি ক্যাডার) • সাবেক সিনিয়র সাইন্টিফিক অফিসার, BARI',
      'titleEn': 'BCS (Agri Cadre) • Former Senior Scientific Officer, BARI',
      'specialty': 'crop',
      'specialtyBn': 'শস্য ও উদ্যানতত্ত্ব বিশেষজ্ঞ 🌾',
      'specialtyEn': 'Crop & Horticulture Specialist 🌾',
      'rating': 4.9,
      'consultations': 1250,
      'fee': 50,
      'isOnline': true,
      'experienceBn': '১৫+ বছর',
      'experienceEn': '15+ Years',
      'locationBn': 'গাজীপুর / বগুড়া রিসার্চ স্টেশন',
      'locationEn': 'Gazipur / Bogura Research Station',
      'imageUrl': 'https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=400&auto=format&fit=crop&q=60',
      'availableTimeBn': 'আজ বিকাল ৪:০০ - রাত ৯:০০',
      'availableTimeEn': 'Today 4:00 PM - 9:00 PM',
    },
    {
      'id': 'DOC-02',
      'nameBn': 'ড. ফারহানা ইয়াসমিন',
      'nameEn': 'Dr. Farhana Yasmin',
      'titleBn': 'সিনিয়র রিসার্চার • বাংলাদেশ মৎস্য গবেষণা ইনস্টিটিউট (BFRI)',
      'titleEn': 'Senior Researcher • Bangladesh Fisheries Research Institute (BFRI)',
      'specialty': 'fish',
      'specialtyBn': 'মাছের রোগ ও পানি ব্যবস্থাপনা 🐟',
      'specialtyEn': 'Fish Disease & Aqua Quality Specialist 🐟',
      'rating': 4.9,
      'consultations': 890,
      'fee': 40,
      'isOnline': true,
      'experienceBn': '১২+ বছর',
      'experienceEn': '12+ Years',
      'locationBn': 'ময়মনসিংহ রিসার্চ হেডকোয়ার্টার',
      'locationEn': 'Mymensingh Research HQ',
      'imageUrl': 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400&auto=format&fit=crop&q=60',
      'availableTimeBn': 'আজ দুপুর ৩:০০ - সন্ধ্যা ৭:০০',
      'availableTimeEn': 'Today 3:00 PM - 7:00 PM',
    },
    {
      'id': 'DOC-03',
      'nameBn': 'কৃষিবিদ রফিকুল ইসলাম',
      'nameEn': 'Rafiqul Islam (Agriculturist)',
      'titleBn': 'উপসহকারী কৃষি কর্মকর্তা (DAE) • প্ল্যান্ট ডক্টর',
      'titleEn': 'Sub-Assistant Agriculture Officer (DAE) • Plant Doctor',
      'specialty': 'crop',
      'specialtyBn': 'কীটপতঙ্গ ও বালাইনাশক বিশেষজ্ঞ 🌿',
      'specialtyEn': 'Pest & Pesticide Specialist 🌿',
      'rating': 4.8,
      'consultations': 2100,
      'fee': 30,
      'isOnline': false,
      'experienceBn': '১০+ বছর',
      'experienceEn': '10+ Years',
      'locationBn': 'রাজশাহী কৃষি সম্প্রসারণ অধিদপ্তর',
      'locationEn': 'DAE Rajshahi Division',
      'imageUrl': 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400&auto=format&fit=crop&q=60',
      'availableTimeBn': 'আগামীকাল সকাল ৯:০০ - দুপুর ১:০০',
      'availableTimeEn': 'Tomorrow 9:00 AM - 1:00 PM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2E7D32);
    final bool isBn = LanguageProvider.isBn(context);

    final filteredDoctors = _selectedSpecialty == 'all'
        ? _doctors
        : _doctors.where((d) => d['specialty'] == _selectedSpecialty).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          isBn ? 'কৃষি ও মৎস্য ডাক্তার 🩺' : 'Agri & Fishery Doctor 🩺',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryGreen, Color(0xFF1B5E20)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isBn ? 'লাইভ বিশেষজ্ঞ পরামর্শ সেবা' : 'Live Expert Consultation',
                      style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isBn ? 'সরকারি বিশেষজ্ঞ' : 'Govt Specialists',
                        style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  isBn 
                      ? 'ফসলের পোকা-মাকড়, মাছের মড়ক বা মাটির সমস্যায় সরাসরি অডিও/ভিডিও কলে বিসিএস কর্মকর্তা ও গবেষকদের পরামর্শ নিন।'
                      : 'Get direct audio/video call consultations with BCS officers and agricultural researchers for crop pests, fish diseases, and soil issues.',
                  style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.white.withValues(alpha: 0.9), height: 1.3),
                ),
              ],
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _filterChip(isBn ? 'সব বিশেষজ্ঞ' : 'All Specialists', 'all'),
                const SizedBox(width: 8),
                _filterChip(isBn ? '🌾 শস্য ও শাকসবজি' : '🌾 Crop & Vegetables', 'crop'),
                const SizedBox(width: 8),
                _filterChip(isBn ? '🐟 মৎস্য ও চিংড়ি' : '🐟 Fishery & Aqua', 'fish'),
              ],
            ),
          ),

          // Doctor List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: filteredDoctors.length,
              itemBuilder: (context, index) {
                final doc = filteredDoctors[index];
                return _buildDoctorCard(doc, primaryGreen, isBn);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String specialty) {
    final isSelected = _selectedSpecialty == specialty;
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
        if (selected) setState(() => _selectedSpecialty = specialty);
      },
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doc, Color primaryGreen, bool isBn) {
    final isOnline = doc['isOnline'] == true;
    final name = isBn ? doc['nameBn'] : doc['nameEn'];
    final title = isBn ? doc['titleBn'] : doc['titleEn'];
    final specialtyText = isBn ? doc['specialtyBn'] : doc['specialtyEn'];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Image + Online badge
              Stack(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.green.shade100,
                    backgroundImage: NetworkImage(doc['imageUrl']),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 12),
                              const SizedBox(width: 2),
                              Text('${doc['rating']}', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade700),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      specialtyText,
                      style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF2E7D32)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Experience & Fee
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBn ? 'পরামর্শ ফি (টোকেন):' : 'Fee (Token):',
                    style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  Text(
                    isBn ? '৳ ${doc['fee']} / কল' : '৳ ${doc['fee']} / call',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFE65100),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _bookConsultation(doc, isBn),
                icon: const Icon(Icons.video_call_rounded, color: Colors.white, size: 18),
                label: Text(
                  isOnline 
                      ? (isBn ? 'সরাসরি কল বুক করুন' : 'Book Call')
                      : (isBn ? 'অ্যাপয়েন্টমেন্ট নিন' : 'Appointment'),
                  style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOnline ? const Color(0xFF2E7D32) : const Color(0xFF1976D2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _bookConsultation(Map<String, dynamic> doc, bool isBn) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final fee = doc['fee'] as int;
        final platformCut = (fee * 0.30).toStringAsFixed(0);
        final doctorPayout = (fee * 0.70).toStringAsFixed(0);
        final name = isBn ? doc['nameBn'] : doc['nameEn'];
        final title = isBn ? doc['titleBn'] : doc['titleEn'];

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.verified, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 8),
                  Text(
                    isBn ? 'টোকেন পেমেন্ট ও ভিডিও কল রুম' : 'Token Payment & Video Call Room',
                    style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${isBn ? 'বিশেষজ্ঞ' : 'Specialist'}: $name\n${isBn ? 'পদবি' : 'Title'}: $title',
                style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.grey.shade800),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isBn ? 'মোট কনসাল্টেশন ফি:' : 'Total Consultation Fee:', style: GoogleFonts.hindSiliguri(fontSize: 13)),
                        Text('৳ $fee', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isBn ? 'ডাক্তার পাবেন (৭০%): ৳ $doctorPayout' : 'Doctor payout (70%): ৳ $doctorPayout',
                          style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade700),
                        ),
                        Text(
                          isBn ? 'প্ল্যাটফর্ম চার্জ (৩০%): ৳ $platformCut' : 'Platform fee (30%): ৳ $platformCut',
                          style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.green.shade900, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Get.snackbar(
                      isBn ? '🎉 কল বুকিং সম্পন্ন!' : '🎉 Consultation Booked!',
                      isBn 
                          ? '$name এর সাথে আপনার ভিডিও কনসাল্টেশন টোকেন সফল হয়েছে। রুম আইডি: #AGRI-${DateTime.now().millisecondsSinceEpoch % 10000}'
                          : 'Your video consultation token with $name is confirmed. Room ID: #AGRI-${DateTime.now().millisecondsSinceEpoch % 10000}',
                      backgroundColor: const Color(0xFF2E7D32),
                      colorText: Colors.white,
                      duration: const Duration(seconds: 4),
                    );
                  },
                  icon: const Icon(Icons.payment, color: Colors.white),
                  label: Text(
                    isBn 
                        ? 'বিকাশ/নগদে ৳$fee পরিশোধ করে কল শুরু করুন'
                        : 'Pay ৳$fee via bKash/Nagad & Start Call',
                    style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE65100),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
