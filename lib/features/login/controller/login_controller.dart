
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travelPortal/features/analytics/controllers/analytics_controller.dart';
import 'package:travelPortal/features/expense/controllers/expenseCreateController.dart';
import 'package:travelPortal/features/splash/splashPage.dart';
import 'package:travelPortal/features/travel/controllers/travel_controller.dart';
import '../../../core/services/storage_service.dart';
import '../../dashboard/bottomNavigationBar.dart';
import '../../attendance/controllers/attendance_controller.dart';
import '../../dashboard/controller/dashboard_controller.dart';
import '../../profile/controller/profile_controller.dart';
import '../../timesheets/controllers/VehicleController.dart';
import '../datasource/login_datasource.dart';
import '../welcome_page.dart';

class LoginController extends GetxController {

  final AuthRepository _repository = AuthRepository();
  final StorageService _storage = Get.find();

  ProfileController get profileController => Get.find();
  DashboardController get dashboardController => Get.find();
  AnalyticsController get analyticsController => Get.find();
  TravelController get travelController => Get.find();
  ExpenseController get expenseController => Get.find();
  VehicleController get timesheetController => Get.find();
  AttendanceController get attendanceController => Get.find();


  // ✅ User List State
  RxList<Map<String, dynamic>> userList = <Map<String, dynamic>>[].obs;
  var isUserLoading = false.obs;
  var userErrorMessage = ''.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var searchQuery = "".obs;
  var isLoading = false.obs;
  bool isLoggedIn = false;
  var isPasswordVisible = true.obs;
  int? UserId;
  int? rollId;
  int? employeeId;
  final assignedId = RxnInt();
  final assignedName = RxnString();
  String? UserName;
  String? UserEmployeeId;

  RxList allUsers = [].obs;      // original list
  RxList filteredUsers = [].obs; // search result

  void filterUsers(String query) {
    searchQuery.value = query;

    if (query.isEmpty) {
      filteredUsers.assignAll(allUsers);
    } else {
      filteredUsers.assignAll(
        allUsers.where((user) =>
            user["name"]
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase())),
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  void loadInitialData() {
    profileController.loadProfile();
    dashboardController.loadDashboard();
    analyticsController.loadAnalytics();
    travelController.loadTravels();
    expenseController.loadExpenses();
    timesheetController.UserData();
    timesheetController.ProjectData();
    attendanceController.loadToday();
  }
  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  void checkLoginStatus() {
    isLoggedIn = _storage.isLoggedIn;
    if(isLoggedIn == true && _storage.userId != null) {
      UserId = _storage.userId!;
      UserName = _storage.userName!;
      UserEmployeeId = _storage.userEmpId!;
      assignedId.value = _storage.managerId;
      assignedName.value = _storage.managerName;
      rollId = _storage.roleId;
      print(isLoggedIn);
    }
  }

  // ✅ Fetch Users
  Future<void> fetchfUsers() async {
    try {
      isUserLoading.value = true;

      final result = await _repository.getUserList();

      result.fold(
            (failure) {
          userErrorMessage.value = failure.message;
          print("Error: ${failure.message}");
        },
            (responseData) {
          final users = responseData['data'] as List;

          final apiData = users
              .map((e) => Map<String, dynamic>.from(e))
              .toList();

          allUsers.assignAll(apiData);
       filteredUsers.assignAll(apiData);

          userErrorMessage.value = '';
          print("Fetched users count: ${userList.length}");
        },
      );
    } catch (e) {
      userErrorMessage.value = e.toString();
      print("Exception: $e");
    } finally {
      isUserLoading.value = false;
    }
  }
  // ✅ Login
  Future<void> loginUser() async {
    try {
      isLoading.value = true;
      userErrorMessage.value = '';
      final response = await _repository.login(
        emailController.text,
        passwordController.text,
      );
      await response.fold(
        (failure) async {
          userErrorMessage.value = failure.message.toString();
        },
        (data) async {
          if (data["status"] == true) {
            userErrorMessage.value = "";
            final user = data['user'] is Map
                ? Map<String, dynamic>.from(data['user'] as Map)
                : <String, dynamic>{};
            UserName = user['name']?.toString();
            UserId = _asInt(user['id']);
            UserEmployeeId = user['employee_id']?.toString();
            rollId =
                _asInt(user['role'] ?? user['role_id'] ?? user['roll_id']);
            _applyReportingTo(user, data);

            await _storage.saveLogin(
              UserId!,
              UserName!,
              UserEmployeeId!,
              token: data['token']?.toString(),
              managerId: assignedId.value,
              managerName: assignedName.value,
              roleId: rollId,
            );
            isLoggedIn = true;
            loadInitialData();
            if (Get.isBottomSheetOpen == true) {
              Get.back();
            }
            Get.offAll(() => BottomNav());
          } else {
            userErrorMessage.value =
                data["message"]?.toString() ?? "Login failed";
          }
        },
      );
    } catch (e) {
      userErrorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Logout
  Future<void> logout() async {
    await _storage.clearLogin();
    isLoggedIn = false;
    UserId = null;
    UserName = null;
    UserEmployeeId = null;
    assignedId.value = null;
    assignedName.value = null;
    rollId = null;
    Get.offAll(() => SplashScreen());
  }

  Future<void> persistAssigned() async {
    await _storage.saveManagerId(assignedId.value);
    await _storage.saveManagerName(assignedName.value);
  }

  void _applyReportingTo(Map<String, dynamic> user, Map<String, dynamic> data) {
    final reportingRaw = user['reporting_to'] ??
        user['manager'] ??
        data['reporting_to'] ??
        data['manager'];

    Map<String, dynamic>? reportingMap;
    if (reportingRaw is Map) {
      reportingMap = Map<String, dynamic>.from(reportingRaw);
    }

    assignedId.value = _asInt(
      user['manager_id'] ??
          user['reporting_to_id'] ??
          user['reporting_manager_id'] ??
          reportingMap?['id'] ??
          reportingMap?['user_id'] ??
          data['manager_id'] ??
          data['reporting_to_id'] ??
          (reportingMap == null ? reportingRaw : null),
    );

    final nameRaw = reportingMap?['name'] ??
        user['manager_name'] ??
        user['reporting_manager'] ??
        data['manager_name'];
    final name = nameRaw?.toString().trim();
    assignedName.value = (name == null || name.isEmpty) ? null : name;

    if (assignedName.value != null &&
        _asInt(assignedName.value) == assignedId.value) {
      assignedName.value = null;
    }
  }

  int? _asInt(dynamic value) {
    if (value == null || value == '') return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  @override
  void onClose() {
    // ✅ FIXED
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}