import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/models/phase2_models/farm_models.dart';
import 'package:agrolinkbd/core/services/phase2_services/farm_service.dart';
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Fertilizer': return Icons.science;
      case 'Labor': return Icons.people;
      case 'Seeds': return Icons.grass;
      case 'Equipment': return Icons.agriculture;
      case 'Pesticides': return Icons.pest_control;
      case 'Irrigation': return Icons.water_drop;
      default: return Icons.attach_money;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Fertilizer': return Colors.blue;
      case 'Labor': return Colors.orange;
      case 'Seeds': return Colors.green;
      case 'Equipment': return Colors.brown;
      case 'Pesticides': return Colors.purple;
      case 'Irrigation': return Colors.lightBlue;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF44336),
        elevation: 0,
        title: Text(
          'Expense Management',
          style: GoogleFonts.openSans(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
          Map<String, double> categoryTotals = {};

          for (var exp in expenses) {
            if (exp.date.month == currentMonth && exp.date.year == currentYear) {
              totalThisMonth += exp.amount;
              categoryTotals[exp.category] = (categoryTotals[exp.category] ?? 0) + exp.amount;
            }
          }

          return CustomScrollView(
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
                        'Total Expenses (This Month)',
                        style: GoogleFonts.openSans(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '৳ ${NumberFormat('#,##0.00').format(totalThisMonth)}',
                        style: GoogleFonts.openSans(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: categoryTotals.entries.map((e) {
                            final percentage = totalThisMonth > 0 ? (e.value / totalThisMonth * 100) : 0.0;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: _buildSummaryChip(e.key, '${percentage.toStringAsFixed(0)}%'),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Transactions',
                          style: GoogleFonts.openSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D3748),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (expenses.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            'No expenses recorded yet',
                            style: GoogleFonts.openSans(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ...expenses.map((tx) => _buildTransactionCard(tx)).toList(),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditExpenseScreen()),
          );
        },
        backgroundColor: const Color(0xFFF44336),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryChip(String label, String percentage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            percentage,
            style: GoogleFonts.openSans(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.openSans(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(FarmExpense tx) {
    final color = _getCategoryColor(tx.category);
    final icon = _getCategoryIcon(tx.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCBD5E1).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.category,
                  style: GoogleFonts.openSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                if (tx.description.isNotEmpty)
                  Text(
                    tx.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.openSans(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy').format(tx.date),
                  style: GoogleFonts.openSans(
                    fontSize: 12,
                    color: const Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '- ৳${NumberFormat('#,##0').format(tx.amount)}',
            style: GoogleFonts.openSans(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: const Color(0xFFF44336),
            ),
          ),
        ],
      ),
    );
  }
}
