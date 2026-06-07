import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../navigation.dart';
import '../providers/auth_provider.dart';
import '../providers/orders_provider.dart';
import '../providers/products_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/cart_panel.dart';
import '../widgets/pos_shell.dart';
import '../widgets/product_grid.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().refreshTodaySummary();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orders = context.watch<OrdersProvider>();
    final products = context.watch<ProductsProvider>();
    final isWide = MediaQuery.sizeOf(context).width > 900;

    return PosShell(
      title: auth.user?.branchName ?? 'APS Pro POS',
      actions: [
        if (!orders.loadingSummary)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Chip(
              avatar: const Icon(Icons.today, size: 16, color: AppTheme.accent),
              label: Text(
                '${orders.todayOrderCount} sales • ${formatCurrency(orders.todayTotal)}',
              ),
              backgroundColor: AppTheme.bgHover,
            ),
          ),
        IconButton(
          tooltip: 'Resync',
          icon: products.isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.sync),
          onPressed: products.isLoading
              ? null
              : () async {
                  final user = auth.user;
                  if (user == null) return;
                  try {
                    await products.loadFromSync(user);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  }
                },
        ),
        PopupMenuButton<String>(
          icon: CircleAvatar(
            backgroundColor: AppTheme.accent,
            child: Text(
              (auth.user?.displayName ?? 'U')[0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          onSelected: (value) {
            if (value == 'logout') {
              auth.logout();
              AppNav.toLogin(context);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              enabled: false,
              child: Text('Signed in as ${auth.user?.displayName}'),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(value: 'logout', child: Text('Sign out')),
          ],
        ),
        const SizedBox(width: 8),
      ],
      floatingActionButton: isWide ? null : const CartFab(),
      body: products.isLoading && products.products.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accent),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search name, SKU or barcode…',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                products.setSearchQuery('');
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      products.setSearchQuery(value);
                      setState(() {});
                    },
                  ),
                ),
                const CategoryChips(),
                const SizedBox(height: 8),
                Expanded(
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Expanded(flex: 3, child: ProductGrid()),
                            SizedBox(width: 380, child: CartPanel()),
                          ],
                        )
                      : const ProductGrid(),
                ),
              ],
            ),
    );
  }
}
