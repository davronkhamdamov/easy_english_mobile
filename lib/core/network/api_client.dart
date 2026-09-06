import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// Middleware for intercepting API requests and responses.
abstract class ApiMiddleware {
  const ApiMiddleware();

  /// Called before a request is sent. Can mutate or return updated headers.
  Future<Map<String, String>> onRequest(
    String path,
    Map<String, String> headers,
  ) async => headers;

  /// Called after receiving an HTTP response.
  Future<http.Response> onResponse(http.Response response) async => response;

  /// Triggered whenever an API returns HTTP 403 Forbidden.
  void onForbidden(http.Response response) {}

  /// Triggered whenever an API returns HTTP 401 Unauthorized.
  void onUnauthorized(http.Response response) {}
}

/// Exception thrown or emitted when an API call encounters HTTP 403 Forbidden.
class ForbiddenException implements Exception {
  final String message;
  final http.Response response;

  const ForbiddenException({
    this.message = 'Forbidden: Access is denied.',
    required this.response,
  });

  @override
  String toString() =>
      'ForbiddenException (403): $message (Status: ${response.statusCode}, Body: ${response.body})';
}

class ApiClient {
  /// Current Mac local IP: 172.20.10.4
  /// Supports dynamic injection via: flutter run --dart-define=API_URL=http://$(ipconfig getifaddr en0):8080
  static const String defaultLocalUrl = 'http://172.20.10.4:8080';
  static const String defaultProdUrl = 'https://easy-english.uz';

  static String baseUrl = const String.fromEnvironment(
    'API_URL',
    defaultValue: defaultLocalUrl,
  );

  static void setBaseUrl(String newUrl) {
    baseUrl = newUrl;
  }

  /// Global broadcast stream for listening to 403 Forbidden events across the app.
  static final StreamController<http.Response> _forbiddenStreamController =
      StreamController<http.Response>.broadcast();

  /// Stream of all 403 Forbidden responses.
  static Stream<http.Response> get onForbidden =>
      _forbiddenStreamController.stream;

  /// Global optional callback when any API responds with 403 Forbidden.
  static void Function(http.Response response)? onForbiddenCallback;

  /// Global list of registered middlewares.
  static final List<ApiMiddleware> middlewares = [];

  /// Register an [ApiMiddleware] to intercept all API requests and responses.
  static void addMiddleware(ApiMiddleware middleware) {
    if (!middlewares.contains(middleware)) {
      middlewares.add(middleware);
    }
  }

  /// Remove a registered [ApiMiddleware].
  static void removeMiddleware(ApiMiddleware middleware) {
    middlewares.remove(middleware);
  }

  /// Clear all registered middlewares.
  static void clearMiddlewares() {
    middlewares.clear();
  }

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> getAccessToken() async =>
      await _storage.read(key: 'access_token');
  Future<String?> getRefreshToken() async =>
      await _storage.read(key: 'refresh_token');
  Future<String?> getUserId() async => await _storage.read(key: 'user_id');

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
    String? userId,
  }) async {
    await _storage.write(key: 'access_token', value: accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.write(key: 'refresh_token', value: refreshToken);
    }
    if (userId != null && userId.isNotEmpty) {
      await _storage.write(key: 'user_id', value: userId);
    }
  }

  Future<void> clearTokens() async {
    await _storage.deleteAll();
  }

  Future<Map<String, String>> _headers(String path) async {
    final token = await getAccessToken();
    final userId = await getUserId();
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      if (userId != null && userId.isNotEmpty) 'X-User-ID': userId,
    };

    for (final middleware in middlewares) {
      headers = await middleware.onRequest(path, headers);
    }

    return headers;
  }

  Future<http.Response> get(String path) async {
    final fullUrl = '$baseUrl$path';
    final headers = await _headers(path);
    final response = await http.get(Uri.parse(fullUrl), headers: headers);
    return _handleResponse(response, () => get(path));
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final fullUrl = '$baseUrl$path';
    final headers = await _headers(path);
    final response = await http.post(
      Uri.parse(fullUrl),
      headers: headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response, () => post(path, body));
  }

  Future<http.Response> put(String path, Map<String, dynamic> body) async {
    final fullUrl = '$baseUrl$path';
    final headers = await _headers(path);
    final response = await http.put(
      Uri.parse(fullUrl),
      headers: headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response, () => put(path, body));
  }

  Future<http.Response> delete(String path) async {
    final fullUrl = '$baseUrl$path';
    final headers = await _headers(path);
    final response = await http.delete(Uri.parse(fullUrl), headers: headers);
    return _handleResponse(response, () => delete(path));
  }

  Future<http.Response> postMultipart(
    String path, {
    Map<String, String>? fields,
    String? filePath,
    String fileField = 'file',
  }) async {
    return postMultipartWithBaseUrl(
      baseUrl,
      path,
      fields: fields,
      filePath: filePath,
      fileField: fileField,
    );
  }

  Future<http.Response> postMultipartWithBaseUrl(
    String targetBaseUrl,
    String path, {
    Map<String, String>? fields,
    String? filePath,
    String fileField = 'file',
  }) async {
    final fullUrl = '$targetBaseUrl$path';
    final token = await getAccessToken();
    final request = http.MultipartRequest('POST', Uri.parse(fullUrl));

    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    if (fields != null) {
      request.fields.addAll(fields);
    }

    if (filePath != null && filePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath(fileField, filePath));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return _handleResponse(
      response,
      () => postMultipartWithBaseUrl(
        targetBaseUrl,
        path,
        fields: fields,
        filePath: filePath,
        fileField: fileField,
      ),
    );
  }

  Future<http.Response> _handleResponse(
    http.Response response,
    Future<http.Response> Function() retry,
  ) async {
    if (response.statusCode == 401) {
      for (final middleware in middlewares) {
        middleware.onUnauthorized(response);
      }
      final refreshed = await refreshToken();
      if (refreshed) return await retry();
    }

    if (response.statusCode == 403) {
      _handleForbidden(response);
    }

    http.Response currentResponse = response;
    for (final middleware in middlewares) {
      currentResponse = await middleware.onResponse(currentResponse);
    }

    return currentResponse;
  }

  void _handleForbidden(http.Response response) {
    if (kDebugMode) {
      debugPrint('[ApiClient] 403 Forbidden: ${response.request?.url ?? response.statusCode}');
    }

    if (_forbiddenStreamController.hasListener) {
      _forbiddenStreamController.add(response);
    }
    onForbiddenCallback?.call(response);

    for (final middleware in middlewares) {
      try {
        middleware.onForbidden(response);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[ApiClient] Error in middleware onForbidden: $e');
        }
      }
    }
  }

  Future<bool> refreshToken() async {
    final refresh = await getRefreshToken();
    if (refresh == null || refresh.isEmpty) return false;

    final fullUrl = '$baseUrl/api/v1/auth/refresh';
    final headers = {'Content-Type': 'application/json'};
    final body = {'refresh_token': refresh};

    try {
      final res = await http.post(
        Uri.parse(fullUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final newAccessToken = (data['access_token'] ?? data['token'] ?? '')
            .toString();
        if (newAccessToken.isNotEmpty) {
          await _storage.write(key: 'access_token', value: newAccessToken);
          return true;
        }
      }
    } catch (_) {
      // Ignored
    }
    return false;
  }
}
