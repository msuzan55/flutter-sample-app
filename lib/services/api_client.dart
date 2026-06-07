import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.path});

  final String message;
  final int? statusCode;
  final String? path;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  String? _token;

  void setToken(String? token) => _token = token;
  String? get token => _token;

  Map<String, String> get _jsonHeaders => {
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Future<http.Response> get(
    String path, {
    Duration? timeout,
  }) async {
    try {
      return await _client
          .get(_uri(path), headers: _jsonHeaders)
          .timeout(timeout ?? ApiConfig.timeout);
    } on Exception catch (e) {
      throw ApiException(
        'Network error: ${e.toString()}. Check internet and API ${ApiConfig.baseUrl}',
        path: path,
      );
    }
  }

  Future<http.Response> postJson(
    String path,
    Map<String, dynamic> body, {
    Duration? timeout,
  }) async {
    try {
      return await _client
          .post(
            _uri(path),
            headers: {..._jsonHeaders, 'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(timeout ?? ApiConfig.timeout);
    } on Exception catch (e) {
      throw ApiException(
        'Network error: ${e.toString()}. Check internet and API ${ApiConfig.baseUrl}',
        path: path,
      );
    }
  }

  Future<http.Response> postForm(String path, Map<String, String> fields) async {
    try {
      return await _client
          .post(
            _uri(path),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: fields,
          )
          .timeout(ApiConfig.timeout);
    } on Exception catch (e) {
      throw ApiException(
        'Network error: ${e.toString()}. Check internet and API ${ApiConfig.baseUrl}',
        path: path,
      );
    }
  }

  Map<String, dynamic> decodeJsonMap(http.Response response) {
    if (response.body.isEmpty) {
      throw ApiException(
        'Empty response from server (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw ApiException('Unexpected response format from server');
  }

  String errorMessage(http.Response response) {
    try {
      final data = decodeJsonMap(response);
      final detail = data['detail'];
      if (detail is String) return detail;
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map && first['msg'] != null) {
          return first['msg'].toString();
        }
      }
      return data['message']?.toString() ??
          'Request failed (${response.statusCode})';
    } catch (_) {
      return 'Request failed (${response.statusCode})';
    }
  }
}
