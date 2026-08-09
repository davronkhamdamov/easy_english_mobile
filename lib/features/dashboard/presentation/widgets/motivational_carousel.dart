import 'package:flutter/material.dart';
import '../../domain/entities/achievement_motivation.dart';

class MotivationalCarousel extends StatefulWidget {
  final List<MotivationalCard> cards;

  const MotivationalCarousel({super.key, required this.cards});

  @override
  State<MotivationalCarousel> createState() => _MotivationalCarouselState();
}

class _MotivationalCarouselState extends State<MotivationalCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Color _parseAccentColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'orange':
        return Colors.orange.shade700;
      case 'indigo':
        return Colors.indigo.shade600;
      case 'cyan':
        return Colors.cyan.shade700;
      case 'amber':
        return Colors.amber.shade800;
      case 'purple':
        return Colors.purple.shade600;
      case 'blue':
      default:
        return Colors.blue.shade700;
    }
  }

  IconData _parseIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'ac_unit':
        return Icons.ac_unit;
      case 'shield':
        return Icons.shield;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'bolt':
        return Icons.bolt;
      case 'emoji_events':
        return Icons.emoji_events;
      default:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.cards.length,
            onPageChanged: (idx) {
              setState(() {
                _currentIndex = idx;
              });
            },
            itemBuilder: (context, index) {
              final card = widget.cards[index];
              final accentColor = _parseAccentColor(card.accentColor);
              final iconData = _parseIcon(card.iconName);

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      accentColor.withValues(alpha: 0.12),
                      accentColor.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: accentColor.withValues(alpha: 0.2),
                      child: Icon(iconData, color: accentColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            card.message,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Colors.black87,
                              height: 1.3,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        if (widget.cards.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.cards.length,
              (idx) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentIndex == idx ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentIndex == idx
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
