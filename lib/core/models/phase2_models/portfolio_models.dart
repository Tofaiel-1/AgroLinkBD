// Portfolio Models for Phase 2

class PortfolioItem {
  final String id;
  final String title;
  final String description;
  final List<String> imageUrls;
  final String category;
  final double rating;
  final DateTime createdDate;
  final String clientName;

  PortfolioItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.category,
    required this.rating,
    required this.createdDate,
    required this.clientName,
  });
}

class Certification {
  final String name;
  final String issuedBy;
  final DateTime issuedDate;
  final DateTime expiryDate;
  final String certificateNumber;
  final String imageUrl;

  Certification({
    required this.name,
    required this.issuedBy,
    required this.issuedDate,
    required this.expiryDate,
    required this.certificateNumber,
    required this.imageUrl,
  });
}
