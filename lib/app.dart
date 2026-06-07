import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/orders_provider.dart';
import 'providers/products_provider.dart';
import 'screens/checkout_screen.dart';
import 'screens/login_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/pos_screen.dart';
import 'screens/receipt_screen.dart';
import 'screens/sync_screen.dart';
import 'theme/app_theme.dart';

class PosApp extends StatefulWidget {
  const PosApp({super.key});

  @override
  State<PosApp> createState() => _PosAppState();
}

class _PosAppState extends State<PosApp> {
  late final AuthProvider _authProvider;
  late final ProductsProvider _productsProvider;
  late final CartProvider _cartProvider;
  late final OrdersProvider _ordersProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    _productsProvider = ProductsProvider();
    _cartProvider = CartProvider(_productsProvider);
    _ordersProvider = OrdersProvider(_authProvider);
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? '';
    if (name.startsWith('/receipt/')) {
      final orderId = name.split('/').last;
      return MaterialPageRoute<void>(
        builder: (_) => ReceiptScreen(orderId: orderId),
        settings: settings,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _productsProvider),
        ChangeNotifierProvider.value(value: _cartProvider),
        ChangeNotifierProvider.value(value: _ordersProvider),
      ],
      child: MaterialApp(
        title: 'APS Pro POS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        builder: (context, child) => ColoredBox(
          color: AppTheme.bgPrimary,
          child: child ?? const SizedBox.shrink(),
        ),
        home: const LoginScreen(),
        routes: {
          '/sync': (_) => const SyncScreen(),
          '/pos': (_) => const PosScreen(),
          '/checkout': (_) => const CheckoutScreen(),
          '/orders': (_) => const OrdersScreen(),
        },
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }
}
