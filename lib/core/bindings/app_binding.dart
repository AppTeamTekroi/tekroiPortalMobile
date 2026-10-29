
import 'package:get/get.dart';
import 'package:travelPortal/features/analytics/controllers/analytics_controller.dart';

import '../../features/attendance/controllers/attendance_controller.dart';
import '../../features/dashboard/controller/dashboard_controller.dart';
import '../../features/expense/controllers/expenseCreateController.dart';
import '../../features/login/controller/login_controller.dart';
import '../../features/profile/controller/profile_controller.dart';
import '../../features/travel/controllers/travel_controller.dart';
import '../../features/timesheets/controllers/VehicleController.dart';
import '../routes/route_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());

    Get.put<ProfileController>(ProfileController(), permanent: true);

    Get.put<DashboardController>(DashboardController(), permanent: true);
    Get.put<AttendanceController>(AttendanceController(), permanent: true);
    Get.put<AnalyticsController>(AnalyticsController(), permanent: true);


    Get.put<RouteController>(RouteController(), permanent: true);
    Get.put<TravelController>(TravelController(), permanent: true);
    Get.put<ExpenseController>(ExpenseController(), permanent: true);
    Get.put<VehicleController>(VehicleController(), permanent: true);
  }
}