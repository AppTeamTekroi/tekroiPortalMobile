import 'dart:ffi';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import '../../core/utils/size_utils.dart';
import '../theme/appColor.dart';
import 'commonTextStyles.dart';

class ContainerWidget {

  static Widget headerGradient({Widget? child}) {
    return Container(
        padding: EdgeInsets.all(26.h),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: AlignmentGeometry.centerLeft,
            end: AlignmentGeometry.centerRight,
            // begin: AlignmentGeometry.bottomLeft,
            // end: AlignmentGeometry.topRight,
            colors: [
              Colors.purple.shade600,
              Colors.blue.shade600
              // AppColors.primary,
              //   AppColors.primary,

              // AppColors.primary.withValues(alpha: 0.7),
              // Colors.blue,
              // Color(0xFF0055A4),

            ],
          ),
        ),
        child: child
    );
  }

  static Widget cardheaderGradient({Widget? child, required Colors}) {
    return Container(
        padding: EdgeInsets.all(26.h),
        decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentGeometry.bottomLeft,
              end: AlignmentGeometry.topRight,
              colors: Colors,
            ),
            borderRadius: BorderRadius.circular(18)
        ),
        child: child
    );
  }

  static Widget commonSelectableContainer({
    required bool selected,
    required String label,
    EdgeInsetsGeometry? padding,
    // required dynamic value,
    required VoidCallback onTap,
    double? borderRadius,
  }) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        padding: padding ??
            const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color:
          selected ? AppColors.blue.withOpacity(0.1) : AppColors.white,
          border: Border.all(
            color: selected ? AppColors.blue : AppColors.border,
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? AppColors.blue : Colors.black,
          ),
        ),
      ),
    );
  }

  // Widget _commonToggle({
  //   required String value,
  //   required RxString group,
  //   required Function(String) onTap,
  // }) {
  //   return Obx(() {
  //     final selected = group.value == value;
  //
  //     return Expanded(
  //       child: GestureDetector(
  //         onTap: () => onTap(value),
  //         child: Container(
  //           padding: const EdgeInsets.symmetric(vertical: 12),
  //           margin: const EdgeInsets.symmetric(horizontal: 4),
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(12),
  //             color: selected
  //                 ? AppColors.blue.withOpacity(0.1)
  //                 : AppColors.white,
  //             border: Border.all(
  //               color: selected ? AppColors.blue : AppColors.border,
  //             ),
  //           ),
  //           child: Center(
  //             child: Text(
  //               value,
  //               style: TextStyle(
  //                 color: selected ? AppColors.primary : Colors.black,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     );
  //   });
  // }

  static Widget commonSelectableContainerColors({
    required Widget child,
    EdgeInsetsGeometry? padding,
    required bool value,
    required ValueChanged<dynamic> onTap,
    double? borderRadius,
    Color? selectedColor,
  }) {
    final Color activeColor = selectedColor ?? AppColors.white;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        // height: 80.h,
        width: 170.h,
        margin: EdgeInsets.only(bottom: 15.h),
        padding: padding ??
            EdgeInsets.symmetric(vertical: 15.h, horizontal: 0.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius ?? 14),
          color: value == true ? selectedColor?.withOpacity(0.1) : AppColors
              .white,
          border: Border.all(
            color: value == true ? activeColor : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Center(child: child),
      ),
    );
  }

  static Widget commonContainer({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding:
      padding ?? EdgeInsets.symmetric(vertical: 16.h, horizontal: 17.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFE4F0FB),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: child,
    );
  }

  static Widget iconContainer({
    required Widget child,
    EdgeInsetsGeometry? padding,
    Color? background
  }) {
    return Container(
      padding:
      padding ?? EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: background?.withValues(alpha: 0.2) ?? Color(0xFFE4F0FB),
      ),
      child: child,
    );
  }


  static Widget gradientCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(

            gradient: LinearGradient(
                begin: AlignmentGeometry.centerLeft,
                end: AlignmentGeometry.centerRight,
                colors: colors),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                    padding: EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(icon, color: Colors.white)),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget dashedButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          dashPattern: [5, 2],
          color: AppColors.container,
          strokeWidth: 2,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          radius: Radius.circular(9),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.grey.shade600, size: 20),
            SizedBox(width: 8.h),
            Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget backContainer(VoidCallback onTap, String title) {
    return Row(
      spacing: 10,
      children: [
        // ContainerWidget.backContainer(() => routes.back()),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 30,
            width: 30,

            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),

            ),
            child: Icon(
              Icons.arrow_back_ios_new_outlined,
              color: Colors.blueGrey,
              size: 13,
            ),
          ),
        ),
        CommonTextStyles.commonSecondaryStyle(title: title,Size: 17),
      ],
    );
  }
}

// Widget _actionCard({
//   required VoidCallback onTap,
//   required IconData icon,
//   required String title,
//   required String subtitle,
//   required List<Color> gradient,
// }) {
//   return InkWell(
//     onTap: onTap,
//     borderRadius: BorderRadius.circular(16),
//     child: Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(colors: gradient),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, size: 28, color: Colors.white),
//           const SizedBox(height: 12),
//           Text(
//             title,
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//               fontSize: 14,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             subtitle,
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.85),
//               fontSize: 12,
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }