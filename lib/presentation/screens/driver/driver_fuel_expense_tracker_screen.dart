import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class DriverFuelExpenseTrackerScreen extends StatefulWidget {
  const DriverFuelExpenseTrackerScreen({super.key});

  @override
  State<DriverFuelExpenseTrackerScreen> createState() => _DriverFuelExpenseTrackerScreenState();
}

class _DriverFuelExpenseTrackerScreenState extends State<DriverFuelExpenseTrackerScreen> {
  double _grossEarnings = 14500.0;
  double _fuelCost = 3200.0;
  double _tollCost = 1400.0;
  double _otherCost = 500.0; // Maintenance / Police / Food

  final List<Map<String, dynamic>> _recentExpenseLogs = [
    {
      'date': 'আজ (২৯ আগস্ট)',
      'type': 'ডিজেল (৩০ লিটার)',
      'amount': '৳ ৩,২০০',
      'icon': Icons.local_gas_station,
      'color': Colors.red,
    },
    {
      'date': 'আজ (২৯ আগস্ট)',
      'type': 'বঙ্গবন্ধু যমুনা সেতু টোল',
      'amount': '৳ ১,৪০০',
      'icon': Icons.toll,
      'color': Colors.blue,
    },
    {
      'date': 'গতকাল (২৮ আগস্ট)',
      'type': 'টায়ার মেরামত ও মোবিল টপ-আপ',
      'amount': '৳ ৫০০',
      'icon': Icons.build,
      'color': Colors.orange,
    },
  ];

  double get _totalExpense => _fuelCost + _tollCost + _otherCost;
  double get _netProfit => _grossEarnings - _totalExpense;

  @override
  Widget build(BuildContext context) {
    const Color primaryOrange = Color(0xFFF57C00);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'জ্বালানি ও নিট মুনাফা ট্র্যাকার ⛽',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
        ),
        backgroundColor: primaryOrange,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddExpenseDialog,
        backgroundColor: primaryOrange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('খরচ এন্ট্রি দিন', style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Net Profit Hero Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('আজকের আসল নিট লাভ (Net Profit)', style: GoogleFonts.hindSiliguri(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('${((_netProfit / _grossEarnings) * 100).toInt()}% মার্জিন', style: GoogleFonts.poppins(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('৳ ${_netProfit.toInt()}', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 32)),
                  const Divider(color: Colors.white24, height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('মোট আয় (Gross)', style: GoogleFonts.hindSiliguri(color: Colors.white60, fontSize: 11)),
                          Text('৳ ${_grossEarnings.toInt()}', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('মোট খরচ (Fuel & Toll)', style: GoogleFonts.hindSiliguri(color: Colors.white60, fontSize: 11)),
                          Text('৳ ${_totalExpense.toInt()}', style: GoogleFonts.poppins(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Cost Breakdown Grid
            Text('খরচের খাতসমূহ (Cost Breakdown)', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(child: _buildExpensePill('ডিজেল/জ্বালানি', '৳ ${_fuelCost.toInt()}', Icons.local_gas_station, Colors.red, isDark)),
                const SizedBox(width: 8),
                Expanded(child: _buildExpensePill('সেতু টোল ফি', '৳ ${_tollCost.toInt()}', Icons.toll, Colors.blue, isDark)),
                const SizedBox(width: 8),
                Expanded(child: _buildExpensePill('মেরামত/অন্যান্য', '৳ ${_otherCost.toInt()}', Icons.build, Colors.orange, isDark)),
              ],
            ),
            const SizedBox(height: 20),

            // Recent Logs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('সাম্প্রতিক খরচের হিসেব', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 15)),
                Text('৩টি রেকর্ড', style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 10),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentExpenseLogs.length,
              itemBuilder: (context, index) {
                final log = _recentExpenseLogs[index];
                return Card(
                  color: Theme.of(context).cardColor,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 1,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: (log['color'] as Color).withOpacity(0.12),
                      child: Icon(log['icon'] as IconData, color: log['color'] as Color, size: 20),
                    ),
                    title: Text(log['type'], style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(log['date'], style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600)),
                    trailing: Text(log['amount'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red.shade700)),
                  ),
                );
              },
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensePill(String title, String amount, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(title, style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600)),
          Text(amount, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
        ],
      ),
    );
  }

  void _showAddExpenseDialog() {
    final typeController = TextEditingController();
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 16),
            Text('নতুন খরচের হিসাব যুক্ত করুন ⛽', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 17)),
            const SizedBox(height: 12),
            TextField(controller: typeController, decoration: const InputDecoration(labelText: 'খরচের বিবরণ (যেমন: ডিজেল / পদ্মা সেতু টোল)', prefixIcon: Icon(Icons.description))),
            const SizedBox(height: 10),
            TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'টাকার পরিমাণ (৳)', prefixIcon: Icon(Icons.monetization_on))),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final amt = double.tryParse(amountController.text) ?? 0.0;
                  if (amt > 0) {
                    setState(() {
                      _fuelCost += amt;
                      _recentExpenseLogs.insert(0, {
                        'date': 'আজকের এন্ট্রি',
                        'type': typeController.text.isNotEmpty ? typeController.text : 'ডিজেল খরচ',
                        'amount': '৳ ${amt.toInt()}',
                        'icon': Icons.local_gas_station,
                        'color': Colors.red,
                      });
                    });
                  }
                  Navigator.pop(ctx);
                  Get.snackbar('খরচ সংরক্ষিত হয়েছে! 📊', 'আপনার নিট মুনাফার হিসাব স্বয়ংক্রিয়ভাবে আপডেট হয়েছে।', backgroundColor: const Color(0xFF2E7D32), colorText: Colors.white);
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF57C00), padding: const EdgeInsets.symmetric(vertical: 12)),
                child: Text('হিসাব সংরক্ষণ করুন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
