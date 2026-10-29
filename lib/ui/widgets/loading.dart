// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class LoadingOverlay {
//   static void show() {
//     if (!Get.isDialogOpen!) {
//       Get.dialog(
//         Center(
//           child: CircularProgressIndicator(),
//         ),
//         barrierDismissible: false, // Prevent dismissing while loading
//       );
//     }
//   }
//
//   static void hide() {
//     if (Get.isDialogOpen!) {
//       Get.back();
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../assets/app_assets.dart';

class LoadingOverlay {
  static void show(String text) {
    if (!Get.isDialogOpen!) {
      Get.dialog(
        PopScope(
          canPop: false, // disables back button & gesture pop
          onPopInvoked: (didPop) async {
            // Explicitly prevent popping
            return;
          },
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Material(
              color: Colors.transparent,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        AppImagePaths.applogo,
                        height: 90,
                        width: 70,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        text,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        barrierDismissible: false, // disables tap-outside dismiss
      );
    }
  }

  static void hide() {
    if (Get.isDialogOpen!) {
      Get.back();
    }
  }
}

class AppSnackbar {
  static void show(String message, bool isError) {
      // Fluttertoast.showToast(
      //   gravity: ToastGravity.SNACKBAR,
      //   toastLength: Toast.LENGTH_SHORT,
      //   backgroundColor: Colors.blue.shade600,
      //   textColor: Colors.white,
      //   // elevation: 0,
      //   msg: "Exccccvvvvvvvvvgbhsdytnd \n ergtegwtgwt", // required but unused
      // );

      // Fluttertoast.cancel(); // clear default
      //
      Fluttertoast.showToast(
        gravity: ToastGravity.SNACKBAR,
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: isError ? Colors.red : Colors.green,
        msg: message,
        timeInSecForIosWeb: 2,
        webBgColor: "linear-gradient(to right, #333333, #333333)",
        webPosition: "center",
      );
      //
      // // Custom widget using FToast
      // FToast fToast = FToast();
      // // fToast.init(navigatorKey.currentContext!);
      //
      // fToast.showToast(
      //   child: Container(
      //     margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      //     decoration: BoxDecoration(
      //       color: isError ? Colors.red.shade600 : Colors.green.shade600,
      //       borderRadius: BorderRadius.circular(14),
      //       boxShadow: [
      //         BoxShadow(
      //           color: Colors.black26,
      //           blurRadius: 6,
      //           offset: Offset(0, 3),
      //         )
      //       ],
      //     ),
      //     child: Row(
      //       mainAxisSize: MainAxisSize.min,
      //       children: [
      //         Icon(
      //           isError ? Icons.error : Icons.check_circle,
      //           color: Colors.white,
      //         ),
      //         const SizedBox(width: 10),
      //         Flexible(
      //           child: Text(
      //             message,
      //             style: const TextStyle(
      //               color: Colors.white,
      //               fontSize: 14,
      //             ),
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      //   toastDuration: const Duration(seconds: 2)
      // );
    }


  static void success(String message) {
    show( message, false);
  }

  static void error(String message) {
    show( message, true);
  }
}