import 'package:flutter/material.dart';

class AppTextArea extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String hint;
  final int maxLines;
  final bool compact;

  const AppTextArea({
    super.key,
    required this.controller,
    this.label,
    required this.hint,
    this.maxLines = 2,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(fontSize: compact ? 12 : 14, height: 1.25),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: compact ? 12 : 12),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              vertical: compact ? 6 : 8,
              horizontal: compact ? 8 : 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(compact ? 8 : 10),
            ),
          ),
        ),
      ],
    );
  }
}
