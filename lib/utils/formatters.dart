import 'package:intl/intl.dart';

final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

String formatCurrency(double amount) => currencyFormat.format(amount);

String formatDateTime(DateTime dateTime) =>
    DateFormat('MMM d, yyyy • h:mm a').format(dateTime);

String formatTime(DateTime dateTime) => DateFormat('h:mm a').format(dateTime);
