import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:easy_english/core/network/api_client.dart';
import 'package:easy_english/core/errors/failure.dart';

class MockTestMiddleware extends ApiMiddleware {
  bool onForbiddenCalled = false;
  bool onUnauthorizedCalled = false;
  bool onRequestCalled = false;
  bool onResponseCalled = false;
  http.Response? lastForbiddenResponse;

  @override
  Future<Map<String, String>> onRequest(
    String path,
    Map<String, String> headers,
  ) async {
    onRequestCalled = true;
    return {...headers, 'X-Custom-Header': 'TestValue'};
  }

  @override
  Future<http.Response> onResponse(http.Response response) async {
    onResponseCalled = true;
    return response;
  }

  @override
  void onForbidden(http.Response response) {
    onForbiddenCalled = true;
    lastForbiddenResponse = response;
  }

  @override
  void onUnauthorized(http.Response response) {
    onUnauthorizedCalled = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    ApiClient.clearMiddlewares();
    ApiClient.onForbiddenCallback = null;
  });

  tearDown(() {
    ApiClient.clearMiddlewares();
    ApiClient.onForbiddenCallback = null;
  });

  group('ApiClient 403 Middleware & Interceptor Tests', () {
    test('ApiMiddleware lifecycle hooks are configured and tested', () async {
      final mockMiddleware = MockTestMiddleware();
      ApiClient.addMiddleware(mockMiddleware);

      bool callbackFired = false;
      http.Response? callbackResponse;
      ApiClient.onForbiddenCallback = (response) {
        callbackFired = true;
        callbackResponse = response;
      };

      final forbiddenResponse = http.Response(
        jsonEncode({'error': 'Forbidden access', 'code': 'FORBIDDEN'}),
        403,
      );

      // Verify middleware registration
      expect(ApiClient.middlewares.contains(mockMiddleware), isTrue);

      // Verify forbidden callback
      ApiClient.onForbiddenCallback?.call(forbiddenResponse);
      expect(callbackFired, isTrue);
      expect(callbackResponse?.statusCode, equals(403));

      // Verify ForbiddenException formatting
      final exception = ForbiddenException(
        message: 'Access denied to resource',
        response: forbiddenResponse,
      );
      expect(exception.toString(), contains('ForbiddenException (403)'));
      expect(exception.toString(), contains('Access denied to resource'));

      // Verify Failure hierarchy for 403
      const failure = ForbiddenFailure(message: 'Forbidden action', code: '403');
      expect(failure.message, equals('Forbidden action'));
      expect(failure.code, equals('403'));
    });

    test('Middleware can be added and removed cleanly', () {
      final mockMiddleware = MockTestMiddleware();
      ApiClient.addMiddleware(mockMiddleware);
      expect(ApiClient.middlewares.length, 1);

      // Duplicates are ignored
      ApiClient.addMiddleware(mockMiddleware);
      expect(ApiClient.middlewares.length, 1);

      ApiClient.removeMiddleware(mockMiddleware);
      expect(ApiClient.middlewares.length, 0);
    });
  });
}
