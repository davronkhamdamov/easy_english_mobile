import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'api_log_model.dart';
import 'api_logger.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../design_system/components/button/ds_button.dart';
import '../../design_system/components/badge/ds_badge.dart';

class ApiDebuggerScreen extends StatefulWidget {
  const ApiDebuggerScreen({super.key});

  @override
  State<ApiDebuggerScreen> createState() => _ApiDebuggerScreenState();
}

class _ApiDebuggerScreenState extends State<ApiDebuggerScreen> {
  String _searchQuery = '';
  String _selectedMethodFilter = 'ALL';
  String _selectedStatusFilter = 'ALL';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ApiLogItem> _filterLogs(List<ApiLogItem> allLogs) {
    return allLogs.where((log) {
      // Method filter
      if (_selectedMethodFilter != 'ALL' &&
          log.method.toUpperCase() != _selectedMethodFilter) {
        return false;
      }

      // Status filter
      if (_selectedStatusFilter == '2XX' && !log.isSuccess) return false;
      if (_selectedStatusFilter == 'ERRORS' && !log.isError) return false;
      if (_selectedStatusFilter == 'PENDING' && !log.isPending) return false;

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchUrl = log.url.toLowerCase().contains(q);
        final matchMethod = log.method.toLowerCase().contains(q);
        final matchStatus = log.statusCode?.toString().contains(q) ?? false;
        final matchBody = log.formattedResponseBody.toLowerCase().contains(q) ||
            log.formattedRequestBody.toLowerCase().contains(q);
        return matchUrl || matchMethod || matchStatus || matchBody;
      }

      return true;
    }).toList();
  }

  void _showDetailBottomSheet(BuildContext context, ApiLogItem log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ApiLogDetailSheet(log: log),
    );
  }

  /// Sends a simulated or real sample API request for demonstration and testing
  Future<void> _sendSampleApiCall() async {
    final startTime = DateTime.now();
    final log = ApiLogger.instance.logRequest(
      method: 'POST',
      url: 'https://easy-english.uz/api/v1/debug/echo',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer sample_debug_token_123',
        'X-Device-Platform': 'Flutter-iOS-Android',
      },
      body: {
        'action': 'test_api_call',
        'timestamp': DateTime.now().toIso8601String(),
        'debug_mode': true,
        'features_tested': ['API Inspector', 'cURL Generator', 'JSON Formatting']
      },
    );

    // Simulate network delay for real-world feel
    await Future.delayed(const Duration(milliseconds: 240));

    ApiLogger.instance.logResponse(
      logItem: log,
      statusCode: 200,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'server': 'nginx/1.24.0',
        'x-request-id': 'req_${DateTime.now().millisecondsSinceEpoch}',
      },
      body: {
        'status': 'success',
        'code': 200,
        'message': 'API Call captured successfully by ApiLogger!',
        'payload_received': {
          'action': 'test_api_call',
          'debug_mode': true,
        },
        'server_timestamp': DateTime.now().toIso8601String(),
      },
      duration: DateTime.now().difference(startTime),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sample API Call logged!'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _sendSampleErrorCall() async {
    final startTime = DateTime.now();
    final log = ApiLogger.instance.logRequest(
      method: 'GET',
      url: 'https://easy-english.uz/api/v1/auth/protected-resource',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer expired_token',
      },
    );

    await Future.delayed(const Duration(milliseconds: 180));

    ApiLogger.instance.logResponse(
      logItem: log,
      statusCode: 401,
      headers: {'content-type': 'application/json'},
      body: {
        'error': 'Unauthorized',
        'code': 401,
        'message': 'Access token is expired or invalid.',
      },
      duration: DateTime.now().difference(startTime),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final inputBg = isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.api_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'API Call Inspector',
                  style: AppTypography.h3.copyWith(color: textPrimary),
                ),
                Text(
                  'Real-time Network Debugger',
                  style: AppTypography.caption.copyWith(color: textSecondary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Export Logs as JSON',
            icon: const Icon(Icons.file_download_outlined, color: AppColors.primary),
            onPressed: () {
              final jsonStr = ApiLogger.instance.exportJson();
              Clipboard.setData(ClipboardData(text: jsonStr));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All API logs copied as JSON!')),
              );
            },
          ),
          IconButton(
            tooltip: 'Clear All Logs',
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
            onPressed: () {
              ApiLogger.instance.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('API logs cleared')),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<List<ApiLogItem>>(
        valueListenable: ApiLogger.instance.logsNotifier,
        builder: (context, allLogs, child) {
          final filteredLogs = _filterLogs(allLogs);

          return Column(
            children: [
              // Search & Filter Header Toolbar
              Container(
                color: cardColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  children: [
                    // Search Field
                    TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: AppTypography.bodySm.copyWith(color: textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search URL, body, method, status...',
                        hintStyle: AppTypography.bodySm.copyWith(color: textSecondary),
                        prefixIcon: Icon(Icons.search, color: textSecondary, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: inputBg,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Filter Chips & Test Triggers
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('ALL', 'ALL (${allLogs.length})'),
                          const SizedBox(width: 6),
                          _buildFilterChip('GET', 'GET'),
                          const SizedBox(width: 6),
                          _buildFilterChip('POST', 'POST'),
                          const SizedBox(width: 6),
                          _buildStatusFilterChip('ALL', 'Status: All'),
                          const SizedBox(width: 6),
                          _buildStatusFilterChip('2XX', '2xx Success'),
                          const SizedBox(width: 6),
                          _buildStatusFilterChip('ERRORS', 'Errors 4xx/5xx'),
                          const SizedBox(width: 12),
                          Container(
                            height: 24,
                            width: 1,
                            color: isDark ? Colors.white24 : Colors.black12,
                          ),
                          const SizedBox(width: 12),
                          // Quick Test Call Triggers
                          InkWell(
                            onTap: _sendSampleApiCall,
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.accentGreenDark.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.accentGreenDark.withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.play_arrow_rounded, color: AppColors.accentGreen, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Test POST Call',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.accentGreen,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: _sendSampleErrorCall,
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.danger.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Test 401 Error',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.danger,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // API Calls List
              Expanded(
                child: filteredLogs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: textSecondary.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              allLogs.isEmpty
                                  ? 'No API calls captured yet'
                                  : 'No matching API calls found',
                              style: AppTypography.bodyMd.copyWith(color: textSecondary),
                            ),
                            const SizedBox(height: 8),
                            if (allLogs.isEmpty)
                              DSButton(
                                text: 'Send Test API Call',
                                variant: DSButtonVariant.outline,
                                size: DSButtonSize.sm,
                                leftIcon: const Icon(Icons.network_check_rounded),
                                onPressed: _sendSampleApiCall,
                              ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: filteredLogs.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final log = filteredLogs[index];
                          return _ApiLogTile(
                            log: log,
                            isDark: isDark,
                            onTap: () => _showDetailBottomSheet(context, log),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String method, String label) {
    final isSelected = _selectedMethodFilter == method;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _selectedMethodFilter = method);
      },
      selectedColor: AppColors.primary,
      backgroundColor: Colors.transparent,
      labelStyle: AppTypography.caption.copyWith(
        color: isSelected ? Colors.white : AppColors.secondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildStatusFilterChip(String status, String label) {
    final isSelected = _selectedStatusFilter == status;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _selectedStatusFilter = status);
      },
      selectedColor: AppColors.secondary,
      backgroundColor: Colors.transparent,
      labelStyle: AppTypography.caption.copyWith(
        color: isSelected ? Colors.white : AppColors.secondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ApiLogTile extends StatelessWidget {
  final ApiLogItem log;
  final bool isDark;
  final VoidCallback onTap;

  const _ApiLogTile({
    required this.log,
    required this.isDark,
    required this.onTap,
  });

  Color _getStatusColor() {
    if (log.isPending) return Colors.blue;
    if (log.isSuccess) return AppColors.accentGreenDark;
    if (log.isError) return AppColors.danger;
    return Colors.orange;
  }

  Color _getMethodColor() {
    switch (log.method.toUpperCase()) {
      case 'GET':
        return Colors.blue;
      case 'POST':
        return Colors.green;
      case 'PUT':
        return Colors.orange;
      case 'DELETE':
        return Colors.red;
      default:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(log.url);
    final displayPath = uri != null ? (uri.path.isEmpty ? '/' : uri.path) : log.url;
    final displayHost = uri?.host ?? '';
    final statusColor = _getStatusColor();
    final methodColor = _getMethodColor();
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Material(
      color: cardBg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Method Badge, Status Code, Path, Duration
              Row(
                children: [
                  // Method badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: methodColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: methodColor.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      log.method.toUpperCase(),
                      style: TextStyle(
                        color: methodColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Status code badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      log.isPending ? 'PENDING' : '${log.statusCode ?? 'ERR'}',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Path
                  Expanded(
                    child: Text(
                      displayPath,
                      style: AppTypography.bodySm.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Duration badge
                  if (log.duration != null)
                    Text(
                      '${log.duration!.inMilliseconds} ms',
                      style: AppTypography.caption.copyWith(
                        color: textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),

              // Row 2: Host & Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      displayHost.isNotEmpty ? displayHost : log.url,
                      style: AppTypography.caption.copyWith(color: textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatTime(log.timestamp),
                    style: AppTypography.caption.copyWith(color: textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    final ms = dt.millisecond.toString().padLeft(3, '0');
    return '$h:$m:$s.$ms';
  }
}

/// Modal Bottom Sheet displaying detailed request/response/cURL info
class _ApiLogDetailSheet extends StatefulWidget {
  final ApiLogItem log;

  const _ApiLogDetailSheet({required this.log});

  @override
  State<_ApiLogDetailSheet> createState() => _ApiLogDetailSheetState();
}

class _ApiLogDetailSheetState extends State<_ApiLogDetailSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle indicator
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 10),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          DSBadge(
                            label: widget.log.method.toUpperCase(),
                            variant: DSBadgeVariant.primary,
                          ),
                          const SizedBox(width: 8),
                          DSBadge(
                            label: widget.log.isPending
                                ? 'PENDING'
                                : 'Status ${widget.log.statusCode ?? 'ERR'}',
                            variant: widget.log.isSuccess
                                ? DSBadgeVariant.success
                                : (widget.log.isError
                                    ? DSBadgeVariant.danger
                                    : DSBadgeVariant.neutral),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        widget.log.url,
                        style: AppTypography.bodySm.copyWith(color: textPrimary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: textSecondary,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Request'),
              Tab(text: 'Response'),
              Tab(text: 'cURL'),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Request Tab
                _buildCodeView(
                  headers: widget.log.requestHeaders,
                  body: widget.log.formattedRequestBody,
                  onCopyBody: () => _copyToClipboard(widget.log.formattedRequestBody, 'Request Body'),
                ),

                // Response Tab
                _buildCodeView(
                  headers: widget.log.responseHeaders,
                  body: widget.log.formattedResponseBody,
                  error: widget.log.error,
                  onCopyBody: () => _copyToClipboard(widget.log.formattedResponseBody, 'Response Body'),
                ),

                // cURL Tab
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Executable cURL Command',
                              style: AppTypography.label.copyWith(color: textPrimary)),
                          DSButton(
                            text: 'Copy cURL',
                            size: DSButtonSize.sm,
                            leftIcon: const Icon(Icons.copy_rounded),
                            onPressed: () => _copyToClipboard(widget.log.toCurl(), 'cURL Command'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          ),
                          child: SingleChildScrollView(
                            child: SelectableText(
                              widget.log.toCurl(),
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: AppColors.accentGreen,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeView({
    Map<String, String>? headers,
    required String body,
    String? error,
    required VoidCallback onCopyBody,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (error != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
            ),
            child: Text(
              'Error: $error',
              style: AppTypography.bodySm.copyWith(color: AppColors.danger),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Headers (${headers?.length ?? 0})',
                style: AppTypography.label.copyWith(color: textPrimary)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: headers == null || headers.isEmpty
              ? const Text('(No headers)', style: TextStyle(color: Colors.grey, fontSize: 12))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: headers.entries
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: SelectableText.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${e.key}: ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                                TextSpan(
                                  text: e.value,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
        ),

        const SizedBox(height: 16),

        // Body
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Body Payload',
                style: AppTypography.label.copyWith(color: textPrimary)),
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: onCopyBody,
              tooltip: 'Copy Body',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
          child: SelectableText(
            body,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: isDark ? Colors.lightGreenAccent : Colors.indigo,
            ),
          ),
        ),
      ],
    );
  }
}
