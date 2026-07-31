import 'package:get/get.dart';
import '../models/marketplace_item_model.dart';

class MarketplaceController extends GetxController {
  var items = <MarketplaceItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialItems();
  }

  void _loadInitialItems() {
    items.add(MarketplaceItemModel(
      id: 'PROD_1',
      farmerId: 'F1',
      farmerName: 'রহিম মিয়া',
      fishType: 'রুই',
      quantityKg: 200,
      avgWeightGram: 1500,
      pricePerKg: 350,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ));
    items.add(MarketplaceItemModel(
      id: 'PROD_2',
      farmerId: 'F2',
      farmerName: 'করিম শেখ',
      fishType: 'কাতলা',
      quantityKg: 150,
      avgWeightGram: 2000,
      pricePerKg: 400,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ));
    items.add(MarketplaceItemModel(
      id: 'PROD_3',
      farmerId: 'F3',
      farmerName: 'শফিক আলম',
      fishType: 'পাঙ্গাস',
      quantityKg: 500,
      avgWeightGram: 1000,
      pricePerKg: 180,
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ));
  }

  void addItem(MarketplaceItemModel item) {
    items.insert(0, item); // Insert at the beginning so it shows up top
  }
}
