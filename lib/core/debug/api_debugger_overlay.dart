import 'package:flutter/material.dart';
import 'api_log_model.dart';
import 'api_logger.dart';
import 'api_debugger_screen.dart';
import '../theme/app_colors.dart';

/// Floating overlay button for launching the API Debugger Inspector from anywhere in the app.
class ApiDebuggerOverlay extends StatefulWidget {
  /// Global navigator key to allow pushing routes from outside the Navigator tree
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final Widget child;

  /// Whether the floating button is enabled by default
  final bool enableFloatingButton;

  const ApiDebuggerOverlay({
    super.key,
    required this.child,
    this.enableFloatingButton = true,
  });

  @override
  State<ApiDebuggerOverlay> createState() => _ApiDebuggerOverlayState();
}

class _ApiDebuggerOverlayState extends State<ApiDebuggerOverlay> {
  Offset _position = const Offset(16, 120);

  void _openDebugger(BuildContext context) {
    // 1. Try global navigator key first
    final navState = ApiDebuggerOverlay.navigatorKey.currentState;
    if (navState != null) {
      navState.push(
        MaterialPageRoute(
          builder: (context) => const ApiDebuggerScreen(),
        ),
      );
      return;
    }

    // 2. Fallback to searching context up the widget tree
    try {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => const ApiDebuggerScreen(),
        ),
      );
    } catch (e) {
      debugPrint('ApiDebuggerOverlay navigator error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableFloatingButton) {
      return widget.child;
    }

    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;

    return Stack(
      children: [
        widget.child,

        // Floating Draggable API Debugger Button
        Positioned(
          left: _position.dx,
          top: _position.dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                double newX = _position.dx + details.delta.dx;
                double newY = _position.dy + details.delta.dy;

                // Clamp to screen bounds
                newX = newX.clamp(0.0, size.width - 70.0);
                newY = newY.clamp(40.0, size.height - 70.0);

                _position = Offset(newX, newY);
              });
            },
            onTap: () => _openDebugger(context),
            child: Material(
              elevation: 8,
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              child: ValueListenableBuilder<List<ApiLogItem>>(
                valueListenable: ApiLogger.instance.logsNotifier,
                builder: (context, logs, child) {
                  final errorCount = logs.where((l) => l.isError).length;
                  final pendingCount = logs.where((l) => l.isPending).length;

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: errorCount > 0
                            ? [const Color(0xFFE53935), const Color(0xFFB71C1C)]
                            : [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: (errorCount > 0 ? AppColors.danger : AppColors.primary)
                              .withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.api_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'API (${logs.length})',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        if (errorCount > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: const BoxDecoration(
                              color: Colors.yellowAccent,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$errorCount',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ] else if (pendingCount > 0) ...[
                          const SizedBox(width: 6),
                          const SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
