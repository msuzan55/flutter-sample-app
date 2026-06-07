import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../navigation.dart';
import '../providers/auth_provider.dart';
import '../providers/products_provider.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runSync());
  }

  Future<void> _runSync() async {
    final auth = context.read<AuthProvider>();
    final products = context.read<ProductsProvider>();
    final user = auth.user;
    if (user == null) {
      if (mounted) AppNav.toLogin(context);
      return;
    }

    setState(() => _error = null);
    try {
      await products.loadFromSync(user);
      if (mounted) AppNav.toPos(context);
    } catch (e) {
      setState(() {
        _error = e is ApiException ? e.message : e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'APS Pro',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error == null ? 'Syncing products…' : 'Sync failed',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 24),
              if (_error == null)
                const CircularProgressIndicator(color: AppTheme.accent)
              else ...[
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.danger),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _runSync,
                  child: const Text('Retry'),
                ),
                TextButton(
                  onPressed: () {
                    context.read<AuthProvider>().logout();
                    AppNav.toLogin(context);
                  },
                  child: const Text('Sign out'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
