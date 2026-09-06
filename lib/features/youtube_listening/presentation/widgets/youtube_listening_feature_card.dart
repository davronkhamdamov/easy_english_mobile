import 'dart:ui';
import 'package:flutter/material.dart';
import '../screens/youtube_listening_screen.dart';

/// App Store / Practice Hub featured hero card for the YouListen YouTube Subtitle feature.
/// Redesigned with a sophisticated monochrome dark aesthetic.
class YoutubeListeningFeatureCard extends StatelessWidget {
  final VoidCallback? onTap;

  const YoutubeListeningFeatureCard({
    super.key,
    this.onTap,
  });

  void _openYouListen(BuildContext context) {
    if (onTap != null) {
      onTap!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const YoutubeListeningScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.15 : 0.25),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openYouListen(context),
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Subtle Decorative Large Monochrome Icon in Background
              Positioned(
                right: -10,
                top: -10,
                child: Icon(
                  Icons.headphones_rounded,
                  size: 150,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
                ),
              ),

              // Card Content
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Eyebrow & Monochrome Status Pill
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.15 : 0.2),
                            ),
                          ),
                          child: Text(
                            'REAL-WORLD CONTEXT',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.2 : 0.25),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.headphones_rounded,
                                color: theme.colorScheme.onSurface,
                                size: 12,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'YouListen PRO',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Title
                    Text(
                      'YouListen: Video Pronunciation',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Subtitle / Description
                    Text(
                      'Search real YouTube clips for any word, repeat tricky accents, and practice cloze listening quizzes.',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Monochrome Feature Badges
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _buildFeatureBadge('🎧 Instant Clips', theme, isDark),
                        _buildFeatureBadge('🌍 US / UK Accents', theme, isDark),
                        _buildFeatureBadge('🎯 Cloze Quizzes', theme, isDark),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Bottom Monochrome Glass Action Pill
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.15 : 0.25),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.play_circle_outline_rounded,
                                color: theme.colorScheme.onSurface,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Explore clips & dialogue',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.onSurface,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Open',
                                  style: TextStyle(
                                    color: theme.colorScheme.surface,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
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
      ),
    );
  }

  Widget _buildFeatureBadge(String label, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.12 : 0.2),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
