import 'package:flutter/material.dart';

import '../theme/appColor.dart';

class CommonTextStyles {
  static Widget commonBoldStyle({
   required title,
    Color? titleColor,
    double? Size,
    FontWeight? weight,
  }) {
    return Text(
      title,
      style: TextStyle(
        color: titleColor,
            // Color(0xFFFFF100),
        fontSize: Size,
        fontWeight: weight,
      ),
    );
  }

  static Widget commonSecondaryStyle({
    title,
    Color? titleColor,
    double? Size,
    FontWeight? weight,
  }) {
    return Text(
      title,
      style: TextStyle(
        color: titleColor,
        fontSize: Size ?? 13,
        fontWeight: weight,
      ),
    );
  }

  static Widget rowText({

      required String key, required String value, Color? leftText, Color? rightText, double? rightSize}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: TextStyle(color: leftText ?? Colors.grey.shade600, fontSize: 14)),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,

              style: TextStyle(
                fontSize: rightSize ?? 13,
                color: rightText ?? AppColors.black,
                // fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  // Widget _row({required String key, required String value, Color? color}) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 4),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(key, style: TextStyle(fontWeight: FontWeight.w500)),
  //         Flexible(
  //             child: Text(value,
  //                 textAlign: TextAlign.right,
  //                 style: TextStyle(
  //                   color: color ?? AppColors.black,
  //                 ))),
  //       ],
  //     ),
  //   );
  // }
  // Widget _detailRow(String label, String value) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 4),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(
  //           label,
  //           style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
  //         ),
  //         Text(
  //           value,
  //           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  static Widget rowIconText(
    String text,
    IconData icon,
    Color iconColor,
    double? iconSize,
  ) {
    return RichText(
      text: TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Icon(icon, color: iconColor, size: iconSize ?? 12),
          ),
          const WidgetSpan(child: SizedBox(width: 6)), // spacing
          TextSpan(
            text: text,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  static Widget commonRichText({
    required String label,
    required String value,
    double? font,
  }) {
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.fade,
      softWrap: true,

      text: TextSpan(
        text: label,
        style: TextStyle(color: Colors.grey.shade600, fontSize: font ?? 14),
        children: [
          TextSpan(
            text: value,
            style: TextStyle(
              color: Colors.grey.shade900,
              fontSize: font ?? 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}


// Widget _buildTitleWithSubtitle() {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     mainAxisSize: MainAxisSize.min,
//     children: [
//       Text(
//         title,
//         style: TextStyleHelper.instance.title20RegularInter.copyWith(
//             color: titleColor ?? Color(0xFFFFF100), height: 25.h / 20.fSize),
//       ),
//       SizedBox(height: 4.h),
//       Text(
//         subtitle!,
//         style: TextStyleHelper.instance.body14RegularInter.copyWith(
//             color: subtitleColor ?? Color(0xFFD0D5DB),
//             height: 17.h / 14.fSize),
//       ),
//     ],
//   );
// }
