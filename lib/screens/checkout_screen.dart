import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../navigation.dart';
import '../providers/cart_provider.dart';
import '../providers/orders_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/pos_shell.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  PaymentMethod _method = PaymentMethod.cash;
  final _amountController = TextEditingController();
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    final total = context.read<CartProvider>().total;
    _amountController.text = total.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double? get _amountPaid {
    final value = double.tryParse(_amountController.text);
    return value;
  }

  double get _change {
    final cart = context.read<CartProvider>();
    final paid = _amountPaid ?? 0;
    if (_method != PaymentMethod.cash) return 0;
    return (paid - cart.total).clamp(0, double.infinity);
  }

  Future<void> _complete() async {
    final cart = context.read<CartProvider>();
    if (cart.isEmpty) return;

    if (_method == PaymentMethod.cash) {
      final paid = _amountPaid;
      if (paid == null || paid < cart.total) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Amount paid must cover the total')),
        );
        return;
      }
    }

    setState(() => _processing = true);

    try {
      final order = await context.read<OrdersProvider>().completeSale(
            cart: cart,
            paymentMethod: _method,
            amountPaid: _method == PaymentMethod.cash ? _amountPaid : cart.total,
          );

      if (mounted) {
        setState(() => _processing = false);
        AppNav.toReceipt(context, order.id);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _processing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return PosShell(
      title: 'Checkout',
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _SummaryRow('Items', '${cart.itemCount}'),
          _SummaryRow('Subtotal', formatCurrency(cart.subtotal)),
          const Divider(),
                        _SummaryRow(
                          'Total',
                          formatCurrency(cart.total),
                          highlight: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Payment method',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 12),
                SegmentedButton<PaymentMethod>(
                  segments: const [
                    ButtonSegment(
                      value: PaymentMethod.cash,
                      icon: Icon(Icons.payments_outlined),
                      label: Text('Cash'),
                    ),
                    ButtonSegment(
                      value: PaymentMethod.card,
                      icon: Icon(Icons.credit_card),
                      label: Text('Card'),
                    ),
                    ButtonSegment(
                      value: PaymentMethod.mobile,
                      icon: Icon(Icons.phone_android),
                      label: Text('Mobile'),
                    ),
                  ],
                  selected: {_method},
                  onSelectionChanged: (set) {
                    setState(() {
                      _method = set.first;
                      if (_method == PaymentMethod.cash) {
                        _amountController.text = cart.total.toStringAsFixed(2);
                      }
                    });
                  },
                ),
                if (_method == PaymentMethod.cash) ...[
                  const SizedBox(height: 20),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Amount received',
                      prefixText: '\$ ',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  if (_amountPaid != null && _amountPaid! >= cart.total)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Change: ${formatCurrency(_change)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.success,
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _processing ? null : _complete,
                  icon: _processing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(_processing ? 'Processing...' : 'Complete Sale'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value, {this.highlight = false});

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: highlight ? 18 : 14,
              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              color: highlight ? AppTheme.textPrimary : AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: highlight ? 22 : 14,
              fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
              color: highlight ? AppTheme.accent : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
