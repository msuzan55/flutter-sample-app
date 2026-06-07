import 'package:flutter/material.dart';

import 'screens/login_screen.dart';

/// Simple Navigator helpers (no GoRouter — avoids blank redirect frames on Android).
class AppNav {
  AppNav._();

  static void toSync(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/sync');
  }

  static void toPos(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/pos');
  }

  static void toCheckout(BuildContext context) {
    Navigator.pushNamed(context, '/checkout');
  }

  static void toReceipt(BuildContext context, String orderId) {
    Navigator.pushReplacementNamed(context, '/receipt/$orderId');
  }

  static void toOrders(BuildContext context) {
    Navigator.pushNamed(context, '/orders');
  }

  static void toLogin(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }
}
