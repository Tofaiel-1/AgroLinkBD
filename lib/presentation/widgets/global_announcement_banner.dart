import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/models/user_model.dart';
import 'package:google_fonts/google_fonts.dart';

class GlobalAnnouncementBanner extends StatefulWidget {
  const GlobalAnnouncementBanner({super.key});

  @override
  State<GlobalAnnouncementBanner> createState() => _GlobalAnnouncementBannerState();
}

class _GlobalAnnouncementBannerState extends State<GlobalAnnouncementBanner> {
  bool _isVisible = true;
  Timer? _hideTimer;
  Timer? _carouselTimer;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Hide the banner completely after 1 minute (60 seconds)
    _hideTimer = Timer(const Duration(seconds: 60), () {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
      }
    });
  }

  void _startCarouselTimer(int itemCount) {
    _carouselTimer?.cancel();
    if (itemCount > 1) {
      _carouselTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (mounted && _pageController.hasClients) {
          _currentPage = (_currentPage + 1) % itemCount;
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.fastOutSlowIn,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getDemoAnnouncements(UserModel user) {
    if (user.userType == UserType.farmer) {
      return [
        {
          'title': 'সার ও বীজে বিশেষ ছাড়!',
          'details': 'আগামী ৭ দিন পর্যন্ত ইউরিয়া সারে ১০% ক্যাশব্যাক। বিস্তারিত জানতে অফার পেইজ ভিজিট করুন। (Demo)',
          'priority': 'High',
        },
        {
          'title': 'বৃষ্টির সতর্কবার্তা',
          'details': 'আগামীকাল আপনার এলাকায় ভারী বৃষ্টির সম্ভাবনা রয়েছে। দয়া করে আপনার ফসল பாதுகாப்பভাবে রাখুন। (Demo)',
          'priority': 'Normal',
        },
      ];
    } else if (user.userType == UserType.buyer) {
      return [
        {
          'title': 'পণ্য ডেলিভারি আপডেট',
          'details': 'আজকের সকল পাইকারি অর্ডারের ডেলিভারি বিকেল ৫ টার মধ্যে সম্পন্ন হবে। (Demo)',
          'priority': 'Normal',
        },
        {
          'title': 'নতুন কৃষিপণ্য',
          'details': 'রাজশাহীর বিখ্যাত আম এখন অ্যাগ্রোলিংক-এ আকর্ষণীয় মূল্যে পাওয়া যাচ্ছে। (Demo)',
          'priority': 'High',
        },
      ];
    } else if (user.userType == UserType.driver) {
      return [
        {
          'title': 'রাস্তার সতর্কতা',
          'details': 'মহাসড়কে আজ অতিরিক্ত ট্রাফিক থাকতে পারে। সাবধানে গাড়ি চালান। (Demo)',
          'priority': 'High',
        },
        {
          'title': 'নতুন ট্রিপ বোনাস',
          'details': 'আজকের প্রথম ৩টি ট্রিপ সম্পূর্ণ করলেই পাচ্ছেন ১০০ টাকা এক্সট্রা বোনাস! (Demo)',
          'priority': 'Normal',
        },
      ];
    } else {
      return [
        {
          'title': 'সিস্টেম আপডেট',
          'details': 'আমাদের অ্যাপের নতুন ভার্সন এসেছে, অনুগ্রহ করে আপডেট করে নিন। (Demo)',
          'priority': 'Low',
        },
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final currentUser = userProvider.currentUser;
        if (currentUser == null) return const SizedBox.shrink();

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('announcements')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            List<Map<String, dynamic>> itemsToShow = [];

            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              final docs = snapshot.data!.docs;
              final relevantAnnouncements = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                
                final isActive = data['isActive'] == true;
                if (!isActive) return false;

                final audience = data['audience'] as String? ?? 'All Users';

                if (audience == 'All Users') return true;
                if (currentUser.userType == UserType.farmer && audience == 'Farmers Only') return true;
                if (currentUser.userType == UserType.buyer && audience == 'Buyers Only') return true;
                if (currentUser.userType == UserType.driver && audience == 'Drivers Only') return true;
                
                return false;
              }).toList();

              itemsToShow = relevantAnnouncements
                  .map((doc) => doc.data() as Map<String, dynamic>)
                  .toList();
            }

            // If no real announcements, fallback to role-based demo ones
            if (itemsToShow.isEmpty) {
              itemsToShow = _getDemoAnnouncements(currentUser);
            }

            if (itemsToShow.isEmpty) return const SizedBox.shrink();

            // Restart carousel timer if itemCount changed
            _startCarouselTimer(itemsToShow.length);

            return AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: itemsToShow.length,
                      onPageChanged: (index) {
                        _currentPage = index;
                      },
                      itemBuilder: (context, index) {
                        final item = itemsToShow[index];
                        return _buildAnnouncementCard(item);
                      },
                    ),
                    // Indicator Dots
                    if (itemsToShow.length > 1)
                      Positioned(
                        bottom: 8,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            itemsToShow.length,
                            (index) => AnimatedBuilder(
                              animation: _pageController,
                              builder: (context, child) {
                                double selectedness = 0.0;
                                if (_pageController.hasClients && _pageController.position.haveDimensions) {
                                  selectedness = 1.0 - (_pageController.page! - index).abs().clamp(0.0, 1.0);
                                } else {
                                  selectedness = _currentPage == index ? 1.0 : 0.0;
                                }
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  height: 6,
                                  width: 6 + (10 * selectedness),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.4 + (0.6 * selectedness)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    // Close Button
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isVisible = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 16, color: Colors.white70),
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

  Widget _buildAnnouncementCard(Map<String, dynamic> data) {
    final priority = data['priority'] as String? ?? 'Normal';
    final title = data['title'] ?? 'Announcement';
    final details = data['details'] ?? '';

    List<Color> gradientColors;
    IconData icon;
    Color iconBgColor;

    switch (priority) {
      case 'High':
        gradientColors = [const Color(0xFFFF416C), const Color(0xFFFF4B2B)];
        icon = Icons.campaign_rounded;
        iconBgColor = Colors.white.withOpacity(0.2);
        break;
      case 'Normal':
        gradientColors = [const Color(0xFF4A00E0), const Color(0xFF8E2DE2)];
        icon = Icons.info_outline_rounded;
        iconBgColor = Colors.white.withOpacity(0.2);
        break;
      case 'Low':
        gradientColors = [const Color(0xFF11998e), const Color(0xFF38ef7d)];
        icon = Icons.notifications_active_rounded;
        iconBgColor = Colors.white.withOpacity(0.2);
        break;
      default:
        gradientColors = [const Color(0xFF36D1DC), const Color(0xFF5B86E5)];
        icon = Icons.campaign_rounded;
        iconBgColor = Colors.white.withOpacity(0.2);
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 32, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.hindSiliguri(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  details,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
