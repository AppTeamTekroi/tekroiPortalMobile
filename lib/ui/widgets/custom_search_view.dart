import 'package:flutter/material.dart';

import '../../core/utils/size_utils.dart';

/**
 * A customizable search input field widget with icon support and validation.
 *
 * This component provides a text input field specifically designed for search functionality,
 * featuring a customizable prefix icon, placeholder text, and comprehensive styling options.
 *
 * @param controller - TextEditingController for managing the input text
 * @param hintText - Placeholder text displayed when field is empty
 * @param prefixIconPath - Path to the prefix icon image (SVG, PNG, etc.)
 * @param validator - Function to validate the input text
 * @param onChanged - Callback function triggered when text changes
 * @param enabled - Whether the search field is enabled for input
 * @param keyboardType - Type of keyboard to display for input
 * @param borderRadius - Border radius for the search field
 * @param contentPadding - Internal padding for the search field content
 */
class CustomSearchView extends StatelessWidget {
  CustomSearchView({
    Key? key,
    this.controller,
    this.hintText,
    this.prefixIconPath,
    this.validator,
    this.onChanged,
    this.enabled,
    this.keyboardType,
    this.borderRadius,
    this.contentPadding,
  }) : super(key: key);

  /// Controller for managing the search input text
  final TextEditingController? controller;

  /// Placeholder text shown when the field is empty
  final String? hintText;

  /// Path to the prefix icon image
  final String? prefixIconPath;

  /// Function to validate the search input
  final String? Function(String?)? validator;

  /// Callback function triggered when the search text changes
  final Function(String)? onChanged;

  /// Whether the search field is enabled for user input
  final bool? enabled;

  /// Type of keyboard to display for input
  final TextInputType? keyboardType;

  /// Border radius for the search field
  final double? borderRadius;

  /// Internal padding for the search field content
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled ?? true,
      keyboardType: keyboardType ?? TextInputType.text,
      validator: validator,
      onChanged: onChanged,
      // style: TextStyleHelper.instance.title16RegularInter
      //     .copyWith(color: Colors.grey, height: 1.25),
      decoration: InputDecoration(
        hintText: hintText ?? "Search products...",
        // hintStyle: TextStyleHelper.instance.title16RegularInter
        //     .copyWith(color: appTheme.color7F0A0A, height: 1.25),
        // prefixIcon: prefixIconPath != null
        //     ? Padding(
        //         padding: EdgeInsets.all(12.h),
        //         child: CustomImageView(
        //           imagePath: prefixIconPath!,
        //           height: 20.h,
        //           width: 20.h,
        //         ),
        //       )
        //     : null,
        contentPadding: contentPadding ??
            EdgeInsets.only(
              top: 12.h,
              right: 16.h,
              bottom: 12.h,
              left: 30.h,
            ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 14.h),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
            width: 0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 14.h),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
            width: 0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 14.h),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
            width: 1.h,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 14.h),
          borderSide: BorderSide(
            color: Colors.red,
            width: 1.h,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 14.h),
          borderSide: BorderSide(
            color: Colors.red,
            width: 1.h,
          ),
        ),
        filled: true,
        fillColor: Colors.white,

      ),
    );
  }
}
