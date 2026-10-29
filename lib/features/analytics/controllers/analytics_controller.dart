import 'package:get/get.dart';
import 'package:travelPortal/features/analytics/data/analytics_data.dart';
import 'package:travelPortal/features/analytics/models/analytics_model.dart';
import 'package:travelPortal/features/login/controller/login_controller.dart';
import '../../../core/utils/helpers.dart';
import '../../profile/model/vehicle_model.dart';

class AnalyticsController extends GetxController {
  final AnalyticsService _service = AnalyticsService();
  LoginController loginController = Get.find();
  final analyticsState = ApiResult<AnalyticsModel>.initial().obs;
  VehicleModel? selectedVehicle;

  @override
  void onInit() {
    super.onInit();
    if (loginController.UserId != 0) {
      loadAnalytics();
    }
  }

  Future<void> loadAnalytics() async {
    analyticsState.value = ApiResult.loading();

    try {
      final result =
          await _service.fetchAnalytics(loginController.UserId.toString());

      result.fold(
        (failure) => analyticsState.value = ApiResult.error(failure.message),
        (data) => analyticsState.value = ApiResult.success(data),
      );
    } catch (e) {
      analyticsState.value = ApiResult.error(e.toString());
    }
  }
}
