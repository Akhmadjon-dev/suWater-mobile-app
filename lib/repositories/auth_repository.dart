import 'package:suwater_mobile/core/api/dio_client.dart';
import 'package:suwater_mobile/core/api/endpoints.dart';
import 'package:suwater_mobile/core/storage/secure_storage.dart';
import 'package:suwater_mobile/models/user.dart';

class AuthRepository {
  final _dio = DioClient().dio;

  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      Endpoints.login,
      data: {'email': email, 'password': password},
    );

    final data = response.data;
    final user = User.fromJson(data['user'] as Map<String, dynamic>);

    final accessToken = data['access_token'] as String;
    final refreshToken = data['refresh_token'] as String;

    // Set in-memory tokens immediately (reliable on web)
    DioClient.setTokens(accessToken: accessToken, refreshToken: refreshToken);

    // Also persist to secure storage (for native app restarts)
    await SecureStorage.saveAuthData(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: data['user'] as Map<String, dynamic>,
    );

    return user;
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final response = await _dio.post(
      Endpoints.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'role': 'CITIZEN',
        'org_id': 'c17ac9d4-f136-401a-a8bc-bffb2bf901c7',
        if (phone != null) 'phone': phone,
      },
    );

    final data = response.data;

    final accessToken = data['access_token'] as String;
    final refreshToken = data['refresh_token'] as String;

    DioClient.setTokens(accessToken: accessToken, refreshToken: refreshToken);

    await SecureStorage.saveAuthData(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: data['user'] as Map<String, dynamic>,
    );

    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<User?> getCurrentUser() async {
    try {
      final response = await _dio.get(Endpoints.me);
      return User.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<User?> tryRestoreSession() async {
    final token = await SecureStorage.getAccessToken();
    if (token == null) return null;

    final userJson = await SecureStorage.getUser();
    if (userJson != null) {
      return User.fromJson(userJson);
    }

    return getCurrentUser();
  }

  Future<void> logout() async {
    await SecureStorage.clearAll();
    DioClient.reset();
  }
}
