import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/models/user_model.dart';
import 'package:agrolinkbd/presentation/screens/card/card_preview_screen.dart' as agrolinkbd;

class GreetingSection extends StatefulWidget {
  final UserModel? user;

  const GreetingSection({super.key, required this.user});

  @override
  State<GreetingSection> createState() => _GreetingSectionState();
}

class _GreetingSectionState extends State<GreetingSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
            begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2E7D32),
                Color(0xFF1B5E20),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const agrolinkbd.CardPreviewScreen(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                      child: Row(
                        children: [
                          // User Avatar
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white,
                            child: Text(
                              widget.user?.name.isNotEmpty == true ? widget.user!.name[0].toUpperCase() : 'U',
                              style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // User Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Time-based greeting in Bengali
                                Text(
                                  _getBengaliGreeting(),
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // User name
                                Text(
                                  '${widget.user?.name ?? 'User'} 👋',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                // User type with icon
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    _getUserTypeText(widget.user?.userType),
                                    style: GoogleFonts.roboto(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const agrolinkbd.CardPreviewScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.qr_code, size: 32),
                color: Colors.white,
                tooltip: 'আমার কার্ড',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getBengaliGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'শুভ সকাল'; // Suvo Sokal (Good Morning)
    } else if (hour >= 12 && hour < 16) {
      return 'শুভ দুপুর'; // Suvo Dupur (Good Afternoon)
    } else if (hour >= 16 && hour < 18) {
      return 'শুভ বিকেল'; // Suvo Bikel (Good Evening/Late Afternoon)
    } else if (hour >= 18 && hour < 20) {
      return 'শুভ সন্ধ্যা'; // Suvo Sondhya (Good Evening)
    } else {
      return 'শুভ রাত্রি'; // Suvo Ratri (Good Night)
    }
  }

  String _getUserTypeText(UserType? type) {
    switch (type) {
      case UserType.farmer:
        return '🌾 Farmer';
      case UserType.buyer:
        return '🛍️ Buyer';
      case UserType.driver:
        return '🚗 Driver';
      case UserType.serviceProvider:
        return '🔧 Service Provider';
      case UserType.company:
        return '🏢 Company';
      case UserType.seller:
        return '🏢 Company';
      default:
        return 'User';
    }
  }
}
