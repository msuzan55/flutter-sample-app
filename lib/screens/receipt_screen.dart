import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../navigation.dart';
import '../providers/orders_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/pos_shell.dart';

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrdersProvider>();
    Order? order;
    for (final o in orders.orders) {
      if (o.id == orderId) {
        order = o;
        break;
      }
    }

    if (order == null) {
      return PosShell(
        title: 'Receipt',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppNav.toPos(context),
        ),
        body: const Center(child: Text('Order not found')),
      );
    }

    return PosShell(
      title: 'Receipt',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => AppNav.toPos(context),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle, color: AppTheme.success, size: 56),
                      const SizedBox(height: 12),
                      const Text(
                        'Payment Successful',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'APS Pro',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Order #${order.id}',
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                      Text(
                        formatDateTime(order.createdAt),
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                      Text(
                        'Cashier: ${order.cashierName}',
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                      const Divider(height: 32),
                      ...order.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text('${item.quantity}x ${item.product.name}'),
                              ),
                              Text(formatCurrency(item.lineTotal)),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 24),
                      _ReceiptRow('Subtotal', formatCurrency(order.subtotal)),
                      _ReceiptRow('Total', formatCurrency(order.total), bold: true),
                      _ReceiptRow(
                        'Payment',
                        _paymentLabel(order.paymentMethod),
                      ),
                      if (order.amountPaid != null)
                        _ReceiptRow('Paid', formatCurrency(order.amountPaid!)),
                      if (order.change != null && order.change! > 0)
                        _ReceiptRow('Change', formatCurrency(order.change!)),
                      const SizedBox(height: 16),
                      const Text(
                        'Thank you for your purchase!',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => AppNav.toPos(context),
                        child: const Text('New Sale'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => AppNav.toOrders(context),
                        child: const Text('View Orders'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _paymentLabel(PaymentMethod method) {
    return switch (method) {
      PaymentMethod.cash => 'Cash',
      PaymentMethod.card => 'Card',
      PaymentMethod.mobile => 'Mobile Pay',
    };
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow(this.label, this.value, {this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              fontSize: bold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
