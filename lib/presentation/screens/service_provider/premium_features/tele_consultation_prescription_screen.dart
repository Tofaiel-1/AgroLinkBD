import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/presentation/widgets/premium_feature_gatekeeper.dart';

class TeleConsultationPrescriptionScreen extends StatefulWidget {
  const TeleConsultationPrescriptionScreen({super.key});

  @override
  State<TeleConsultationPrescriptionScreen> createState() => _TeleConsultationPrescriptionScreenState();
}

class _TeleConsultationPrescriptionScreenState extends State<TeleConsultationPrescriptionScreen> {
  final _farmerNameController = TextEditingController(text: 'মোঃ আনোয়ার হোসেন');
  final _pondSizeController = TextEditingController(text: '৫০ শতক (পাবদা প্রজেক্ট)');
  final _diagnosisController = TextEditingController(text: 'মাছের ফুলকা পচা রোগ (Gill Rot) ও ব্যাকটেরিয়াল ইনফেকশন');

  final List<Map<String, String>> _prescribedMedicines = [
    {
      'name': 'পটাশিয়াম পারম্যাঙ্গানেট (KMnO4)',
      'dose': 'প্রতি শতকে ২ গ্রাম',
      'instruction': 'পুকুরের পানিতে গুলে সকাল বেলা ছিটাতে হবে (৩ দিন পর পর)',
    },
    {
      'name': 'অক্সি-টেট্রাসাইক্লিন (ভেটেরিনারি গ্রেড)',
      'dose': 'প্রতি কেজি খাবারে ৫ গ্রাম',
      'instruction': 'খাবারের সাথে ভালো করে মিশিয়ে পরপর ৫ দিন খাওয়াতে হবে',
    },
    {
      'name': 'ডলোমাইট চুন (Dolomite)',
      'dose': 'প্রতি শতকে ১ কেজি',
      'instruction': 'পানির পিএইচ ও ক্ষারত্ব স্বাভাবিক রাখতে প্রয়োগ করুন',
    },
  ];

  @override
  Widget build(BuildContext context) {
    const Color doctorTeal = Color(0xFF00695C);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'ডিজিটাল প্রেসক্রিপশন প্যাড 🩺',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
        ),
        backgroundColor: doctorTeal,
        elevation: 0,
        centerTitle: true,
      ),
      body: PremiumFeatureGatekeeper(
        featureName: 'টেলি-কনসালটেশন ও ডিজিটাল প্রেসক্রিপশন প্যাড',
        description: 'সার্টিফাইড মৎস্য ও কৃষি বিশেষজ্ঞ হিসেবে ডিজিটাল প্রেসক্রিপশন তৈরি, ওষুধের সঠিক ডোজ ও ভিজিট ফি গ্রহণ করুন।',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Prescription Header Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: doctorTeal, width: 1.5),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Color(0xFFE0F2F1),
                              child: Icon(Icons.local_hospital, color: doctorTeal),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ডাঃ এস. কে. রায়', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text('সিনিয়র মৎস্য বিজ্ঞানী ও কনসালটেন্ট', style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600)),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8)),
                          child: Text('Rx V-9821', style: GoogleFonts.poppins(color: doctorTeal, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Patient/Farmer Details
                    TextField(
                      controller: _farmerNameController,
                      decoration: const InputDecoration(labelText: 'খামারির নাম', prefixIcon: Icon(Icons.person, color: doctorTeal)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _pondSizeController,
                      decoration: const InputDecoration(labelText: 'পুকুরের তথ্য ও মাছের প্রজাতি', prefixIcon: Icon(Icons.pool, color: doctorTeal)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _diagnosisController,
                      decoration: const InputDecoration(labelText: 'রোগের ডায়াগনোসিস ও লক্ষণ', prefixIcon: Icon(Icons.medical_services, color: doctorTeal)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Prescribed Medicines Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('প্রেসক্রাইবকৃত ওষুধ ও ডোজ 💊', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 15)),
                  IconButton(
                    onPressed: _showAddMedicineDialog,
                    icon: const Icon(Icons.add_circle, color: doctorTeal),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _prescribedMedicines.length,
                itemBuilder: (context, index) {
                  final med = _prescribedMedicines[index];
                  return Card(
                    color: Theme.of(context).cardColor,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${index + 1}. ${med['name']}', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(6)),
                                child: Text(med['dose']!, style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: FontWeight.bold, color: doctorTeal)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('প্রয়োগবিধি: ${med['instruction']}', style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade700)),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.snackbar(
                          'প্রেসক্রিপশন প্রেরণ সম্পন্ন! 🚀',
                          'ডিজিটাল প্রেসক্রিপশনটি খামারি ${_farmerNameController.text} এর প্রোফাইলে সরাসরি পাঠানো হয়েছে।',
                          backgroundColor: doctorTeal,
                          colorText: Colors.white,
                        );
                      },
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                      label: Text('খামারিকে পাঠান', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: doctorTeal, padding: const EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddMedicineDialog() {
    final nameCtrl = TextEditingController();
    final doseCtrl = TextEditingController();
    final instCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 16),
            Text('নতুন ওষুধ যুক্ত করুন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'ওষুধের নাম')),
            const SizedBox(height: 8),
            TextField(controller: doseCtrl, decoration: const InputDecoration(labelText: 'ডোজ (যেমন: শতকে ২ গ্রাম)')),
            const SizedBox(height: 8),
            TextField(controller: instCtrl, decoration: const InputDecoration(labelText: 'প্রয়োগবিধি')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.isNotEmpty) {
                    setState(() {
                      _prescribedMedicines.add({
                        'name': nameCtrl.text,
                        'dose': doseCtrl.text,
                        'instruction': instCtrl.text,
                      });
                    });
                  }
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00695C)),
                child: Text('যুক্ত করুন', style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
