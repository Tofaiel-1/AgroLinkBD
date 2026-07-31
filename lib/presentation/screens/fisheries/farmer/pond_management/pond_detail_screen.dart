import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:agrolinkbd/core/models/pond_model.dart';
import 'package:agrolinkbd/core/controllers/pond_controller.dart';

class PondDetailScreen extends StatefulWidget {
  final PondModel pond;

  const PondDetailScreen({super.key, required this.pond});

  @override
  State<PondDetailScreen> createState() => _PondDetailScreenState();
}

class _PondDetailScreenState extends State<PondDetailScreen> {
  final PondController _pondController = Get.find<PondController>();

  void _showAddActivityDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final amountController = TextEditingController();
    String selectedType = 'Feed';
    bool isIncome = false;
    final formKey = GlobalKey<FormState>();

    Get.defaultDialog(
      title: 'নতুন লেনদেন / এক্টিভিটি যোগ করুন',
      titleStyle: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
      content: StatefulBuilder(
        builder: (context, setDialogState) {
          return Form(
            key: formKey,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ChoiceChip(
                      label: const Text('খরচ'),
                      selected: !isIncome,
                      selectedColor: Colors.red.shade100,
                      onSelected: (val) {
                        setDialogState(() => isIncome = false);
                      },
                    ),
                    ChoiceChip(
                      label: const Text('আয়'),
                      selected: isIncome,
                      selectedColor: Colors.green.shade100,
                      onSelected: (val) {
                        setDialogState(() => isIncome = true);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  items: ['Feed', 'Medicine', 'Maintenance', 'Harvest', 'Sale', 'Other']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedType = val);
                  },
                  decoration: const InputDecoration(labelText: 'ধরণ'),
                ),
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'শিরোনাম (যেমন: ফিড ক্রয় / মাছ বিক্রি)'),
                  validator: (v) => v!.isEmpty ? 'প্রয়োজনীয়' : null,
                ),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'বিবরণ'),
                ),
                TextFormField(
                  controller: amountController,
                  decoration: InputDecoration(labelText: isIncome ? 'আয় (৳)' : 'খরচ (৳)'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'প্রয়োজনীয়' : null,
                ),
              ],
            ),
          );
        }
      ),
      confirm: ElevatedButton(
        onPressed: () {
          if (formKey.currentState!.validate()) {
            _pondController.addActivity(
              widget.pond.id,
              titleController.text,
              descController.text,
              double.tryParse(amountController.text) ?? 0.0,
              selectedType,
              isIncome: isIncome,
            );
            Get.back();
            setState(() {}); // refresh screen
            Get.snackbar('সফল', 'লেনদেন যুক্ত হয়েছে!', backgroundColor: Colors.green, colorText: Colors.white);
          }
        },
        child: const Text('সংরক্ষণ করুন'),
      ),
      cancel: OutlinedButton(
        onPressed: () => Get.back(),
        child: const Text('বাতিল'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color oceanBlue = Color(0xFF0288D1);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          widget.pond.name,
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: oceanBlue,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'কার্যক্রম ও খরচের ইতিহাস',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showAddActivityDialog,
                  icon: const Icon(Icons.add, size: 16),
                  label: Text('যোগ করুন', style: GoogleFonts.hindSiliguri()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: oceanBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildHistoryList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('মোট খরচ', style: GoogleFonts.hindSiliguri(fontSize: 16, color: Colors.red.shade700)),
              Text(
                '৳${widget.pond.totalCost.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red.shade700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('মোট আয়', style: GoogleFonts.hindSiliguri(fontSize: 16, color: Colors.green.shade700)),
              Text(
                '৳${widget.pond.totalIncome.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade700),
              ),
            ],
          ),
          const Divider(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('মোট মাছ', style: GoogleFonts.hindSiliguri(fontSize: 14)),
              Text('${widget.pond.totalFishCount} টি', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('চাষের দিন', style: GoogleFonts.hindSiliguri(fontSize: 14)),
              Text('${widget.pond.daysSinceStocked} দিন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    if (widget.pond.activities.isEmpty) {
      return Center(child: Text('কোনো ইতিহাস নেই', style: GoogleFonts.hindSiliguri()));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.pond.activities.length,
      itemBuilder: (context, index) {
        // Reverse order so newest is on top
        final activity = widget.pond.activities[widget.pond.activities.length - 1 - index];
        return Card(
          color: Theme.of(context).cardColor,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getColorForType(activity.type).withOpacity(0.2),
              child: Icon(_getIconForType(activity.type), color: _getColorForType(activity.type)),
            ),
            title: Text(activity.title, style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
            subtitle: Text(
              '${DateFormat('dd MMM yyyy').format(activity.date)} • ${activity.description}',
              style: GoogleFonts.hindSiliguri(fontSize: 12),
            ),
            trailing: Text(
              '${(activity.isIncome == true) ? '+' : '-'}৳${activity.amount.toStringAsFixed(0)}',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: (activity.isIncome == true) ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'Stock': return Colors.blue;
      case 'Feed': return Colors.orange;
      case 'Medicine': return Colors.teal;
      default: return Colors.grey;
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Stock': return Icons.set_meal;
      case 'Feed': return Icons.inventory_2;
      case 'Medicine': return Icons.health_and_safety;
      default: return Icons.money;
    }
  }
}
