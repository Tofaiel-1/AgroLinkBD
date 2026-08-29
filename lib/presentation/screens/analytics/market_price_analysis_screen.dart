import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/models/market_price_model.dart';
import 'package:agrolinkbd/core/services/market_price_service.dart';
import 'package:intl/intl.dart';

class MarketPriceAnalysisScreen extends StatefulWidget {
  const MarketPriceAnalysisScreen({super.key});

  @override
  State<MarketPriceAnalysisScreen> createState() => _MarketPriceAnalysisScreenState();
}

class _MarketPriceAnalysisScreenState extends State<MarketPriceAnalysisScreen> {
  final MarketPriceService _priceService = MarketPriceService();
  List<MarketPriceModel> _allPrices = [];
  List<MarketPriceModel> _filteredPrices = [];
  bool _isLoading = true;
  String _selectedCategory = 'সব';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'label': 'সব', 'key': 'all'},
    {'label': 'সবজি', 'key': 'vegetables'},
    {'label': 'ফলমূল', 'key': 'fruits'},
    {'label': 'চাল', 'key': 'grains'},
    {'label': 'মাছ', 'key': 'fish'},
  ];

  @override
  void initState() {
    super.initState();
    _loadPrices();
    _searchController.addListener(_filterPrices);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPrices() async {
    setState(() => _isLoading = true);
    try {
      final prices = await _priceService.fetchCurrentMarketPrices();
      setState(() {
        _allPrices = prices;
        _filteredPrices = prices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading prices: $e')),
        );
      }
    }
  }

  void _filterPrices() {
    String query = _searchController.text.toLowerCase();
    String categoryKey = _categories.firstWhere((c) => c['label'] == _selectedCategory)['key'];

    setState(() {
      _filteredPrices = _allPrices.where((price) {
        bool matchesCategory = categoryKey == 'all' || price.category == categoryKey;
        bool matchesSearch = price.productName.toLowerCase().contains(query);
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'বাজার দর বিশ্লেষণ',
          style: GoogleFonts.hindSiliguri(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1B5E20),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPrices,
          )
        ],
      ),
      body: Column(
        children: [
          // Header Section with Search
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF1B5E20),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'আজকের পাইকারি ও খুচরা বাজার দর',
                  style: GoogleFonts.hindSiliguri(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'পণ্য অনুসন্ধান করুন (যেমন: আলু, টমেটো)',
                      hintStyle: GoogleFonts.hindSiliguri(color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF1B5E20)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Categories
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat['label'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      cat['label'],
                      style: GoogleFonts.hindSiliguri(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF4CAF50),
                    backgroundColor: Colors.white,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = cat['label'];
                          _filterPrices();
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),

          // Price List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPrices.isEmpty
                    ? Center(
                        child: Text(
                          'কোনো তথ্য পাওয়া যায়নি',
                          style: GoogleFonts.hindSiliguri(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadPrices,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredPrices.length,
                          itemBuilder: (context, index) {
                            return _buildPriceCard(_filteredPrices[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(MarketPriceModel priceData) {
    Color trendColor;
    IconData trendIcon;
    String trendText;

    switch (priceData.trend) {
      case PriceTrend.up:
        trendColor = Colors.red.shade600;
        trendIcon = Icons.arrow_upward;
        trendText = 'বেড়েছে';
        break;
      case PriceTrend.down:
        trendColor = Colors.green.shade600;
        trendIcon = Icons.arrow_downward;
        trendText = 'কমেছে';
        break;
      case PriceTrend.stable:
        trendColor = Colors.blue.shade600;
        trendIcon = Icons.remove;
        trendText = 'অপরিবর্তিত';
        break;
    }

    final double priceDiff = (priceData.currentPrice - priceData.previousPrice).abs();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Product Info
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    priceData.productName,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        priceData.location ?? 'সারাদেশ',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'আপডেট: ${DateFormat('dd MMM, HH:mm').format(priceData.updatedAt)}',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            
            // Current Price
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '৳${priceData.currentPrice.toStringAsFixed(0)}',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1B5E20),
                    ),
                  ),
                  Text(
                    'প্রতি ${priceData.unit}',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Trend indicator
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: trendColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(trendIcon, size: 14, color: trendColor),
                        const SizedBox(width: 4),
                        Text(
                          priceData.trend == PriceTrend.stable 
                            ? trendText 
                            : '৳${priceDiff.toStringAsFixed(0)}',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: trendColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
