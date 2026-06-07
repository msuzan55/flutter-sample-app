import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/order.dart';
import '../services/app_services.dart';
import 'auth_provider.dart';
import 'cart_provider.dart';

class OrdersProvider extends ChangeNotifier {
  OrdersProvider(this._authProvider);

  final AuthProvider _authProvider;

  List<Order> _orders = [];
  double _todayTotal = 0;
  int _todayCount = 0;
  bool _loadingSummary = false;

  List<Order> get orders => List.unmodifiable(_orders.reversed);
  double get todayTotal => _todayTotal;
  int get todayOrderCount => _todayCount;
  bool get loadingSummary => _loadingSummary;

  Future<void> refreshTodaySummary() async {
    _loadingSummary = true;
    notifyListeners();
    try {
      final data = await AppServices.instance.salesApi.fetchTodaySummary();
      _todayTotal = (data['total'] as num?)?.toDouble() ??
          (data['total_amount'] as num?)?.toDouble() ??
          0;
      _todayCount = (data['count'] as num?)?.toInt() ??
          (data['sale_count'] as num?)?.toInt() ??
          0;
    } catch (_) {
      _todayTotal = _orders.fold(0.0, (s, o) => s + o.total);
      _todayCount = _orders.length;
    }
    _loadingSummary = false;
    notifyListeners();
  }

  Future<Order> completeSale({
    required CartProvider cart,
    required PaymentMethod paymentMethod,
    double? amountPaid,
  }) async {
    final user = _authProvider.user;
    if (user == null) throw Exception('Not authenticated');

    final order = await AppServices.instance.salesApi.createSale(
      user: user,
      items: List<CartItem>.from(cart.items),
      paymentMethod: paymentMethod,
      amountPaid: amountPaid,
    );

    cart.applyStockChanges();
    cart.clear();
    _orders.add(order);
    await refreshTodaySummary();
    notifyListeners();
    return order;
  }
}
