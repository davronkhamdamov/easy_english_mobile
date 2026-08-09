import 'package:flutter_test/flutter_test.dart';
import 'package:easy_english/core/debug/api_log_model.dart';
import 'package:easy_english/core/debug/api_logger.dart';

void main() {
  group('ApiLogger & ApiLogItem Tests', () {
    setUp(() {
      ApiLogger.instance.clear();
    });

    test('ApiLogger logs request and 2xx success responses correctly', () {
      final log200 = ApiLogger.instance.logRequest(
        method: 'GET',
        url: 'https://easy-english.uz/api/v1/profile',
      );

      ApiLogger.instance.logResponse(
        logItem: log200,
        statusCode: 200,
        body: {'status': 'ok'},
        duration: const Duration(milliseconds: 120),
      );

      final log201 = ApiLogger.instance.logRequest(
        method: 'POST',
        url: 'https://easy-english.uz/api/v1/user/profile',
        body: {'full_name': 'Test User'},
      );

      ApiLogger.instance.logResponse(
        logItem: log201,
        statusCode: 201,
        body: {'id': 'user_1'},
        duration: const Duration(milliseconds: 210),
      );

      expect(log200!.isSuccess, isTrue);
      expect(log200.isError, isFalse);
      expect(log201!.isSuccess, isTrue);
      expect(log201.isError, isFalse);
      expect(ApiLogger.instance.logs.length, 2);
    });

    test(
      'ApiLogger captures all error status codes (400, 401, 403, 404, 500)',
      () {
        final statusCodes = [400, 401, 403, 404, 500];

        for (final code in statusCodes) {
          final log = ApiLogger.instance.logRequest(
            method: 'POST',
            url: 'https://easy-english.uz/api/v1/test/$code',
          );

          ApiLogger.instance.logResponse(
            logItem: log,
            statusCode: code,
            body: {'error': 'Error $code'},
            duration: const Duration(milliseconds: 80),
          );

          expect(log!.isSuccess, isFalse);
          expect(log.isError, isTrue);
          expect(log.statusCode, code);
        }

        expect(ApiLogger.instance.logs.length, 5);
        expect(ApiLogger.instance.logs.where((l) => l.isError).length, 5);
      },
    );

    test('ApiLogger handles network exceptions & socket errors correctly', () {
      final log = ApiLogger.instance.logRequest(
        method: 'GET',
        url: 'https://easy-english.uz/api/v1/error',
      );

      ApiLogger.instance.logError(
        logItem: log,
        error: 'SocketException: Connection refused',
        duration: const Duration(milliseconds: 50),
      );

      expect(log!.isError, isTrue);
      expect(log.error, contains('Connection refused'));
    });

    test('ApiLogItem generates valid cURL command', () {
      final log = ApiLogItem(
        id: '1',
        method: 'POST',
        url: 'https://easy-english.uz/api/v1/login',
        requestHeaders: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer 123',
        },
        requestBody: {'username': 'testuser'},
        timestamp: DateTime.now(),
      );

      final curl = log.toCurl();
      expect(
        curl,
        contains('curl -X POST "https://easy-english.uz/api/v1/login"'),
      );
      expect(curl, contains('-H "Content-Type: application/json"'));
      expect(curl, contains('-H "Authorization: Bearer 123"'));
      expect(curl, contains('-d \'{"username":"testuser"}\''));
    });

    test('ApiLogger exports JSON correctly', () {
      ApiLogger.instance.logRequest(
        method: 'GET',
        url: 'https://easy-english.uz/api/v1/profile',
      );

      final jsonStr = ApiLogger.instance.exportJson();
      expect(jsonStr, contains('"method": "GET"'));
      expect(
        jsonStr,
        contains('"url": "https://easy-english.uz/api/v1/profile"'),
      );
    });
  });
}
