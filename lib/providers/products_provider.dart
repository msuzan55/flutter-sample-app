import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../models/user.dart';
import '../services/app_services.dart';

class ProductsProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<String> _categories = const ['All'];
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _loading = false;
  String? _error;

  List<Product> get products => _products;
  List<String> get categories => _categories;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _loading;
  String? get error => _error;

  List<Product> get filteredProducts {
    return _products.where((product) {
      final matchesCategory =
          _selectedCategory == 'All' || product.category == _selectedCategory;
      final query = _searchQuery.toLowerCase();
      final matchesSearch = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          (product.sku?.toLowerCase().contains(query) ?? false) ||
          (product.barcode?.toLowerCase().contains(query) ?? false);
      return matchesCategory && matchesSearch && product.canSell;
    }).toList();
  }

  Future<void> loadFromSync(PosUser user) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await AppServices.instance.syncApi.fetchInitialSync(user);
      _products = AppServices.instance.syncApi.parseProducts(data, user);
      if (_products.isEmpty) {
        throw Exception('No products found for your branch');
      }
      _categories = AppServices.instance.syncApi.parseCategories(_products);
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void applyProducts(List<Product> products) {
    _products = products;
    _categories = AppServices.instance.syncApi.parseCategories(products);
    notifyListeners();
  }

  void decreaseStock(int? productId, int quantity) {
    if (productId == null) return;
    final index = _products.indexWhere((p) => p.serverId == productId);
    if (index < 0) return;
    final p = _products[index];
    _products[index] = Product(
      id: p.id,
      serverId: p.serverId,
      name: p.name,
      price: p.price,
      category: p.category,
      sku: p.sku,
      barcode: p.barcode,
      stock: (p.stock - quantity).clamp(0, 999999),
      costPrice: p.costPrice,
      categoryId: p.categoryId,
      imageUrl: p.imageUrl,
      allowSaleOutOfStock: p.allowSaleOutOfStock,
    );
    notifyListeners();
  }
}
