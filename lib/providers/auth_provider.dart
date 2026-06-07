import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/api_client.dart';
import '../services/app_services.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _bootstrap();
  }

  final _services = AppServices.instance;

  PosUser? _user;
  bool _isLoading = false;
  bool _initialized = false;
  String? _error;

  PosUser? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitialized => _initialized;
  String? get error => _error;
  bool get isLoggedIn => _user != null && _services.apiClient.token != null;
  bool get needsSetup => _user?.needsSetup ?? false;

  Future<void> _bootstrap() async {
    try {
      await _services.restoreSession().timeout(const Duration(seconds: 3));
      _user = await _services.readStoredUser().timeout(const Duration(seconds: 3));
    } catch (_) {
      await _services.clearSession();
    }

    _initialized = true;
    notifyListeners();

    if (_services.apiClient.token != null && _user != null) {
      unawaited(_refreshUserInBackground());
    }
  }

  Future<void> _refreshUserInBackground() async {
    try {
      final fresh = await _services.authApi.fetchMe();
      _user = fresh;
      await _services.persistSession(_services.apiClient.token!, fresh);
      notifyListeners();
    } catch (_) {
      // Keep cached user when offline or token expired.
    }
  }

  Future<void> waitForInit() async {
    while (!_initialized) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _services.authApi.login(username, password);
      _user = result.user;
      await _services.persistSession(result.token, result.user);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e is ApiException ? e.message : e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    await _services.clearSession();
    notifyListeners();
  }
}
