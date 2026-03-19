import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage(
    webOptions: WebOptions(
      dbName: 'suwater',
      publicKey: 'suwater_public',
    ),
  );

  // On web, flutter_secure_storage can fail with OperationError.
  // We use a simple in-memory fallback for web dev.
  static final Map<String, String> _webFallback = {};
  static bool _useWebFallback = false;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userKey = 'user';

  static Future<String?> _read(String key) async {
    if (kIsWeb && _useWebFallback) {
      return _webFallback[key];
    }
    try {
      return await _storage.read(key: key);
    } catch (_) {
      if (kIsWeb) {
        _useWebFallback = true;
        return _webFallback[key];
      }
      rethrow;
    }
  }

  static Future<void> _write(String key, String value) async {
    if (kIsWeb && _useWebFallback) {
      _webFallback[key] = value;
      return;
    }
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {
      if (kIsWeb) {
        _useWebFallback = true;
        _webFallback[key] = value;
        return;
      }
      rethrow;
    }
  }

  // Access token
  static Future<String?> getAccessToken() => _read(_accessTokenKey);

  static Future<void> setAccessToken(String token) =>
      _write(_accessTokenKey, token);

  // Refresh token
  static Future<String?> getRefreshToken() => _read(_refreshTokenKey);

  static Future<void> setRefreshToken(String token) =>
      _write(_refreshTokenKey, token);

  // User JSON
  static Future<Map<String, dynamic>?> getUser() async {
    final json = await _read(_userKey);
    if (json == null) return null;
    return jsonDecode(json) as Map<String, dynamic>;
  }

  static Future<void> setUser(Map<String, dynamic> user) =>
      _write(_userKey, jsonEncode(user));

  // Save all auth data at once
  static Future<void> saveAuthData({
    required String accessToken,
    required String refreshToken,
    required Map<String, dynamic> user,
  }) async {
    await Future.wait([
      setAccessToken(accessToken),
      setRefreshToken(refreshToken),
      setUser(user),
    ]);
  }

  // Clear everything on logout
  static Future<void> clearAll() async {
    if (kIsWeb && _useWebFallback) {
      _webFallback.clear();
      return;
    }
    try {
      await _storage.deleteAll();
    } catch (_) {
      if (kIsWeb) {
        _webFallback.clear();
      }
    }
  }
}
