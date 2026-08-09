import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'api_log_model.dart';

/// Central API logger engine for capturing every network call.
class ApiLogger {
  ApiLogger._internal();
  static final ApiLogger instance = ApiLogger._internal();

  /// Reactive notifier for UI updates when API calls occur
  final ValueNotifier<List<ApiLogItem>> logsNotifier =
      ValueNotifier<List<ApiLogItem>>([]);

  /// Control whether API logging is enabled
  bool isEnabled = true;

  /// Max log items stored in memory
  int maxLogs = 200;

  int _counter = 0;

  List<ApiLogItem> get logs => List.unmodifiable(logsNotifier.value);

  /// Start tracking a new API request
  ApiLogItem? logRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    dynamic body,
  }) {
    if (!isEnabled) return null;

    _counter++;
    final now = DateTime.now();
    final logItem = ApiLogItem(
      id: '${now.millisecondsSinceEpoch}_$_counter',
      method: method,
      url: url,
      requestHeaders: headers,
      requestBody: body,
      timestamp: now,
    );

    final currentLogs = List<ApiLogItem>.from(logsNotifier.value);
    currentLogs.insert(0, logItem); // Newest first

    if (currentLogs.length > maxLogs) {
      currentLogs.removeLast();
    }

    logsNotifier.value = currentLogs;
    return logItem;
  }

  /// Complete tracking an API request with response details
  void logResponse({
    required ApiLogItem? logItem,
    required int statusCode,
    Map<String, String>? headers,
    dynamic body,
    Duration? duration,
    String? error,
  }) {
    if (!isEnabled || logItem == null) return;

    logItem.statusCode = statusCode;
    logItem.responseHeaders = headers;
    logItem.responseBody = body;
    logItem.duration = duration;
    logItem.error = error;

    // Trigger UI refresh
    logsNotifier.value = List<ApiLogItem>.from(logsNotifier.value);
  }

  /// Log network error or exception
  void logError({
    required ApiLogItem? logItem,
    required String error,
    Duration? duration,
  }) {
    if (!isEnabled || logItem == null) return;

    logItem.error = error;
    logItem.duration = duration;

    logsNotifier.value = List<ApiLogItem>.from(logsNotifier.value);
  }

  /// Clear all stored logs
  void clear() {
    logsNotifier.value = [];
  }

  /// Export all logs as pretty JSON string
  String exportJson() {
    final list = logsNotifier.value.map((e) => e.toJson()).toList();
    return const JsonEncoder.withIndent('  ').convert(list);
  }
}
