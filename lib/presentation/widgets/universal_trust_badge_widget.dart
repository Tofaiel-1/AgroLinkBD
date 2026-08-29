import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/models/user_model.dart';
import 'package:agrolinkbd/core/services/user_rating_service.dart';

/// Universal Trust Header Widget
/// Shows the authoritative Root Trust Rating on top of any role Dashboard
class UniversalTrustHeaderWidget extends StatelessWidget {
  final UserModel? user;
  final VoidCallback? onTap;

  const UniversalTrustHeaderWidget({
    super.key,
    required this.user,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = const Color(0xFF2E7D32);

    final double trustScore = user != null
        ? UserRatingService.calculateTrustScore(user!)
        : 98.0;
    final double rating = user?.rating ?? 4.9;
    final int totalRatings = user?.totalRatings ?? 0;
    final int totalOrders = user?.totalOrders ?? 0;
    final double totalSpent = user?.totalSpent ?? 0.0;
    final int fraudReports = user?.fraudReports ?? 0;
    final int totalPenalties = fraudReports +
        (user?.cancelledOrders ?? 0) +
        (user?.paymentDefaults ?? 0) +
        (user?.lateDeliveries ?? 0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.3),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.verified, color: primaryColor, size: 20),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'মূল রেটিং (Root Trust Score)',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.grey[300] : Colors.grey[800],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    totalRatings == 0
                        ? '১০০% বিশ্বস্ততা'
                        : '${trustScore.toStringAsFixed(0)}% বিশ্বস্ততা',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      totalRatings == 0
                          ? '৫.০ / ৫.০ ⭐️ (নতুন ভেরিফাইড ইউজার)'
                          : '${rating.toStringAsFixed(1)} / 5.0 ⭐️ ($totalRatings জন মূল্যায়ন করেছেন)',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildCompactBadge(
                  Icons.work_outline,
                  '$totalOrders টি কাজ',
                  Colors.blue,
                ),
                const SizedBox(width: 8),
                _buildCompactBadge(
                  Icons.payments_outlined,
                  '৳ ${totalSpent.toStringAsFixed(0)}',
                  Colors.green,
                ),
                const SizedBox(width: 8),
                _buildCompactBadge(
                  totalPenalties == 0
                      ? Icons.shield_outlined
                      : Icons.warning_amber_rounded,
                  totalPenalties == 0 ? 'ক্লিন রেকর্ড' : '$totalPenalties রিপোর্ট',
                  totalPenalties == 0 ? Colors.teal : Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactBadge(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact Trust Badge with Quick Rate action for Cards (Driver, Service, Product)
class UniversalTrustBadgeWidget extends StatelessWidget {
  final String targetUserId;
  final String targetUserName;
  final String targetUserType;
  final double rating;
  final int totalRatings;
  final String currentUserId;
  final String currentUserName;
  final String? reviewerRole;

  const UniversalTrustBadgeWidget({
    super.key,
    required this.targetUserId,
    required this.targetUserName,
    this.targetUserType = 'User',
    this.rating = 4.9,
    this.totalRatings = 0,
    required this.currentUserId,
    required this.currentUserName,
    this.reviewerRole,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF2E7D32);

    final bool isSelf = currentUserId.isNotEmpty && targetUserId.isNotEmpty && currentUserId == targetUserId;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 4,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, size: 16, color: Colors.amber[700]),
            const SizedBox(width: 4),
            Text(
              totalRatings == 0
                  ? '৫.০ • ১০০% বিশ্বস্ত'
                  : '${rating.toStringAsFixed(1)} • $totalRatings জন মূল্যায়ন',
              style: GoogleFonts.hindSiliguri(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: primaryGreen,
              ),
            ),
          ],
        ),
        if (!isSelf)
          TextButton.icon(
            onPressed: () {
              UserRatingService.showUniversalRateModal(
                context: context,
                targetUserId: targetUserId,
                targetUserName: targetUserName,
                reviewerId: currentUserId,
                reviewerName: currentUserName,
                reviewerRole: reviewerRole,
                targetUserRole: targetUserType,
                onRatingSubmitted: () {},
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(Icons.rate_review_outlined, size: 15),
            label: Text(
              'মূল্যায়ন করুন',
              style: GoogleFonts.hindSiliguri(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}
