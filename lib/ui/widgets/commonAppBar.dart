import 'package:flutter/material.dart';

import '../../core/utils/size_utils.dart';
import '../assets/app_assets.dart';
import '../theme/appColor.dart';
// import 'package:get/get.dart';

PreferredSizeWidget CommonAppBar(
  String? one,
  String? two, {
  VoidCallback? onProfileTap,
}) {
  return AppBar(
    backgroundColor: AppColors.white,
    automaticallyImplyLeading: false,
    elevation: 0,
    centerTitle: false,
    title: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        spacing: 5,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 2,horizontal: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Image.asset(AppImagePaths.applogo,scale: 5,),
            ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'TEKROI SUPPORT',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
                ),
                Text(
                  '${one ?? '--'}  . ${two ?? '--'}',
                  maxLines: 1,
                  softWrap: false,

                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 12),
        child: InkWell(
          onTap: onProfileTap,
          borderRadius: BorderRadius.circular(20),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Icon(Icons.person, color: AppColors.primary, size: 20),
          ),
        ),
      ),
    ],
  );
}
// required String title,
// Color backgroundColor = Colors.white,
// Color titleColor = Colors.black,
// bool showBack = true,
// List<Widget>? actions,