import 'package:flutter/material.dart';
import '../../domain/services/review_rating.dart';

class FlashcardRatingButtons extends StatelessWidget {
  final ValueChanged<ReviewRating> onRatingSelected;

  const FlashcardRatingButtons({
    super.key,
    required this.onRatingSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildButton(
            context,
            rating: ReviewRating.again,
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildButton(
            context,
            rating: ReviewRating.hard,
            color: Colors.amber.shade700,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildButton(
            context,
            rating: ReviewRating.good,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildButton(
            context,
            rating: ReviewRating.easy,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required ReviewRating rating,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: () => onRatingSelected(rating),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            rating.label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            rating.intervalLabel,
            style: TextStyle(
              fontSize: 10,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
