import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agrolinkbd/presentation/buyer/models/product_model.dart';

final productsCollectionRef = FirebaseFirestore.instance.collection('products');

// Provider for all products
final allProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  try {
    final snapshot = await productsCollectionRef.get();
    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data()))
        .toList();
  } catch (e) {
    throw Exception('Failed to fetch products: $e');
  }
});

// Provider for category-filtered products
final productsByCategoryProvider =
    FutureProvider.family<List<ProductModel>, String>((ref, category) async {
  try {
    final snapshot = await productsCollectionRef
        .where('category', isEqualTo: category)
        .get();
    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data()))
        .toList();
  } catch (e) {
    throw Exception('Failed to fetch category products: $e');
  }
});

// Provider for trending products
final trendingProductsProvider =
    FutureProvider<List<ProductModel>>((ref) async {
  try {
    final snapshot = await productsCollectionRef
        .orderBy('totalOrders', descending: true)
        .limit(10)
        .get();
    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data()))
        .toList();
  } catch (e) {
    throw Exception('Failed to fetch trending products: $e');
  }
});

// Provider for single product details
final productDetailsProvider =
    FutureProvider.family<ProductModel, String>((ref, productId) async {
  try {
    final doc = await productsCollectionRef.doc(productId).get();
    if (doc.exists) {
      return ProductModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    throw Exception('Product not found');
  } catch (e) {
    throw Exception('Failed to fetch product: $e');
  }
});

// Provider for search products
final searchProductsProvider =
    FutureProvider.family<List<ProductModel>, String>((ref, query) async {
  try {
    if (query.isEmpty) {
      return [];
    }
    final lowerQuery = query.toLowerCase();
    final snapshot = await productsCollectionRef.get();
    return snapshot.docs
        .where((doc) {
          final product = ProductModel.fromMap(doc.data());
          return product.name.toLowerCase().contains(lowerQuery) ||
              product.namebn.toLowerCase().contains(lowerQuery) ||
              product.variety.toLowerCase().contains(lowerQuery);
        })
        .map((doc) => ProductModel.fromMap(doc.data()))
        .toList();
  } catch (e) {
    throw Exception('Failed to search products: $e');
  }
});

// Provider for discounted products
final discountedProductsProvider =
    FutureProvider<List<ProductModel>>((ref) async {
  try {
    final snapshot = await productsCollectionRef
        .where('isDiscounted', isEqualTo: true)
        .get();
    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data()))
        .toList();
  } catch (e) {
    throw Exception('Failed to fetch discounted products: $e');
  }
});

// Filter state providers
final selectedCategoryProvider = StateProvider<String?>((ref) => null);
final minPriceProvider = StateProvider<double>((ref) => 0);
final maxPriceProvider = StateProvider<double>((ref) => 50000);
final selectedRatingProvider = StateProvider<int>((ref) => 0);
final selectedDistanceProvider = StateProvider<double?>((ref) => null);
final sortByProvider = StateProvider<String>(
    (ref) => 'relevance'); // relevance, price_asc, price_desc, rating

// Filtered products provider
final filteredProductsProvider =
    FutureProvider<List<ProductModel>>((ref) async {
  try {
    var query = productsCollectionRef.snapshots();
    final products = await query.first;

    List<ProductModel> filteredList =
        products.docs.map((doc) => ProductModel.fromMap(doc.data())).toList();

    // Apply category filter
    final selectedCategory = ref.watch(selectedCategoryProvider);
    if (selectedCategory != null) {
      filteredList =
          filteredList.where((p) => p.category == selectedCategory).toList();
    }

    // Apply price filter
    final minPrice = ref.watch(minPriceProvider);
    final maxPrice = ref.watch(maxPriceProvider);
    filteredList = filteredList
        .where((p) => p.price >= minPrice && p.price <= maxPrice)
        .toList();

    // Apply rating filter
    final minRating = ref.watch(selectedRatingProvider);
    if (minRating > 0) {
      filteredList =
          filteredList.where((p) => p.averageRating >= minRating).toList();
    }

    // Apply sorting
    final sortBy = ref.watch(sortByProvider);
    switch (sortBy) {
      case 'price_asc':
        filteredList.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        filteredList.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        filteredList.sort((a, b) => b.averageRating.compareTo(a.averageRating));
        break;
      default: // relevance
        break;
    }

    return filteredList;
  } catch (e) {
    throw Exception('Failed to filter products: $e');
  }
});

// Pagination provider
final productsPaginationProvider = StateProvider<int>((ref) => 0);

final paginatedProductsProvider = Provider<List<ProductModel>>((ref) {
  final allProducts = ref.watch(filteredProductsProvider);
  final pageIndex = ref.watch(productsPaginationProvider);
  const pageSize = 20;

  return allProducts
          .whenData((products) {
            final startIndex = pageIndex * pageSize;
            if (startIndex >= products.length) return <ProductModel>[];
            final endIndex = startIndex + pageSize;
            return products.sublist(
              startIndex,
              endIndex > products.length ? products.length : endIndex,
            );
          })
          .asData
          ?.value ??
      [];
});

// Categories provider
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  try {
    final snapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    return snapshot.docs.map((doc) => doc['name'] as String).toList();
  } catch (e) {
    return [
      'ধান',
      'সবজি',
      'ফল',
      'মসলা',
      'ডাল',
      'তেলবীজ',
      'গবাদি পশুর খাদ্য',
      'জৈব পণ্য'
    ];
  }
});
