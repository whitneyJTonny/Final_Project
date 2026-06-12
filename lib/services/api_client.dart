import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dart:io' as io;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final _storage = const FlutterSecureStorage();

  // ─────────────────────────────────────────────────────────────────────────
  // ✅ CHANGE THIS IP to your computer's local IP address
  //    → On Windows: open CMD and run "ipconfig"
  //      look for "IPv4 Address" under your WiFi adapter
  //      e.g. 192.168.1.105
  //    → Your phone and computer must be on the SAME WiFi network
  //    → Run Django with: python manage.py runserver 0.0.0.0:8000
  // ─────────────────────────────────────────────────────────────────────────
  static const String _localIp = '192.168.1.105'; // <-- REPLACE THIS

  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    }
    try {
      if (io.Platform.isAndroid) {
        // Android emulator → 10.0.2.2 maps to your computer's localhost
        // Android real device → use your computer's local IP
        return kDebugMode
            ? 'http://$_localIp:8000/api' // real device (debug)
            : 'http://$_localIp:8000/api'; // real device (release)
      }
      if (io.Platform.isIOS) {
        // iOS simulator → localhost works fine
        // iOS real device → use your computer's local IP
        return 'http://$_localIp:8000/api';
      }
    } catch (e) {
      debugPrint('Platform detection error: $e');
    }
    return 'http://$_localIp:8000/api';
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: 'access_token', value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<http.Response> get(String path) async {
    return _sendRequest('GET', path);
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    return _sendRequest('POST', path, body: body);
  }

  Future<http.Response> put(String path, Map<String, dynamic> body) async {
    return _sendRequest('PUT', path, body: body);
  }

  Future<http.Response> _sendRequest(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool isRetry = false,
  }) async {
    final url = Uri.parse('$baseUrl$path');
    final accessToken = await getAccessToken();

    final headers = {
      'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };

    http.Response response;
    final encodedBody = body != null ? jsonEncode(body) : null;

    try {
      if (method == 'GET') {
        response = await http.get(url, headers: headers);
      } else if (method == 'POST') {
        response = await http.post(url, headers: headers, body: encodedBody);
      } else if (method == 'PUT') {
        response = await http.put(url, headers: headers, body: encodedBody);
      } else {
        throw UnsupportedError('Unsupported method $method');
      }
    } catch (e) {
      debugPrint('Network error on $method $path: $e');
      rethrow;
    }

    if (response.statusCode == 401 && !isRetry) {
      final refreshed = await _refreshTokens();
      if (refreshed) {
        return _sendRequest(method, path, body: body, isRetry: true);
      }
    }

    return response;
  }

  Future<bool> _refreshTokens() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final url = Uri.parse('$baseUrl/auth/token/refresh/');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccess = data['access'];
        final newRefresh = data['refresh'] ?? refreshToken;
        await saveTokens(newAccess, newRefresh);
        return true;
      }
    } catch (e) {
      debugPrint('Token refresh failed: $e');
    }

    await clearTokens();
    return false;
  }
}
