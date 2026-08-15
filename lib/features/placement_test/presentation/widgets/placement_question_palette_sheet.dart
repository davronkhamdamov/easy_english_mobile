import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/placement_question.dart';

class PlacementQuestionPaletteSheet extends StatelessWidget {
  final List<PlacementQuestion> questions;
  final Map<String, int> userAnswers;
  final int currentIndex;
  final ValueChanged<int> onSelectQuestion;

  const PlacementQuestionPaletteSheet({
    super.key,
    required this.questions,
    required this.userAnswers,
    required this.currentIndex,
    required this.onSelectQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question Navigator',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            itemCount: questions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              final q = questions[index];
              final isAnswered = userAnswers.containsKey(q.id);
              final isCurrent = index == currentIndex;

              Color btnColor = AppColors.lightSurfaceVariant;
              Color textColor = AppColors.lightTextPrimary;

              if (isCurrent) {
                btnColor = AppColors.primary;
                textColor = Colors.white;
              } else if (isAnswered) {
                btnColor = AppColors.successLight;
                textColor = AppColors.success;
              }

              return InkWell(
                onTap: () {
                  onSelectQuestion(index);
                  Navigator.of(context).pop();
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: btnColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCurrent
                          ? AppColors.primary
                          : (isAnswered
                                ? AppColors.success
                                : AppColors.lightBorder),
                      width: isCurrent ? 2 : 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Q${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
