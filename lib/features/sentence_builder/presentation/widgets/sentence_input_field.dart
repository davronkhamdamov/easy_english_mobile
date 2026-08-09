import 'package:flutter/material.dart';

/// Text input field and action button widget for sentence submission.
class SentenceInputField extends StatelessWidget {
  final TextEditingController controller;
  final String targetWord;
  final bool isEvaluating;
  final VoidCallback onSubmit;

  const SentenceInputField({
    super.key,
    required this.controller,
    required this.targetWord,
    required this.isEvaluating,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Sentence:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          maxLines: 4,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Type your sentence incorporating "$targetWord"...',
            hintStyle: const TextStyle(color: Color(0xFF64748B)),
            filled: true,
            fillColor: const Color(0xFF1E293B),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF334155)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isEvaluating ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isEvaluating
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Submit & Evaluate',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
