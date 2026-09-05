import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';

/// Service Provider portfolio gallery screen with big prominent images,
/// neat bottom-stacked text, and a large stylish Add Project action button.
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
      'titleBN': 'হাই-টেক গ্রিনহাউস স্থাপন',
      'client': 'Rahim Farms Ltd.',
      'clientBN': 'রহিম ফার্মস লি.',
      'rating': 4.9,
      'image': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788535186/images_skktld.jpg',
      'category': 'Greenhouse',
      'categoryBN': 'গ্রিনহাউস',
      'date': 'Oct 2025',
    },
    {
      'title': 'Drip Irrigation System',
      'titleBN': 'ড্রিপ সেচ ব্যবস্থা স্থাপন',
      'client': 'Bogra Agro Co.',
      'clientBN': 'বগুড়া এগ্রো কো.',
      'rating': 4.8,
      'image': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788535243/images_k98wbv.jpg',
      'category': 'Irrigation',
      'categoryBN': 'সেচ ব্যবস্থা',
      'date': 'Nov 2025',
    },
    {
      'title': 'Soil Testing & Analysis',
      'titleBN': 'মাটি পরীক্ষা ও পুষ্টি বিশ্লেষণ',
      'client': 'Karim Miah',
      'clientBN': 'করিম মিয়া',
      'rating': 5.0,
      'image': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788535407/images_na4fqh.jpg',
      'category': 'Consulting',
      'categoryBN': 'পরামর্শ সেবা',
      'date': 'Jan 2026',
    },
    {
      'title': 'Organic Fertilizer Supply',
      'titleBN': 'জৈব সার পাইকারি সরবরাহ',
      'client': 'Savar Dairy & Agro',
      'clientBN': 'সাভার ডেইরি ও এগ্রো',
      'rating': 4.7,
      'image': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788535458/images_ylhsen.jpg',
      'category': 'Supply',
      'categoryBN': 'পণ্য সরবরাহ',
      'date': 'Feb 2026',
    },
    {
      'title': 'Solar Water Pump Installation',
      'titleBN': 'সোলার ওয়াটার পাম্প স্থাপন',
      'client': 'Eco Farms BD',
      'clientBN': 'ইকো ফার্মস বিডি',
      'rating': 4.9,
      'image': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788535512/images_xkzti6.jpg',
      'category': 'Machinery',
      'categoryBN': 'যন্ত্রপাতি',
      'date': 'Mar 2026',
    },
    {
      'title': 'Pest Control Management',
      'titleBN': 'কীটপতঙ্গ ও বালাই দমন প্রকল্প',
      'client': 'Green Valley',
      'clientBN': 'গ্রিন ভ্যালি',
      'rating': 4.6,
      'image': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788535556/images_vzwlpw.jpg',
      'category': 'Services',
      'categoryBN': 'সেবা',
      'date': 'Apr 2026',
    },
  ];

  String _selectedFilter = 'All';
  final List<Map<String, String>> _filters = [
    {'key': 'All', 'bn': 'সব', 'en': 'All'},
    {'key': 'Greenhouse', 'bn': 'গ্রিনহাউস', 'en': 'Greenhouse'},
    {'key': 'Irrigation', 'bn': 'সেচ ব্যবস্থা', 'en': 'Irrigation'},
    {'key': 'Consulting', 'bn': 'পরামর্শ', 'en': 'Consulting'},
    {'key': 'Supply', 'bn': 'সরবরাহ', 'en': 'Supply'},
    {'key': 'Machinery', 'bn': 'যন্ত্রপাতি', 'en': 'Machinery'},
    {'key': 'Services', 'bn': 'সেবা', 'en': 'Services'},
  ];

  @override
  Widget build(BuildContext context) {
    final isBn = LanguageProvider.isBn(context);
    final canPop = Navigator.canPop(context);

    List<Map<String, dynamic>> filteredItems = _selectedFilter == 'All'
        ? _portfolioItems
        : _portfolioItems.where((item) => item['category'] == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        toolbarHeight: 52,
        elevation: 0,
        backgroundColor: const Color(0xFFFF416C),
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                onPressed: () => Get.back(),
              )
            : null,
        titleSpacing: canPop ? 0 : 16,
        title: Row(
          children: [
            const Icon(Icons.photo_library_rounded, size: 20, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              isBn ? 'পোর্টফোলিও গ্যালারি' : 'Portfolio Gallery',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${filteredItems.length}',
                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Category Filter Bar
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter['key'];
                final label = isBn ? filter['bn']! : filter['en']!;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = filter['key']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFF416C) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFFF416C) : Colors.grey.shade300,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFFFF416C).withValues(alpha: 0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        label,
                        style: GoogleFonts.poppins(
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Portfolio Grid with BIG Images & Bottom Stacked Details
          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_not_supported_rounded, size: 50, color: Colors.grey.shade300),
                        const SizedBox(height: 10),
                        Text(
                          isBn ? 'কোনো পোর্টফোলিও পাওয়া যায়নি' : 'No portfolio items found',
                          style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(10, 4, 10, 80),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      return _buildPortfolioCard(filteredItems[index], isBn);
                    },
                  ),
          ),
        ],
      ),

      // BIG PROMINENT ADD PROJECT BUTTON
      floatingActionButton: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF416C).withValues(alpha: 0.45),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showAddProjectBottomSheet(context, isBn),
            borderRadius: BorderRadius.circular(25),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_photo_alternate_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    isBn ? '+ নতুন প্রজেক্ট যোগ করুন' : '+ Add New Project',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// Portfolio Card with BIG Image and Text Lower Down at the Bottom
  Widget _buildPortfolioCard(Map<String, dynamic> item, bool isBn) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BIG Project Image (Expanded to take upper ~65% of card)
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                    image: DecorationImage(
                      image: NetworkImage(item['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Rating Badge on top right of the big image
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 11),
                        const SizedBox(width: 2.5),
                        Text(
                          '${item['rating']}',
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Text content positioned neatly down at the bottom
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Category
                Text(
                  isBn ? (item['categoryBN'] ?? item['category']) : item['category'],
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFF416C),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                // Project Title
                Text(
                  isBn ? (item['titleBN'] ?? item['title']) : item['title'],
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                    height: 1.15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                // Client Name (Stacked cleanly underneath)
                Row(
                  children: [
                    Icon(Icons.business_rounded, size: 11, color: Colors.grey.shade600),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        isBn ? (item['clientBN'] ?? item['client']) : item['client'],
                        style: GoogleFonts.poppins(
                          fontSize: 9.5,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }

  /// Bottom Sheet for Adding a New Portfolio Project
  void _showAddProjectBottomSheet(BuildContext context, bool isBn) {
    final titleController = TextEditingController();
    final clientController = TextEditingController();
    String selectedCat = 'Greenhouse';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 18,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 18,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isBn ? 'নতুন প্রজেক্ট যোগ করুন' : 'Add New Project',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Project Title Field
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: isBn ? 'প্রজেক্টের নাম' : 'Project Title',
                        hintText: isBn ? 'উদাঃ ড্রিপ সেচ ব্যবস্থা স্থাপন' : 'e.g., Drip Irrigation Setup',
                        prefixIcon: const Icon(Icons.title_rounded, color: Color(0xFFFF416C)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Client Name Field
                    TextField(
                      controller: clientController,
                      decoration: InputDecoration(
                        labelText: isBn ? 'ক্লায়েন্ট বা ফার্মের নাম' : 'Client / Farm Name',
                        hintText: isBn ? 'উদাঃ রহিম এগ্রো লি.' : 'e.g., Rahim Agro Ltd.',
                        prefixIcon: const Icon(Icons.business_rounded, color: Color(0xFFFF416C)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Category Selector
                    Text(
                      isBn ? 'ক্যাটাগরি নির্বাচন করুন' : 'Select Category',
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: [
                        'Greenhouse',
                        'Irrigation',
                        'Consulting',
                        'Supply',
                        'Machinery',
                        'Services',
                      ].map((cat) {
                        final isSel = selectedCat == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSel,
                          selectedColor: const Color(0xFFFF416C),
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : Colors.black87,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (val) {
                            if (val) setModalState(() => selectedCat = cat);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          if (titleController.text.trim().isEmpty) {
                            Get.snackbar(
                              isBn ? 'সতর্কতা' : 'Warning',
                              isBn ? 'অনুগ্রহ করে প্রজেক্টের নাম লিখুন' : 'Please enter project title',
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white,
                            );
                            return;
                          }

                          setState(() {
                            _portfolioItems.insert(0, {
                              'title': titleController.text.trim(),
                              'titleBN': titleController.text.trim(),
                              'client': clientController.text.trim().isNotEmpty
                                  ? clientController.text.trim()
                                  : 'Client Project',
                              'clientBN': clientController.text.trim().isNotEmpty
                                  ? clientController.text.trim()
                                  : 'ক্লায়েন্ট প্রজেক্ট',
                              'rating': 5.0,
                              'image':
                                  'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788535186/images_skktld.jpg',
                              'category': selectedCat,
                              'categoryBN': selectedCat,
                              'date': 'Now',
                            });
                          });

                          Navigator.pop(ctx);
                          Get.snackbar(
                            isBn ? 'সফল!' : 'Success!',
                            isBn ? 'নতুন প্রজেক্ট সফলভাবে যোগ করা হয়েছে!' : 'New project added successfully!',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF416C),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          isBn ? 'সংরক্ষণ করুন' : 'Save Project',
                          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
