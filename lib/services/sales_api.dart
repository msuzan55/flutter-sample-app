import 'package:uuid/uuid.dart';

import '../config/api_config.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/user.dart';
import 'api_client.dart';
import 'sync_api.dart';

class SalesApi {
  SalesApi(this._client, this._syncApi);

  final ApiClient _client;
  final SyncApi _syncApi;
  final _uuid = const Uuid();

  Future<Map<String, dynamic>> fetchTodaySummary() async {
    final response = await _client.get(ApiConfig.salesTodaySummary);
    if (response.statusCode != 200) {
      return {'total': 0.0, 'count': 0};
    }
    return _client.decodeJsonMap(response);
  }

  Future<Order> createSale({
    required PosUser user,
    required List<CartItem> items,
    required PaymentMethod paymentMethod,
    double? amountPaid,
  }) async {
    final localId = _uuid.v4();
    final now = DateTime.now().toUtc().toIso8601String();

    final lineItems = items.map((cartItem) {
      final p = cartItem.product;
      final qty = cartItem.quantity;
      final unitPrice = p.price;
      final lineTotal = unitPrice * qty;
      final cost = p.costPrice;
      return {
        'product_id': p.serverId,
        'item_code': p.sku ?? '',
        'product_name': p.name,
        'category_id': p.categoryId,
        'category_name': p.category,
        'quantity': qty,
        'unit_price': unitPrice,
        'line_total': lineTotal,
        'cost_price': cost,
        'line_cost': cost * qty,
        'line_profit': (unitPrice - cost) * qty,
        'discount_amount': 0,
        'business_id': user.businessId,
        'branch_id': user.branchId,
        'status': 'active',
      };
    }).toList();

    final subtotal = lineItems.fold<double>(
      0,
      (sum, i) => sum + (i['line_total'] as num).toDouble(),
    );
    const taxAmount = 0.0;
    const discountAmount = 0.0;
    final total = subtotal - discountAmount + taxAmount;

    final method = switch (paymentMethod) {
      PaymentMethod.cash => 'cash',
      PaymentMethod.card => 'card',
      PaymentMethod.mobile => 'mobile',
    };

    final paid = paymentMethod == PaymentMethod.cash
        ? (amountPaid ?? total)
        : total;
    final change = paymentMethod == PaymentMethod.cash
        ? (paid - total).clamp(0, double.infinity).toDouble()
        : 0.0;

    final totalCost = lineItems.fold<double>(
      0,
      (sum, i) => sum + (i['line_cost'] as num).abs().toDouble(),
    );
    final totalProfit = lineItems.fold<double>(
      0,
      (sum, i) => sum + (i['line_profit'] as num).toDouble(),
    );

    final saleData = {
      'sale_number': 'TEMP-${localId.substring(0, 8).toUpperCase()}',
      'business_id': user.businessId,
      'branch_id': user.branchId,
      'cashier_id': user.id,
      'customer_id': null,
      'customer_name': null,
      'subtotal': subtotal,
      'discount_amount': discountAmount,
      'tax_amount': taxAmount,
      'total_amount': total,
      'total_cost': totalCost,
      'total_profit': totalProfit,
      'gross_profit': totalProfit,
      'payment_method': method,
      'paid_amount': paid,
      'change_amount': change,
      'status': 'completed',
      'notes': null,
      'is_refund': false,
      'is_exchange': false,
      'items': lineItems,
      'payments': [
        {'method': method, 'amount': paid},
      ],
      'created_at': now,
      'created_by': user.id,
    };

    final pushResult = await _syncApi.pushChanges([
      {
        'entity': 'sales',
        'action': 'create',
        'local_id': localId,
        'entity_id': null,
        'data': saleData,
        'timestamp': now,
        'client_timestamp': now,
      },
    ]);

    if (pushResult['success'] != true) {
      final errors = pushResult['errors'];
      if (errors is List && errors.isNotEmpty) {
        throw Exception(errors.first.toString());
      }
      throw Exception('Sale sync failed');
    }

    final newIds = pushResult['new_ids'];
    String orderId = localId.substring(0, 8).toUpperCase();
    if (newIds is Map && newIds[localId] != null) {
      orderId = newIds[localId].toString();
    }

    return Order(
      id: orderId,
      items: items,
      subtotal: subtotal,
      tax: taxAmount,
      total: total,
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
      amountPaid: paid,
      change: change > 0 ? change : null,
      cashierName: user.displayName,
    );
  }
}
