import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/models/phase2_models/farm_models.dart';
import 'package:agrolinkbd/core/services/phase2_services/farm_service.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:intl/intl.dart';
import 'add_edit_expense_screen.dart';

class ExpenseManagementScreen extends StatefulWidget {
  const ExpenseManagementScreen({Key? key}) : super(key: key);

  @override
  State<ExpenseManagementScreen> createState() => _ExpenseManagementScreenState();
}

class _ExpenseManagementScreenState extends State<ExpenseManagementScreen> {
  final FarmService _farmService = FarmService();
  late Stream<List<FarmExpense>> _expensesStream;

  @override
  void initState() {
    super.initState();
    _expensesStream = _farmService.getExpensesStream();
  }

  void _refreshStream() {
    setState(() {
      _expensesStream = _farmService.getExpensesStream();
    });
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Fertilizer': return Icons.science;
      case 'Labor': return Icons.people;
      case 'Seeds': return Icons.grass;
      case 'Equipment': return Icons.agriculture;
      case 'Pesticides': return Icons.pest_control;
      case 'Irrigation': return Icons.water_drop;
      case 'Transport': return Icons.local_shipping;
      default: return Icons.attach_money;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Fertilizer': return Colors.blue.shade700;
      case 'Labor': return Colors.orange.shade800;
      case 'Seeds': return Colors.green.shade700;
      case 'Equipment': return Colors.brown.shade700;
      case 'Pesticides': return Colors.purple.shade700;
      case 'Irrigation': return Colors.lightBlue.shade700;
      case 'Transport': return Colors.teal.shade700;
      default: return Colors.blueGrey;
    }
  }

  String _getCategoryName(BuildContext context, String category) {
    final isBn = LanguageProvider.isBn(context);
    if (!isBn) return category;
    switch (category) {
      case 'Fertilizer': return 'সার';
      case 'Labor': return 'শ্রমিক মজুরি';
      case 'Seeds': return 'বীজ / চারা';
      case 'Equipment': return 'যন্ত্রপাতি ও জ্বালানি';
      case 'Pesticides': return 'কীটনাশক';
      case 'Irrigation': return 'সেচ খরচ';
      case 'Transport': return 'পরিবহন';
      default: return 'অন্যান্য';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBn = LanguageProvider.isBn(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF44336),
        elevation: 0,
        title: Text(
          isBn ? 'খরচ ব্যবস্থাপনা' : 'Expense Management',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshStream,
          ),
        ],
      ),
      body: StreamBuilder<List<FarmExpense>>(
        stream: _expensesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFF44336)));
          }

          final expenses = snapshot.data ?? [];
          final currentMonth = DateTime.now().month;
          final currentYear = DateTime.now().year;

          double totalThisMonth = 0.0;
          double totalAllTime = 0.0;
          Map<String, double> categoryTotals = {};

          for (var exp in expenses) {
            totalAllTime += exp.amount;
            if (exp.date.month == currentMonth && exp.date.year == currentYear) {
              totalThisMonth += exp.amount;
              categoryTotals[exp.category] = (categoryTotals[exp.category] ?? 0) + exp.amount;
            }
          }

          final displayTotal = totalThisMonth > 0 ? totalThisMonth : totalAllTime;
          final totalLabel = totalThisMonth > 0
              ? (isBn ? 'চলতি মাসের মোট খরচ' : 'Total Expenses (This Month)')
              : (isBn ? 'সর্বমোট খরচ' : 'Total Expenses (All Time)');

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF44336),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        totalLabel,
                        style: GoogleFonts.hindSiliguri(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '৳ ${NumberFormat('#,##0').format(displayTotal)}',
                        style: GoogleFonts.hindSiliguri(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (categoryTotals.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: categoryTotals.entries.map((e) {
                              final percentage = displayTotal > 0 ? (e.value / displayTotal * 100) : 0.0;
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: _buildSummaryChip(_getCategoryName(context, e.key), '${percentage.toStringAsFixed(0)}%'),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isBn ? 'সাম্প্রতিক খরচের তালিকা' : 'Recent Expenses',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D3748),
                          ),
                        ),
                        Text(
                          '${expenses.length} ${isBn ? "টি রেকর্ড" : "records"}',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (expenses.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Column(
                            children: [
                              Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text(
                                isBn ? 'এখনো কোনো খরচের হিসাব যোগ করা হয়নি' : 'No expenses recorded yet',
                                style: GoogleFonts.hindSiliguri(color: Colors.grey.shade600, fontSize: 15),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const AddEditExpenseScreen()),
                                  ).then((_) => _refreshStream());
                                },
                                icon: const Icon(Icons.add, color: Colors.white),
                                label: Text(
                                  isBn ? 'নতুন খরচ যোগ করুন' : 'Add First Expense',
                                  style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF44336),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...expenses.map((tx) => _buildTransactionCard(context, tx)).toList(),
                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditExpenseScreen()),
          ).then((_) => _refreshStream());
        },
        backgroundColor: const Color(0xFFF44336),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          isBn ? 'খরচ যোগ' : 'Add Expense',
          style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSummaryChip(String label, String percentage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            percentage,
            style: GoogleFonts.hindSiliguri(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.hindSiliguri(
              color: Colors.white.withOpacity(0.9),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, FarmExpense tx) {
    final color = _getCategoryColor(tx.category);
    final icon = _getCategoryIcon(tx.category);
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
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getCategoryName(context, tx.category),
                  style: GoogleFonts.hindSiliguri(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                if (tx.description.isNotEmpty)
                  Text(
                    tx.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('dd MMM yyyy').format(tx.date),
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
                '- ৳${NumberFormat('#,##0').format(tx.amount)}',
                style: GoogleFonts.hindSiliguri(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: const Color(0xFFF44336),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(isBn ? 'খরচ মুছুন' : 'Delete Expense'),
                      content: Text(isBn ? 'আপনি কি এই খরচের হিসাবটি মুছে ফেলতে চান?' : 'Are you sure you want to delete this expense?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(isBn ? 'না' : 'No')),
                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(isBn ? 'হ্যাঁ' : 'Yes', style: const TextStyle(color: Colors.red))),
                      ],
                    ),
                  );
                  if (confirm == true && tx.id.isNotEmpty) {
                    await _farmService.deleteExpense(tx.id);
                    _refreshStream();
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
