import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

/// Service Provider portfolio gallery screen
class PortfolioGalleryScreen extends StatefulWidget {
  const PortfolioGalleryScreen({Key? key}) : super(key: key);

  @override
  State<PortfolioGalleryScreen> createState() => _PortfolioGalleryScreenState();
}

class _PortfolioGalleryScreenState extends State<PortfolioGalleryScreen> {
  // Mock portfolio items for a gorgeous UI demo
  final List<Map<String, dynamic>> _portfolioItems = [
    {
      'title': 'High-Tech Greenhouse Setup',
      'client': 'Rahim Farms Ltd.',
      'rating': 4.9,
      'image': 'https://images.unsplash.com/photo-1585314062340-f1a5a7c9328d?q=80&w=600&auto=format&fit=crop',
      'category': 'Greenhouse',
      'date': 'Oct 2025',
    },
    {
      'title': 'Drip Irrigation System',
      'client': 'Bogra Agro Co.',
      'rating': 4.8,
      'image': 'https://images.unsplash.com/photo-1563514227147-6d2ff665a6a0?q=80&w=600&auto=format&fit=crop',
      'category': 'Irrigation',
      'date': 'Nov 2025',
    },
    {
      'title': 'Soil Testing & Analysis',
      'client': 'Karim Miah',
      'rating': 5.0,
      'image': 'https://images.unsplash.com/photo-1530836369250-ef71a3fb114c?q=80&w=600&auto=format&fit=crop',
      'category': 'Consulting',
      'date': 'Jan 2026',
    },
    {
      'title': 'Organic Fertilizer Supply',
      'client': 'Savar Dairy & Agro',
      'rating': 4.7,
      'image': 'https://images.unsplash.com/photo-1628562300431-7b19bf35a4d9?q=80&w=600&auto=format&fit=crop',
      'category': 'Supply',
      'date': 'Feb 2026',
    },
    {
      'title': 'Solar Water Pump Installation',
      'client': 'Eco Farms BD',
      'rating': 4.9,
      'image': 'https://images.unsplash.com/photo-1509391366360-2e959784a276?q=80&w=600&auto=format&fit=crop',
      'category': 'Machinery',
      'date': 'Mar 2026',
    },
    {
      'title': 'Pest Control Management',
      'client': 'Green Valley',
      'rating': 4.6,
      'image': 'https://images.unsplash.com/photo-1599577180570-8b17b209e7c3?q=80&w=600&auto=format&fit=crop',
      'category': 'Services',
      'date': 'Apr 2026',
    },
  ];

  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Greenhouse', 'Irrigation', 'Consulting', 'Supply', 'Machinery', 'Services'];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredItems = _selectedFilter == 'All'
        ? _portfolioItems
        : _portfolioItems.where((item) => item['category'] == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Gorgeous App Bar
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            stretch: true,
            backgroundColor: const Color(0xFFFF416C),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative patterns
                    Positioned(
                      right: -30,
                      top: -20,
                      child: Icon(Icons.photo_library_rounded, size: 150, color: Colors.white.withOpacity(0.15)),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 24, bottom: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'পোর্টফোলিও',
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'আপনার সফল কাজের গ্যালারি',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Filters
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = _selectedFilter == filter;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedFilter = filter),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFF416C) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFFF416C) : Colors.grey.shade300,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: const Color(0xFFFF416C).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            filter,
                            style: GoogleFonts.poppins(
                              color: isSelected ? Colors.white : Colors.grey.shade700,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Portfolio Grid
          filteredItems.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.image_not_supported_rounded, size: 80, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text('কোনো পোর্টফোলিও পাওয়া যায়নি', style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.7,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildPortfolioCard(filteredItems[index]);
                      },
                      childCount: filteredItems.length,
                    ),
                  ),
                ),
                
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.snackbar('নতুন কাজ', 'পোর্টফোলিওতে নতুন ছবি যোগ করার সুবিধা শীঘ্রই আসছে!',
            backgroundColor: Colors.white, colorText: Colors.black87);
        },
        backgroundColor: const Color(0xFFFF416C),
        icon: const Icon(Icons.add_a_photo_rounded, color: Colors.white),
        label: Text('নতুন যোগ করুন', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildPortfolioCard(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                image: DecorationImage(
                  image: NetworkImage(item['image']),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${item['rating']}',
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['category'],
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFF416C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['title'],
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.person_outline_rounded, size: 12, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item['client'],
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
