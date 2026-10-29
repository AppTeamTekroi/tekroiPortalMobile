import 'dart:io';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:travelPortal/core/routes/route_controller.dart';
import 'package:travelPortal/features/dashboard/controller/dashboard_controller.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/utils/helpers.dart';
import '../../../ui/widgets/loading.dart';
import '../../login/controller/login_controller.dart';
import '../data/travel_data.dart';
import '../models/travel_model.dart';
import 'package:flutter/material.dart';
import '../../profile/model/vehicle_model.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class TravelController extends GetxController {
  final TravelService _service = TravelService();
  var customerList = [].obs;
  var projectList = [].obs;

  Rx<ApiResult<List<TravelModel>>> travelState = ApiResult<List<TravelModel>>.initial().obs;
  Rx<ApiResult<String>> deleteState = ApiResult<String>.initial().obs;
  final customerState = ApiResult<dynamic>.initial().obs;
  final projectState = ApiResult<List>.initial().obs;
  RouteController routeController = Get.find();
  LoginController loginController = Get.find();

  final dateController = TextEditingController();
  final checkInController = TextEditingController();
  final checkOutController = TextEditingController();
  final notesController = TextEditingController();
  final taxiAmountController = TextEditingController();
  final customerController = TextEditingController();

  var showPicker = false.obs;

  /// 🔹 Dropdown Values (Reactive)
  var customer = "".obs;
  var project = "".obs;
  var checkInAddress = "".obs;
  var checkOutAddress = "".obs;


  /// 🔹 Toggle Values (Reactive)
  var travelType = "Implementation & Support".obs;
  var travelMode = "Self".obs;
  File? taxiBill;
  int? editingId;
  String? serverFile;

  /// 🔹 API State
  // final dashboardState = ApiResult<CreateTravelModel>.initial().obs;

  /// 🔹 Selected Vehicle
  var selectedVehicle = Rxn<VehicleModel>();

  /// 🔹 Loading State (for submit)
  var isSubmitting = false.obs;
  void setTravelType(String value) {
    travelType.value = value;
  }

  void setTravelMode(String value) {
    travelMode.value = value;
  }

  void setCustomer(String value) {
    customer.value = value;
  }

  void setProject(String value) {
    project.value = value;
  }

  void setVehicle(VehicleModel? vehicle) {
    selectedVehicle.value = vehicle;
  }

  RxString searchQuery = "".obs;
  RxString selectedStatus = "All".obs;

// ✅ MUST be list
  RxList<TravelModel> filteredList = <TravelModel>[].obs;

  void applyFilter() {
    final original = travelState.value.data;
     print(original);
    if (original == null) return; // ✅ safety check

    List<TravelModel> temp = List.from(original); // ✅ copy list

    // 🎯 Status filter
    if (selectedStatus.value != "All") {
      temp = temp
          .where((item) =>
      item.status.toString() == selectedStatus.value)
          .toList();
    }

    // 🔍 Search filter
    if (searchQuery.value.isNotEmpty) {
      temp = temp
          .where((item) =>
          item.project
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase()))
          .toList();
    }

    filteredList.value = temp;

    print("✅ FILTERED COUNT => ${filteredList.length}");
  }

  /// =========================
  /// 🔥 VALIDATION
  /// =========================
  bool validateForm(int type) {
    print("validateForm called");

    if (loginController.UserId == 0) {
      AppSnackbar.error("* Something went Wrong, Please Login Again");
      return false;
    }

    if (dateController.text.isEmpty) {
      print("Date failed");
      AppSnackbar.error("Date is required");
      return false;
    }

    if (checkInController.text.isEmpty) {
      print("Check-in failed");
      AppSnackbar.error("Check-in time is required");
      return false;
    }

    if (checkOutController.text.isEmpty && type == 1) {
      print("Check-out failed");
      AppSnackbar.error("Check-out time is required");
      return false;
    }

    if (travelType.value == "Sales" && customerController.text.isEmpty) {
      print("Customer failed");
      AppSnackbar.error("Customer is required");
      return false;
    }
    if (travelType.value == "Sales" && customerController.text.isNotEmpty) {
      customer.value = customerController.text;
    }

    if (travelMode.value == "Taxi" && type == 1 &&
        (taxiAmountController.text.isEmpty || taxiBill == null)) {
      print("Taxi failed");
      AppSnackbar.error("Amount & Invoice are required");
      return false;
    }

    print("Validation passed");
    return true;
  }

  void copyToEditTravel(TravelModel data) {
    clearForm();
    /// 🔹 Fill Text Controllers
    dateController.text = data.date;
    checkInController.text = data.checkIn;
    checkOutController.text = data.checkOut ?? "";
    notesController.text = data.notes;
    taxiAmountController.text = data.amount;
    travelType.value = data.travelType;
    travelMode.value = data.travelMode;

    /// 🔹 Fill Reactive Fields
    if(travelType.value == "Sales"){
      customerController.text = data.customer;
    }else{
      customer.value = data.customer;
      project.value = data.project;
    }

    checkInAddress.value = data.checkInLocation;
    checkOutAddress.value = data.checkOutLocation ?? "";

    /// 🔹 Toggles

    /// 🔹 Optional: Reset file (or keep if editing existing)
    print(data.filePath);
    //
    // if(data.filePath != null && data.filePath!.isNotEmpty){
    //   taxiBill = File(data.filePath!);
    //    showPicker.value = true;
    // }{
    //   taxiBill = null;
    //   showPicker.value = false;
    // }
    /// 🔹 If you need edit mode flag
    // isEdit.value = true;
    editingId = data.id;
    serverFile = data.filePath;
    update();
  }
  Future<void> getCurrentLocation(int stage) async {
    LoadingOverlay.show("Fetching location...");

    try {
      bool serviceEnabled;
      LocationPermission permission;

      // ✅ Check service
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showMsg("Location services are disabled.");
        return;
      }

      // ✅ Check permission
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          _showMsg("Location permission denied");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showMsg("Location permission permanently denied");
        return;
      }

      // ✅ Get position
      Position position = await Geolocator.getCurrentPosition();

      print("Latitude: ${position.latitude}");
      print("Longitude: ${position.longitude}");

      // ✅ Convert to address
      List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        print("----$placemarks");
        Placemark place = placemarks[0];

        String address = _formatAddress(place);

        if (stage == 0) {
          checkInAddress.value = address;
        } else {
          checkOutAddress.value = address;
        }

        print("Address: $address");
      }

    } catch (e) {
      _showMsg("Failed to get location");
    } finally {
      // ✅ ALWAYS CLOSE LOADER (ONLY ONCE)
      LoadingOverlay.hide();
    }
  }

  // Future<void> getCurrentLocation(int stage) async {
  //   bool serviceEnabled;
  //   LocationPermission permission;
  //
  //   // Check if location services are enabled
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     print('Location services are disabled.');
  //     return;
  //   }
  //
  //   // Check and request permission
  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       print('Location permissions are denied.');
  //       return;
  //     }
  //   }
  //
  //   if (permission == LocationPermission.deniedForever) {
  //     print('Location permissions are permanently denied.');
  //     return;
  //   }
  //
  //   // Get current position
  //   Position position = await Geolocator.getCurrentPosition();
  //
  //   // Print to console
  //   print("Latitude: ${position.latitude}");
  //   print("Longitude: ${position.longitude}");
  //
  //   final location = 'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
  //
  //   String formatAddress(Placemark place) {
  //     List<String> parts = [];
  //
  //     if (place.street != null && place.street!.isNotEmpty)
  //       parts.add(place.street!);
  //     if (place.subLocality != null && place.subLocality!.isNotEmpty)
  //       parts.add(place.subLocality!);
  //     if (place.locality != null && place.locality!.isNotEmpty)
  //       parts.add(place.locality!);
  //     if (place.postalCode != null && place.postalCode!.isNotEmpty)
  //       parts.add(place.postalCode!);
  //     if (place.country != null && place.country!.isNotEmpty)
  //       parts.add(place.country!);
  //
  //     return parts.join(', ');
  //   }
  //
  //   List<Placemark> placemarks =
  //   await placemarkFromCoordinates(position.latitude, position.longitude);
  //   print(placemarks);
  //
  //   if (placemarks.isNotEmpty) {
  //     Placemark place = placemarks[0];
  //     print(place);
  //
  //     String output = formatAddress(place);
  //     final address = output;
  //     if(stage == 0){
  //       checkInAddress.value = address;
  //     }else{
  //       checkOutAddress.value = address;
  //     }
  //     print("hgfdxdcfgh$address");
  //   }
  // }

  @override
  void onInit() {
    super.onInit();
    if (loginController.UserId != 0) {
      loadTravels();
      loadCustomers();
    }
  }

  void clearForm() {
    dateController.clear();
    checkInController.clear();
    checkOutController.clear();
    checkInAddress.value = "";
    checkOutAddress.value = "";

    notesController.clear();
    taxiAmountController.clear();
    customer.value = "";
    project.value = "";
    travelType.value = "Implementation & Support";
    travelMode.value = "Self";
    editingId = null;
    serverFile = null;
    taxiBill = null;
  }

  @override
  void onClose() {
    dateController.dispose();
    checkInController.dispose();
    checkOutController.dispose();
    notesController.dispose();
    taxiAmountController.dispose();
    super.onClose();
  }

  Future<void> submitTravel(int type) async {
    print("vcccc  1111");
    if (!validateForm(type)) return;
    LoadingOverlay.show("Submitting your travel details...");
    String formattedDate = "";
    try {
      final parsed = DateFormat("dd/MM/yyyy").parse(dateController.text);
      formattedDate = DateFormat("yyyy-MM-dd").format(parsed);
    } catch (e) {
      print("⚠️ Date parse failed: ${dateController.text} -> $e");
    }
    try {
      final payload = {
        "date": formattedDate,
        "check_in": checkInController.text,
        "check_location": checkInAddress.value,
        "check_out": checkOutController.text,
        "check_out_location": checkOutAddress.value,
        "travel_type": travelType.value,
        "travel_mode": travelMode.value,
        "customer": customer.value,
        "project": project.value,
        "amount":taxiAmountController.text,
        "notes": notesController.text,
        "status": type,
        "user_id" : loginController.UserId
      };
      debugPrint("Payload => $payload");

      final result = await _service.createTravel(payload,taxiBill);
      print(result);
      result.fold(
            (failure) {
          _handleResponse(false, failure.message.toString());
        },
            (data) {
          final res = data;
          if (res["status"] == true) {
            _handleResponse(true, "Travel Updated Successfully");
            clearForm();

            routeController.off(Routes.travel);
            loadTravels();
            _refreshDashboard();
          } else {
            _handleResponse(false, "Something went wrong");
          }
        },
      );
    }  catch (e) {
      _handleResponse(false, "Something went wrong");
    }
  }

  Future<void> updateTravel(BuildContext context, int type) async {
    print("vcccc $type");

    if (!validateForm(type)) return;

    LoadingOverlay.show("Updating your travel details...");

    try {
      final payload = {
        "id": editingId,
        "date": dateController.text,
        "check_in": checkInController.text,
        "check_location": checkInAddress,
        "check_out": checkOutController.text,
        "check_out_location": checkOutAddress,
        "travel_type": travelType.value,
        "travel_mode": travelMode.value,
        "customer": customer.value,
        "project": project.value,
        "amount": taxiAmountController.text,
        "notes": notesController.text,
        "status": type,
        "user_id" : loginController.UserId
      };

      debugPrint("Payload => $payload");
      print("Payfsfload => ${taxiBill?.path}");

      if (editingId != null) {
        final result = await _service.updateTravel(
          payload,
          taxiBill,
          editingId.toString(),
        );
print("inn con$result");
        result.fold(
              (failure) {
            _handleResponse(false, failure.message.toString());
          },
              (data) {
            final res = data;
            if (res["status"] == true) {
              _handleResponse(true, "Travel Updated Successfully");
              clearForm();
              routeController.off(Routes.travel);
              loadTravels();
              _refreshDashboard();

            } else {
              _handleResponse(false, "Something went wrong");
            }
          },
        );
      }
    } catch (e) {
      _handleResponse(false, "Something went wrong");
    }
  }

  Future<void> loadTravels() async {
    print("travel loding");
    travelState.value = ApiResult.loading();

    try {
      final result = await _service.fetchTravels(loginController.UserId.toString());

      result.fold(
            (failure) =>
            travelState.value = ApiResult.error(failure.message),
            (data) {
              travelState.value = ApiResult.success(data);
              filteredList.value = List.from(data);
              applyFilter();
            }
      );
    } catch (e) {
      travelState.value = ApiResult.error(e.toString());
    }
  }

  Future<void> deleteTravel(String id) async {
    print("travel loding");
    LoadingOverlay.show("Removing the Travel Log");
    deleteState.value = ApiResult.loading();
    try {
      final result = await _service.deleteTravel(id);
      result.fold(
              (failure) {
                deleteState.value = ApiResult.error(failure.message);
                _handleResponse(false, "Refresh and try again");
                },
              (data) {
                deleteState.value = ApiResult.success(data);
                _handleResponse(true, data);
                routeController.off(Routes.travel);
                loadTravels();
                _refreshDashboard();
          }
      );
    } catch (e) {
      _handleResponse(false, "Something Went Wrong, Try after some time");
      deleteState.value = ApiResult.error(e.toString());
    }
  }

  Future<void> loadCustomers() async {
    customerState.value = ApiResult.loading();

    try {
      final result = await _service.fetchCustomersAndProjects();

      result.fold(
            (failure) {
          customerState.value = ApiResult.error(failure.message);
        },
            (data) {
              customerState.value = ApiResult.success(data);

              // final users = data["users"];
          // final users = data["users"];

          // if (users == null || users.isEmpty) {
          //   customerState.value = ApiResult.success([]);
          // } else {
          //   customerState.value = ApiResult.success(users);
          // }
        },
      );
    } catch (e) {
      customerState.value = ApiResult.error(e.toString());
    }
  }

  void _refreshDashboard() {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().loadDashboard();
    }
  }

  void _handleResponse(bool isSuccess, String message) {
    // ✅ Hide loader ONCE
    LoadingOverlay.hide();

    // ✅ Delay snackbar (avoids crash)
    Future.delayed(const Duration(milliseconds: 100), () {

      if(isSuccess ) {
        AppSnackbar.success("Success");

    }else{
        AppSnackbar.success("Error");

      }
    });
  }
  String _formatAddress(Placemark place) {
    List<String> parts = [];

    if (place.thoroughfare?.isNotEmpty ?? false) parts.add(place.thoroughfare!);
    if(place.thoroughfare?.isEmpty ?? false){
      if (place.street?.isNotEmpty ?? false) parts.add(place.street!);
    }    if (place.subLocality?.isNotEmpty ?? false) parts.add(place.subLocality!);
    if (place.locality?.isNotEmpty ?? false) parts.add(place.locality!);
    if (place.postalCode?.isNotEmpty ?? false) parts.add(place.postalCode!);
    if (place.country?.isNotEmpty ?? false) parts.add(place.country!);

    return parts.join(', ');
  }
  void _showMsg(String msg) {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (Get.context != null) {
        Get.snackbar("Info", msg);
      }
    });
  }
}