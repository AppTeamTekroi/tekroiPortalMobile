import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';

Widget shimmerBox(double height, {double width = double.infinity}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade400,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}


// Widget listShimmer() {
//   return ListView.builder(
//     itemCount: 6,
//     itemBuilder: (_, __) => Padding(
//       padding: const EdgeInsets.all(12),
//       child: Row(
//         children: [
//           shimmerBox(height: 50, width: 50),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 shimmerBox(height: 14, width: 150),
//                 const SizedBox(height: 8),
//                 shimmerBox(height: 12, width: 100),
//               ],
//             ),
//           )
//         ],
//       ),
//     ),
//   );
// }

// Shimmer.fromColors(
// baseColor: Colors.grey.shade300,
// highlightColor: Colors.grey.shade100,
// child: Container(
// height: 120,
// margin: EdgeInsets.all(12),
// decoration: BoxDecoration(
// color: Colors.white,
// borderRadius: BorderRadius.circular(12),
// ),
// ),
// )
