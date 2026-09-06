import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../design_system/design_system.dart';
import '../../data/models/youtube_listening_models.dart';
import '../../data/repositories/youtube_listening_repository.dart';
import 'custom_youtube_player.dart';

class YoutubeSearchTab extends StatefulWidget {
  final YoutubeListeningRepository repository;

  const YoutubeSearchTab({
    super.key,
    required this.repository,
  });

  @override
  State<YoutubeSearchTab> createState() => _YoutubeSearchTabState();
}

class _YoutubeSearchTabState extends State<YoutubeSearchTab> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final CustomYoutubePlayerController _playerController =
      CustomYoutubePlayerController();

  bool _isLoading = false;
  String? _statusMessage;

  List<SubtitleSegment> _results = [];
  int _currentIndex = 0;
  double _currentSpeed = 1.0;
  bool _isLooping = false;
  bool _isSubtitleMasked = false;
  bool _hasInitialLoaded = false;

  Timer? _loopTimer;
  int _clipGeneration = 0;
  List<ContextSegment> _activeTimelineSegments = [];
  String _activeSubtitleText = '';
  double _activeSubtitleTimestamp = 0.0;
  int _activeSubtitleKeyId = 0;

  final List<String> _quickSuggestions = [
    'brain',
    'dancing',
    'resilient',
    'trade war',
    'artificial intelligence',
    'social isolation',
    'opportunity',
    'focus',
  ];

  @override
  void initState() {
    super.initState();
    _playerController.onStateChange = (state) {
      if (mounted) setState(() {});
    };
    _playerController.onTimeUpdate = (time) {
      _onPlaybackTimeTick(time);
    };
  }

  @override
  void dispose() {
    _loopTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      final response = await widget.repository.search(
        query: clean,
      );

      if (!mounted) return;

      if (response.results.isEmpty) {
        setState(() {
          _isLoading = false;
          _results = [];
          _statusMessage =
              'No subtitle clips found for "$clean". Try another keyword.';
        });
      } else {
        setState(() {
          _isLoading = false;
          _results = response.results;
          _currentIndex = 0;
          _statusMessage = null;
        });
        _loadClip(0);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error loading clips: $e';
      });
    }
  }

  void _loadClip(int index) {
    if (index < 0 || index >= _results.length) return;

    final clip = _results[index];
    final leadInSec = (clip.startSeconds - 0.8).clamp(0.0, 999999.0);
    final gen = ++_clipGeneration;

    final initialTimeline = [
      ContextSegment(
        id: clip.id,
        sequenceNumber: clip.sequenceNumber,
        startSeconds: clip.startSeconds,
        endSeconds: clip.endSeconds,
        text: clip.highlightedText ?? clip.text,
        isCurrent: true,
      ),
    ];

    setState(() {
      _currentIndex = index;
      _activeSubtitleText = clip.highlightedText ?? clip.text;
      _activeSubtitleTimestamp = clip.startSeconds;
      _activeSubtitleKeyId = clip.id;
      _activeTimelineSegments = initialTimeline;
    });

    if (_hasInitialLoaded) {
      _playerController.loadVideo(
        videoId: clip.videoId,
        startSeconds: leadInSec,
      );
      _playerController.setPlaybackRate(_currentSpeed);
      _playerController.play();
    } else {
      _hasInitialLoaded = true;
    }

    _setupClipPlaybackWatcher(gen, clip);
    _fetchTimelineSegments(gen, clip);
  }

  Future<void> _fetchTimelineSegments(int gen, SubtitleSegment clip) async {
    if (gen != _clipGeneration) return;

    try {
      final res = await widget.repository.getSegmentContext(
        clip.id,
        videoId: clip.videoId,
        window: 1,
      );

      if (!mounted || gen != _clipGeneration) return;

      if (res.segments.isNotEmpty) {
        final filtered = res.segments
            .where((s) => s.startSeconds >= (clip.startSeconds - 1.0))
            .toList()
          ..sort((a, b) => a.startSeconds.compareTo(b.startSeconds));

        if (mounted && gen == _clipGeneration && filtered.isNotEmpty) {
          setState(() {
            _activeTimelineSegments = filtered;
          });
        }
      }
    } catch (_) {}
  }

  void _setupClipPlaybackWatcher(int gen, SubtitleSegment clip) {
    _loopTimer?.cancel();
    _loopTimer =
        Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      if (gen != _clipGeneration) {
        timer.cancel();
        return;
      }
      try {
        final currentSeconds = await _playerController.getCurrentTime();
        if (gen != _clipGeneration) return;
        _onPlaybackTimeTick(currentSeconds);
      } catch (_) {}
    });
  }

  void _onPlaybackTimeTick(double currentSeconds) {
    if (_results.isEmpty || _currentIndex >= _results.length) return;
    final clip = _results[_currentIndex];

    // Determine the end timestamp of the active subtitles group
    final double timelineEndSeconds = _activeTimelineSegments.isNotEmpty
        ? _activeTimelineSegments.last.endSeconds
        : clip.endSeconds;

    // 1. If Loop mode is active, loop the target clip
    if (_isLooping) {
      if (currentSeconds >= (timelineEndSeconds + 0.3)) {
        _replayCurrentSegment();
        return;
      }
    } else {
      // 2. Play until subtitles end, then pause
      if (currentSeconds >= (timelineEndSeconds + 0.3)) {
        _playerController.pause();
        return;
      }
    }

    // 2. Continuous playback across following subtitles in this video
    if (currentSeconds < (clip.startSeconds - 0.2)) {
      // While in lead-in before target clip, stay on clip subtitle
      if (_activeSubtitleKeyId != clip.id) {
        if (mounted) {
          setState(() {
            _activeSubtitleText = clip.highlightedText ?? clip.text;
            _activeSubtitleTimestamp = clip.startSeconds;
            _activeSubtitleKeyId = clip.id;
          });
        }
      }
    } else {
      // Playback reached or passed clip.startSeconds -> dynamically follow subtitle timeline
      if (_activeTimelineSegments.isNotEmpty) {
        ContextSegment? activeSeg;
        // Direct hit: currentSeconds within segment range
        for (final seg in _activeTimelineSegments) {
          if (currentSeconds >= (seg.startSeconds - 0.15) &&
              currentSeconds <= (seg.endSeconds + 0.25)) {
            activeSeg = seg;
            break;
          }
        }

        // Proximity hit: in small gap between sentences
        if (activeSeg == null) {
          for (final seg in _activeTimelineSegments) {
            if (seg.startSeconds <= currentSeconds + 0.15) {
              if (currentSeconds <= seg.endSeconds + 5.0) {
                activeSeg = seg;
              }
            } else {
              break;
            }
          }
        }

        if (activeSeg != null && activeSeg.id != _activeSubtitleKeyId) {
          final newText = activeSeg.text;
          final newTimestamp = activeSeg.startSeconds;
          final newId = activeSeg.id;
          if (mounted) {
            setState(() {
              _activeSubtitleText = newText;
              _activeSubtitleTimestamp = newTimestamp;
              _activeSubtitleKeyId = newId;
            });
          }
        }
      }
    }
  }

  void _replayCurrentSegment() {
    if (_results.isEmpty) return;
    final clip = _results[_currentIndex];
    final leadInSec = (clip.startSeconds - 0.8).clamp(0.0, 999999.0);
    setState(() {
      _activeSubtitleText = clip.highlightedText ?? clip.text;
      _activeSubtitleTimestamp = clip.startSeconds;
      _activeSubtitleKeyId = clip.id;
    });
    _playerController.seekTo(leadInSec);
    _playerController.play();
  }

  void _prevClip() {
    if (_currentIndex > 0) {
      _loadClip(_currentIndex - 1);
    }
  }

  void _nextClip() {
    if (_currentIndex < _results.length - 1) {
      _loadClip(_currentIndex + 1);
    }
  }

  void _setSpeed(double speed) {
    setState(() {
      _currentSpeed = speed;
    });
    _playerController.setPlaybackRate(speed);
  }

  void _toggleLoop() {
    setState(() {
      _isLooping = !_isLooping;
    });
  }

  void _toggleSubtitleMask() {
    setState(() {
      _isSubtitleMasked = !_isSubtitleMasked;
    });
  }

  String _formatTime(double seconds) {
    final mins = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentClip = _results.isNotEmpty ? _results[_currentIndex] : null;

    final isInitialEmptyState =
        _results.isEmpty && !_isLoading && _statusMessage == null;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isInitialEmptyState) ...[
            const SizedBox(height: 28),
            Center(
              child: Text(
                'What do you want to listen to?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.4,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                'Search real YouTube clips by spoken word or idiom',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 22),
          ],

          // 1. Monochrome Search Prompt Bar
          _buildModernSearchBar(isDark, theme),

          // 2. Quick Suggestions Tags (shown only before searching)
          if (isInitialEmptyState) ...[
            const SizedBox(height: 14),
            _buildQuickSuggestions(isDark, theme),
          ],
          const SizedBox(height: 20),

          // 4. Status / Loading / Content Section
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            )
          else if (_statusMessage != null)
            _buildStatusCard(isDark, theme, _statusMessage!)
          else if (currentClip != null) ...[
            // 5. Official YouTube Player Section
            _buildVideoPlayerSection(isDark, theme, currentClip),
            const SizedBox(height: 16),

            // 6. Action Playback Toolbar
            _buildPlayerToolbar(isDark, theme),
            const SizedBox(height: 16),

            // 7. Active Subtitle & Listening Focus Card
            _buildSubtitleFocusCard(isDark, theme, currentClip),
          ] else if (isInitialEmptyState) ...[
            _buildInitialHints(isDark, theme),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildModernSearchBar(bool isDark, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.15 : 0.25),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.only(left: 18, right: 6, top: 4, bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) => _performSearch(value),
              onChanged: (_) => setState(() {}),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Ask anything or type a word...',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
                filled: false,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              color: theme.colorScheme.onSurfaceVariant,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              onPressed: () {
                _searchController.clear();
                _playerController.pause();
                _loopTimer?.cancel();
                setState(() {
                  _results = [];
                  _statusMessage = null;
                  _currentIndex = 0;
                });
              },
            ),
          const SizedBox(width: 4),
          InkWell(
            onTap: () => _performSearch(_searchController.text),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_rounded,
                color: theme.colorScheme.surface,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSuggestions(bool isDark, ThemeData theme) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Try:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        ..._quickSuggestions.map((tag) {
          return InkWell(
            onTap: () {
              _searchController.text = tag;
              _performSearch(tag);
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.15 : 0.25),
                ),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildInitialHints(bool isDark, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.15 : 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: theme.colorScheme.onSurface,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'How YouListen Works',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildHintRow('🎬', 'Search any word to jump directly to exact video timestamps.', theme),
          const SizedBox(height: 8),
          _buildHintRow('🌍', 'Filter clips between US and UK native speakers.', theme),
          const SizedBox(height: 8),
          _buildHintRow('🎧', 'Loop key lines, adjust speed, or inspect synchronized context.', theme),
        ],
      ),
    );
  }

  Widget _buildHintRow(String emoji, String text, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(bool isDark, ThemeData theme, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.15 : 0.25),
        ),
      ),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayerSection(bool isDark, ThemeData theme, SubtitleSegment clip) {
    final leadInSec = (clip.startSeconds - 0.8).clamp(0.0, 999999.0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomYoutubePlayer(
            initialVideoId: clip.videoId,
            initialStartSeconds: leadInSec,
            controller: _playerController,
            autoPlay: true,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: theme.colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clip.title,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      clip.channelTitle ?? 'YouTube',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.2),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        clip.accent ?? 'US',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '⏱ ${_formatTime(clip.startSeconds)}',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerToolbar(bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.15 : 0.25),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_currentIndex + 1} / ${_results.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              IconButton.filledTonal(
                icon: const Icon(Icons.skip_previous_rounded, size: 20),
                onPressed: _currentIndex > 0 ? _prevClip : null,
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  foregroundColor: theme.colorScheme.onSurface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              IconButton.filled(
                icon: const Icon(Icons.replay_rounded, size: 20),
                onPressed: _replayCurrentSegment,
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.onSurface,
                  foregroundColor: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              IconButton.filled(
                icon: Icon(
                  _playerController.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _playerController.togglePlayPause();
                  });
                },
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.onSurface,
                  foregroundColor: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              InkWell(
                onTap: _toggleLoop,
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isLooping
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isLooping
                          ? theme.colorScheme.onSurface
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.repeat_one_rounded,
                        size: 16,
                        color: _isLooping
                            ? theme.colorScheme.surface
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isLooping ? 'ON' : 'OFF',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _isLooping
                              ? theme.colorScheme.surface
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton.filledTonal(
                icon: const Icon(Icons.skip_next_rounded, size: 20),
                onPressed: _currentIndex < _results.length - 1 ? _nextClip : null,
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  foregroundColor: theme.colorScheme.onSurface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              Text(
                'Speed:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              _buildSpeedButton(0.75, '0.75x', isDark, theme),
              const SizedBox(width: 6),
              _buildSpeedButton(1.0, '1.0x', isDark, theme),
              const SizedBox(width: 6),
              _buildSpeedButton(1.25, '1.25x', isDark, theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedButton(double speed, String label, bool isDark, ThemeData theme) {
    final isSelected = (_currentSpeed - speed).abs() < 0.01;
    return InkWell(
      onTap: () => _setSpeed(speed),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.onSurface
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? theme.colorScheme.surface
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitleFocusCard(bool isDark, ThemeData theme, SubtitleSegment clip) {
    final String displayText = _activeSubtitleText.isNotEmpty
        ? _activeSubtitleText
        : (clip.highlightedText ?? clip.text);
    final double currentTimestamp = _activeSubtitleTimestamp > 0
        ? _activeSubtitleTimestamp
        : clip.startSeconds;
    final int segmentKeyId = _activeSubtitleKeyId != 0
        ? _activeSubtitleKeyId
        : clip.id;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.15 : 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.subtitles_rounded,
                color: theme.colorScheme.onSurface,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'Subtitle',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _formatTime(currentTimestamp),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                icon: Icon(
                  _isSubtitleMasked ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurface,
                ),
                label: Text(
                  _isSubtitleMasked ? 'Reveal' : 'Ear Test (Hide)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                onPressed: _toggleSubtitleMask,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.15 : 0.25),
              ),
            ),
            child: _isSubtitleMasked
                ? Row(
                    children: [
                      Icon(
                        Icons.lock_rounded,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Subtitles hidden! Listen carefully, then click Reveal.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  )
                : _buildInteractiveSubtitleText(
                    displayText,
                    segmentKeyId,
                    isDark,
                    theme,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveSubtitleText(
    String text,
    int segmentKeyId,
    bool isDark,
    ThemeData theme,
  ) {
    return DSInteractiveText(
      text,
      key: ValueKey('subtitle_$segmentKeyId'),
      highlightQuery: _searchController.text.trim(),
      style: TextStyle(
        fontSize: 16,
        height: 1.55,
        fontWeight: FontWeight.w500,
        color: theme.colorScheme.onSurface,
      ),
      highlightStyle: DSWordHighlightStyle.dottedUnderline,
      activeWordColor: theme.colorScheme.primary,
      searchHighlightColor:
          isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
      searchHighlightBackgroundColor: isDark
          ? const Color(0xFF78350F).withValues(alpha: 0.55)
          : const Color(0xFFFEF3C7),
      dropdownPlacement: DSWordDropdownPlacement.auto,
    );
  }
}
