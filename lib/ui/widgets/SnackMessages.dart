import 'package:flash/flash.dart';
import 'package:flutter/material.dart';

class AppFlash {
  static void show(BuildContext context,
      {required bool status, required String message}) {
    showFlash(
      context: context,
      duration: const Duration(seconds: 3),
      builder: (context, controller) {
        return Flash(
          controller: controller,
          position: FlashPosition.bottom,
          // behavior: FlashBehavior.floating,
          // margin: const EdgeInsets.all(20),
          // borderRadius: BorderRadius.circular(12),
          // backgroundColor: Colors.white,
          // boxShadows: [
          //   BoxShadow(
          //     color: Colors.black12,
          //     blurRadius: 6,
          //   )
          // ],
          child: FlashBar(
            content: Row(
              children: [
                Icon(
                  status ? Icons.check_circle : Icons.error,
                  color:
                  status ? Colors.green.shade900 : Colors.red.shade900,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status ? "Success" : "Error",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        message,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ), controller: controller,
          ),
        );
      },
    );
  }
}