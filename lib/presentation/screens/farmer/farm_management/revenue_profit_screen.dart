import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/models/phase2_models/farm_models.dart';
import 'package:agrolinkbd/core/services/phase2_services/farm_service.dart';
import 'package:intl/intl.dart';
import 'add_edit_revenue_screen.dart';

class RevenueProfitScreen extends StatefulWidget {
  const RevenueProfitScreen({Key? key}) : super(key: key);

  @override
  State<RevenueProfitScreen> createState() => _RevenueProfitScreenState();
}

class _RevenueProfitScreenState extends State<RevenueProfitScreen> {
  final FarmService _farmService = FarmService();
  late Stream<List<FarmRevenue>> _revenuesStream;
  late Stream<List<FarmExpense>> _expensesStream;

  @override
  void initState() {
    super.initState();
    _revenuesStream = _farmService.getRevenuesStream();
    _expensesStream = _farmService.getExpensesStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF009688),
        elevation: 0,
        title: Text(
          'Revenue & Profit',
          style: GoogleFonts.openSans(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: StreamBuilder<List<FarmRevenue>>(
        stream: _revenuesStream,
        builder: (context, revSnapshot) {
          return StreamBuilder<List<FarmExpense>>(
            stream: _expensesStream,
            builder: (context, expSnapshot) {
              if (revSnapshot.connectionState == ConnectionState.waiting || 
                  expSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF009688)));
              }

              final revenues = revSnapshot.data ?? [];
              final expenses = expSnapshot.data ?? [];
              
              final currentMonth = DateTime.now().month;
              final currentYear = DateTime.now().year;

              double totalRevThisMonth = 0.0;
              for (var r in revenues) {
                if (r.date.month == currentMonth && r.date.year == currentYear) {
                  totalRevThisMonth += r.amount;
                }
              }

              double totalExpThisMonth = 0.0;
              for (var e in expenses) {
                if (e.date.month == currentMonth && e.date.year == currentYear) {
                  totalExpThisMonth += e.amount;
                }
              }

              final netProfit = totalRevThisMonth - totalExpThisMonth;

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildFinancialSummary(totalRevThisMonth, totalExpThisMonth, netProfit),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'Recent Sales',
                        style: GoogleFonts.openSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D3748),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        revenues.isEmpty
                            ? [
                                Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Center(
                                    child: Text(
                                      'No sales recorded yet',
                                      style: GoogleFonts.openSans(color: Colors.grey),
                                    ),
                                  ),
                                )
                              ]
                            : revenues.map((sale) => _buildSaleCard(sale)).toList(),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditRevenueScreen()),
          );
        },
        backgroundColor: const Color(0xFF009688),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFinancialSummary(double rev, double exp, double profit) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF009688),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric('Total Revenue', '৳ ${NumberFormat('#,##0').format(rev)}', Icons.arrow_upward, Colors.greenAccent),
              _buildMetric('Total Expenses', '৳ ${NumberFormat('#,##0').format(exp)}', Icons.arrow_downward, Colors.redAccent),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Text(
                  'Net Profit',
                  style: GoogleFonts.openSans(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '৳ ${NumberFormat('#,##0').format(profit)}',
                  style: GoogleFonts.openSans(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon, Color iconColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.openSans(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.openSans(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSaleCard(FarmRevenue sale) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCBD5E1).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF009688).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.shopping_bag, color: Color(0xFF009688), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${sale.cropName} (${sale.quantity} ${sale.unit})',
                  style: GoogleFonts.openSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy').format(sale.date),
                  style: GoogleFonts.openSans(
                    fontSize: 13,
                    color: const Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+ ৳${NumberFormat('#,##0').format(sale.amount)}',
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: const Color(0xFF009688),
            ),
          ),
        ],
      ),
    );
  }
}
