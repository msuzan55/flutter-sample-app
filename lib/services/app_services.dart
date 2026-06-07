import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../services/api_client.dart';
import '../services/auth_api.dart';
import '../services/sales_api.dart';
import '../services/sync_api.dart';

class AppServices {
  AppServices._();

  static final AppServices instance = AppServices._();

  final apiClient = ApiClient();
  late final authApi = AuthApi(apiClient);
  late final syncApi = SyncApi(apiClient);
  late final salesApi = SalesApi(apiClient, syncApi);

  static const _tokenKey = 'pos_token';
  static const _userKey = 'pos_user';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _storage() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> restoreSession() async {
    final prefs = await _storage();
    final token = prefs.getString(_tokenKey);
    if (token != null && token.isNotEmpty) {
      apiClient.setToken(token);
    }
  }

  Future<void> persistSession(String token, PosUser user) async {
    final prefs = await _storage();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<PosUser?> readStoredUser() async {
    final prefs = await _storage();
    final raw = prefs.getString(_userKey);
    if (raw == null || raw.isEmpty) return null;
    return PosUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> clearSession() async {
    apiClient.setToken(null);
    final prefs = await _storage();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
