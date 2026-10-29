

import '../../ui/theme/appColor.dart';
import 'pageStatus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ApiResult<T> {
  final PageStatus status;
  final T? data;
  final String? error;

  ApiResult._(this.status, {this.data, this.error});

  factory ApiResult.initial() => ApiResult._(PageStatus.initial);
  factory ApiResult.loading() => ApiResult._(PageStatus.loading);
  factory ApiResult.success(T data) => ApiResult._(PageStatus.success, data: data);
  factory ApiResult.empty() => ApiResult._(PageStatus.empty);
  factory ApiResult.error(String msg) =>
      ApiResult._(PageStatus.error, error: msg);
}


// class Helpers {
//
//   AppSnackbar.error()
//   static void showSnackbar(
//       String message, {
//         String title = "Alert",
//         bool isError = true,
//       }) {
//     Get.snackbar(
//       title,
//       message,
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: isError ? Colors.red : Colors.green,
//       colorText: Colors.white,
//       margin: const EdgeInsets.all(12),
//       borderRadius: 10,
//       duration: const Duration(seconds: 3),
//       icon: Icon(
//         isError ? Icons.error_outline : Icons.check_circle,
//         color: Colors.white,
//       ),
//     );
//   }
//
// }

enum TravelStatus { draft, submitted, approved, rejected }

extension TravelStatusExtension on TravelStatus {
  String get label {
    switch (this) {
      case TravelStatus.draft:
        return "Draft";
      case TravelStatus.submitted:
        return "Submitted";
      case TravelStatus.approved:
        return "Approved";
      case TravelStatus.rejected:
        return "Rejected";
    }
  }

  Color get color {
    switch (this) {
      case TravelStatus.draft:
        return Colors.grey;
      case TravelStatus.submitted:
        return AppColors.blue;
      case TravelStatus.approved:
        return AppColors.green;
      case TravelStatus.rejected:
        return Colors.red;
    }
  }
}