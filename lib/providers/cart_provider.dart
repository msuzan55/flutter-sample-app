import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';
import 'products_provider.dart';

class CartProvider extends ChangeNotifier {
  CartProvider(this._productsProvider);

  final ProductsProvider _productsProvider;
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _items.fold(0, (sum, item) => sum + item.lineTotal);

  double get tax => 0;
  double get total => subtotal + tax;

  void addProduct(Product product) {
    final index = _items.indexWhere(
      (item) => item.product.serverId == product.serverId,
    );
    if (index >= 0) {
      final current = _items[index];
      if (current.quantity >= product.stock) return;
      _items[index] = current.copyWith(quantity: current.quantity + 1);
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void increment(int? productId) {
    if (productId == null) return;
    final index = _items.indexWhere((item) => item.product.serverId == productId);
    if (index < 0) return;
    final item = _items[index];
    if (item.quantity >= item.product.stock) return;
    _items[index] = item.copyWith(quantity: item.quantity + 1);
    notifyListeners();
  }

  void decrement(int? productId) {
    if (productId == null) return;
    final index = _items.indexWhere((item) => item.product.serverId == productId);
    if (index < 0) return;
    final item = _items[index];
    if (item.quantity <= 1) {
      _items.removeAt(index);
    } else {
      _items[index] = item.copyWith(quantity: item.quantity - 1);
    }
    notifyListeners();
  }

  void remove(int? productId) {
    if (productId == null) return;
    _items.removeWhere((item) => item.product.serverId == productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  void applyStockChanges() {
    for (final item in _items) {
      _productsProvider.decreaseStock(item.product.serverId, item.quantity);
    }
  }
}
