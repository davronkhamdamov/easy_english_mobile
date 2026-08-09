import 'dart:convert';

/// Represents a single logged API call with detailed request/response metadata.
class ApiLogItem {
  final String id;
  final String method;
  final String url;
  final Map<String, String>? requestHeaders;
  final dynamic requestBody;
  final DateTime timestamp;

  int? statusCode;
  Map<String, String>? responseHeaders;
  dynamic responseBody;
  Duration? duration;
  String? error;

  ApiLogItem({
    required this.id,
    required this.method,
    required this.url,
    this.requestHeaders,
    this.requestBody,
    required this.timestamp,
    this.statusCode,
    this.responseHeaders,
    this.responseBody,
    this.duration,
    this.error,
  });

  bool get isPending => statusCode == null && error == null;
  bool get isSuccess =>
      statusCode != null && statusCode! >= 200 && statusCode! < 300;
  bool get isError =>
      error != null || (statusCode != null && statusCode! >= 400);

  /// Generates executable cURL command for this API call
  String toCurl() {
    final buffer = StringBuffer();
    buffer.write('curl -X ${method.toUpperCase()} "$url"');

    if (requestHeaders != null) {
      requestHeaders!.forEach((key, value) {
        buffer.write(' -H "$key: $value"');
      });
    }

    if (requestBody != null) {
      String bodyStr = '';
      if (requestBody is String) {
        bodyStr = requestBody as String;
      } else {
        try {
          bodyStr = jsonEncode(requestBody);
        } catch (_) {
          bodyStr = requestBody.toString();
        }
      }
      if (bodyStr.isNotEmpty) {
        // Escape single quotes for bash
        final escapedBody = bodyStr.replaceAll("'", "'\\''");
        buffer.write(" -d '$escapedBody'");
      }
    }

    return buffer.toString();
  }

  /// Convert to JSON map for exporting logs
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'method': method,
      'url': url,
      'timestamp': timestamp.toIso8601String(),
      'statusCode': statusCode,
      'durationMs': duration?.inMilliseconds,
      'requestHeaders': requestHeaders,
      'requestBody': requestBody,
      'responseHeaders': responseHeaders,
      'responseBody': responseBody,
      'error': error,
    };
  }

  /// Utility to get formatted request body string
  String get formattedRequestBody {
    if (requestBody == null) return '(No request body)';
    if (requestBody is String) {
      try {
        final decoded = jsonDecode(requestBody as String);
        return const JsonEncoder.withIndent('  ').convert(decoded);
      } catch (_) {
        return requestBody as String;
      }
    }
    try {
      return const JsonEncoder.withIndent('  ').convert(requestBody);
    } catch (_) {
      return requestBody.toString();
    }
  }

  /// Utility to get formatted response body string
  String get formattedResponseBody {
    if (responseBody == null) return '(No response body)';
    if (responseBody is String) {
      try {
        final decoded = jsonDecode(responseBody as String);
        return const JsonEncoder.withIndent('  ').convert(decoded);
      } catch (_) {
        return responseBody as String;
      }
    }
    try {
      return const JsonEncoder.withIndent('  ').convert(responseBody);
    } catch (_) {
      return responseBody.toString();
    }
  }
}
