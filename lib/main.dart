
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travelPortal/ui/theme/appColor.dart';
import 'core/bindings/app_binding.dart';
import 'core/routes/app_pages.dart';
import 'core/services/storage_service.dart';
import 'core/utils/size_utils.dart';
import 'features/splash/splashPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync<StorageService>(() async {
    return await StorageService().init();
  });
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Sizer(
        builder: (context, orientation, deviceType) {
          return GetMaterialApp(
              debugShowCheckedModeBanner: false,
              initialBinding: AppBinding(),
              home: SplashScreen(),
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
                useMaterial3: true,
              ),
              title: 'TEKROI SUPPORT',
            // initialRoute: AppPage.initial.toString(),
            // getPages: AppPage.page,
          );
        }
    );
  }
}


