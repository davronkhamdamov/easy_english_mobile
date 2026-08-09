import 'package:flutter/material.dart';

class WritingEditor extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const WritingEditor({super.key, required this.controller, this.onChanged});

  int get _wordCount {
    final text = controller.text;
    if (text.trim().isEmpty) return 0;
    return text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 10,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      decoration: InputDecoration(
        hintText: 'Type your essay response here...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        counterText: '$_wordCount words',
      ),
      onChanged: onChanged,
    );
  }
}
