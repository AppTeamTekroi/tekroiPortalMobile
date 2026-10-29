import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travelPortal/features/travel/controllers/travel_controller.dart';
import 'package:travelPortal/ui/assets/app_assets.dart';

import '../../core/services/storage_service.dart';
import '../../core/utils/size_utils.dart';
import '../../ui/theme/appColor.dart';
import '../dashboard/bottomNavigationBar.dart';
import '../dashboard/controller/dashboard_controller.dart';
import '../login/controller/login_controller.dart';
import '../login/welcome_page.dart';
import '../profile/controller/profile_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final storage = Get.find<StorageService>();
  LoginController loginController = Get.find();
  // ProfileController profileController = Get.find();
  // DashboardController controller = Get.find();
  // TravelController travelController = Get.find();

  @override
  void initState() {
    super.initState();
    _navigateToAuth();
    loginController.checkLoginStatus();
  }



  Future<void> _navigateToAuth() async {
    await Future.delayed(const Duration(seconds: 3));
    if (loginController.isLoggedIn == true) {
      loginController.loadInitialData();
      Get.offAll(() => BottomNav());
    } else {
      loginController.fetchfUsers();
      Get.offAll(() => WelcomePage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Container
            Container(
              width: 120.h,
              height: 120.h,
              decoration: BoxDecoration(
                color: Colors.white70,

                borderRadius: BorderRadius.circular(24.h),
                // boxShadow: [
                //   BoxShadow(
                //     color: AppColors.primary,
                //     blurRadius: 20.h,
                //     offset: Offset(0, 10.h),
                //   ),
                // ],
              ),
              child: Center(

                child:Image.asset(AppImagePaths.applogo,
                  fit: BoxFit.fitHeight
                )
                // Image(
                //   image: ImageConstant.imgImageShauryaCement,
                //   width: 90.h,
                //   height: 90.h,
                // ),
              ),
            ),
            SizedBox(height: 22.h),
            // Company Name
            Text(
              'TEKROI',
              style: TextStyle(fontSize: 32,
                  fontWeight: FontWeight.bold,color: AppColors.primary
            ),
            ),
            SizedBox(height: 8.h),
            // Subtitle
            Text(
              'TEKROI SUPPORT',
              style: TextStyle(fontSize: 17,
                  fontWeight: FontWeight.w400,
                 color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
