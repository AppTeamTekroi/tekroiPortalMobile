import 'package:flutter/material.dart';

import '../theme/appColor.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String label;
  IconData? icon;
  bool? readOnly;
  final TextInputType keyboardType;
  final int? maxLength;
  final Widget? prefixExtra;
  final Color? color;

  AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.label,
    this.icon,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.prefixExtra, this.readOnly,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          maxLines: 3,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            text: label,
            style: TextStyle(color: Colors.black,fontSize: 14, fontWeight: FontWeight.w500,),
            children: [
              TextSpan(
                text: " *",
                style: TextStyle(color: color),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          readOnly: readOnly ?? false,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),

            counterText: "",
            hintText: hint,
            prefixIcon: icon != null ?
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 12),
                Icon(icon, size: 18, color: Colors.grey),
                if (prefixExtra != null) ...[
                  const SizedBox(width: 6),
                  prefixExtra!,
                ],
                const SizedBox(width: 12),
              ],
            ) : null,
            // border: OutlineInputBorder(
            //   borderRadius: BorderRadius.circular(12),
            //   borderSide: BorderSide(color: AppColors.border)
            // ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border), // normal border
              ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:  BorderSide(color: AppColors.primary),
            ),

          ),
        ),
      ],
    );
  }
}
