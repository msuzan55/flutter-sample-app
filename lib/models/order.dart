import 'cart_item.dart';

enum PaymentMethod { cash, card, mobile }

class Order {
  const Order({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    required this.createdAt,
    this.amountPaid,
    this.change,
    this.cashierName = 'Cashier',
  });

  final String id;
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double total;
  final PaymentMethod paymentMethod;
  final DateTime createdAt;
  final double? amountPaid;
  final double? change;
  final String cashierName;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
}
