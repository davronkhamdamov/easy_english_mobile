import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

/// Callback when the player changes playback state.
typedef PlayerStateCallback = void Function(int state);

/// A bulletproof, cross-platform YouTube IFrame controller.
class CustomYoutubePlayerController {
  WebViewController? _webViewController;
  bool _isReady = false;
  bool _isPlaying = false;
  String _currentVideoId = '';
  double _currentTime = 0.0;
  PlayerStateCallback? onStateChange;
  VoidCallback? onReady;
  void Function(double time)? onTimeUpdate;

  bool get isReady => _isReady;
  bool get isPlaying => _isPlaying;
  String get currentVideoId => _currentVideoId;
  double get currentTime => _currentTime;

  void attachWebViewController(WebViewController controller) {
    _webViewController = controller;
  }

  void onPlayerReady() {
    _isReady = true;
    onReady?.call();
  }

  void handleMessage(String message) {
    try {
      final data = jsonDecode(message) as Map<String, dynamic>;
      final type = data['type'] as String?;
      if (type == 'ready') {
        onPlayerReady();
      } else if (type == 'time') {
        final t = (data['time'] as num?)?.toDouble() ?? 0.0;
        _currentTime = t;
        onTimeUpdate?.call(t);
      } else if (type == 'stateChange') {
        final state = data['state'] is int
            ? data['state'] as int
            : int.tryParse(data['state']?.toString() ?? '0') ?? 0;
        // YT.PlayerState: 1 = PLAYING, 2 = PAUSED, 3 = BUFFERING, 0 = ENDED
        _isPlaying = (state == 1 || state == 3);
        onStateChange?.call(state);
      } else if (type == 'error') {
        if (kDebugMode) {
          debugPrint('[CustomYoutubePlayer] YouTube Error Code: ${data['code']}');
        }
      }
    } catch (_) {}
  }

  void loadVideo({required String videoId, double startSeconds = 0.0}) {
    _currentVideoId = videoId;
    _currentTime = startSeconds;
    if (_webViewController != null && _isReady) {
      _webViewController!.runJavaScript(
        "loadVideo('$videoId', $startSeconds);",
      );
    }
  }

  void seekTo(double seconds) {
    _currentTime = seconds;
    if (_webViewController != null && _isReady) {
      _webViewController!.runJavaScript("seekTo($seconds);");
    }
  }

  void play() {
    _isPlaying = true;
    if (_webViewController != null && _isReady) {
      _webViewController!.runJavaScript("playVideo();");
    }
  }

  void pause() {
    _isPlaying = false;
    if (_webViewController != null && _isReady) {
      _webViewController!.runJavaScript("pauseVideo();");
    }
  }

  void togglePlayPause() {
    if (_isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void setPlaybackRate(double rate) {
    if (_webViewController != null && _isReady) {
      _webViewController!.runJavaScript("setPlaybackRate($rate);");
    }
  }

  Future<double> getCurrentTime() async {
    if (_webViewController == null || !_isReady) return _currentTime;
    try {
      final res = await _webViewController!.runJavaScriptReturningResult(
        "player && player.getCurrentTime ? player.getCurrentTime() : 0;",
      );
      if (res is num) {
        _currentTime = res.toDouble();
        return _currentTime;
      }
      final clean = res.toString().replaceAll('"', '').replaceAll("'", '').trim();
      final parsed = double.tryParse(clean);
      if (parsed != null) {
        _currentTime = parsed;
        return parsed;
      }
      return _currentTime;
    } catch (_) {
      return _currentTime;
    }
  }
}

/// Custom Flutter YouTube Player widget rendering the official YouTube Iframe API.
class CustomYoutubePlayer extends StatefulWidget {
  final String initialVideoId;
  final double initialStartSeconds;
  final CustomYoutubePlayerController controller;
  final double aspectRatio;
  final bool autoPlay;
  final bool showControls;

  const CustomYoutubePlayer({
    super.key,
    required this.initialVideoId,
    this.initialStartSeconds = 0.0,
    required this.controller,
    this.aspectRatio = 16 / 9,
    this.autoPlay = true,
    this.showControls = false,
  });

  @override
  State<CustomYoutubePlayer> createState() => _CustomYoutubePlayerState();
}

class _CustomYoutubePlayerState extends State<CustomYoutubePlayer> {
  late final WebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebViewController();
  }

  void _initWebViewController() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = AndroidWebViewControllerCreationParams();
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Mobile Safari/537.36',
      )
      ..addJavaScriptChannel(
        'FlutterBridge',
        onMessageReceived: (JavaScriptMessage message) {
          widget.controller.handleMessage(message.message);
          if (_isLoading) {
            setState(() {
              _isLoading = false;
            });
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (error) {
            if (kDebugMode) {
              debugPrint('[CustomYoutubePlayer] WebView error: ${error.description}');
            }
          },
          onNavigationRequest: (request) {
            return NavigationDecision.navigate;
          },
        ),
      );

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(kDebugMode);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _webViewController = controller;
    widget.controller.attachWebViewController(_webViewController);

    final html = _buildPlayerHtml(
      videoId: widget.initialVideoId,
      startSeconds: widget.initialStartSeconds,
      autoPlay: widget.autoPlay,
      showControls: widget.showControls,
    );

    _webViewController.loadHtmlString(
      html,
      baseUrl: 'https://www.youtube-nocookie.com',
    );
  }

  String _buildPlayerHtml({
    required String videoId,
    required double startSeconds,
    required bool autoPlay,
    bool showControls = false,
  }) {
    final autoPlayInt = autoPlay ? 1 : 0;
    final controlsInt = showControls ? 1 : 0;
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; border: none; outline: none; }
    html, body {
      width: 100%;
      height: 100%;
      background-color: #000000;
      overflow: hidden;
      margin: 0;
      padding: 0;
    }
    #player, iframe {
      width: 100% !important;
      height: 100% !important;
      position: absolute;
      top: 0;
      left: 0;
      border: none !important;
      outline: none !important;
    }
    .ytp-caption-window-bottom,
    .ytp-caption-window-rollup,
    .caption-window,
    .ytp-caption-segment,
    .ytp-subtitles-player-button {
      display: none !important;
      visibility: hidden !important;
      opacity: 0 !important;
    }
  </style>
</head>
<body>
  <div id="player"></div>
  <script src="https://www.youtube.com/iframe_api"></script>
  <script>
    var player;
    var isReady = false;
    var currentVideoId = '$videoId';
    var currentStartSeconds = $startSeconds;

    function hideCaptions() {
      try {
        if (player) {
          if (player.unloadModule) {
            player.unloadModule('captions');
            player.unloadModule('cc');
          }
          if (player.setOption) {
            player.setOption('captions', 'track', {});
            player.setOption('cc', 'track', {});
          }
        }
      } catch (e) {}
    }

    function onYouTubeIframeAPIReady() {
      player = new YT.Player('player', {
        height: '100%',
        width: '100%',
        videoId: currentVideoId,
        playerVars: {
          'autoplay': $autoPlayInt,
          'controls': $controlsInt,
          'modestbranding': 1,
          'rel': 0,
          'fs': 0,
          'playsinline': 1,
          'disablekb': 1,
          'cc_load_policy': 0,
          'cc_lang_pref': 'none',
          'iv_load_policy': 3,
          'start': Math.floor(currentStartSeconds)
        },
        events: {
          'onReady': onPlayerReady,
          'onStateChange': onPlayerStateChange,
          'onError': onPlayerError
        }
      });
    }

    var timeReportInterval = null;
    function startTimeReporting() {
      if (timeReportInterval) clearInterval(timeReportInterval);
      timeReportInterval = setInterval(function() {
        if (player && player.getCurrentTime && isReady) {
          try {
            var t = player.getCurrentTime();
            if (typeof t === 'number' && !isNaN(t) && window.FlutterBridge) {
              FlutterBridge.postMessage(JSON.stringify({ type: 'time', time: t }));
            }
          } catch (e) {}
        }
      }, 100);
    }

    function onPlayerReady(event) {
      isReady = true;
      hideCaptions();
      startTimeReporting();
      if (window.FlutterBridge) {
        FlutterBridge.postMessage(JSON.stringify({ type: 'ready' }));
      }
      if ($autoPlayInt === 1) {
        try {
          event.target.playVideo();
        } catch (e) {}
      }
    }

    function onPlayerStateChange(event) {
      hideCaptions();
      startTimeReporting();
      if (window.FlutterBridge) {
        FlutterBridge.postMessage(JSON.stringify({ type: 'stateChange', state: event.data }));
      }
    }

    function onPlayerError(event) {
      if (window.FlutterBridge) {
        FlutterBridge.postMessage(JSON.stringify({ type: 'error', code: event.data }));
      }
    }

    function playVideo() {
      if (player && player.playVideo) player.playVideo();
      hideCaptions();
    }

    function pauseVideo() {
      if (player && player.pauseVideo) player.pauseVideo();
    }

    function seekTo(seconds) {
      if (player && player.seekTo) {
        player.seekTo(seconds, true);
      }
      hideCaptions();
    }

    function setPlaybackRate(rate) {
      if (player && player.setPlaybackRate) {
        player.setPlaybackRate(rate);
      }
    }

    function loadVideo(videoId, startSeconds) {
      currentVideoId = videoId;
      currentStartSeconds = startSeconds;
      if (player && player.loadVideoById) {
        player.loadVideoById({
          videoId: videoId,
          startSeconds: startSeconds
        });
        player.playVideo();
        hideCaptions();
      }
    }
  </script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            WebViewWidget(controller: _webViewController),
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  strokeWidth: 2.5,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
