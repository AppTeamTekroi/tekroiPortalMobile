import 'dart:math';

import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../core/services/storage_service.dart';
import '../../../core/utils/helpers.dart';
import '../../login/controller/login_controller.dart';
import '../datasource/profile_datasource.dart';
import '../model/profile_model.dart';
import '../model/vehicle_model.dart';

class ProfileController extends GetxController {
  final ProfileService _service = ProfileService();
  final StorageService _storage = Get.find();

  final Rx<ApiResult<ProfileModel>> profileState =
      ApiResult<ProfileModel>.initial().obs;

  final Rx<ApiResult<List<VehicleModel>>> vehiclesState =
      ApiResult<List<VehicleModel>>.initial().obs;

  final Rx<ApiResult<ProfileModel>> profileEditState =
      ApiResult<ProfileModel>.initial().obs;
  final nameController = TextEditingController();
  final altphoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();
  final DOB = TextEditingController();
  String? gender;
  Map<String, dynamic> originalProfile = {};
  LoginController loginController = Get.find();

  @override
  void onInit() {
    super.onInit();
    if (loginController.UserId != 0) {
      loadProfile();
    }
  }
  // void copyforEdit() {
  //   final profile = profileState.value.data;
  //   if (profile != null) {
  //     nameController.text = profile.fullName ?? '';
  //     altphoneController.text = profile.phone ?? '';
  //     emailController.text = profile.email ?? '';
  //     addressController.text = profile.address ?? '';
  //     cityController.text = profile.city ?? '';
  //     stateController.text = profile.state ?? '';
  //     pincodeController.text = profile.pincode ?? '';
  //     gender = profile.gender;
  //     DOB.text = profile.dateOfBirth ?? '';
  //     originalProfile = {
  //       "full_name": profile.fullName ?? '',
  //       "phone": profile.phone ?? '',
  //       "email": profile.email ?? '',
  //       "address": profile.address ?? '',
  //       "city": profile.city ?? '',
  //       "state": profile.state ?? '',
  //       "pincode": profile.pincode ?? '',
  //       "gender": profile.gender ?? '',
  //       "date_of_birth": profile.dateOfBirth ?? '',
  //     };
  //   }
  // }
  bool mapsEqual(Map a, Map b) {
    return a.length == b.length &&
        a.keys.every((key) => a[key] == b[key]);
  }
  @override
  void onClose() {
    nameController.dispose();
    altphoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    super.onClose();
  }

  Future<void> loadProfile() async {
    print("caling....");
    profileState.value = ApiResult.loading();
    try {
      final result = await _service.fetchProfile(loginController.UserId.toString());
      print(result);

      result.fold(
        (failure) {
          profileState.value = ApiResult.error(failure.message);
        },
        (profile) {
          profileState.value = ApiResult.success(profile);
          final reportingTo = _reportingToName(profile.data?.employee);
          if (reportingTo != null && reportingTo.isNotEmpty) {
            if (loginController.assignedName.value == null ||
                loginController.assignedName.value!.trim().isEmpty) {
              loginController.assignedName.value = reportingTo;
            }
            _storage.saveManagerName(loginController.assignedName.value);
          }
        },
      );
    } catch (e) {
      profileState.value = ApiResult.error(e.toString());
    }
  }

  String? _reportingToName(Employee? employee) {
    final value = employee?.reportingTo?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }
}
