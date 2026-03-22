import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:suwater_mobile/core/storage/secure_storage.dart';
import 'package:suwater_mobile/core/api/endpoints.dart';

class DioClient {
  static DioClient? _instance;
  late final Dio dio;
  bool _isRefreshing = false;

  /// In-memory token cache — reliable on all platforms including web
  static String? _accessToken;
  static String? _refreshToken;

  DioClient._() {
    dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_BASE_URL'] ??
            (throw StateError('API_BASE_URL not set in .env file')),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );
  }

  factory DioClient() {
    _instance ??= DioClient._();
    return _instance!;
  }

  /// Set tokens after login (call this from auth repository)
  static void setTokens({
    required String accessToken,
    required String refreshToken,
  }) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  /// Reset singleton (used on logout)
  static void reset() {
    _accessToken = null;
    _refreshToken = null;
    _instance = null;
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Use in-memory token first, fall back to storage
    final token = _accessToken ?? await SecureStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    if (error.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshTkn =
            _refreshToken ?? await SecureStorage.getRefreshToken();
        if (refreshTkn == null) {
          _isRefreshing = false;
          return handler.next(error);
        }

        // Use a fresh Dio to avoid interceptor loop
        final refreshDio = Dio(BaseOptions(
          baseUrl: dio.options.baseUrl,
        ));

        final response = await refreshDio.post(
          Endpoints.refresh,
          data: {'refresh_token': refreshTkn},
        );

        if (response.statusCode != 200 || response.data == null) {
          debugPrint('DioClient: token refresh returned invalid response (${response.statusCode})');
          _isRefreshing = false;
          await SecureStorage.clearAll();
          _accessToken = null;
          _refreshToken = null;
          return handler.next(error);
        }

        final newAccessToken = response.data['access_token'] as String?;
        final newRefreshToken = response.data['refresh_token'] as String?;

        if (newAccessToken == null || newRefreshToken == null) {
          debugPrint('DioClient: token refresh response missing token fields');
          _isRefreshing = false;
          await SecureStorage.clearAll();
          _accessToken = null;
          _refreshToken = null;
          return handler.next(error);
        }

        // Update in-memory + storage
        _accessToken = newAccessToken;
        _refreshToken = newRefreshToken;
        await SecureStorage.setAccessToken(newAccessToken);
        await SecureStorage.setRefreshToken(newRefreshToken);

        // Retry the original request with new token
        final options = error.requestOptions;
        options.headers['Authorization'] = 'Bearer $newAccessToken';

        final retryResponse = await dio.fetch(options);
        _isRefreshing = false;
        return handler.resolve(retryResponse);
      } on DioException catch (e) {
        debugPrint('DioClient: token refresh failed: $e');
        _isRefreshing = false;
        await SecureStorage.clearAll();
        _accessToken = null;
        _refreshToken = null;
        return handler.next(error);
      }
    }
    handler.next(error);
  }
}
