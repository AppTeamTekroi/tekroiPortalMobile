import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:travelPortal/features/login/controller/login_controller.dart';

import '../data/source.dart';
import '../models/model.dart';

class VehicleController extends GetxController {
  final VehicleDataSourceImpl vehicleDataSourceImpl = VehicleDataSourceImpl();
  final LoginController loginController = Get.find<LoginController>();

  var isLoading2 = false.obs;

  var workdata = <User>[].obs;
  var errorMessage2 = ''.obs;
  var isLoading = false.obs;
  var project = <Project>[].obs;
  var errorMessage = ''.obs;
  RxList<Map<String, dynamic>> binbatch = <Map<String, dynamic>>[].obs;
  RxBool isLoading7 = false.obs;
  RxString errorMessage7 = ''.obs;

  RxList<Map<String, dynamic>> leavesList = <Map<String, dynamic>>[].obs;
  RxBool isLoading8 = false.obs;
  RxString errorMessage8 = ''.obs;

  RxBool isLoading3 = false.obs;
  RxString errorMessage3 = ''.obs;

  RxInt annualLeaveCount = 0.obs;
  RxString lastTimesheet = ''.obs;
  RxInt openTickets = 0.obs;
  RxInt todayTickets = 0.obs;
  RxInt yesterdayTickets = 0.obs;
  RxInt last7Days = 0.obs;
  RxInt last30Days = 0.obs;
  RxInt beyond30Days = 0.obs;



  RxMap<String, dynamic> summaryData = <String, dynamic>{}.obs;
  RxList<Map<String, dynamic>> summary = <Map<String, dynamic>>[].obs;
  RxBool isLoading9 = false.obs;
  RxString errorMessage9 = ''.obs;

 RxMap<String, dynamic> supportData = <String, dynamic>{}.obs;
  RxList<Map<String, dynamic>> support = <Map<String, dynamic>>[].obs;
  RxBool isLoading10 = false.obs;
  RxString errorMessage10 = ''.obs;

  var isLoading11 = false.obs;
  var domain = <Domain>[].obs;
  var errorMessage11 = ''.obs;

  Future<void> UserData() async {
    print('hititng Work');
    try {
      isLoading2.value = true;
      final result = await vehicleDataSourceImpl.Users();
      result.fold(
            (failure) {
          isLoading2.value = false;
          workdata.clear();
          errorMessage2.value = 'Error: ${failure.message}';
        },
            (resData) {
          workdata.value = resData;
          errorMessage2.value = '';
          isLoading2.value = false;
          _syncAssignedFromUsers();
        },
      );
    } catch (e) {
      isLoading2.value = false;
      errorMessage2.value = 'An error occurred: $e';
    }
  }
  
  Future<void> ProjectData() async {
    print('hititng Work');
    try {
      isLoading.value = true;
      final result = await vehicleDataSourceImpl.Projects();
      result.fold(
            (failure) {
          isLoading.value = false;
          project.clear();
          errorMessage.value = 'Error: ${failure.message}';
        },
            (resData) {
              project.value = resData;
          errorMessage.value = '';
          isLoading.value = false;
        },
      );
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'An error occurred: $e';
    }
  }

  Future<void> DomainData(BuildContext context, String userId) async {
    print('hititng Domain');
    try {
      isLoading11.value = true;
      final result = await vehicleDataSourceImpl.supportList(context, userId);
      result.fold(
            (failure) {
          isLoading11.value = false;
          domain.clear();
          errorMessage11.value = 'Error: ${failure.message}';
        },
            (resData) {
              domain.value = resData;
          errorMessage11.value = '';
          isLoading11.value = false;
        },
      );
    } catch (e) {
      isLoading11.value = false;
      errorMessage11.value = 'An error occurred: $e';
    }
  }


  Future<void> fetchbinbatch(
    BuildContext context,
    String userId,
    String roleId, {
    String? min,
    String? max,
    String? userSelect,
  }) async {
    print('Calling fetchbinbatch in controller');
    try {
      isLoading7.value = true;
      final result = await vehicleDataSourceImpl.timesheetslist(
        context,
        userId,
        roleId,
        min: min,
        max: max,
        userSelect: userSelect,
      );
      result.fold(
            (failure) {
          isLoading7.value = false;
          errorMessage7.value = 'Error: ${failure.message}';
        },
            (responseData) {
          if (responseData is List) {
            binbatch.value = List<Map<String, dynamic>>.from(responseData);
          } else {
            binbatch.value = [];
          }
          print('Fetched BinBatch: ${binbatch.length}');
          errorMessage7.value = '';
          isLoading7.value = false;
        },
      );
    } catch (e) {
      isLoading7.value = false;
      errorMessage7.value = 'An error occurred: ${e.toString()}';
    }
  }

  Future<void> fetchleaves(BuildContext context, String userId, String roleId) async {
    print('Calling fetchbinbatch in controller');
    try {
      isLoading8.value = true;
      final result = await vehicleDataSourceImpl.leavesList(context, userId, roleId);
      result.fold(
            (failure) {
          isLoading8.value = false;
          errorMessage8.value = 'Error: ${failure.message}';
        },
            (responseData) {
          if (responseData is List) {
            leavesList.value = List<Map<String, dynamic>>.from(responseData);
          } else {
            leavesList.value = [];
          }
          print('Fetched BinBatch: ${leavesList.length}');
          errorMessage8.value = '';
          isLoading8.value = false;
        },
      );
    } catch (e) {
      isLoading8.value = false;
      errorMessage8.value = 'An error occurred: ${e.toString()}';
    }
  }

  Future<void> fetchDashboard({
    required BuildContext context,
    required String userId,
  }) async {
    isLoading.value = true;

    final result = await vehicleDataSourceImpl.fetchDashboard(context, userId);

    result.fold(
          (failure) {
        isLoading.value = false;
        errorMessage.value = failure.message;
        print('❌ Dashboard fetch failed: ${failure.message}');
      },
          (jsonData) {
        isLoading.value = false;
        errorMessage.value = '';

        final issues = jsonData['open_issues'] ?? {};
        todayTickets.value = issues['today'] ?? 0;
        yesterdayTickets.value = issues['yesterday'] ?? 0;
        last7Days.value = issues['week'] ?? 0;
        last30Days.value = issues['month'] ?? 0;
        beyond30Days.value = issues['beyondmonth'] ?? 0;

        lastTimesheet.value = jsonData['last_timesheet']?['created_at'] ?? '';

        // 🔹 Print the last timesheet value
        print('🕒 Last Timesheet Created At: ${lastTimesheet.value}');

        annualLeaveCount.value = jsonData['employee_leaves_count'] ?? 0;

        openTickets.value = (jsonData['open_customers'] as List).fold<int>(
          0,
              (sum, e) => sum + ((e['open'] ?? 0) as int),
        );
      },
    );
  }


  Future<void> fetchsummary(BuildContext context, String userId) async {
    try {
      isLoading9.value = true;
      final result = await vehicleDataSourceImpl.summaryData(context, userId);
      result.fold(
            (failure) {
          errorMessage9.value = 'Error: ${failure.message}';
        },
            (response) {
              print('✅ Full API Response:\n$response');
              summaryData.value = response;
          summary.value = List<Map<String, dynamic>>.from(response['data'] ?? []);
          print('Fetched Summary: ${summary.value.length}');
          errorMessage9.value = '';
        },
      );
    } catch (e) {
      errorMessage9.value = 'An error occurred: ${e.toString()}';
    } finally {
      isLoading9.value = false;
    }
  }

  Future<void> fetchSupport(BuildContext context, String userId) async {
    try {
      isLoading10.value = true;
      final result = await vehicleDataSourceImpl.supportData(context, userId);
      result.fold(
            (failure) {
          errorMessage10.value = 'Error: ${failure.message}';
        },
            (response) {
              print('✅ Full API Response:\n$response');
              supportData.value = response;
          support.value = List<Map<String, dynamic>>.from(response['data'] ?? []);
          print('Fetched Support: ${support.value.length}');
          errorMessage10.value = '';
        },
      );
    } catch (e) {
      errorMessage10.value = 'An error occurred: ${e.toString()}';
    } finally {
      isLoading10.value = false;
    }
  }

  void _syncAssignedFromUsers() {
    if (loginController.assignedId.value == null &&
        loginController.UserId != null) {
      final self = workdata.firstWhereOrNull(
        (u) => u.id == loginController.UserId,
      );
      if (self?.managerId != null) {
        loginController.assignedId.value = self!.managerId;
      }
    }

    if (loginController.assignedId.value != null &&
        (loginController.assignedName.value == null ||
            loginController.assignedName.value!.trim().isEmpty)) {
      final match = workdata.firstWhereOrNull(
        (u) => u.id == loginController.assignedId.value,
      );
      if (match != null && match.name.trim().isNotEmpty) {
        loginController.assignedName.value = match.name;
        loginController.persistAssigned();
      }
    } else if (loginController.assignedId.value != null) {
      loginController.persistAssigned();
    }
  }

  String? defaultWhoAssignedName() {
    if (workdata.isEmpty) return null;

    if (loginController.assignedId.value != null) {
      final byId = workdata.firstWhereOrNull(
        (u) => u.id == loginController.assignedId.value,
      );
      if (byId != null && byId.name.trim().isNotEmpty) {
        return byId.name;
      }
    }

    final savedName = loginController.assignedName.value?.trim();
    if (savedName == null || savedName.isEmpty) return null;

    final byName = workdata.firstWhereOrNull(
      (u) => u.name.trim().toLowerCase() == savedName.toLowerCase(),
    );
    return byName?.name;
  }
}