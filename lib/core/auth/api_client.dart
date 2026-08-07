import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../debug/api_logger.dart';

class ApiClient {
  static const String baseUrl = 'https://easy-english.uz';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> getAccessToken() async => await _storage.read(key: 'access_token');
  Future<String?> getRefreshToken() async => await _storage.read(key: 'refresh_token');

  Future<void> saveTokens({required String accessToken, String? refreshToken}) async {
    await _storage.write(key: 'access_token', value: accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.write(key: 'refresh_token', value: refreshToken);
    }
  }

  Future<void> clearTokens() async {
    await _storage.deleteAll();
  }

  Future<Map<String, String>> _headers() async {
    final token = await getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String path) async {
    final fullUrl = '$baseUrl$path';
    final headers = await _headers();
    final startTime = DateTime.now();
    final log = ApiLogger.instance.logRequest(
      method: 'GET',
      url: fullUrl,
      headers: headers,
    );

    try {
      final response = await http.get(Uri.parse(fullUrl), headers: headers);
      ApiLogger.instance.logResponse(
        logItem: log,
        statusCode: response.statusCode,
        headers: response.headers,
        body: response.body,
        duration: DateTime.now().difference(startTime),
      );
      return _handleResponse(response, () => get(path));
    } catch (e) {
      ApiLogger.instance.logError(
        logItem: log,
        error: e.toString(),
        duration: DateTime.now().difference(startTime),
      );
      rethrow;
    }
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final fullUrl = '$baseUrl$path';
    final headers = await _headers();
    final startTime = DateTime.now();
    final log = ApiLogger.instance.logRequest(
      method: 'POST',
      url: fullUrl,
      headers: headers,
      body: body,
    );

    try {
      final response = await http.post(
        Uri.parse(fullUrl),
        headers: headers,
        body: jsonEncode(body),
      );
      ApiLogger.instance.logResponse(
        logItem: log,
        statusCode: response.statusCode,
        headers: response.headers,
        body: response.body,
        duration: DateTime.now().difference(startTime),
      );
      return _handleResponse(response, () => post(path, body));
    } catch (e) {
      ApiLogger.instance.logError(
        logItem: log,
        error: e.toString(),
        duration: DateTime.now().difference(startTime),
      );
      rethrow;
    }
  }

  Future<http.Response> put(String path, Map<String, dynamic> body) async {
    final fullUrl = '$baseUrl$path';
    final headers = await _headers();
    final startTime = DateTime.now();
    final log = ApiLogger.instance.logRequest(
      method: 'PUT',
      url: fullUrl,
      headers: headers,
      body: body,
    );

    try {
      final response = await http.put(
        Uri.parse(fullUrl),
        headers: headers,
        body: jsonEncode(body),
      );
      ApiLogger.instance.logResponse(
        logItem: log,
        statusCode: response.statusCode,
        headers: response.headers,
        body: response.body,
        duration: DateTime.now().difference(startTime),
      );
      return _handleResponse(response, () => put(path, body));
    } catch (e) {
      ApiLogger.instance.logError(
        logItem: log,
        error: e.toString(),
        duration: DateTime.now().difference(startTime),
      );
      rethrow;
    }
  }

  Future<http.Response> delete(String path) async {
    final fullUrl = '$baseUrl$path';
    final headers = await _headers();
    final startTime = DateTime.now();
    final log = ApiLogger.instance.logRequest(
      method: 'DELETE',
      url: fullUrl,
      headers: headers,
    );

    try {
      final response = await http.delete(Uri.parse(fullUrl), headers: headers);
      ApiLogger.instance.logResponse(
        logItem: log,
        statusCode: response.statusCode,
        headers: response.headers,
        body: response.body,
        duration: DateTime.now().difference(startTime),
      );
      return _handleResponse(response, () => delete(path));
    } catch (e) {
      ApiLogger.instance.logError(
        logItem: log,
        error: e.toString(),
        duration: DateTime.now().difference(startTime),
      );
      rethrow;
    }
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

    final startTime = DateTime.now();
    final log = ApiLogger.instance.logRequest(
      method: 'POST (Multipart)',
      url: fullUrl,
      headers: request.headers,
      body: fields,
    );

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      ApiLogger.instance.logResponse(
        logItem: log,
        statusCode: response.statusCode,
        headers: response.headers,
        body: response.body,
        duration: DateTime.now().difference(startTime),
      );

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
    } catch (e) {
      ApiLogger.instance.logError(
        logItem: log,
        error: e.toString(),
        duration: DateTime.now().difference(startTime),
      );
      rethrow;
    }
  }

  Future<http.Response> _handleResponse(
    http.Response response,
    Future<http.Response> Function() retry,
  ) async {
    if (response.statusCode == 401) {
      final refreshed = await refreshToken();
      if (refreshed) return await retry();
    }
    return response;
  }

  Future<bool> refreshToken() async {
    final refresh = await getRefreshToken();
    if (refresh == null || refresh.isEmpty) return false;

    final fullUrl = '$baseUrl/api/v1/auth/refresh';
    final headers = {'Content-Type': 'application/json'};
    final body = {'refresh_token': refresh};
    final startTime = DateTime.now();
    final log = ApiLogger.instance.logRequest(
      method: 'POST',
      url: fullUrl,
      headers: headers,
      body: body,
    );

    try {
      final res = await http.post(
        Uri.parse(fullUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      ApiLogger.instance.logResponse(
        logItem: log,
        statusCode: res.statusCode,
        headers: res.headers,
        body: res.body,
        duration: DateTime.now().difference(startTime),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final newAccessToken = (data['access_token'] ?? data['token'] ?? '').toString();
        if (newAccessToken.isNotEmpty) {
          await _storage.write(key: 'access_token', value: newAccessToken);
          return true;
        }
      }
    } catch (e) {
      ApiLogger.instance.logError(
        logItem: log,
        error: e.toString(),
        duration: DateTime.now().difference(startTime),
      );
    }
    return false;
  }
}
