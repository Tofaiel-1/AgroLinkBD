import json

with open('D:/App/AgroLinkBD/lib/presentation/screens/driver/driver_dashboard.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
skip = False
for i, line in enumerate(lines):
    if skip:
        if '// ============================================\n' in line and '// PERFORMANCE METRICS' in lines[i+1]:
            skip = False
        else:
            continue
            
    if "import 'package:provider/provider.dart';" in line:
        new_lines.append("import 'package:provider/provider.dart' as prov;\n")
        new_lines.append("import 'package:flutter_riverpod/flutter_riverpod.dart';\n")
        new_lines.append("import 'package:agrolinkbd/core/providers/payment_provider.dart';\n")
    elif "class DriverDashboard extends StatefulWidget {" in line:
        new_lines.append("class DriverDashboard extends ConsumerStatefulWidget {\n")
    elif "State<DriverDashboard> createState() => _DriverDashboardState();" in line:
        new_lines.append("  ConsumerState<DriverDashboard> createState() => _DriverDashboardState();\n")
    elif "class _DriverDashboardState extends State<DriverDashboard>" in line:
        new_lines.append("class _DriverDashboardState extends ConsumerState<DriverDashboard>\n")
    elif "late Animation<double> _fadeAnimation;" in line:
        new_lines.append(line)
        new_lines.append("  bool _hasActiveTrip = false;\n")
        new_lines.append("  Map<String, dynamic>? _activeTrip;\n")
        new_lines.append("  bool _isLoadingPayment = false;\n")
    elif "Widget build(BuildContext context) {" in line:
        new_lines.append(line)
        new_lines.append("    final userProvider = prov.Provider.of<UserProvider>(context);\n")
        new_lines.append("    final userId = userProvider.currentUser?.uid ?? 'driver_mock_id';\n")
        new_lines.append("    final walletBalanceAsync = ref.watch(walletBalanceProvider(userId));\n")
        new_lines.append("    final pendingBalanceAsync = ref.watch(pendingBalanceProvider(userId));\n")
        new_lines.append("    final walletBalance = walletBalanceAsync.value ?? 0.0;\n")
        new_lines.append("    final pendingBalance = pendingBalanceAsync.value ?? 0.0;\n")
    elif "'৳ 2,450'" in line:
        new_lines.append("                                      '৳ ${walletBalance.toStringAsFixed(0)}',\n")
    elif "'১২/১৫'" in line:
        new_lines.append("                                      '৳ ${pendingBalance.toStringAsFixed(0)} (Pending)',\n")
    elif "'ট্রিপ সম্পন্ন'" in line:
        new_lines.append("                                      'এসক্রো (Pending)',\n")
    elif "Provider.of<UserProvider>(context, listen: false);" in line:
        new_lines.append("                    prov.Provider.of<UserProvider>(context, listen: false);\n")
    elif "// Active trip card\n" == line:
        new_lines.append('''                    if (_hasActiveTrip && _activeTrip != null)
                      _buildActiveTripCard(userId)
                    else
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: const Center(
                          child: Text('কোনো বর্তমান ট্রিপ নেই। একটি ট্রিপ গ্রহণ করুন।'),
                        ),
                      ),
                    const SizedBox(height: 16),
''')
        skip = True
    elif "Widget _buildMetricCard({" in line:
        new_lines.append('''
  Widget _buildActiveTripCard(String userId) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ট্রিপ #TR2024-05821',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'ডেলিভারিতে',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on, size: 20, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('শুরু: ${_activeTrip!['pickup']}', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600)),
                    const SizedBox(height: 2),
                    Text('শেষ: ${_activeTrip!['delivery']}', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Text(
                _activeTrip!['pay'],
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _isLoadingPayment
              ? const Center(child: CircularProgressIndicator())
              : Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          setState(() => _isLoadingPayment = true);
                          final amountStr = _activeTrip!['pay'].toString().replaceAll(RegExp(r'[^0-9]'), '');
                          final amount = double.tryParse(amountStr) ?? 0.0;
                          final amountAfterCommission = amount * 0.95; // 5% platform fee
                          
                          final success = await ref.read(transactionNotifierProvider.notifier).releaseEscrow(
                            userId: userId,
                            amount: amountAfterCommission,
                            reason: 'Trip Completed: ${_activeTrip!['pickup']} to ${_activeTrip!['delivery']}',
                          );
                          
                          setState(() {
                            _isLoadingPayment = false;
                            if (success) {
                              _hasActiveTrip = false;
                              _activeTrip = null;
                              Get.snackbar('সফল', 'ডেলিভারি সম্পন্ন এবং পেমেন্ট ওয়ালেটে যুক্ত হয়েছে।',
                                  backgroundColor: Colors.green, colorText: Colors.white);
                            } else {
                              Get.snackbar('ত্রুটি', 'পেমেন্ট প্রসেস করতে সমস্যা হয়েছে।',
                                  backgroundColor: Colors.red, colorText: Colors.white);
                            }
                          });
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('ডেলিভারি সম্পন্ন'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
''')
        new_lines.append(line)
    elif "Get.snackbar(" in line and "ট্রিপ গৃহীত" in lines[i+1] and "${job['pickup']}" in lines[i+2]:
        new_lines.append('''                    final userProvider = prov.Provider.of<UserProvider>(context, listen: false);
                    final userId = userProvider.currentUser?.uid ?? 'driver_mock_id';
                    
                    if (_hasActiveTrip) {
                      Get.snackbar('ত্রুটি', 'আপনার ইতিমধ্যে একটি চলমান ট্রিপ রয়েছে।', backgroundColor: Colors.red, colorText: Colors.white);
                      return;
                    }
                    
                    final amountStr = job['pay'].toString().replaceAll(RegExp(r'[^0-9]'), '');
                    final amount = double.tryParse(amountStr) ?? 0.0;
                    
                    ref.read(transactionNotifierProvider.notifier).addEscrow(
                      userId: userId,
                      amount: amount,
                      reason: 'Trip Accepted: ${job['pickup']} to ${job['delivery']}',
                    ).then((success) {
                      if (success) {
                        setState(() {
                          _hasActiveTrip = true;
                          _activeTrip = job;
                        });
                        Get.snackbar('ট্রিপ গৃহীত', 'পেমেন্ট Escrow তে সিকিউরড হয়েছে।', backgroundColor: Colors.blue, colorText: Colors.white);
                      }
                    });\n''')
        # Skip the next 3 lines
        for j in range(3):
            lines[i+j+1] = ""
    elif "Provider.of<UserProvider>(context" in line:
        new_lines.append("                    prov.Provider.of<UserProvider>(context, listen: false);\n")
    else:
        new_lines.append(line)

with open('D:/App/AgroLinkBD/lib/presentation/screens/driver/driver_dashboard.dart', 'w', encoding='utf-8') as f:
    f.writelines(new_lines)
