import 'package:agrolinkbd/core/models/phase2_models/portfolio_models.dart';

/// Mock data for portfolio module testing
class PortfolioMocks {
  /// Sample portfolio items
  static List<PortfolioItem> getSamplePortfolioItems() {
    return [
      PortfolioItem(
        id: 'PORT_001',
        title: 'Complete Garden Renovation',
        description:
            'Full garden redesign with new plants and irrigation system',
        imageUrls: ['image1.jpg', 'image2.jpg', 'image3.jpg'],
        category: 'Landscaping',
        rating: 4.9,
        createdDate: DateTime.now().subtract(const Duration(days: 30)),
        clientName: 'Mr. Ahmed',
      ),
      PortfolioItem(
        id: 'PORT_002',
        title: 'Rooftop Garden Project',
        description: 'Converted rooftop to productive organic garden',
        imageUrls: ['rt1.jpg', 'rt2.jpg', 'rt3.jpg'],
        category: 'Organic Farming',
        rating: 4.8,
        createdDate: DateTime.now().subtract(const Duration(days: 45)),
        clientName: 'Ms. Fatima',
      ),
      PortfolioItem(
        id: 'PORT_003',
        title: 'Commercial Greenhouse Setup',
        description: 'Built and maintained commercial vegetable greenhouse',
        imageUrls: ['gh1.jpg', 'gh2.jpg'],
        category: 'Greenhouse',
        rating: 5.0,
        createdDate: DateTime.now().subtract(const Duration(days: 60)),
        clientName: 'AgriCorp Ltd',
      ),
    ];
  }

  /// Sample certifications
  static List<Certification> getSampleCertifications() {
    return [
      Certification(
        name: 'Certified Garden Designer',
        issuedBy: 'National Landscape Association',
        issuedDate: DateTime(2020, 1, 15),
        expiryDate: DateTime(2025, 1, 15),
        certificateNumber: 'NLA-2020-001',
        imageUrl: 'cert1.jpg',
      ),
      Certification(
        name: 'Organic Farming Certification',
        issuedBy: 'Bangladesh Organic Certification Board',
        issuedDate: DateTime(2019, 6, 20),
        expiryDate: DateTime(2024, 6, 20),
        certificateNumber: 'BOCB-2019-0456',
        imageUrl: 'cert2.jpg',
      ),
      Certification(
        name: 'Agricultural Extension Diploma',
        issuedBy: 'Bangladesh Agricultural University',
        issuedDate: DateTime(2018, 12, 10),
        expiryDate: DateTime(2028, 12, 10),
        certificateNumber: 'BAU-DPLM-2018-789',
        imageUrl: 'cert3.jpg',
      ),
    ];
  }
}
