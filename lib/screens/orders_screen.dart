import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../providers/orders_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/pos_shell.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrdersProvider>().orders;

    return PosShell(
      title: 'Order History',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      body: orders.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 48, color: AppTheme.textSecondary),
                  SizedBox(height: 12),
                  Text('No orders yet', style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.accent.withValues(alpha: 0.15),
                      child: const Icon(Icons.receipt, color: AppTheme.accent),
                    ),
                    title: Text('Order #${order.id}'),
                    subtitle: Text(
                      '${order.itemCount} items • ${formatDateTime(order.createdAt)}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatCurrency(order.total),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accent,
                          ),
                        ),
                        Text(
                          _paymentLabel(order.paymentMethod),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/receipt/${order.id}',
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _paymentLabel(PaymentMethod method) {
    return switch (method) {
      PaymentMethod.cash => 'Cash',
      PaymentMethod.card => 'Card',
      PaymentMethod.mobile => 'Mobile',
    };
  }
}
