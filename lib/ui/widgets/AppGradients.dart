import 'package:flutter/material.dart';

import '../theme/appColor.dart';

class AppGradients {
  static  List<List<Color>> rewardGradients = [
   [
     Color(0xFF1857CF),
     Color(0xFF1088B3),
   ],
    [Colors.purple, Colors.pink],
    [
      Color(0xFFF94D00),
      Color(0xFFCF0C05),
    ],
    [Color(0xFF08C349),
      Color(0xFF049141)], // Green

  ];

  /// Cycles 1,2,3,4,1,2,3,4...
  static List<Color> byIndex(int index) {
    return rewardGradients[index % rewardGradients.length];
  }
}
// [Color(0xFF2563EB), Color(0xFF3B82F6)], // Blue
//     [Color(0xFFF97316), Color(0xFFFB923C)], //


// Color(0xFFF94D00),
//       Color(0xFFF90800),