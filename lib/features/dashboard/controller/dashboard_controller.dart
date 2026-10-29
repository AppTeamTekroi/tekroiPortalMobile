import 'package:get/get.dart';
import 'package:travelPortal/features/login/controller/login_controller.dart';
import '../../../core/utils/helpers.dart';
import '../../profile/model/vehicle_model.dart';
import '../datasource/dashboard_datasource.dart';
import '../model/dashboard_model.dart';

class DashboardController extends GetxController {
  final DashboardService _service = DashboardService();
  LoginController loginController = Get.find();
  final dashboardState = ApiResult<DashboardModel>.initial().obs;
  VehicleModel? selectedVehicle;

  @override
  void onInit() {
    super.onInit();
    if (loginController.UserId != 0) {
      loadDashboard();
    }
  }

  Future<void> loadDashboard() async {
    dashboardState.value = ApiResult.loading();

    try {
      final result =
          await _service.fetchDashboard(loginController.UserId.toString());

      result.fold(
        (failure) => dashboardState.value = ApiResult.error(failure.message),
        (data) => dashboardState.value = ApiResult.success(data),
      );
    } catch (e) {
      dashboardState.value = ApiResult.error(e.toString());
    }
  }
}
