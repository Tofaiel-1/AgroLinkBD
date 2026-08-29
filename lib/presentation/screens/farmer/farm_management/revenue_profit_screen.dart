import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/models/phase2_models/farm_models.dart';
import 'package:agrolinkbd/core/services/phase2_services/farm_service.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
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

  void _refreshStreams() {
    setState(() {
      _revenuesStream = _farmService.getRevenuesStream();
      _expensesStream = _farmService.getExpensesStream();
    });
  }

  String _formatUnit(BuildContext context, String unit) {
    final isBn = LanguageProvider.isBn(context);
    if (!isBn) return unit;
    switch (unit) {
      case 'kg': return 'কেজি';
      case 'maund': return 'মণ';
      case 'ton': return 'টন';
      case 'piece': return 'টি';
      case 'liter': return 'লিটার';
      default: return unit;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBn = LanguageProvider.isBn(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF009688),
        elevation: 0,
        title: Text(
          isBn ? 'আয় ও লাভ-লোকসান' : 'Revenue & Profit',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshStreams,
          ),
        ],
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
              double totalRevAll = 0.0;
              for (var r in revenues) {
                totalRevAll += r.amount;
                if (r.date.month == currentMonth && r.date.year == currentYear) {
                  totalRevThisMonth += r.amount;
                }
              }

              double totalExpThisMonth = 0.0;
              double totalExpAll = 0.0;
              for (var e in expenses) {
                totalExpAll += e.amount;
                if (e.date.month == currentMonth && e.date.year == currentYear) {
                  totalExpThisMonth += e.amount;
                }
              }

              final bool hasThisMonthData = totalRevThisMonth > 0 || totalExpThisMonth > 0;
              final displayRev = hasThisMonthData ? totalRevThisMonth : totalRevAll;
              final displayExp = hasThisMonthData ? totalExpThisMonth : totalExpAll;
              final displayProfit = displayRev - displayExp;
              final periodLabel = hasThisMonthData
                  ? (isBn ? 'চলতি মাস' : 'This Month')
                  : (isBn ? 'সর্বমোট' : 'All Time');

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildFinancialSummary(context, displayRev, displayExp, displayProfit, periodLabel),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isBn ? 'সাম্প্রতিক ফসল বিক্রয়ের তালিকা' : 'Recent Sales',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2D3748),
                            ),
                          ),
                          Text(
                            '${revenues.length} ${isBn ? "টি বিক্রয়" : "sales"}',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        revenues.isEmpty
                            ? [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Icon(Icons.point_of_sale_outlined, size: 64, color: Colors.grey.shade400),
                                        const SizedBox(height: 12),
                                        Text(
                                          isBn ? 'এখনো কোনো বিক্রয় বা আয়ের হিসাব যোগ করা হয়নি' : 'No sales recorded yet',
                                          style: GoogleFonts.hindSiliguri(color: Colors.grey.shade600, fontSize: 15),
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => const AddEditRevenueScreen()),
                                            ).then((_) => _refreshStreams());
                                          },
                                          icon: const Icon(Icons.add, color: Colors.white),
                                          label: Text(
                                            isBn ? 'নতুন বিক্রয় যোগ করুন' : 'Add First Sale',
                                            style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF009688),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ]
                            : revenues.map((sale) => _buildSaleCard(context, sale)).toList(),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditRevenueScreen()),
          ).then((_) => _refreshStreams());
        },
        backgroundColor: const Color(0xFF009688),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          isBn ? 'আয় যোগ' : 'Add Sale',
          style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildFinancialSummary(BuildContext context, double rev, double exp, double profit, String period) {
    final isBn = LanguageProvider.isBn(context);

    return Container(
      padding: const EdgeInsets.all(20),
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
              _buildMetric(
                isBn ? 'মোট আয় ($period)' : 'Total Revenue ($period)',
                '৳ ${NumberFormat('#,##0').format(rev)}',
                Icons.arrow_upward_rounded,
                Colors.greenAccent,
              ),
              _buildMetric(
                isBn ? 'মোট খরচ ($period)' : 'Total Expense ($period)',
                '৳ ${NumberFormat('#,##0').format(exp)}',
                Icons.arrow_downward_rounded,
                Colors.redAccent,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      profit >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      color: profit >= 0 ? Colors.greenAccent : Colors.redAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isBn ? 'নিট মুনাফা / লাভ ($period)' : 'Net Profit ($period)',
                      style: GoogleFonts.hindSiliguri(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${profit < 0 ? '-' : ''}৳ ${NumberFormat('#,##0').format(profit.abs())}',
                  style: GoogleFonts.hindSiliguri(
                    color: Colors.white,
                    fontSize: 34,
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
              style: GoogleFonts.hindSiliguri(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSaleCard(BuildContext context, FarmRevenue sale) {
    final isBn = LanguageProvider.isBn(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF009688).withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF009688), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${sale.cropName} (${sale.quantity.toStringAsFixed(0)} ${_formatUnit(context, sale.unit)})',
                  style: GoogleFonts.hindSiliguri(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                if (sale.buyerName.isNotEmpty)
                  Text(
                    '${isBn ? "ক্রেতা: " : "Buyer: "}${sale.buyerName}',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('dd MMM yyyy').format(sale.date),
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 11,
                    color: const Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+ ৳${NumberFormat('#,##0').format(sale.amount)}',
                style: GoogleFonts.hindSiliguri(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: const Color(0xFF009688),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(isBn ? 'বিক্রয় মুছুন' : 'Delete Sale'),
                      content: Text(isBn ? 'আপনি কি এই বিক্রয়ের হিসাবটি মুছে ফেলতে চান?' : 'Are you sure you want to delete this sale?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(isBn ? 'না' : 'No')),
                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(isBn ? 'হ্যাঁ' : 'Yes', style: const TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                  if (confirm == true && sale.id.isNotEmpty) {
                    await _farmService.deleteRevenue(sale.id);
                    _refreshStreams();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Icon(Icons.delete_outline, size: 18, color: Colors.grey.shade400),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
