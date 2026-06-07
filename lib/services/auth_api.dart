import '../config/api_config.dart';
import '../models/user.dart';
import '../services/api_client.dart';

class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;

  Future<({String token, PosUser user})> login(
    String username,
    String password,
  ) async {
    final response = await _client.postForm(ApiConfig.authLogin, {
      'username': username.trim(),
      'password': password,
    });

    if (response.statusCode != 200) {
      throw ApiException(
        _client.errorMessage(response),
        statusCode: response.statusCode,
        path: ApiConfig.authLogin,
      );
    }

    final data = _client.decodeJsonMap(response);
    final token = data['access_token'] as String?;
    if (token == null || token.isEmpty) {
      throw ApiException('Invalid response from server');
    }

    _client.setToken(token);
    PosUser user;
    if (data['user'] is Map<String, dynamic>) {
      user = PosUser.fromJson(data['user'] as Map<String, dynamic>);
    } else {
      user = await fetchMe();
    }

    return (token: token, user: user);
  }

  Future<PosUser> fetchMe() async {
    final response = await _client.get(ApiConfig.authMe);
    if (response.statusCode == 401) {
      throw ApiException('Session expired', statusCode: 401);
    }
    if (response.statusCode != 200) {
      throw ApiException(
        _client.errorMessage(response),
        statusCode: response.statusCode,
        path: ApiConfig.authMe,
      );
    }
    return PosUser.fromJson(_client.decodeJsonMap(response));
  }
}
